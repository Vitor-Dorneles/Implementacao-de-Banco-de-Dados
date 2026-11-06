USE EMPRESA_2026
GO

-- Os testes rodam entre BEGIN TRAN e ROLLBACK TRAN: mostram o efeito e desfazem,
-- assim o arquivo pode ser executado de novo (visto na Aula 11, Transações).
-- Cada exemplo termina com DROP TRIGGER para não interferir no próximo.

-- ===== 1. TRIGGER AFTER =====
-- AFTER (ou FOR): roda depois que o comando executou e passou nas constraints
CREATE OR ALTER TRIGGER trg_after_insert_dpt
ON DEPARTAMENTO
AFTER INSERT
AS
BEGIN
    PRINT 'Olá meu primeiro TRIGGER!'
END;
GO

/* VAI DAR ERRO, POIS O CAMPO DNUMERO É NOT NULL
   o NULL é barrado no passo 2 do fluxo, antes de chegar no trigger
INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (NULL, 'Expedição'); */

BEGIN TRAN;
INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (88, 'Expedição'); -- imprime: Olá meu primeiro TRIGGER!
ROLLBACK TRAN;
GO

-- INSERTED: tabela virtual com as linhas que o comando inseriu
-- CREATE OR ALTER troca o corpo do trigger que já existe
CREATE OR ALTER TRIGGER trg_after_insert_dpt
ON DEPARTAMENTO
AFTER INSERT
AS
BEGIN
    DECLARE @nome VARCHAR(40);
    SELECT @nome = I.Dnome
    FROM inserted AS I; -- esse insert nos permite pegar qualquer valor que foi inserido
                        -- a variável guarda só uma linha: num INSERT de várias, mostra uma delas

    PRINT 'Novo departamento: ' + @nome
END;
GO

BEGIN TRAN;
INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (88, 'Expedição'); -- imprime: Novo departamento: Expedição
ROLLBACK TRAN;
GO

DROP TRIGGER trg_after_insert_dpt;
GO

-- ===== 2. TRIGGER INSTEAD OF =====
-- roda NO LUGAR do comando: o DELETE original não acontece
CREATE OR ALTER TRIGGER trg_insteadof_delete_dpt
ON DEPARTAMENTO
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'NÃO DELETEI O REGISTRO'
END
GO

BEGIN TRAN;
INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (88, 'Expedição');

DELETE
FROM DEPARTAMENTO
WHERE Dnumero = 88; -- só imprime a mensagem

SELECT * FROM DEPARTAMENTO; -- o 88 continua na tabela
ROLLBACK TRAN;
GO

-- desabilitar o trigger pode ser manualmente (SSMS) ou com esse comando
ALTER TABLE DEPARTAMENTO DISABLE TRIGGER trg_insteadof_delete_dpt;
ALTER TABLE DEPARTAMENTO ENABLE TRIGGER trg_insteadof_delete_dpt; -- religa

--mostra os triggers da tabela
EXEC sp_helptrigger DEPARTAMENTO;
GO

DROP TRIGGER trg_insteadof_delete_dpt;
GO

-- ===== 3. SEM NOMES DUPLICADOS COM INSTEAD OF =====
-- verifica ANTES de inserir; se estiver tudo certo, o próprio trigger faz o INSERT
CREATE OR ALTER TRIGGER trg_insteadof_insert_dpt
ON DEPARTAMENTO
INSTEAD OF INSERT
AS
BEGIN
    -- JOIN com inserted em vez de @nome: funciona também com INSERT de várias linhas
    IF EXISTS (SELECT 1 FROM DEPARTAMENTO AS D JOIN inserted AS I ON D.Dnome = I.Dnome)
        RAISERROR('Já existe um departamento com esse nome', 16, 1);
    ELSE
    BEGIN
        -- sem refazer o INSERT nada é gravado; as colunas do SELECT
        -- vão na mesma ordem da lista do INSERT
        INSERT INTO DEPARTAMENTO (Dnumero, Dnome, Cpf_gerente, Data_inicio_gerente)
        SELECT I.Dnumero, I.Dnome, I.Cpf_gerente, I.Data_inicio_gerente
        FROM inserted AS I

        PRINT 'Departamento inserido'
    END
END
GO

BEGIN TRAN;
INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (100, 'Vendas'); -- erro: Vendas já existe

INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (100, 'Estoque'); -- passa

SELECT * FROM DEPARTAMENTO;
ROLLBACK TRAN;
GO

DROP TRIGGER trg_insteadof_insert_dpt;
GO

-- ===== 4. SEM NOMES DUPLICADOS COM AFTER =====
-- no AFTER a linha nova já está na tabela: duplicado = o nome aparece mais de 1 vez
CREATE OR ALTER TRIGGER trg_after_insert_dpt_dupli
ON DEPARTAMENTO
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1
               FROM DEPARTAMENTO AS D
               WHERE D.Dnome IN (SELECT I.Dnome FROM inserted AS I)
               GROUP BY D.Dnome
               HAVING COUNT(*) > 1)
    BEGIN
        ROLLBACK TRANSACTION; -- volta para o original e não salva
        RAISERROR('Já existe um departamento com esse nome', 16, 1);
    END
END;
GO

-- teste fora do BEGIN TRAN: o ROLLBACK do trigger desfaz o INSERT e encerra o lote
INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (101, 'Vendas'); -- erro, nada é salvo
GO

SELECT * FROM DEPARTAMENTO; -- sem o 101
GO

DROP TRIGGER trg_after_insert_dpt_dupli;
GO

