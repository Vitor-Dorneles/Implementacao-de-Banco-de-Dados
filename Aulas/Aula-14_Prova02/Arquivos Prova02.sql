USE CLINICAVET;
GO

--2 
BEGIN TRAN;
DECLARE @erro int, @linhas int;
UPDATE Procedimento SET PrecoPadrao = '105' WHERE ProcedimentoID = 'HEMO';
SELECT @erro = @@ERROR, @linhas = @@ROWCOUNT;
IF @erro <> 0 OR @linhas <> 1
BEGIN
	ROLLBACK TRAN;
END;
ELSE COMMIT TRAN;
GO

GO
--4
CREATE OR ALTER TRIGGER trg_Consulta_Ativos
ON Consulta
AFTER INSERT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Animal AS A WHERE A.AnimalID IN (SELECT I.AnimalID FROM inserted AS I) 
	AND (A.Ativo ='1') AND EXISTS (SELECT 1 FROM Veterinario AS V WHERE V.VeterinarioID IN (SELECT I.VeterinarioID FROM inserted AS I) AND (V.Ativo ='1')))
		BEGIN 
			PRINT 'inserçao com SUCESSO'; 
			COMMIT TRAN;
		END;
	ELSE
		BEGIN
			PRINT 'Transferencia NÃO realizada';
			ROLLBACK TRAN;
		END


END

INSERT INTO Consulta (AnimalID, VeterinarioID, DataConsulta,Motivo)
VALUES (7,3,'2026-11-20 04:00:00','CONSULTA TESTEE ACEITA, CCAD');




5
CREATE OR ALTER TRIGGER trg_ConsultaProcedimento_ValorTotal
ON ConsultaProcedimento
AFTER INSERT
AS
BEGIN
	IF EXISTS(select 1 from ConsultaProcedimento AS CP WHERE CP.ProcedimentoID IN (SELECT I.ProcedimentoID FROM inserted AS I) AND CP.ConsultaProcedimentoID = )

END

GO

--6 
CREATE TABLE dbo.HistoricoPrecoProcedimento (
    HistoricoID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ProcedimentoID VARCHAR(10) NOT NULL,
	PrecoAnterior DECIMAL(10,2) NOT NULL,
	PrecoNovo DECIMAL (10,2) NOT NULL,
	DataAlteracao DATETIME2(0) DEFAULT SYSDATETIME() NOT NULL, 
);

GO

GO
CREATE OR ALTER TRIGGER trg_Procedimento_Preco
ON Procedimento
AFTER UPDATE, INSERT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Procedimento AS P
				WHERE P.ProcedimentoID IN (SELECT I.ProcedimentoID  FROM inserted AS I) 
				AND EXISTS (SELECT 1 FROM Procedimento AS P
							WHERE P.PrecoPadrao IN (SELECT I.PrecoPadrao  FROM inserted AS I)
				AND EXISTS (SELECT 1 FROM Procedimento AS P
							WHERE P.PrecoPadrao IN (SELECT D.PrecoPadrao  FROM deleted AS D)))
	)
	DECLARE @PRECO_ANTERIOR DECIMAL(10,2);
	SELECT @PRECO_ANTERIOR = P.PrecoPadrao
	FROM PROCEDIMENTO AS P

	INSERT INTO dbo.HistoricoPrecoProcedimento (ProcedimentoID, PrecoAnterior, PrecoNovo)
	SELECT I.ProcedimentoID,  @PRECO_ANTERIOR, I.PrecoPadrao	FROM inserted AS I

END

GO

UPDATE Procedimento SET PrecoPadrao = '60' WHERE ProcedimentoID = 'COLETA';
select * from dbo.HistoricoPrecoProcedimento



--12
GO
create login usuarioRecepcao with password = '123';
CREATE user usuarioRecepcao
for login usuarioRecepcao;
alter role CLINICAVET add member usuarioRecepcao;
grant select on vw_RelatorioConsultas to usuarioRecepcao;
grant insert on dbo.Consulta to usuarioRecepcao;
deny update on dbo.Consulta to usuarioRecepcao;
deny delete on dbo.Consulta to usuarioRecepcao;
GO