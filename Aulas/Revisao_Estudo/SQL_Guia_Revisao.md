# Guia de Revisão — SQL (do básico ao visto na Aula 08)

> Documento de apoio, não é nota de aula. Feito para eu revisar sozinho: ler a
> sintaxe, tampar e tentar escrever de cabeça, só depois conferir.
>
> Schemas usados nos exemplos: `EMPRESA` (FUNCIONARIO, DEPARTAMENTO, PROJETO,
> TRABALHA_EM, DEPENDENTE, LOCALIZACAO_DEP) e `LIVRARIA` (LIVRO, AUTOR, EDITORA).

---

## 1. As quatro categorias de comando

SQL não é uma linguagem homogênea — cada comando pertence a uma categoria com
um objetivo diferente. Isso importa porque prova de marcar gosta de perguntar
"em qual categoria está o comando X".

| Categoria | Sigla | Objetivo | Comandos |
|---|---|---|---|
| Data Definition Language | DDL | Define/altera a **estrutura** (tabelas, colunas, chaves) | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| Data Manipulation Language | DML | Manipula os **dados** dentro da estrutura já existente | `INSERT`, `UPDATE`, `DELETE` |
| Data Query Language | DQL | Só **consulta**, não altera nada | `SELECT` |
| Data Control Language | DCL | Controla **permissões** de acesso | `GRANT`, `REVOKE` |

> Alguns autores colocam `SELECT` dentro do DML. Não existe consenso universal
> — se a questão cobrar isso, responda pela definição: DML **muda** dado, DQL
> só **lê**. `SELECT` só lê, então a divisão mais precisa é separá-lo.

`TRUNCATE` fica na DDL, não na DML, mesmo lidando com dados: ele reseta a
tabela inteira (remove todas as linhas e reinicia o auto-incremento) sem
possibilidade de `WHERE` — a lógica é mais próxima de "recriar a estrutura
vazia" do que de "apagar linhas selecionadas" (isso é o `DELETE`).

---

## 2. DDL — definindo estrutura

```sql
CREATE TABLE AUTOR (
    id_autor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50),
    nacionalidade VARCHAR(30),
    ano_nascimento INT
);

ALTER TABLE AUTOR ADD email VARCHAR(100);      -- adiciona coluna
ALTER TABLE AUTOR DROP COLUMN email;           -- remove coluna
ALTER TABLE AUTOR MODIFY nome VARCHAR(80);     -- muda tipo/tamanho (MySQL)

DROP TABLE AUTOR;      -- apaga a tabela inteira (estrutura + dados)
TRUNCATE TABLE AUTOR;  -- apaga todas as linhas, mantém a estrutura
```

**Quando usar cada um:** `CREATE` uma única vez, no início. `ALTER` quando a
estrutura precisa mudar depois que a tabela já existe e já tem dados (não dá
pra simplesmente recriar sem perder informação). `DROP` quando a tabela não
deve mais existir. `TRUNCATE` quando você quer "zerar" a tabela mantendo o
formato, mais rápido que `DELETE FROM tabela` porque não avalia linha por
linha.

---

## 3. DML — manipulando dados

```sql
INSERT INTO AUTOR (nome, nacionalidade, ano_nascimento)
VALUES ('Heryson', 'Brasileiro', 1939);

-- múltiplos registros de uma vez
INSERT INTO EDITORA (nome, cidade, site, ano_fundacao)
VALUES
    ('Companhia das Letras', 'São Paulo', 'www.cdl.br', 1986),
    ('Penguin', 'Londres', 'www.pg.uk', 1935);

UPDATE AUTOR
SET nacionalidade = 'Português'
WHERE id_autor = 3;

DELETE FROM AUTOR
WHERE id_autor = 3;
```

**Cuidado que cai em prova:** `UPDATE` e `DELETE` sem `WHERE` afetam **todas**
as linhas da tabela. Antes de rodar um `UPDATE`/`DELETE` de verdade, rode o
mesmo filtro com `SELECT` primeiro pra conferir quais linhas seriam pegas.

---

## 4. DQL — anatomia do SELECT

