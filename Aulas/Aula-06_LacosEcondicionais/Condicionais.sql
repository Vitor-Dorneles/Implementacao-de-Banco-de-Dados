USE EMPRESA

-- Convert
DECLARE @data_nasc DATE;
DECLARE @nome VARCHAR(100);

SET @nome = 'Ana';
SELECT @data_nasc = F.Datanasc
FROM FUNCIONARIO AS F
WHERE F.Pnome = @nome

print @data_nasc
GO;

-- Condicionais IF/ELSE
-- Verificar se o funcinário recebe abaixo da média
DECLARE @salario_medio DECIMAL(10,2),
		@nome VARCHAR(100),
		@salario DECIMAL(10,2);
SET @nome = 'Jennifer';
SELECT @salario_medio = AVG(F.Salario) FROM FUNCIONARIO AS F;
SELECT @salario = Salario FROM FUNCIONARIO WHERE @nome = Pnome;

IF (@salario < @salario_medio)
	BEGIN
		print 'O funcionário ' + @nome + ' ganha abaixo da média'
	END;
ELSE
	BEGIN
		Print 'O funcionário ' + @nome + ' ganha acima da média'
	END;
GO

-- Aposentadoria == 60 anos
DECLARE @nome VARCHAR(100),
		@idade INT,
		@ano_atual INT;

SET @nome = 'Ana';
SET @ano_atual = YEAR(GETDATE());

SELECT @idade = (@ano_atual - YEAR(Datanasc)) 
FROM FUNCIONARIO 
WHERE @nome = Pnome;


PRINT @idade
IF (@idade < 56)
	BEGIN
		print 'O funcionário ' + @nome + ' ainda é novo para se aposentar'
	END;
ELSE IF (@idade <= 60)
	BEGIN
		Print 'O funcionário ' + @nome + ' está proximo de se aposentar'
	END;
ELSE
	BEGIN;
		PRINT 'Passou da idade'
	END;
GO

-- IF/ELSE
-- TENDO O NOME DA PESSOA CALCULAR A IDADE CORRETA
DECLARE @data_nasc DATE,
		@nome VARCHAR (100),
		@idade INT;
SET @nome = 'Ana';
SELECT @data_nasc = Datanasc FROM FUNCIONARIO WHERE Pnome = @nome

IF(MONTH(GETDATE()) < MONTH (@data_nasc))
	SET @idade = DATEDIFF(YEAR, @data_nasc, GETDATE()) -1
ELSE IF (MONTH(GETDATE()) = MONTH(@data_nasc)
		and DAY(GETDATE()) > DAY(@data_nasc))
		SET @idade = DATEDIFF(YEAR,@data_nasc, GETDATE())-1
ELSE 
	SET @idade = DATEDIFF (YEAR, @data_nasc, GETDATE())

PRINT @data_nasc
PRINT @idade

SELECT * FROM FUNCIONARIO;