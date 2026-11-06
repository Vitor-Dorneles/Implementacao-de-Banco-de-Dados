USE EMPRESA_2026
GO

-- VIEW: tabela virtual; guarda só o SELECT, os dados vêm das tabelas a cada uso
-- CREATE OR ALTER: cria ou substitui a view (ALTER VIEW só altera, DROP VIEW apaga)
CREATE OR ALTER VIEW vw_rh_funcionario_dpt
AS
SELECT
    -- coluna calculada precisa de apelido; Minicial + '. ' vira NULL quando não há inicial,
    -- e o CONCAT trata NULL como texto vazio (evita 'Ana . Souza')
    CONCAT(F.Pnome, ' ', F.Minicial + '. ', F.Unome) AS 'NOME',
    -- DATEDIFF(YEAR) só conta viradas de ano: desconta 1 se o aniversário deste ano ainda não chegou
    DATEDIFF(YEAR, F.Datanasc, GETDATE())
        - IIF(DATEADD(YEAR, DATEDIFF(YEAR, F.Datanasc, GETDATE()), F.Datanasc) > GETDATE(), 1, 0) AS 'IDADE',
    F.Endereco AS 'Endereço',
    F.Data_Admissao as 'Admissão',
    D.Dnome as 'Departamento'
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero;
GO

-- a view é usada como uma tabela: WHERE e ORDER BY ficam aqui fora
-- (dentro da view, ORDER BY só é aceito com TOP)
SELECT *
FROM vw_rh_funcionario_dpt
ORDER BY NOME;

SELECT *
FROM vw_rh_funcionario_dpt
WHERE Departamento = 'Matriz';
GO
