USE EMPRESA;
GO

-- 1) Autocommit x Transação Explícita
INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Logística', 20); -- autocommit


BEGIN TRAN;
INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Jurídico', 21);
SELECT * FROM DEPARTAMENTO;
ROLLBACK TRAN; -- desfaz o 21

-- a linha que permaneceu
SELECT D.Dnumero, D.Dnome
FROM DEPARTAMENTO AS D
WHERE D.Dnumero IN (20, 21);
-- só o 20 fica o rollback desfaz apenas o que está dentro do BEGIN TRAN
GO

-- 2) Save Point
BEGIN TRAN;
INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Compras', 30);
--save point
SAVE TRAN comprasOk

INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
VALUES ('Financeiro', 31);
SELECT * FROM DEPARTAMENTO;

ROLLBACK TRAN comprasOk -- desfaz o 31
SELECT @@TRANCOUNT; -- precisa do commit
COMMIT TRAN; -- commita o 30

-- depois do commit só o 30 
SELECT D.Dnumero, D.Dnome
FROM DEPARTAMENTO AS D
WHERE D.Dnumero IN (30, 31);
GO
