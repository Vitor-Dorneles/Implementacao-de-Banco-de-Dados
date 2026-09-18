USE BIBLIOTECA;
GO

-- PROCEDURE QUE INSERE UMA NOVA CATEGORIA
CREATE OR ALTER PROCEDURE sp_InserirCategoria (
	@tipo_categoria VARCHAR (50)
)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Categoria WHERE tipo_categoria = @tipo_categoria)
		BEGIN
			PRINT 'JA EXISTE:   ' + @tipo_categoria;
			RETURN;
		END
	ELSE
		BEGIN
			INSERT INTO Categoria (tipo_categoria)
			VALUES (@tipo_categoria);
			PRINT 'CATEGORIA INSERIDA:   ' + @tipo_categoria;
		END
END;
GO

EXEC sp_InserirCategoria @tipo_categoria = 'Terror';
GO

-- ATUALIZA TITULO E ANO DE UM LIVRO A PARTIR DO ISBN
CREATE OR ALTER PROCEDURE sp_AtualizarLivro (
	@isbn   VARCHAR (50),
	@titulo VARCHAR (100),
	@ano    INT
)
AS
BEGIN
	UPDATE Livro
	SET titulo = @titulo,
		ano    = @ano
	WHERE isbn = @isbn;
	PRINT 'LIVRO ATUALIZADO:   ' + @isbn;
END;
GO

EXEC sp_AtualizarLivro @isbn = '8532511015', @titulo = 'Harry Potter e a Pedra Filosofal (Ed. Gremista)', @ano = 2001;
GO

-- ADICIONA UM NOVO AUTOR
CREATE OR ALTER PROCEDURE sp_AdicionarAutor (
	@nome          VARCHAR (100),
	@nacionalidade VARCHAR (50) = NULL
)
AS
BEGIN
	INSERT INTO Autor (nome, nacionalidade)
	VALUES (@nome, @nacionalidade);
	PRINT 'AUTOR INSERIDO:   ' + @nome;
END;
GO

EXEC sp_AdicionarAutor @nome = 'Zamba', @nacionalidade = 'Brasil';
GO

-- EXCLUIR UM AUTOR E REMOVER ASSOCIACAO EM LIVROAUTOR
CREATE OR ALTER PROCEDURE sp_ExcluirAutor (
	@id_autor INT
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Autor WHERE id = @id_autor)
		BEGIN
			PRINT 'AUTOR NAO ENCONTRADO:   ' + CAST(@id_autor AS VARCHAR);
			RETURN;
		END
	ELSE
		BEGIN
			DELETE FROM LivroAutor WHERE fk_autor = @id_autor;
			DELETE FROM Autor WHERE id = @id_autor;
			PRINT 'AUTOR EXCLUIDO:   ' + CAST(@id_autor AS VARCHAR);
		END
END;
GO

EXEC sp_ExcluirAutor @id_autor = 6;
GO

-- RETORNA OS LIVROS DE UMA CATEGORIA A PARTIR DO NOME DA CATEGORIA
CREATE OR ALTER PROCEDURE sp_LivrosPorCategoria (
	@tipo_categoria VARCHAR (50)
)
AS
BEGIN
	SELECT
		L.isbn      AS 'ISBN',
		L.titulo    AS 'TITULO',
		L.ano       AS 'ANO'
	FROM Livro AS L
	JOIN Categoria AS C
		ON L.fk_categoria = C.id
	WHERE C.tipo_categoria = @tipo_categoria;
END;
GO

EXEC sp_LivrosPorCategoria @tipo_categoria = 'Literatura Juvenil';
GO
