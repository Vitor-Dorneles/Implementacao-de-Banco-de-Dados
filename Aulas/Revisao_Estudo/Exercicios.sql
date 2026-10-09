USE EMPRESA;

SELECT *
FROM FUNCIONARIO AS F
WHERE F.Salario BETWEEN 30000 AND 45000
ORDER BY F.Salario DESC;
GO

SELECT *
FROM FUNCIONARIO AS F
WHERE F.Pnome != 'Fernando' AND F.Dnr = '5';
GO

SELECT *
FROM FUNCIONARIO AS F
WHERE F.Cpf_supervisor IS NULL;
GO

SELECT *
FROM PROJETO AS P
WHERE P.Projnumero IN (2,3,10,20);
GO

SELECT *
FROM   PROJETO AS P
WHERE  P.Projnumero = 2 OR P.Projnumero = 3 OR P.Projnumero = 10 OR P.Projnumero = 20;
GO

SELECT COUNT(F.Pnome), F.Dnr
FROM FUNCIONARIO AS F
GROUP BY F.Dnr;

-- 13) salário médio por departamento, mostrando só os departamentos com mais de 2 funcionários?
SELECT COUNT(F.Pnome) AS Funcionarios, AVG(F.Salario) as Salario ,F.Dnr
FROM FUNCIONARIO AS F
WHERE F.Dnr IS NOT NULL
GROUP BY F.Dnr
HAVING COUNT(*) > 2

-- 16. escreva uma consulta que filtre funcionários com salário acima de 20000 (antes de agrupar) **e** mostre só departamentos com mais de 3 desses funcionários (depois de agrupar).

SELECT SUM (F.Salario), F.Dnr
FROM FUNCIONARIO AS F
WHERE F.Salario > 20000
GROUP BY F.Dnr
HAVING COUNT(*) > 3;

-- JOINS
--17. Liste nome do funcionário e nome do departamento em que ele trabalha.
SELECT F.Pnome,F.Dnr, D.Dnome, D.Dnumero
FROM FUNCIONARIO AS F
INNER JOIN DEPARTAMENTO AS D ON D.Dnumero = F.Dnr
ORDER BY D.Dnome;

-- 18. Liste o nome dos funcionários que estão trabalhando no projeto "ProdutoX", junto com as horas trabalhadas.
SELECT f.Pnome, T.Horas, p.Projnome
FROM FUNCIONARIO AS F
INNER JOIN TRABALHA_EM AS T ON F.Cpf = T.Fcpf
INNER JOIN PROJETO AS P ON P.Projnumero = T.Pnr
INNER JOIN DEPARTAMENTO as D ON D.Dnumero = P.Dnum
WHERE P.Projnome = 'ProdutoX'

USE EMPRESA;
-- EXEC sp_help 'FUNCIONARIO';
EXEC sp_fkeys 'FUNCIONARIO';

-- 20. Liste os departamentos que não têm nenhum funcionário.
SELECT COUNT(F.Cpf) AS Funcionarios, D.Dnome
FROM DEPARTAMENTO AS D
LEFT JOIN FUNCIONARIO AS F ON D.Dnumero = F.Dnr
GROUP BY D.Dnome
ORDER BY COUNT(F.Cpf)

-- 21. Liste cada funcionário junto com o nome do seu supervisor (mesma tabela, dos dois lados).
SELECT f.Pnome, s.Cpf_supervisor as SCpf, S.Pnome
FROM FUNCIONARIO AS F
LEFT JOIN FUNCIONARIO AS S ON F.Cpf = s.Cpf_supervisor

-- 24. Liste, numa única lista, o nome e a data de nascimento de todos os funcionários e de todos os dependentes (sem duplicar linhas idênticas).
SELECT F.Pnome, F.Datanasc
FROM FUNCIONARIO AS F

UNION

SELECT D.Nome_dependente, D.Datanasc
FROM DEPENDENTE AS D

--25. Liste os CPFs de funcionários que aparecem tanto na tabela FUNCIONARIO quanto na tabela TRABALHA_EM (ou seja, que de fato têm alguma alocação em projeto).
SELECT F.Cpf
FROM FUNCIONARIO AS F

INTERSECT 

SELECT T.Fcpf
FROM TRABALHA_EM AS T

--26. Liste os funcionários que ganham mais que a média salarial geral da empresa (subconsulta escalar).
SELECT F.Pnome, F.Salario
FROM FUNCIONARIO AS F
WHERE F.Salario > (SELECT AVG(F.Salario)
FROM   FUNCIONARIO AS F);

--27. Liste os nomes dos funcionários que trabalham em algum dos projetos que têm mais de (mudei para 50 horas) 100 horas registradas ao todo (isso exige uma subconsulta com `GROUP BY`/`HAVING` dentro do `IN`).
SELECT F.Pnome, F.Dnr
FROM FUNCIONARIO AS F
WHERE F.Cpf IN (
    SELECT T.Fcpf
    FROM   TRABALHA_EM AS T
    WHERE  T.Pnr IN (
                -- proj 1, 10, 30
                 SELECT   T2.Pnr
                 FROM     TRABALHA_EM AS T2
                 GROUP BY T2.Pnr
                 HAVING   SUM(T2.Horas) > 50
                 )
);


--## Bloco 6 — Variáveis, IF/CASE/WHILE 


