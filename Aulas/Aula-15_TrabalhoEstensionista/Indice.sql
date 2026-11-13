CREATE DATABASE INDICE;
USE INDICE;

CREATE TABLE Funcionario (
	Id int PRIMARY KEY,
	Nome VARCHAR(100),
	Cargo VARCHAR(50),
	Salario DECIMAL (10,2),
	DataAdmissao DATE
	);

--DROP TABLE Funcionario;

INSERT INTO Funcionario
VALUES (1,'João', 'Gerente', 4000, GETDATE()),
		(2,'João Pedro', 'Gerente', 6000, GETDATE()),
		(3,'João Vitor', 'estoque', 5000, GETDATE()),
		(4,'João pAULO', 'TI', 3000, GETDATE()),
		(5,'João Cesar', 'Gerente', 4000, GETDATE());

select *  from Funcionario;

DECLARE @Contador INT = 1;
DECLARE @Id INT;

SELECT @Id = ISNULL(MAX(Id), 0 ) from Funcionario;

while @Contador <= 300000
BEGIN
	SET @Id = @Id +1;
	INSERT INTO Funcionario
	VALUES
	(@Id, 'Funcionario' + CAST (@Id AS VARCHAR(10)),
	CASE @Contador % 5
		WHEN 0 THEN 'Gerente'
		WHEN 1 THEN 'Desenvolvevor'
		WHEN 2 THEN 'Analista'
		WHEN 3 THEN 'Suporte'
		ELSE 'Financeiro'
	END,
	FLOOR (10000 * RAND()) + 1600,

	DATEADD(DAY, @Contador % 3650, '20150101')
	
	)
	SET @Contador = @Contador +1;
END

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM Funcionario
WHERE Nome Like '%255000';

INSERT INTO Funcionario
VALUES 
(300100, 'jj', 'Gerencia', 3500, GETDATE());

CREATE NONCLUSTERED INDEX ix_Funcionario_Nome
ON Funcionario (Nome);

SELECT * FROM Funcionario
WHERE DataAdmissao > '20150101' AND DataAdmissao <= '20150201'