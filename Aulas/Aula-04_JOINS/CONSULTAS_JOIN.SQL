USE EMPRESA

SELECT *
FROM TRABALHA_EM AS T
WHERE T.Pnr in (2,3,10,20);

-- nome do funcionário e o número do projeto em que trabalha SEM REPETIÇÃO DE NOME
SELECT F.Pnome, t.Pnr
FROM TRABALHA_EM AS T, FUNCIONARIO AS F
WHERE 
	F.Cpf = T.Fcpf 
	AND T.Pnr IN (2,3,10,20)
	AND F.Pnome <> 'Fernando';

-- Selects aninhados
SELECT F.Pnome, T.Pnr
FROM TRABALHA_EM AS T, FUNCIONARIO AS F
WHERE
	F.Cpf = T.Fcpf
	AND F.Pnome <> 'Fernando'
	AND T.Pnr IN (
		SELECT Pnr
		FROM TRABALHA_EM)


-- BETWEEN - MINIMO E MAXIMO
SELECT F.Pnome ,F.Salario
FROM FUNCIONARIO AS F
WHERE F.Dnr = 5 AND F.Salario BETWEEN 30000 AND 45000;

-- JOINS
-- Funcionarios que trabalham no departamento de pesquisa
SELECT F.Pnome as Nome, F.Unome as sobrenome, F.Endereco, d.Dnome as departamento
FROM FUNCIONARIO AS F
INNER JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
WHERE D.Dnome = 'Pesquisa'

-- O nome dos funcionarios que estão desenvolvendo o "ProdutoX"
SELECT *
FROM PROJETO

SELECT F.Cpf, F.Pnome, P.Projnome, T.Horas
FROM TRABALHA_EM AS T
INNER JOIN PROJETO AS P
ON T.Pnr = P.Projnumero
INNER JOIN FUNCIONARIO AS F
ON T.Fcpf = F.Cpf 
WHERE P.Projnome = 'ProdutoX'

-- Numero do departamento que controla os projetos localizados em Mauá
SELECT D.Dnome, P.Projnome, P.Projlocal, d.Cpf_gerente, F.Unome, F.Endereco
FROM DEPARTAMENTO AS D
JOIN PROJETO AS P
ON P.Dnum = D.Dnumero
JOIN FUNCIONARIO AS F
ON F.Cpf = D.Cpf_gerente
WHERE P.Projlocal = 'Mauá';

-- lEFT JOIN
SELECT *
FROM FUNCIONARIO AS F
LEFT JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero

-- Departamentos que não tem funcionários
SELECT *
FROM DEPARTAMENTO AS D
LEFT JOIN FUNCIONARIO AS F
ON F.Dnr = D.Dnumero
WHERE F.Cpf IS NULL;

-- CROSS JOIN
SELECT *
FROM FUNCIONARIO AS F
FULL JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
WHERE D.Dnumero is NULL
	OR F.Cpf IS NULL;

-- self join - PARA A consulta de uma tabela em si mesma
SELECT f.Pnome as 'Funcionario', S.Unome 
FROM FUNCIONARIO AS F
JOIN FUNCIONARIO AS S
ON F.Cpf_supervisor = S.Cpf;

-- UNION, INTERSECT, EXCEPT
--Union -- PARA ISSO PRECISAMOS PADRONIZAR A TABELA
SELECT F.Pnome AS 'Nome', F.Sexo, F.Datanasc 
FROM FUNCIONARIO AS F

UNION

SELECT D.Nome_dependente AS 'Nome' , d.Sexo, d.Datanasc
FROM DEPENDENTE AS D