### 4.1 Ordem de escrita vs. ordem de execução

Você **escreve** nessa ordem:

```sql
SELECT colunas
FROM tabela
JOIN outra_tabela ON condição
WHERE condição_de_linha
GROUP BY coluna
HAVING condição_de_grupo
ORDER BY coluna;
```

O banco **executa** nessa ordem:

1. `FROM` / `JOIN` → monta a fonte de dados
2. `WHERE` → filtra linha por linha, antes de qualquer agrupamento
3. `GROUP BY` → agrupa o que sobrou
4. `HAVING` → filtra **grupos** (por isso pode usar `COUNT`, `SUM`, etc.)
5. `SELECT` → escolhe/calcula as colunas de saída
6. `ORDER BY` → ordena o resultado final

Essa diferença é o motivo de `WHERE` **não aceitar** função de agregação —
quando ele roda, os grupos ainda nem foram formados. Se precisar filtrar por
um valor agregado (`COUNT(*) > 3`, `AVG(salario) > 5000`), o filtro tem que
ser `HAVING`.

### 4.2 Filtros no WHERE

```sql
SELECT * FROM LIVRO WHERE titulo LIKE '%Dom%';     -- padrão de texto
SELECT * FROM FUNCIONARIO WHERE salario BETWEEN 30000 AND 45000;  -- faixa (inclusiva)
SELECT * FROM TRABALHA_EM WHERE pnr IN (2, 3, 10, 20);            -- lista de valores
SELECT * FROM FUNCIONARIO WHERE pnome <> 'Fernando';              -- diferente de
SELECT * FROM DEPARTAMENTO WHERE cpf_gerente IS NULL;             -- nulo (NUNCA use "= NULL")
SELECT * FROM FUNCIONARIO WHERE salario > 20000 AND dnr = 5;      -- combinando condições
```

`LIKE` usa curingas: `%` (zero ou mais caracteres) e `_` (exatamente um
caractere). `IS NULL` / `IS NOT NULL` é obrigatório para nulo — `= NULL` não
funciona porque `NULL` não é igual a nada, nem a si mesmo.

### 4.3 Funções de agregação + GROUP BY + HAVING

Agregação = resume várias linhas em um valor só.

```sql
COUNT(*)      -- quantidade de linhas
SUM(coluna)   -- soma
AVG(coluna)   -- média
MIN(coluna)   -- menor valor
MAX(coluna)   -- maior valor
```

```sql
-- Média de horas trabalhadas por projeto
SELECT P.projnome, AVG(T.horas) AS media_horas
FROM TRABALHA_EM AS T
JOIN PROJETO AS P ON T.pnr = P.projnumero
GROUP BY P.projnome
ORDER BY media_horas DESC;

-- Departamentos com mais de 3 funcionários ganhando acima de 20000
SELECT F.dnr, COUNT(*) AS qtd **5º**
FROM FUNCIONARIO AS F **1º**
WHERE F.salario > 20000 **2º**
GROUP BY F.dnr  **3º**
HAVING COUNT(*) > 3; **4º**
```

Regra prática: toda coluna do `SELECT` que **não** está dentro de uma função
de agregação precisa aparecer no `GROUP BY`. Se aparece uma coluna solta que
não é agregada e não está no `GROUP BY`, a consulta está errada (ou o banco
recusa, ou devolve um valor arbitrário, dependendo do SGBD).

---

## 5. JOINS — combinando tabelas

Regra geral: junção sempre define **de onde** vêm as linhas e **como** elas
se relacionam (`ON`).

