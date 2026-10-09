USE FACULDADE_2;
GO

-- 9
SELECT T.Identificacao_turma, D.Nome_disciplina, T.Semestre, T.Ano,
COUNT(H.Numero_aluno)
FROM TURMA AS T 
LEFT JOIN HISTORICO_ESCOLAR AS H
ON T.Identificacao_turma = H.Identificacao_turma
JOIN DISCIPLINA AS D
ON D.Numero_disciplina = T.Numero_disciplina
GROUP BY
    T.Identificacao_turma,
    D.Nome_disciplina,
    T.Semestre,
    T.Ano
GO
-- 11
CREATE OR ALTER FUNCTION fn_ConverterNotaConceito (@nota DECIMAL(4,2))
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @conceito VARCHAR(10);
    IF @nota is NULL
        SET @conceito = 'SEM NOTA';
    ELSE IF @nota >=9
        SET @conceito = 'A';
    ELSE IF @nota >= 7
        SET @conceito = 'B';
    ELSE IF @nota >= 5
        SET @conceito = 'C';
    ELSE
        SET @conceito = 'D';
    RETURN @conceito;
END
GO

SELECT dbo.fn_ConverterNotaConceito(H.Nota) AS 'Conceito'
FROM HISTORICO_ESCOLAR AS H

--12
GO
CREATE OR ALTER PROCEDURE usp_ListarAluno
    @curso VARCHAR(5)
AS
BEGIN
    SELECT
        A.Numero_aluno,
        A.Nome        
    FROM ALUNO AS A
    WHERE A.Curso = @curso;
END
GO
EXEC dbo.usp_ListarAluno 'CC'
GO
--13
