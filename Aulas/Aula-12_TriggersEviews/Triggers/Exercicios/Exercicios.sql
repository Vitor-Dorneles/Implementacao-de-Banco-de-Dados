USE BIBLIOTECA;
GO

-- 1) Impedir livros com o mesmo título
CREATE OR ALTER TRIGGER trg_after_insert_livro_titulo
ON Livro
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Livro AS L
               WHERE L.titulo IN (SELECT I.titulo FROM inserted AS I)
               GROUP BY L.titulo HAVING COUNT(*) > 1) -- no AFTER o novo já está na tabela
    BEGIN
        RAISERROR('Já existe um livro com esse título', 16, 1);
        ROLLBACK TRAN;
    END
END;
GO

-- falha: título repetido
INSERT INTO Livro (isbn, titulo, ano, fk_editora, fk_categoria)
VALUES ('1111111111', 'O Papai é Pop', 2020, 4, 3);
GO

-- passa
INSERT INTO Livro (isbn, titulo, ano, fk_editora, fk_categoria)
VALUES ('2222222222', 'Banco de Dados I', 2020, 1, 2);
SELECT * FROM Livro;
GO

-- 2) Ano de publicação = ano atual ao inserir
-- INSTEAD OF: um UPDATE depois do insert dispararia a auditoria (6)
CREATE OR ALTER TRIGGER trg_insteadof_insert_livro_ano
ON Livro
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Livro (isbn, titulo, ano, fk_editora, fk_categoria)
    SELECT I.isbn, I.titulo, YEAR(GETDATE()), I.fk_editora, I.fk_categoria
    FROM inserted AS I;
END;
GO

INSERT INTO Livro (isbn, titulo, ano, fk_editora, fk_categoria)
VALUES ('3333333333', 'Banco de Dados II', 1990, 1, 2);
SELECT * FROM Livro WHERE isbn = '3333333333'; -- ano 2026
GO

-- 3) Excluir livro apaga os registros de LivroAutor
-- AFTER não serve: a FK de LivroAutor barra o DELETE antes
CREATE OR ALTER TRIGGER trg_insteadof_delete_livro
ON Livro
INSTEAD OF DELETE
AS
BEGIN
    DELETE LA FROM LivroAutor AS LA JOIN deleted AS D ON LA.fk_livro = D.isbn;
    DELETE L FROM Livro AS L JOIN deleted AS D ON L.isbn = D.isbn;
END;
GO

BEGIN TRAN;
SELECT COUNT(*) FROM LivroAutor WHERE fk_livro = '8532512062'; -- 1
DELETE FROM Livro WHERE isbn = '8532512062';
SELECT COUNT(*) FROM LivroAutor WHERE fk_livro = '8532512062'; -- 0
SELECT * FROM Livro WHERE isbn = '8532512062'; -- vazio
ROLLBACK TRAN;
GO

-- 4) Total de livros por categoria
ALTER TABLE Categoria ADD total_livros INT NOT NULL CONSTRAINT df_total_livros DEFAULT 0;
GO

UPDATE C
SET C.total_livros = (SELECT COUNT(*) FROM Livro AS L WHERE L.fk_categoria = C.id)
FROM Categoria AS C;
GO

CREATE OR ALTER TRIGGER trg_after_insert_livro_total
ON Livro
AFTER INSERT
AS
BEGIN
    UPDATE C
    SET C.total_livros = (SELECT COUNT(*) FROM Livro AS L WHERE L.fk_categoria = C.id) -- recontar, não + 1
    FROM Categoria AS C
    WHERE C.id IN (SELECT I.fk_categoria FROM inserted AS I);
END;
GO

SELECT * FROM Categoria; -- Ficção Científica = 3
INSERT INTO Livro (isbn, titulo, ano, fk_editora, fk_categoria)
VALUES ('4444444444', 'Duna', 1965, 2, 2),
       ('5555555555', 'Fundação', 1951, 2, 2);
SELECT * FROM Categoria; -- Ficção Científica = 5
GO

-- 5) Não excluir categoria com livros
-- AFTER não roda: a FK barra antes (erro 547)
CREATE OR ALTER TRIGGER trg_insteadof_delete_categoria
ON Categoria
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Livro AS L JOIN deleted AS D ON L.fk_categoria = D.id)
        RAISERROR('Categoria possui livros, não pode ser excluída', 16, 1);
    ELSE
        DELETE C FROM Categoria AS C JOIN deleted AS D ON C.id = D.id;
END;
GO

-- falha: Literatura Juvenil tem livros
DELETE FROM Categoria WHERE id = 1;
GO

-- passa: Ação não tem livros
BEGIN TRAN;
DELETE FROM Categoria WHERE id = 4;
SELECT * FROM Categoria;
ROLLBACK TRAN;
GO

-- 6) Auditoria de atualização de livros
CREATE TABLE AuditoriaLivro(
    id INT IDENTITY(1,1) PRIMARY KEY,
    isbn VARCHAR(50),
    titulo_antigo VARCHAR(100),
    titulo_novo VARCHAR(100),
    ano_antigo INT,
    ano_novo INT,
    data_hora DATETIME DEFAULT GETDATE()
);
GO

CREATE OR ALTER TRIGGER trg_after_update_livro_auditoria
ON Livro
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditoriaLivro (isbn, titulo_antigo, titulo_novo, ano_antigo, ano_novo)
    SELECT I.isbn, D.titulo, I.titulo, D.ano, I.ano
    FROM inserted AS I
    JOIN deleted AS D
    ON D.isbn = I.isbn; -- se o isbn mudar o JOIN não acha (exercício 8)
END;
GO

UPDATE Livro
SET ano = 1997
WHERE isbn IN ('8532511015', '8532512062');
SELECT * FROM AuditoriaLivro; -- 2 linhas, nenhuma dos inserts acima
GO

-- 7) Total de livros escritos por autor
ALTER TABLE Autor ADD total_livros_escritos INT NOT NULL CONSTRAINT df_total_livros_escritos DEFAULT 0;
GO

UPDATE A
SET A.total_livros_escritos = (SELECT COUNT(*) FROM LivroAutor AS LA WHERE LA.fk_autor = A.id)
FROM Autor AS A;
GO

CREATE OR ALTER TRIGGER trg_after_insert_livroautor_total
ON LivroAutor
AFTER INSERT
AS
BEGIN
    UPDATE A
    SET A.total_livros_escritos = (SELECT COUNT(*) FROM LivroAutor AS LA WHERE LA.fk_autor = A.id)
    FROM Autor AS A
    WHERE A.id IN (SELECT I.fk_autor FROM inserted AS I);
END;
GO

SELECT * FROM Autor; -- Affonso Solano = 1
INSERT INTO LivroAutor (fk_livro, fk_autor)
VALUES ('2222222222', 3),
       ('3333333333', 3);
SELECT * FROM Autor; -- Affonso Solano = 3
GO
