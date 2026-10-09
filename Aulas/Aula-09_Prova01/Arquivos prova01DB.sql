USE FACULDADE_2;
GO

-- 7 NOME DOS ALUNOS EM "Banco de dados I"
SELECT A.Nome AS NOME, D.Nome_disciplina, T.Semestre,H.Nota,T.Ano, T.Identificacao_turma
FROM ALUNO AS A -- deveria ser historico escolar
INNER JOIN DISCIPLINA AS D ON D.Departamento = A.Curso -- o primeiro deveria ser Disciplina ligada a turma
INNER JOIN TURMA AS T ON T.Numero_disciplina = D.Numero_disciplina
INNER JOIN HISTORICO_ESCOLAR AS H ON H.Identificacao_turma = T.Identificacao_turma -- professor ligou aluno a historico, não vi isso antes
WHERE D.Nome_disciplina = 'Banco de Dados I'
ORDER BY T.Ano, H.Nota;
GO

-- 8 ALUNOS REPROVADOS POR FREQ
SELECT A.Nome, D.Nome_disciplina, T.Semestre, T.Ano, H.Nota, H.Frequencia
FROM ALUNO AS A
INNER JOIN HISTORICO_ESCOLAR AS H ON H.Numero_aluno = A.Numero_aluno
INNER JOIN TURMA AS T ON T.Identificacao_turma = H.Identificacao_turma
INNER JOIN DISCIPLINA AS D ON D.Numero_disciplina = T.Numero_disciplina
WHERE H.Frequencia < 75 OR H.Frequencia IS NULL
ORDER BY H.Frequencia;
GO

-- 9 Listar todas as turmas e qtd de alunos matriculados
SELECT T.Identificacao_turma, D.Nome_disciplina, T.Semestre, T.Ano, COUNT(A.Nome)
FROM ALUNO AS A
FULL JOIN HISTORICO_ESCOLAR AS H ON H.Numero_aluno = A.Numero_aluno
FULL JOIN TURMA AS T ON T.Identificacao_turma = H.Identificacao_turma
FULL JOIN DISCIPLINA AS D ON D.Numero_disciplina = T.Numero_disciplina
GROUP BY T.Identificacao_turma, D.Nome_disciplina, T.Semestre, T.Ano
ORDER BY T.Identificacao_turma
GO


--10 Criar função escalar que receba a nota e a frequencia
CREATE OR ALTER FUNCTION fn_SituacaoAluno(@nota decimal(4,4), @freq DECIMAL(4,4))
RETURNS VARCHAR(30)
AS
BEGIN
DECLARE @situacao VARCHAR(30);
	IF(@freq IS NULL OR @nota IS NULL)
		BEGIN
			SET @situacao = 'Em andamento';
			RETURN @situacao
		END;
	ELSE IF (@freq > 74.0)
			BEGIN
				IF(@nota >= 7)
					BEGIN
						SET @situacao = 'APROVADO';
						RETURN @situacao
					END;
				ELSE IF(@nota > 5 OR @nota < 6.99)
					BEGIN
						SET @situacao = 'EM RECUPERAÇAO';
						RETURN @situacao
					END;
				ELSE
					BEGIN
						SET @situacao = 'Reprovado por nota';
						RETURN @situacao
					END;
			END;
	ELSE
		BEGIN
			SET @situacao = 'REPROVADO POR FREQUENCIA';
			RETURN @situacao
		END;
END
GO


SELECT A.Nome, D.Nome_disciplina, H.Nota, H.Frequencia, dbo.fn_SituacaoAluno(H.Nota, H.Frequencia)
FROM ALUNO AS A
INNER JOIN HISTORICO_ESCOLAR AS H ON H.Numero_aluno = A.Numero_aluno
INNER JOIN TURMA AS T ON T.Identificacao_turma = H.Identificacao_turma
INNER JOIN DISCIPLINA AS D ON D.Numero_disciplina = D.Numero_disciplina;

GO


--12 sp
CREATE OR ALTER PROCEDURE usp_ListarAlunosPorCurso (@sigla nvarchar(5))
AS
BEGIN
	DECLARE @TOTALCC INT = (
	SELECT COUNT(A.Curso)
	FROM ALUNO AS A
	WHERE A.Curso = @sigla
	GROUP BY A.Curso
	)
	SELECT A.Nome, A.Curso, @TOTALCC AS 'TOTAL DE ALUNOS NO CURSO'
	FROM ALUNO AS A
	WHERE A.Curso = @sigla
	ORDER BY A.Nome
END;
GO

EXEC usp_ListarAlunosPorCurso 'CC';
GO
-- 13  SP CADASTRAR DISCIPLINA
CREATE OR ALTER PROCEDURE usp_CadastrarDisciplina(@codigo nvarchar(6), @nome VARCHAR(30), @creditos int, @departamento nvarchar(5))
AS
BEGIN
	IF EXISTS(SELECT 1 FROM DISCIPLINA AS D WHERE D.Numero_disciplina = @codigo)
		BEGIN
			PRINT 'MESMO CÓDIGO DE DISCIPLINA'
			RETURN;
		END;
	ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM DISCIPLINA AS D WHERE D.Nome_disciplina = @nome)
				BEGIN
					PRINT 'DISCIPLINA JÁ EXISTE';
					RETURN;
				END;
			ELSE IF (@creditos <= 0)
				BEGIN
					PRINT 'QUANTIDADE INVÁLIDA';
				END;
			ELSE 
				BEGIN
					INSERT INTO DISCIPLINA(Numero_disciplina, Nome_disciplina, Creditos, Departamento) VALUES (@codigo, @nome, @creditos, @departamento);
					PRINT 'Valores inseridos';
					RETURN;
				END;
		END;
END;
GO


EXEC usp_CadastrarDisciplina'cc102', 'teste', 4, 'CC';


SELECT * FROM DISCIPLINA

	
	
	
	
	