```sql
-- INNER JOIN: só as linhas que casam nas duas tabelas
SELECT F.pnome, D.dnome
FROM FUNCIONARIO AS F
INNER JOIN DEPARTAMENTO AS D ON F.dnr = D.dnumero;

-- LEFT JOIN: todas as linhas da esquerda (FUNCIONARIO), mesmo sem par na direita
SELECT *
FROM FUNCIONARIO AS F
LEFT JOIN DEPARTAMENTO AS D ON F.dnr = D.dnumero;

-- Caso de uso clássico do LEFT JOIN: achar o que NÃO tem relação
-- "Departamentos sem funcionário" / "Editoras sem livro"
SELECT D.*
FROM DEPARTAMENTO AS D
LEFT JOIN FUNCIONARIO AS F ON F.dnr = D.dnumero
WHERE F.cpf IS NULL;   -- se não casou, o LEFT JOIN preenche com NULL

-- FULL JOIN: união dos dois lados, casado ou não (nem todo SGBD suporta direto)
SELECT *
FROM FUNCIONARIO AS F
FULL JOIN DEPARTAMENTO AS D ON F.dnr = D.dnumero
WHERE D.dnumero IS NULL OR F.cpf IS NULL;

-- CROSS JOIN: produto cartesiano, todas as combinações possíveis (sem ON)
SELECT F.pnome, P.projnome
FROM FUNCIONARIO AS F
CROSS JOIN PROJETO AS P;

-- SELF JOIN: tabela consultada contra ela mesma (ex: funcionário e seu supervisor)
SELECT F.pnome AS funcionario, S.unome AS supervisor
FROM FUNCIONARIO AS F
JOIN FUNCIONARIO AS S ON F.cpf_supervisor = S.cpf;
```

**Como decidir qual usar, na hora da prova:** leia o enunciado procurando a
palavra que indica ausência — "que NÃO têm", "sem nenhum", "que nunca" — isso
é sempre `LEFT JOIN` (da tabela que deve aparecer inteira) `+ WHERE
coluna_da_direita IS NULL`. Se o enunciado só pede o cruzamento de quem tem
relação nas duas pontas, é `INNER JOIN`.

> Isso resolve diretamente o exemplo do seu arquivo de prova: *"me liste as
> editoras com nenhum livro atrelado a elas"* → `LEFT JOIN` de EDITORA para
> LIVRO, filtrando `WHERE livro.id IS NULL`.

---

## 6. Operações de conjunto — UNION / INTERSECT / EXCEPT

Combinam o **resultado** de dois `SELECT`s (não tabelas — resultados). Exigem
o mesmo número de colunas, em tipos compatíveis, na mesma ordem.

```sql
-- UNION: junta as duas listas, remove duplicatas
SELECT pnome AS nome, sexo, datanasc FROM FUNCIONARIO
UNION
SELECT nome_dependente AS nome, sexo, datanasc FROM DEPENDENTE;

-- UNION ALL: igual, mas mantém duplicatas (mais rápido, não filtra)

-- INTERSECT: só o que aparece nos dois SELECTs
SELECT cpf FROM FUNCIONARIO
INTERSECT
SELECT fcpf FROM TRABALHA_EM;

-- EXCEPT: primeiro SELECT menos o segundo (o que só existe no primeiro)
SELECT cpf FROM FUNCIONARIO
EXCEPT
SELECT fcpf FROM TRABALHA_EM;
```

---

## 7. Subconsultas (subqueries)

Um `SELECT` dentro de outro. Serve para responder "compare com um valor que eu
ainda não sei, ele vem de outra consulta".

```sql
-- Funcionários que trabalham em algum projeto (a lista de PNR vem de outra consulta)
SELECT F.pnome
FROM FUNCIONARIO AS F
WHERE F.cpf IN (
    SELECT fcpf FROM TRABALHA_EM
);

-- Quem ganha mais que a média geral
SELECT pnome, salario
FROM FUNCIONARIO
WHERE salario > (SELECT AVG(salario) FROM FUNCIONARIO);
```

Diferença de uso: `IN` quando a subconsulta devolve **uma lista** de valores;
`=`, `>`, `<` quando a subconsulta devolve **um valor só** (ex: `AVG`, `MIN`,
`MAX` sem `GROUP BY`).

---

## 8. Variáveis (T-SQL / SQL Server)

> Isso é específico de SQL Server — não existe `DECLARE @var` em MySQL puro
> (no MySQL seria `SET @var = valor;`, sem declarar tipo antes).

