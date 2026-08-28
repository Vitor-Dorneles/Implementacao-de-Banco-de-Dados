-- Declare
-- BASH QUE TEM QUE RODAR COMPLETO
Declare @nome VARCHAR(100),
		@idade INT,
		@salario DECIMAL(10,2),
		@date DATE;
SET @nome = 'Vitor';
SET @idade = 21;
SET @salario = 5000.00;
SET @date = GETDATE();

PRINT 'Olá SQL, MEU NOME:' + @nome + 'Idade: ' + CAST(@idade AS VARCHAR(10));

SELECT 
	@nome as 'Nome',
	@idade as 'Idade',
	@salario as 'Grana',
	@date 'Data de hoje'

GO --Encerra o bash como um bloco

-- Recuperando o nome do departamento com Dnumero = 4
DECLARE @nome_dpt VARCHAR(30);
SELECT @nome_dpt = d.Dnome
FROM DEPARTAMENTO AS D
WHERE D.Dnumero = 4
PRINT 'Departamento: ' + @nome_dpt
GO

-- Exemplo com cálculo
/*Calculando o novo salário da Jennifer com um aumento de 10%  */
DECLARE @salario DECIMAL(10,2),
		@novo_salario DECIMAL (10,2),
		@nome VARCHAR (100);
SET @nome = 'Jennifer';

SELECT @salario = F.Salario
FROM FUNCIONARIO as F
WHERE F.Pnome = @nome;
SET @novo_salario = @salario * 1.1;
PRINT 'Salário: ' + CAST(@salario AS VARCHAR(10));
PRINT 'Novo Salário: ' + CAST(@novo_salario as varchar(10));
GO

-- Calculando a idade da Jennifer
DECLARE @ano_nascimento date,
		@idade int;

SELECT @ano_nascimento = F.Datanasc
FROM FUNCIONARIO AS F
WHERE F.Pnome = 'Jennifer';
PRINT @ano_nascimento
SET @idade = YEAR(GETDATE()) - YEAR(@ano_nascimento);
print 'A Jennifer tem ' + CAST(@idade as VARCHAR(5)) + ' anos'