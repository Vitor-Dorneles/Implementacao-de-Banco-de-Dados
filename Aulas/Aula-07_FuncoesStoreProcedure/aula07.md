// Data: 11/09/2026
## Revisando a última aula
### Declaração de Variáveis
```sql
DECLARE @nome VARCHAR, @numero INT;
SET @numero = 10;
----------------------------------------
SELECT @nome = P.nome
FROM PESSOAS as P
WHERE ID = 10
----------------------------------------
IF (condição) -- A>B OR B = C
  beging
    -- bloco de código
  end
ELSE IF (condição)
ELSE
----------------------------------------
IIF (condição, "Verdadeiro", "Falso")
----------------------------------------
CASE
  WHEN condição THEN "_____"
  WHEN condição THEN "_____"
  ELSE
END
-----------------------------------------
WHILE condição
  Beging
  End

```
## FUNÇÕES
- As funções no SQL Server permitem encapsular lógicas de processamento que podem ser reutilizadas em consultas. Diferente das Stored Procedures, elas retornam obrigatoriamente um valor (escalar ou tabela) e podem ser usadas diretamente em instruções SELECT, WHERE,etc.
```SQL
-- FUNÇÕES: tipo de retorno, nome e parâmetros 

-- CRIANDO UMA FUNÇÃO ESCALAR 
CREATE OR ALTER FUNCTION fn_dobro (@Numero DECIMAL (10,2))
RETURNS DECIMAL (10,2)
AS
BEGIN
	RETURN @Numero * 2
END
GO;

SELECT dbo.fn_dobro(250);

-- DOBRO DO SALÁRIO DA MARIA 
SELECT
	Pnome,
	Unome,
	F.Salario,
	dbo.fn_dobro(F.Salario) AS 'Dobro'
FROM FUNCIONARIO AS F
WHERE F.Pnome = 'Maria';

-- DOBRO DO SALÁRIO DE TODOS OS FUNCIONÁRIOS
SELECT
	Pnome,
	Unome,
	F.Salario,
	dbo.fn_dobro(F.Salario) AS 'Dobro'
FROM FUNCIONARIO AS F;

-- ENCONTRANDO QUEM RECEBE MAIS QUE O DOBRO DO SALÁRIO DE QUEM MENOS RECEBE 
DECLARE @menor_salario DECIMAL (10,2)
SELECT @menor_salario = MIN (Salario)
FROM FUNCIONARIO
SELECT 
	Pnome,
	Unome,
	F.Salario
FROM FUNCIONARIO AS F
WHERE F.Salario > dbo.fn_dobro (@menor_salario);
GO

-- ENCONTRANDO A IDADE DOS FUNCIONÁRIOS NO BANCO
CREATE FUNCTION fn_calcula_idade(@data_nasc DATE)
RETURNS INT 
AS
BEGIN
	DECLARE @idade INT;
	SET @idade = DATEDIFF(YEAR, @data_nasc, GETDATE())
	IF(MONTH(@data_nasc) > MONTH (GETDATE()))
		OR (MONTH(@data_nasc) = MONTH (GETDATE()) AND
			DAY(@data_nasc) > DAY (GETDATE()))
		SET @idade = @idade - 1;
	RETURN @idade;
END;
GO

--IDADE DOS DEPENDENTES 
SELECT 
	D.Nome_dependente,
	CONVERT (VARCHAR, D.Datanasc, 103) AS 'DATA',
	dbo.fn_calcula_idade(D.Datanasc) AS 'IDADE'
FROM DEPENDENTE AS D;

--IDADE DOS FUNCIONÁRIOS
SELECT 
	F.Pnome,
	CONVERT (VARCHAR, F.Datanasc, 103) AS 'DATA NASC',
	dbo.fn_calcula_idade(F.Datanasc) AS 'IDADE'
FROM FUNCIONARIO AS F;
GO

-- FUNÇÃO INLINE: retornando todos os funcionários de um determinado departamento
CREATE FUNCTION fn_funcionario_dpt(@nome_dpt VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
	SELECT 
		F.Pnome,
		F.Unome
	FROM FUNCIONARIO AS F 
	JOIN DEPARTAMENTO AS D
	ON F.Dnr = D.Dnumero
	WHERE D.Dnome = @nome_dpt
);
GO;

SELECT * FROM dbo.fn_funcionario_dpt('Pesquisa');
GO;

-- FUNÇÕES MULTI-STATEMENT: criar uma função que retorna nome completo dos funcionários e o valor anual, com férias e décimo terceiro
CREATE FUNCTION fn_salarioAnual()
RETURNS @salAno TABLE
(
	nome_comp VARCHAR (100),
	salario DECIMAL (10,2),
	salario_anual DECIMAL (10,2)
)
AS 
BEGIN 
	INSERT INTO @salAno
	SELECT 
		CONCAT(F.Pnome, ' ', F.Minicial, ' ', F.Unome),
		f.Salario,
		f.Salario * 13 + (f.Salario * 0.3)
	FROM FUNCIONARIO AS F;
	RETURN;
END
GO

SELECT * FROM dbo.fn_salarioAnual();
```
## STORED PROCEDURE
- São lotes (batches) de declarações SQL que podem ser executados como uma subrotina.
- Permitem centralizar a lógica de acesso aos dados em único local, facilitando a manutenção e otimização de código.
- Também é possível ajustar permissões de acesso aos usuários, definindo quem pode ou não executá-las
```SQL
-- STORED PROCEDURE
CREATE PROCEDURE sp_exibe_meu_nome
AS 
BEGIN
	PRINT 'Maria Antônia';
END
GO

EXEC sp_exibe_meu_nome;
GO

--FAZENDO O AUMENTO DO SÁLARIO DOS FUNCIONARIOS
CREATE OR ALTER PROCEDURE sp_aumento(
@porcentagem DECIMAL(3,1),
@cpf CHAR (11)
)
AS 
BEGIN
	UPDATE FUNCIONARIO
	SET Salario = Salario * (1+(@porcentagem/100))
	WHERE  cpf = @cpf
END;
GO

EXEC dbo.sp_aumento @porcentagem = 5, @cpf = '98765432300';
SELECT * FROM FUNCIONARIO;
	
SELECT COUNT(*) FROM FUNCIONARIO

EXEC sp_help sp_aumento;
GO

-- PROCEDURE CRIPTROGRAFADO 
CREATE PROCEDURE sp_funcionarios
WITH ENCRYPTION 
AS
SELECT * FROM FUNCIONARIO;
GO
EXEC sp_help sp_fuuncionarios;
GO

-- PROCEDURE QUE INSERE UM NOVO DEPARTAMENTO NO BANCO COM SUA RESPECTIVA LOCALIDADE
CREATE OR ALTER PROCEDURE sp_add_dpt_loc (
	@dpt_nome VARCHAR (50),
	@dpt_numero INT,
	@local VARCHAR (50))
AS
BEGIN 
	IF EXISTS ( SELECT 1 FROM DEPARTAMENTO
				WHERE Dnome = @dpt_nome)
		BEGIN 
			PRINT 'JÁ EXISTO:   ' + @dpt_nome;
			RETURN;
		END
	ELSE 
		BEGIN 
			INSERT INTO DEPARTAMENTO (Dnome, Dnumero)
			VALUES (@dpt_nome, @dpt_numero);

			INSERT INTO LOCALIZACAO_DEP (Dnumero, Dlocal)
			VALUES (@dpt_numero, @local);
			PRINT 'DEPARTAMENTO INSERIDO:  ' + @dpt_nome;
			PRINT 'LOCAL INSERIDO:  ' + @local;
		END 
END
GO

EXEC sp_add_dpt_loc 'COMPRAS', 130, 'SANTA MARIA';

SELECT *
FROM DEPARTAMENTO AS D
JOIN LOCALIZACAO_DEP AS L
ON D.Dnumero = L.Dnumero;

```
### PROVA: pode trazer folha A4 com cola para prova, escrita dos dois lados, à mão