```sql
DECLARE @valor INT;         -- inicializa como NULL por padrão
SET @valor = 10;

DECLARE @nome VARCHAR(50), @numero INT;   -- múltiplas na mesma linha

-- atribuindo valor a partir de uma consulta
DECLARE @menor_salario DECIMAL(10,2);
SELECT @menor_salario = MIN(salario) FROM FUNCIONARIO;
```

Use variável quando um valor precisa ser **calculado uma vez** e
**reaproveitado** várias vezes na mesma lógica (ex: o menor salário, pra
comparar contra vários funcionários depois), em vez de repetir a subconsulta
toda hora.

---

## 9. Estruturas de controle

```sql
-- IF/ELSE
IF (condição)
BEGIN
    -- bloco
END
ELSE IF (condição)
BEGIN
    -- bloco
END
ELSE
BEGIN
    -- bloco
END

-- IIF: versão compacta de IF/ELSE que retorna um valor, usada dentro de SELECT
SELECT pnome, IIF(salario < 20000, 'Baixo', 'Alto') AS nivel_salarial
FROM FUNCIONARIO;

-- CASE: várias condições, tipo um switch — também usado dentro de SELECT
SELECT
    pnome,
    salario,
    CASE
        WHEN salario <= 10000 THEN 'Baixo'
        WHEN salario <= 30000 THEN 'Médio'
        WHEN salario > 30000 THEN 'Alto'
        ELSE 'ERRO'
    END AS nivel_salarial
FROM FUNCIONARIO;

-- WHILE
WHILE (condição)
BEGIN
    -- bloco, precisa alterar algo que muda a condição, senão é loop infinito
END
```

**Quando usar IIF vs CASE:** `IIF` só resolve **uma** condição (verdadeiro/
falso). Assim que tiver mais de duas alternativas (baixo/médio/alto), é
`CASE`.

---

## 10. Funções definidas pelo usuário (User-Defined Functions)

Sempre **retornam um valor obrigatoriamente** (diferença chave em relação a
Stored Procedure) e podem ser chamadas dentro de `SELECT`, `WHERE`, etc.

### 10.1 Função escalar — retorna um valor único

```sql
CREATE OR ALTER FUNCTION fn_dobro (@numero DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @numero * 2;
END
GO

SELECT pnome, salario, dbo.fn_dobro(salario) AS dobro
FROM FUNCIONARIO;
```

### 10.2 Função inline table-valued — retorna uma tabela, em uma única consulta

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

SELECT * FROM dbo.fn_funcionario_dpt('Pesquisa');
```

### 10.3 Função multi-statement table-valued — retorna tabela, com lógica em vários passos

```sql
CREATE FUNCTION fn_salario_anual()
RETURNS @salAno TABLE (
    nome_comp VARCHAR(100),
    salario DECIMAL(10,2),
    salario_anual DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @salAno
    SELECT CONCAT(pnome, ' ', unome), salario, salario * 13 + (salario * 0.3)
    FROM FUNCIONARIO;
    RETURN;
END
GO

SELECT * FROM dbo.fn_salario_anual();
```

**Quando usar qual:** escalar quando o resultado é **um número/texto por
linha** (dobro, idade calculada). Inline table-valued quando dá pra escrever
como um `SELECT` só. Multi-statement quando a lógica precisa de passos
intermediários (variáveis, `IF`, inserções acumuladas) antes de montar a
tabela de retorno.

---

## 11. Stored Procedures

Não retornam valor obrigatoriamente (podem, via `OUTPUT`, mas isso é opcional
— a diferença central pra função é essa). Servem para **agrupar uma sequência
de operações** (inclusive `INSERT`/`UPDATE`/`DELETE`, que função não pode
fazer) sob um nome só, reutilizável e com permissão controlável.

### 11.1 Básica

```sql
CREATE PROCEDURE sp_exibe_meu_nome
AS
BEGIN
    PRINT 'Maria Antônia';
END
GO

EXEC sp_exibe_meu_nome;
```

### 11.2 Com parâmetros

```sql
CREATE OR ALTER PROCEDURE sp_aumento (
    @porcentagem DECIMAL(3,1),
    @cpf CHAR(11)
)
AS
BEGIN
    UPDATE FUNCIONARIO
    SET salario = salario * (1 + (@porcentagem / 100))
    WHERE cpf = @cpf;
END
GO

EXEC sp_aumento @porcentagem = 5, @cpf = '98765432300';
```

### 11.3 Parâmetro com valor default

```sql
CREATE PROCEDURE sp_aumento_fixo (
    @cpf CHAR(11),
    @aumento DECIMAL(10,2) = 500   -- usado se não for passado na chamada
)
AS
BEGIN
    UPDATE FUNCIONARIO
    SET salario = salario + @aumento
    WHERE cpf = @cpf;
END
GO

EXEC sp_aumento_fixo '98765432100';         -- usa 500
EXEC sp_aumento_fixo '98765432100', 1000;   -- usa 1000
```

### 11.4 Verificando existência antes de inserir (padrão comum de prova)

```sql
CREATE OR ALTER PROCEDURE sp_add_dpt_loc (
    @dpt_nome VARCHAR(50),
    @dpt_numero INT,
    @local VARCHAR(50)
)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM DEPARTAMENTO WHERE dnome = @dpt_nome)
    BEGIN
        PRINT 'JÁ EXISTE: ' + @dpt_nome;
        RETURN;
    END
    ELSE
    BEGIN
        INSERT INTO DEPARTAMENTO (dnome, dnumero) VALUES (@dpt_nome, @dpt_numero);
        INSERT INTO LOCALIZACAO_DEP (dnumero, dlocal) VALUES (@dpt_numero, @local);
        PRINT 'DEPARTAMENTO INSERIDO: ' + @dpt_nome;
    END
