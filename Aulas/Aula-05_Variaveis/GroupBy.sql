USE EMPRESA

-- UNION ALL -- REMOVE AS DUPLICIDADES
SELECT P.Projlocal AS 'local'
FROM PROJETO AS P

-- UNION -- É COMO SE ESTIVESSE FAZENDO UM DISTINCT 1 de cada
UNION ALL

SELECT L.Dlocal AS 'local'
FROM LOCALIZACAO_DEP AS L;

-- EXCEPT
-- Listar os cpfs dos funcionários que não são gerentes de nenhum departamento
SELECT F.Cpf, F.Pnome
FROM FUNCIONARIO AS F
EXCEPT 
SELECT D.Cpf_gerente, F.Pnome
FROM DEPARTAMENTO AS D
JOIN FUNCIONARIO AS F
ON D.Cpf_gerente = F.Cpf; 

-- INTERSECT
-- Encontre os funcionários que são supervisores
SELECT F.Pnome, F.Cpf, F.Cpf_supervisor
FROM FUNCIONARIO AS F;
INTERSECT
SELECT	Cpf_supervisor
from FUNCIONARIO

-- Declaração GROUP BY
-- Quantidade de funcionários por sexo
SELECT COUNT (F.Cpf) AS 'Qtd', F.Sexo
FROM FUNCIONARIO AS F
GROUP BY F.Sexo;

-- Quantos funcionários em cada departamento
SELECT COUNT(F.Cpf) AS 'Quantidade', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
GROUP BY D.Dnome
ORDER BY Quantidade;

-- Somar os salários por departamento
SELECT COUNT(F.Cpf) AS 'Quantidade',SUM(F.Salario) as Salarios , D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
GROUP BY D.Dnome
ORDER BY Salarios;

-- Media de horas trabalhadas por projeto
SELECT AVG(t.Horas) AS 'Horas Projeto', P.Projnome
FROM TRABALHA_EM AS T
JOIN PROJETO AS P
ON T.Pnr = P.Projnumero
GROUP BY P.Projnome
ORDER BY [Horas Projeto];

-- Maior salário em cada departamento
SELECT MAX(F.Salario) AS 'Maior salário', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
GROUP BY D.Dnome
ORDER BY [Maior salário];

-- Having
-- É UM FILTRO SOBRE O CONJUNTO DE DADOS AGRUPADO, UTILIZADA NORMALMENTE COM GROUP BY
SELECT COUNT(F.Cpf) AS 'Func', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
GROUP BY D.Dnome
HAVING COUNT (F.Cpf) > 3;

SELECT SUM(t.Horas) AS 'Horas Projeto', P.Projnome
FROM TRABALHA_EM AS T
JOIN PROJETO AS P
ON T.Pnr = P.Projnumero
GROUP BY P.Projnome
HAVING SUM(T.Horas) >= 50
ORDER BY [Horas Projeto];

-- Exists
SELECT *
FROM DEPARTAMENTO AS D
WHERE EXISTS (
	SELECT 1
	FROM PROJETO
	WHERE PROJETO.Dnum = D.Dnumero
);

-- Operador Any
-- Quem ganha mais que os funcionários da adm
select FUNCIONARIO.Pnome, FUNCIONARIO.Salario
from FUNCIONARIO
WHERE Salario </*Operador Diferente*/> ALL( -- QUALQUER UM OUTRO SALARIO DA LISTA DO SELECT DE BAIXO
	SELECT F.Salario 
	FROM FUNCIONARIO AS F
	JOIN DEPARTAMENTO AS D
	ON F.Dnr = D.Dnumero
	WHERE D.Dnome = 'Administração'
)
ORDER BY FUNCIONARIO.Salario