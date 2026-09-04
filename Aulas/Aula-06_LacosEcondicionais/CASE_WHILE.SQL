USE EMPRESA

SELECT 
		F.Pnome,
		F.Unome,
		F.Salario,
		IIF(F.Salario < 20000, 'Baixo', 'Alto') AS 'Nivel Salarial'
FROM FUNCIONARIO AS F
ORDER BY 'Nivel Salarial'
GO;

-- CASE
SELECT 
		F.Pnome,
		F.Unome,
		F.Salario,
	CASE
		WHEN F.Salario <= 10000 AND F.Salario > 0 THEN 'Baixo'
		WHEN F.Salario > 10000 AND F.Salario <=30000 THEN 'Medio'
		WHEN F.Salario > 30000 THEN 'Alto'
		ELSE 'ERRO'
	END AS 'Nivel salarial'
FROM FUNCIONARIO AS F;
GO


-- WHILE
DECLARE @contador INT = 0;

WHILE @contador < 10
BEGIN
	SET @contador = @contador +1
	IF @contador % 2 = 0
		CONTINUE -- REPETE O LAÇO A PARTIR DE QUANDO FOI CHAMADO, UM SKIP PARA REPETIR
		-- BREAK; -- ENCERRAMOS O LAÇO
	SET @contador = @contador +1
	PRINT 'Contador: ' + CAST (@contador as VARCHAR(3));
END