// Data: 18/09/2026
# PROVA
- 4 a 5 questões de marcar sobre as cláusulas
- em torno de 2 a 3 questões de montar consultas, simples com regras de montar tabelas "me liste as editoras com nenhum livro atrelado a elas"
- atenção com as funções, declare e questões realizadas em lista de exercícios
- stored procedure = última aula
- dicas:
  - fracionar os problemas para serem resolvidos

# Revisão
## Select
ordem de escrita
```sql
SELECT nome_coluna **5º** escolhe/calcula a saida
FROM tabela AS t  **1º** a ser executada pelo banco
JOIN outra_tabela ON condição que conecta **1º** a ser executada, fonte de dados junto do 'from'
WHERE filtro da linha **2º** a ser executada
  -- WHERE não aceita função de agregação, ele roda antes de formarem grupos 
GROUP BY agrupar por coluna **3º** a ser executada
HAVING condição_do_grupo **4º** filtro de grupos
ORDER BY ordenar por coluna **6º** só ordena o resultado
```

### Funções de agregação
```sql
SELECT P.projnome, AVG(T.horas) as media_horas **3º**
FROM TRABALHA_EM AS T **1º**
JOIN PROJETO AS P ON T.pnr(projNumero) = P.projnumero 1º
GROUP BY P.projnome **2º**
ORDER BY media_horas DESC(decrescente); **4º**
```

### JOINS
De onde vem as linhas e como se relacionam 'ON'

Relação entre tabelas é inner JOIN
  ```sql
  SELECT
  FROM FUNCIONARIO AS F
  INNER JOIN DEPARTAMENTO AS D ON F.dnr(departamentoNumero) = D.dnumero (departamentoNum)
  ```
O que não tem em uma é LEFT JOIN
  ```sql
  -- Departamentos sem funcionário
  SELECT *
  FROM FUNCIONARIO AS F
  LEFT JOIN DEPARTAMENTO AS D ON F.dnr = D.dnumero
  WHERE F.cpf IS NULL;
  ```

### SubQueries
Selects aninhados
```sql
SELECT F.pnome, F.salario
FROM FUNCIONARIO AS F
WHERE F.salario > (SELECT AVG(salario) FROM FUNCIONARIO)
```

### Variáveis
Servem para reaproveitarmos valores, ao invés de ficar fazendo várias consultas iguais
```sql
DECLARE @valor INT;
SET @valor = 10;

DECLARE @nome VARCHAR(50), @numero INT;

-- Atribuindo valor a partir de uma consulta
DECLARE @menor_salario DECIMAL (10,2);
SELECT @menor_salario = MIN(salario) FROM FUNCIONARIO;
```

## Funções
Sempre retornam um valor obrigatóriamente, podemos chamar elas dentro de SELECT, WHERE

### Função Escalar
Retorna um valor único, usar quando o resultado é um texto por linha (dobro, idade)
```sql
CREATE OR ALTER FUNCTION fn_dobro (@numero DECIMAL(10,2)) -- passamos uma variavel de numero
RETURNS DECIMAL (10,2) --retorna um numero decimal
AS 
BEGIN -- Estrutura padrão abrindo e fechando
    RETURN @numero *2; --multiplicado por dois
END
GO -- T-SQL Fechando o bloco

-- chamando a função
SELECT F.pnome, F.salario, dbo.fn_dobro(salario) AS dobro
FROM FUNCIONARIO AS F
```

### Função INLINE
retorna uma tabela em uma única consulta, quando dá pra escrever como um Select só, uma consulta mais simples
```sql
CREATE FUNCTION fn_funcionario_dpt (@nome_dpt VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT F.pnome, F.unome
    FROM FUNCIONARIO AS F
    JOIN DEPARTAMENTO AS D ON F.dnr = D.dnumero
    WHERE D.dnome = @nome_dpt
);
GO

-- Chamada
SELECT * FROM dbo.fn_funcionario_dpt('Pesquisa');
```