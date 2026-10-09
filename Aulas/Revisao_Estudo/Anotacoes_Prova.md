// Data: 24/09/2026
# Anotações para a prova — versão longa

Versão de estudo. O recorte que vai pro papel está em [[Cola_A4]].
Exercícios para treinar: [[Exercicios_Prova]].

Formato da prova, conforme a nota de aula:

- 4 a 5 questões de marcar sobre as cláusulas
- 2 a 3 questões de montar consultas ("me liste as editoras com nenhum livro
  atrelado a elas")
- atenção com funções, `DECLARE` e as questões das listas de exercícios
- stored procedure = última aula
- permitido levar folha A4 com cola, manuscrita, frente e verso

---

## 0. Roteiro de fracionamento — como atacar um enunciado

A dica do professor ("fracionar os problemas") vira um procedimento fixo.
Não comece escrevendo `SELECT`; comece marcando o enunciado.

**Para questão de montar consulta:**

1. **O que ele quer listar?** → essa tabela vai no `FROM`.
2. **Quais outros dados ele cita?** → cada um mora numa tabela → `JOIN`.
3. **Palavras de recorte** ("de", "com", "entre", "cujo") → `WHERE`.
4. **Palavras de agrupamento** ("por", "de cada", "quantos", "média",
   "total") → `GROUP BY` + função de agregação.
5. **Filtro sobre o grupo** ("que têm mais de 3", "com total acima de") →
   `HAVING`, nunca `WHERE`.
6. **"em ordem de"** → `ORDER BY`.
7. **"que não têm"** → `LEFT JOIN` + `IS NULL`.

**Para questão de função ou procedure:**

1. Escreva primeiro o `SELECT` solto que resolve o miolo, sem função nenhuma.
2. Confira que ele devolve o que você quer.
3. Só então embrulhe: decida o tipo de retorno, os parâmetros, e troque os
   valores fixos pelos `@parâmetros`.

Esse passo 1 é o fracionamento. Escrever `CREATE FUNCTION` direto é onde a
maioria trava, porque você está resolvendo duas coisas ao mesmo tempo: a
lógica da consulta e a forma da função.

**Se travar mesmo assim:** escreva em português numerado o que precisa
acontecer, linha a linha. Depois traduza cada linha para SQL.

---

## 1. Pegadinhas de marcar

As 4-5 questões de assinalar saem daqui. São distinções, não sintaxe.

### 1.1 Ordem de execução ≠ ordem de escrita

| Escrita | Execução | |
|---|---|---|
| `SELECT` | 5º | |
| `FROM` / `JOIN` | **1º** | de onde vêm as linhas |
| `WHERE` | 2º | filtra **linha**, antes de existir grupo |
| `GROUP BY` | 3º | forma os grupos |
| `HAVING` | 4º | filtra **grupo** |
| `ORDER BY` | **6º** | só ordena o que já saiu |

Consequências que caem em prova:

- `WHERE` **não aceita** função de agregação (`COUNT`, `SUM`, `AVG`...),
  porque roda antes de os grupos existirem.
- Apelido criado no `SELECT` **não pode** ser usado no `WHERE` (o `SELECT`
  ainda não rodou), **mas pode** no `ORDER BY` (que roda depois).

### 1.2 `WHERE` × `HAVING`

| | `WHERE` | `HAVING` |
|---|---|---|
| filtra | linha individual | grupo |
| quando | antes do `GROUP BY` | depois do `GROUP BY` |
| aceita agregação | não | sim |

"Departamentos com mais de 3 funcionários" → `HAVING COUNT(...) > 3`.
"Funcionários com salário acima de 3000" → `WHERE`.

### 1.3 Qual JOIN devolve o quê

| JOIN | devolve |
|---|---|
| `INNER` | só as linhas que casam nas duas |
| `LEFT` | tudo da tabela do `FROM` + o que casar da outra |
| `FULL` | tudo das duas, preenchendo com `NULL` |
| `CROSS` | produto cartesiano, todas as combinações |
| `SELF` | a tabela contra ela mesma, com dois apelidos |

**A regra do "não tem":** a tabela que você quer listar vai no `FROM`
(lado esquerdo), a outra entra por `LEFT JOIN`, e o `WHERE` testa `IS NULL`
numa coluna da tabela da direita. Use a **chave primária** da direita no
teste — se testar uma coluna que aceita nulo de verdade, o resultado sai
errado e parece certo.

Exemplo da aula (`Aula-04_JOINS/CONSULTAS_JOIN.SQL`):

```sql
-- Departamentos que não têm funcionários
SELECT *
FROM DEPARTAMENTO AS D
LEFT JOIN FUNCIONARIO AS F ON F.Dnr = D.Dnumero
WHERE F.Cpf IS NULL;
```

Vira molde: *"me liste os X sem nenhum Y"* → `FROM X LEFT JOIN Y ON ...
WHERE Y.<pk> IS NULL`.

### 1.4 Operadores de conjunto

| | faz | duplicatas |
|---|---|---|
| `UNION` | empilha as duas consultas | **remove** (age como `DISTINCT`) |
| `UNION ALL` | empilha as duas consultas | **mantém** todas |
| `INTERSECT` | só o que está nas duas | — |
| `EXCEPT` | primeiro **menos** segundo | — |

> Atenção: o comentário na linha 3 do `Aula-05_Variaveis/GroupBy.sql` diz
> que `UNION ALL` remove duplicidade. Está invertido — quem remove é o
> `UNION`.

Exigência comum das três: as duas consultas precisam ter o **mesmo número
de colunas**, na **mesma ordem**, com **tipos compatíveis**. E `EXCEPT` não
é comutativo: trocar a ordem dos selects muda o resultado.

### 1.5 Função × Stored Procedure

| | Função | Procedure |
|---|---|---|
| retorno | **obrigatório** | opcional |
| chamada | dentro de `SELECT`, `WHERE`, `FROM` | `EXEC` |
| `INSERT`/`UPDATE`/`DELETE` em tabela | **não pode** | pode |
| prefixo | precisa de `dbo.` | `EXEC` direto |

Essa é a distinção mais provável de virar questão de marcar, porque a
última aula foi procedure e a penúltima foi função.

### 1.6 Os três tipos de função

| tipo | `RETURNS` | tem `BEGIN/END`? | chamada |
|---|---|---|---|
| Escalar | um tipo (`INT`, `DECIMAL`...) | sim | `SELECT dbo.fn(x)` |
| Inline (tabela) | `TABLE` | **não** | `SELECT * FROM dbo.fn(x)` |
| Multi-statement | `@t TABLE (colunas)` | sim | `SELECT * FROM dbo.fn(x)` |

Escalar = um valor por linha (dobro, idade). Inline = um `SELECT` só,
parametrizado. Multi-statement = quando precisa montar a tabela em etapas.

### 1.7 Detalhes que derrubam

- `IS NULL` / `IS NOT NULL` — nunca `= NULL`.
- `BETWEEN a AND b` inclui os extremos.
- `LIKE '%texto%'` — `%` é qualquer coisa, `_` é um caractere só.
- `DISTINCT` tira linhas repetidas do resultado.
- `TOP n` vem logo depois do `SELECT`, e só faz sentido com `ORDER BY`.
- `GO` fecha o lote: **variável declarada antes do `GO` não existe depois
  dele**.

---

## 2. Sintaxe que engana

O que é difícil de lembrar na hora, com os exemplos da própria aula.

### 2.1 Variáveis

```sql
DECLARE @nome VARCHAR(100),
        @idade INT,
        @salario DECIMAL(10,2);

SET @idade = 21;                    -- valor fixo

SELECT @salario = F.Salario         -- valor vindo de consulta
FROM FUNCIONARIO AS F
WHERE F.Pnome = @nome;
```

Dois jeitos de atribuir: `SET` para valor literal, `SELECT @var =` quando
o valor vem de uma tabela. Declarar e já atribuir também vale:
`DECLARE @contador INT = 0;`

### 2.2 `PRINT` só aceita texto

```sql
PRINT 'Idade: ' + CAST(@idade AS VARCHAR(10));
```

Concatenar número direto dá erro de conversão. É o erro mais comum das
questões de `DECLARE`.

### 2.3 Datas

```sql
CONVERT(VARCHAR, D.Datanasc, 103)        -- data → texto dd/mm/aaaa
CONVERT(DATE, '15/08/1990', 103)         -- texto dd/mm/aaaa → data
DATEDIFF(YEAR, @data_nasc, GETDATE())    -- diferença em anos
YEAR(x)   MONTH(x)   DAY(x)   GETDATE()
```

O `103` é o código do formato brasileiro. Sem ele, o SQL Server tenta ler
`mm/dd/aaaa` e ou erra a data ou estoura.

### 2.4 `IF / ELSE`

```sql
IF (condição)
    BEGIN
        -- bloco
    END;
ELSE IF (condição)
    BEGIN
        -- bloco
    END;
ELSE
    BEGIN
        -- bloco
    END;
```

`BEGIN/END` é obrigatório quando o bloco tem mais de um comando. Com um
comando só, pode omitir — e é aí que se erra, porque o segundo comando
passa a rodar sempre.

### 2.5 `IIF` e `CASE` — condicional **dentro** do `SELECT`

```sql
SELECT F.Pnome,
       IIF(F.Salario < 20000, 'Baixo', 'Alto') AS 'Nivel Salarial'
FROM FUNCIONARIO AS F;

SELECT F.Pnome,
    CASE
        WHEN F.Salario <= 10000 THEN 'Baixo'
        WHEN F.Salario <= 30000 THEN 'Medio'
        ELSE 'Alto'
    END AS 'Nivel salarial'
FROM FUNCIONARIO AS F;
```

`CASE` **não** tem `BEGIN`, mas tem `END` obrigatório. `IF/ELSE` é
controle de fluxo (fora do `SELECT`); `IIF`/`CASE` é expressão (dentro
do `SELECT`). Confundir os dois é pegadinha clássica.

### 2.6 `WHILE`

```sql
DECLARE @contador INT = 0;

WHILE @contador < 10
BEGIN
    SET @contador = @contador + 1;
    IF @contador % 2 = 0
        CONTINUE;          -- pula para a próxima volta
    PRINT 'Contador: ' + CAST(@contador AS VARCHAR(3));
END
```

`BREAK` encerra o laço, `CONTINUE` pula para a próxima volta. Se o `SET`
que faz o contador avançar ficar depois de um `CONTINUE`, o laço não
termina nunca.

### 2.7 Função escalar

```sql
CREATE OR ALTER FUNCTION fn_nome (@param DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @param * 2;
END
GO

SELECT dbo.fn_nome(250);
```

### 2.8 Função inline (retorna tabela)

```sql
CREATE FUNCTION fn_nome (@param VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT ...
    FROM ...
    WHERE ... = @param
);
GO

SELECT * FROM dbo.fn_nome('Pesquisa');
```

Repare: **não tem `BEGIN/END`**, e o `RETURN` vem antes do parêntese.
É a forma que mais se erra por analogia com a escalar.

### 2.9 Função multi-statement

```sql
CREATE FUNCTION fn_nome ()
RETURNS @saida TABLE
(
    coluna1 VARCHAR(100),
    coluna2 DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @saida
    SELECT ...
    FROM ...;
    RETURN;
END
GO
```

Aqui você **declara a estrutura** da tabela de saída e depois a preenche
com `INSERT INTO @saida`. O `RETURN` final vai sozinho, sem valor.

### 2.10 Stored procedure

```sql
CREATE OR ALTER PROCEDURE sp_nome (
    @param1 VARCHAR(50),
    @param2 DECIMAL(10,2) = 500)      -- valor default
AS
BEGIN
    UPDATE FUNCIONARIO
    SET Salario = Salario + @param2
    WHERE ...
END
GO

EXEC sp_nome 'texto', 1000;
EXEC sp_nome @param1 = 'texto';        -- usa o default do @param2
```

### 2.11 `IF EXISTS` antes de inserir — padrão da última aula

```sql
CREATE OR ALTER PROCEDURE sp_nome (@x VARCHAR(50))
AS
BEGIN
    IF EXISTS (SELECT 1 FROM TABELA WHERE Coluna = @x)
        BEGIN
            PRINT 'Já existe: ' + @x;
            RETURN;
        END
    ELSE
        BEGIN
            INSERT INTO TABELA (Coluna) VALUES (@x);
            PRINT 'Inserido: ' + @x;
        END
END
GO
```

`SELECT 1` porque o `EXISTS` só quer saber se veio linha — não importa o
conteúdo. O `RETURN` sai da procedure na hora.

### 2.12 Não cai na prova

`OUTPUT` (parâmetro de saída) — a nota da Aula 08 diz explicitamente que
não é cobrado. Não gaste espaço do papel com isso.

---

## 3. Moldes das questões de montar consulta

Todos com exemplo do banco EMPRESA, que é o que foi usado em aula.

**Agrupar e contar:**

```sql
SELECT COUNT(F.Cpf) AS 'Quantidade', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D ON F.Dnr = D.Dnumero
GROUP BY D.Dnome
ORDER BY Quantidade;
```

**Agrupar e filtrar o grupo:**

```sql
GROUP BY D.Dnome
HAVING COUNT(F.Cpf) > 3;
```

**Três tabelas:**

```sql
FROM TRABALHA_EM AS T
INNER JOIN PROJETO AS P     ON T.Pnr  = P.Projnumero
INNER JOIN FUNCIONARIO AS F ON T.Fcpf = F.Cpf
```

Cada `JOIN` traz **seu próprio** `ON`. Esquecer um `ON` transforma a
consulta em produto cartesiano.

**A tabela contra ela mesma (self join):**

```sql
SELECT F.Pnome AS 'Funcionario', S.Unome AS 'Supervisor'
FROM FUNCIONARIO AS F
JOIN FUNCIONARIO AS S ON F.Cpf_supervisor = S.Cpf;
```

**Subconsulta escalar** (compara com um valor):

```sql
WHERE F.Salario > (SELECT AVG(Salario) FROM FUNCIONARIO)
```

**Subconsulta de lista** (compara com vários):

```sql
WHERE T.Pnr IN (SELECT Pnr FROM TRABALHA_EM)
```

---

## 4. Depois da prova

Registrar na nota da aula correspondente:

- `## Erro que cometi` — o que você entendeu errado, em uma linha.
- `?? pergunta :: resposta` — a pergunta que teria te destravado.
