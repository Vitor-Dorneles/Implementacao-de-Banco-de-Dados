// Data: 18/09/2026
# STORED PROCEDURE 
Crie um procedure que insira um novo funcionário mas antes verifique se já não existe um funcionário com o mesmo nome.

```sql

CREATE OR ALTER PROCEDURE sp_verifica_nome(
	@nome VARCHAR (15),
	@meio_ini CHAR (1),
	@sobrenome VARCHAR (15),
	@cpf CHAR (11))
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM FUNCIONARIO 
	WHERE @nome=Pnome AND @meio_ini=Minicial AND @sobrenome=Unome)
		PRINT 'Já existe alguém com o nome ' + @nome + ' ' + @meio_ini + ' ' + @sobrenome
	ELSE 
		INSERT INTO FUNCIONARIO(Pnome, Minicial, Unome, Cpf)
		VALUES (@nome, @meio_ini, @sobrenome, @cpf)
END 
GO

EXEC sp_verifica_nome 'Maria', 'Z','Oliveira', '98765432301';

SELECT * FROM FUNCIONARIO AS F 
```
## Valor Default
```sql
CREATE PROCEDURE sp_aumento (
	@cpf CHAR (11),
	@aumento DECIMAL (10,2) = 500)
AS 
BEGIN
	UPDATE FUNCIONARIO
	SET Salario = Salario + @aumento
	WHERE Cpf = @cpf
END 
EXEC sp_aumento '98765432100', 1000

SELECT * FROM FUNCIONARIO AS F	WHERE Cpf = '98765432100'
```
## OUTPUT *conteúdo que não caí na prova
```sql
-- OUTPUT: não cobrado em prova

CREATE PROCEDURE sp_duplica (@valor AS INT OUTPUT)
AS
SELECT @valor * 2
RETURN 
GO

DECLARE @numero AS INT = 15;
EXEC sp_duplica @numero OUTPUT;
PRINT @numero;
GO

-- crie um procedure para calcular o salário total de todos os funcionários de um determinado
-- departamento e retorna o valor por meio de um parâmetro de saída

DECLARE @salario_total DECIMAL (10,2)
SELECT  @salario_total = SUM(Salario)
FROM FUNCIONARIO AS F 
WHERE Dnr =	'2';
GO

CREATE OR ALTER PROCEDURE sp_calcula_soma_salario
	@dpt_id INT,
	@salario_total DECIMAL (10,2) OUTPUT
AS 
BEGIN 
	SELECT @salario_total = SUM(F.Salario)
	FROM FUNCIONARIO AS F
	WHERE Dnr = @dpt_id
	IF @salario_total IS NULL
		SET @salario_total = 0
END
GO

DECLARE @salario_total DECIMAL (10,2)
EXEC sp_calcula_soma_salario 5, @salario_total OUTPUT;
PRINT 'O SALÁRIO TOTAL É: ' + CAST (@salario_total AS VARCHAR(10));
```

