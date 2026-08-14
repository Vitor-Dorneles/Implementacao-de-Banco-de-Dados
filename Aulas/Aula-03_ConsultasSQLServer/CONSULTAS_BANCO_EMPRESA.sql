USE EMPRESA
-- Distinct
SELECT DISTINCT F.Salario
FROM FUNCIONARIO AS F;

SELECT DISTINCT F.Sexo
FROM FUNCIONARIO AS F;

-- WHERE
SELECT *
FROM FUNCIONARIO AS F
WHERE F.Pnome = 'João';

-- SQL AND, OR and NOT
SELECT *
FROM FUNCIONARIO AS F
WHERE F.Sexo = 'M' AND F.Salario >= 30000;

SELECT *
FROM FUNCIONARIO AS F
WHERE F.Endereco LIKE '%São Paulo%' 
OR F.Endereco LIKE '%Curitiba%';

--NOT
SELECT *
FROM FUNCIONARIO AS F
WHERE NOT F.Endereco LIKE '%São Paulo%'

-- SQL ORDER BY
SELECT F.Pnome AS 'Nome', F.Unome AS 'Sobrenome',
F.Endereco,
F.Salario*12  as 'CustoAnual'

FROM FUNCIONARIO AS F
ORDER BY CustoAnual DESC;

-- Valores NULL
SELECT F.Pnome AS 'Nome', F.Unome AS 'Sobrenome', 
F.Cpf_supervisor as 'chefe'
FROM FUNCIONARIO AS F
WHERE F.Cpf_supervisor IS NOT NULL;

-- Clásula Select TOP
SELECT TOP 3 *
FROM FUNCIONARIO AS F
ORDER BY F.Salario desc;

-- Função MIN() E MAX()
-- selects aninhados
SELECT *
FROM FUNCIONARIO AS F
WHERE F.Salario = (SELECT MIN(Salario) 
AS SalarioMinimo from FUNCIONARIO);

SELECT MIN(F.Salario) AS SalarioMinimo
FROM FUNCIONARIO AS F

SELECT Max(F.Salario) AS SalarioMinimo
FROM FUNCIONARIO AS F;

--outra forma de resolver o mesmo problema
-- variavel - tipo float
DECLARE @salario_min DECIMAL (10,2);
SET @salario_min = (SELECT MIN(Salario) FROM FUNCIONARIO);
PRINT @salario_min;

SELECT *
FROM FUNCIONARIO AS F
WHERE F.Salario = @salario_min;
-- a variavel só existe em tempo de execução

-- COUNT(), AVG() E SUM()
-- count()
SELECT COUNT(F.CPF) 
FROM FUNCIONARIO as F;
 
SELECT 
 (SELECT COUNT(F.Cpf) FROM FUNCIONARIO AS F) +
 (SELECT COUNT (D.Nome_dependente) FROM DEPENDENTE AS D);

-- avg()
DECLARE @salario_MEDIA DECIMAL (10,2);
SET @salario_MEDIA = (SELECT avg(Salario) FROM FUNCIONARIO)
print @salario_MEDIA
select F.Pnome, F.Salario
from FUNCIONARIO as F
WHERE F.Salario < @salario_MEDIA;

select avg(F.Salario)
from FUNCIONARIO AS F;

SELECT F.Pnome, F.Salario
FROM FUNCIONARIO AS F
WHERE F.Salario < (SELECT AVG(Salario) FROM FUNCIONARIO)

--SUM() - SOMATORIO
SELECT SUM(F.Salario*12) -- anual
FROM FUNCIONARIO AS F;

-- Operador LIKE
select *
from FUNCIONARIO AS F
WHERE F.Datanasc LIKE '%72%'