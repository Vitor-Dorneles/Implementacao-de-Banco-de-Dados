CREATE DATABASE CAIXA;
USE CAIXA;

CREATE TABLE conta(
    id INT PRIMARY KEY,
    Nome VARCHAR(50),
    Saldo MONEY
);

INSERT INTO conta
VALUES (10, 'Maria', 500),
        (20, 'João', 1500),
        (30, 'Maria', 50000),
        (40, 'Paulo', 30000);

SELECT * FROM conta;

GO;
-- Primeira Transação
BEGIN TRAN;
DECLARE @erro INT = 0;
INSERT INTO conta
VALUES (50, 'Pedro', 50);
SET @erro = @erro + @@ERROR

INSERT INTO conta
VALUES (10, 'Judas', 666);
SET @erro = @erro + @@ERROR
SELECT * FROM conta
IF @erro <> 0
BEGIN
    PRINT 'TRANSAÇÃO REVERTIDA;'
    ROLLBACK TRAN;
END
ELSE
BEGIN
    PRINT 'Transação realizada com sucesso'
    COMMIT TRAN;
END
-- PRINT @@ERROR; -- violação de PK
SELECT *
FROM   conta;
GO;

BEGIN TRAN;
UPDATE conta
SET Saldo = Saldo + 10000
WHERE Nome = 'Maria';
IF @@ROWCOUNT <> 1
BEGIN
    SELECT * FROM conta;
    ROLLBACK TRAN
    SELECT * FROM   conta;
END
ELSE 
    COMMIT TRAN

SELECT @@TRANCOUNT;

-- Tranferir dinheiro de uma pessoa para a outra:
GO
CREATE OR ALTER PROCEDURE usp_transferencia
    @id_origem INT,
    @id_destino INT,
    @valor MONEY

AS
BEGIN
    BEGIN TRAN;
    -- tirando dinheiro da conta de origem
    UPDATE conta
    SET Saldo = Saldo - @valor
    WHERE id = @id_origem;

    --depositar na conta de destino
    UPDATE conta
    SET Saldo = Saldo + @valor
    WHERE id = @id_destino;

    -- ver possivel estado do banco
    SELECT * FROM conta; -- mostra como ficaria possivelmente o banco
    -- condição para rollback
    IF (SELECT Saldo FROM conta WHERE id = @id_origem) < 0
    BEGIN
        ROLLBACK TRAN
        PRINT 'Saldo Insuficiente'
        SELECT * FROM conta
    END
    ELSE
    BEGIN
         -- condição para commit
        COMMIT TRAN
        PRINT 'Transferencia realizada'
    END
END
GO

EXEC usp_transferencia 40,10,510;

-- Save Point
BEGIN TRAN;
INSERT INTO conta
VALUES (50, 'Pedro', 50);
--save point
SAVE TRAN pedroOk

INSERT INTO conta
VALUES (10, 'Juca', -200);
IF @@ERROR <>0
BEGIN
    ROLLBACK TRAN pedroOK
    COMMIT TRAN;
    PRINT 'VOLTAMOS PARA O SAVE'
END
ELSE 
    COMMIT TRAN;

-- try catch
BEGIN TRY -- TENTA FAZER O QUE ESTÁ AQUI
    PRINT 'Olá try'
    SELECT 1/0; -- ERRO;
    PRINT 'NÃO CHEGUEI AQUI'
END TRY
BEGIN CATCH
    PRINT 'DEU ERRO!'
    PRINT 'Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10)); -- É O NUMERO QUE É ENVIADO PARA O BACKEND, NUMERO DE ERRO
    PRINT 'Mensagem de ERRO: ' + ERROR_MESSAGE(); -- IMPORTANTE SABER PARA CONSULTAR A DOCUMENTAÇÃO DO BANCO
END CATCH

-- Transaction + try Catch
BEGIN TRAN;
    BEGIN TRY
        INSERT INTO conta
        VALUES (60, 'José', 50);
        INSERT into conta 
        VALUES (10, 'Juca', -200);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        PRINT 'ERRO'
        PRINT 'Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Mensagem de erro: ' + ERROR_MESSAGE();
    END CATCH
SELECT * FROM conta;

-- criar um sp que insira um novo user ao banco, sem permitir duplicidades de nomes

DELETE FROM conta
WHERE id = 30;

GO
CREATE OR ALTER PROCEDURE usp_novo_user
@id INT, 
@nome VARCHAR(50), 
@saldo MONEY
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
    INSERT INTO conta
    VALUES(@id, @nome, @saldo)
    SELECT * FROM conta;
    IF (SELECT COUNT(*) FROM conta WHERE Nome = @nome) > 1
    BEGIN
        ROLLBACK TRAN
        PRINT 'JÁ EXISTE ALGUEM COM O NOME: ' + @nome;
    END
    ELSE
    BEGIN
        COMMIT TRAN
        PRINT 'Cadastro realizado com sucesso'
    END
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    PRINT 'ERRO '
    PRINT 'Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Mensagem de erro: ' + ERROR_MESSAGE();
END CATCH
END
GO

EXEC usp_novo_user 100, 'tiago', 600;
SELECT * from conta