END
GO
```

`EXISTS (SELECT 1 FROM ...)` é o padrão pra checar "já tem isso?" sem
precisar trazer a linha inteira — o `1` é só um valor qualquer, o que importa
é se a subconsulta devolve alguma linha ou nenhuma.

### 11.5 Parâmetro OUTPUT *(marcado como fora da prova na Aula 08, mas fica registrado)*

```sql
CREATE OR ALTER PROCEDURE sp_calcula_soma_salario (
    @dpt_id INT,
    @salario_total DECIMAL(10,2) OUTPUT
)
AS
BEGIN
    SELECT @salario_total = SUM(salario) FROM FUNCIONARIO WHERE dnr = @dpt_id;
    IF @salario_total IS NULL SET @salario_total = 0;
END
GO

DECLARE @total DECIMAL(10,2);
EXEC sp_calcula_soma_salario 5, @total OUTPUT;
PRINT 'Total: ' + CAST(@total AS VARCHAR(10));
```

Serve pra quando a procedure precisa **devolver um valor calculado** pro
código que chamou, sem usar `RETURN` (que em procedure só devolve status de
erro/inteiro, não o resultado do cálculo).

---

## 12. Função vs Stored Procedure — tabela de decisão

| | Função | Stored Procedure |
|---|---|---|
| Retorno | Obrigatório (escalar ou tabela) | Opcional (via `OUTPUT` ou nenhum) |
| Pode usar dentro de `SELECT`/`WHERE` | Sim | Não |
| Pode fazer `INSERT`/`UPDATE`/`DELETE` | Não | Sim |
| Uso típico | Cálculo reutilizável (idade, dobro, conversão) | Operação/rotina (cadastrar, ajustar salário) |

Essa tabela sozinha resolve boa parte das questões de marcar sobre "quando
usar função e quando usar procedure".

---

## 13. Checklist antes da prova

- [ ] Sei dizer, sem olhar, a ordem de **execução** das cláusulas do SELECT (não a de escrita).
- [ ] Sei explicar por que `WHERE` não aceita agregação e `HAVING` aceita.
- [ ] Consigo montar um `LEFT JOIN ... WHERE x IS NULL` para "que não têm nenhum".
- [ ] Sei a diferença entre `IIF` e `CASE` e quando cada um se aplica.
- [ ] Sei por que uma função sempre retorna valor e uma procedure não precisa.
- [ ] Consigo escrever `DECLARE`/`SET`/`IF`/`WHILE` de cabeça, sem consultar.
- [ ] Sei montar uma procedure com `IF EXISTS` antes de inserir.