-- ===== 5. FUNÇÃO UPDATE() =====
-- verificar se um nome foi alterado
CREATE OR ALTER TRIGGER trg_for_update_nome
ON DEPARTAMENTO
FOR UPDATE -- FOR = AFTER
AS
BEGIN
    DECLARE @nome_antigo VARCHAR(40),
            @nome_novo VARCHAR(40);

    SELECT @nome_antigo = D.Dnome
    FROM deleted AS D; -- no UPDATE, deleted tem a versão antiga

    SELECT @nome_novo = I.Dnome
    FROM inserted AS I; -- e inserted tem a versão nova

    IF UPDATE(Dnome) -- verdadeiro se a coluna estava no SET, mesmo sem mudar o valor
    BEGIN
        PRINT 'O nome era: ' + @nome_antigo;
        PRINT 'O novo nome é: ' + @nome_novo;
    END
    ELSE
        PRINT 'O nome não foi alterado';
END;
GO

BEGIN TRAN;
UPDATE DEPARTAMENTO
SET Dnome = 'Tecnologia'
WHERE Dnome = 'TI'; -- O nome era: TI / O novo nome é: Tecnologia

INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (100, 'Estoque');

UPDATE DEPARTAMENTO
SET Dnumero = 9
WHERE Dnome = 'Estoque'; -- O nome não foi alterado

SELECT * FROM DEPARTAMENTO;
ROLLBACK TRAN;
GO

DROP TRIGGER trg_for_update_nome;
GO

-- ===== 6. LOG =====
-- trigger para acompanhar alteração na tabela funcionário, apenas registro
DROP TABLE IF EXISTS LOG_FUNCIONARIO;
CREATE TABLE LOG_FUNCIONARIO(
    log_id INT IDENTITY(100,1) PRIMARY KEY,
    cpf CHAR(11),
    operacao VARCHAR (10),
    data_hora DATETIME DEFAULT GETDATE() -- o trigger não informa a hora, o DEFAULT preenche
)
GO

--TRIGGER DE LOG DE INSERT: as linhas novas estão em inserted
CREATE OR ALTER TRIGGER trg_for_insert_funcionario
ON FUNCIONARIO
FOR INSERT
AS
BEGIN
    INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
    SELECT I.Cpf, 'INSERT'
    FROM inserted AS I
END
GO

--TRIGGER DE LOG DE UPDATE: inserted tem a versão nova da linha
CREATE OR ALTER TRIGGER trg_for_update_funcionario
ON FUNCIONARIO
FOR UPDATE
AS
BEGIN
    INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
    SELECT I.Cpf, 'UPDATE'
    FROM inserted AS I
END
GO

--TRIGGER DE LOG DE DELETE: as linhas apagadas estão em deleted
CREATE OR ALTER TRIGGER trg_for_delete_funcionario
ON FUNCIONARIO
FOR DELETE
AS
BEGIN
    INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
    SELECT D.Cpf, 'DELETE'
    FROM deleted AS D
END
GO

BEGIN TRAN;
INSERT INTO FUNCIONARIO(Pnome, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Bonus, Data_Admissao, Dnr)
VALUES ('juju', 'da silva', '123343434','2004-06-08', 'rua 2', 'M', 1190, 0, '2026-10-23', 4);

SELECT * FROM FUNCIONARIO WHERE Cpf = '123343434';

UPDATE FUNCIONARIO
SET Salario = 2
WHERE Cpf = '123343434'

DELETE FROM FUNCIONARIO
WHERE Cpf = '123343434';

SELECT * FROM LOG_FUNCIONARIO; -- INSERT, UPDATE e DELETE
ROLLBACK TRAN; -- o log também é desfeito: o trigger roda na mesma transação do comando
GO

-- os três são trocados por um só logo abaixo; sem o DROP, cada operação seria registrada duas vezes
DROP TRIGGER trg_for_insert_funcionario, trg_for_update_funcionario, trg_for_delete_funcionario;
GO

-- TRIGGER DE LOG INSERT, UPDATE, DELETE
-- a operação se descobre pelo conteúdo de inserted e deleted
CREATE OR ALTER TRIGGER trg_for_IDU_funcionario
ON FUNCIONARIO
FOR INSERT, DELETE, UPDATE
AS
BEGIN
    --UPDATE: as duas tabelas têm linhas
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
        SELECT I.Cpf, 'UPDATE'
        FROM inserted AS I
    --INSERT: só inserted tem linhas
    ELSE IF EXISTS (SELECT * FROM inserted)
        INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
        SELECT I.Cpf, 'INSERT'
        FROM inserted AS I
    --DELETE: só deleted tem linhas
    ELSE
        INSERT INTO LOG_FUNCIONARIO (cpf, operacao)
        SELECT D.Cpf, 'DELETE'
        FROM deleted AS D
END;
GO

BEGIN TRAN;
INSERT INTO FUNCIONARIO(Pnome, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Bonus, Data_Admissao, Dnr)
VALUES ('Juca', 'da Silva', '4454454', '2005-06-08', 'Rua Sete', 'M', 1100, 0, '2026-10-23', 4);

UPDATE FUNCIONARIO
SET Salario = 100
WHERE Cpf = '4454454';

DELETE FROM FUNCIONARIO
WHERE Cpf = '4454454';

SELECT * FROM LOG_FUNCIONARIO; -- INSERT, UPDATE e DELETE, agora com um trigger só
ROLLBACK TRAN;
GO

DROP TRIGGER trg_for_IDU_funcionario;
GO
