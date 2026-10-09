// Data: 24/09/2026
# Cola A4 — o que vai pro papel

Recorte de [[Anotacoes_Prova]]. Oito blocos na ordem da aula, cada um
construindo em cima do anterior: procedure usa função, que usa variável, que
usa consulta. Cada bloco traz o **gatilho** (o que no enunciado aponta pra
ele), a **sintaxe** e, colado embaixo, o que engana ali (`→`).

Vire a folha depois do bloco 4: **frente = consulta**, **verso = programação**.

---

## 1. SELECT — a ordem das cláusulas

*Gatilho: toda consulta. É daqui que saem as 4-5 questões de marcar.*

```sql
SELECT      -- 5º   escolhe/calcula a saída
FROM/JOIN   -- 1º   de onde vêm as linhas
WHERE       -- 2º   filtra LINHA
GROUP BY    -- 3º   forma os grupos
HAVING      -- 4º   filtra GRUPO
ORDER BY    -- 6º   só ordena o que já saiu
```

→ A ordem de **escrita** não é a de **execução**. Todo o resto do bloco é
consequência disso:

→ `WHERE` não aceita `COUNT/SUM/AVG/MIN/MAX` — ele roda no 2º, antes de
existir grupo pra agregar.

→ Apelido criado no `SELECT` **não** vale no `WHERE` (5º > 2º, ainda não
existe), **vale** no `ORDER BY` (6º > 5º, já existe).

```sql
IS NULL / IS NOT NULL      -- nunca "= NULL"
BETWEEN a AND b            -- inclui os dois extremos
LIKE '%x%'                 -- % = qualquer coisa, _ = 1 caractere
IN (1,2,3)                 -- lista de valores
DISTINCT                   -- tira repetidas
TOP 3                      -- logo após o SELECT, use com ORDER BY
```

---

## 2. JOINs

*Gatilho: o enunciado cita dados que moram em tabelas diferentes.*

```sql
FROM TRABALHA_EM AS T
INNER JOIN PROJETO AS P     ON T.Pnr  = P.Projnumero
INNER JOIN FUNCIONARIO AS F ON T.Fcpf = F.Cpf
```

→ Cada `JOIN` traz o **seu próprio** `ON`. Esquecer um vira produto
cartesiano e o resultado infla sem dar erro.

```
INNER  só o que casa nas duas
LEFT   tudo da tabela do FROM + o que casar da outra
FULL   tudo dos dois lados, completando com NULL
CROSS  todas as combinações
SELF   a mesma tabela, dois apelidos
```

**"Os X que não têm nenhum Y"** — o molde que o professor avisou que cai:

```sql
SELECT *
FROM DEPARTAMENTO AS D
LEFT JOIN FUNCIONARIO AS F ON F.Dnr = D.Dnumero
WHERE F.Cpf IS NULL;
```

→ Monte em três decisões: **(1)** o que você quer listar vai no `FROM`;
**(2)** a outra entra por `LEFT JOIN`, que preserva as linhas sem par;
**(3)** o `WHERE` testa `IS NULL` na **chave primária** da tabela da
direita — é o que marca "não achou par". Testar numa coluna que aceita
nulo de verdade devolve resultado errado com cara de certo.

**Self join** — quando a tabela se refere a ela mesma (supervisor):

```sql
SELECT F.Pnome AS 'Funcionario', S.Unome AS 'Supervisor'
FROM FUNCIONARIO AS F
JOIN FUNCIONARIO AS S ON F.Cpf_supervisor = S.Cpf;
```

→ Dois apelidos diferentes pra mesma tabela: `F` é quem trabalha, `S` é
quem supervisiona.

---

## 3. GROUP BY / HAVING

*Gatilho: "por", "de cada", "quantos", "média", "total". Filtro sobre esse
agrupamento → `HAVING`.*

```sql
SELECT COUNT(F.Cpf) AS 'Quantidade', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D ON F.Dnr = D.Dnumero
GROUP BY D.Dnome
HAVING COUNT(F.Cpf) > 3
ORDER BY Quantidade;
```

`COUNT` · `SUM` · `AVG` · `MIN` · `MAX`

→ `WHERE` filtra **linha** antes de agrupar e não aceita agregação;
`HAVING` filtra **grupo** depois de agrupar e existe justamente pra aceitar
agregação. "Funcionários com salário acima de 3000" é `WHERE`;
"departamentos com mais de 3 funcionários" é `HAVING`.

→ Tudo que está no `SELECT` sem estar dentro de uma função de agregação
precisa estar no `GROUP BY`.

---

## 4. Conjuntos — UNION / INTERSECT / EXCEPT

*Gatilho: empilhar duas listas, ou "o que está numa e não na outra".*

```sql
SELECT F.Pnome AS 'Nome', F.Sexo FROM FUNCIONARIO AS F
UNION
SELECT D.Nome_dependente, D.Sexo FROM DEPENDENTE AS D;
```

```
UNION       empilha e REMOVE duplicata (é o DISTINCT)
UNION ALL   empilha e MANTÉM tudo
INTERSECT   só o que está nas duas
EXCEPT      a primeira MENOS a segunda
```

→ As duas consultas precisam de mesmo **número** de colunas, mesma
**ordem** e **tipos** compatíveis — o nome das colunas pode diferir, quem
manda é a primeira consulta.

→ `EXCEPT` não é comutativo: trocar a ordem dos dois `SELECT` muda o
resultado. `UNION` e `INTERSECT` são.

---

> **vira a folha**

---

## 5. Variáveis — DECLARE

*Gatilho: "guarde em uma variável", "calcule e exiba". O professor
destacou `DECLARE` como ponto de atenção.*

```sql
DECLARE @nome VARCHAR(100),
        @idade INT,
        @salario DECIMAL(10,2);
DECLARE @contador INT = 0;        -- declara e já atribui

SET @idade = 21;                  -- valor fixo

SELECT @salario = F.Salario       -- valor vindo de consulta
FROM FUNCIONARIO AS F
WHERE F.Pnome = @nome;

PRINT 'Idade: ' + CAST(@idade AS VARCHAR(10));
```

→ `SET` para literal, `SELECT @var =` quando o valor vem de tabela.

→ `PRINT` só concatena **texto**: número sem `CAST` dá erro de conversão.
É o erro mais comum das questões de `DECLARE`.

→ `GO` fecha o lote e **mata as variáveis**. Declarou antes do `GO`, não
existe depois dele.

**Datas:**

```sql
CONVERT(VARCHAR, D.Datanasc, 103)      -- data  → 'dd/mm/aaaa'
CONVERT(DATE, '15/08/1990', 103)       -- texto → data
DATEDIFF(YEAR, @nasc, GETDATE())
YEAR( )   MONTH( )   DAY( )   GETDATE()
```

→ `103` é o código do formato brasileiro. Sem ele o SQL Server lê
`mm/dd/aaaa` e ou troca dia com mês em silêncio, ou estoura.

---

## 6. Condicionais e laço

*Gatilho: "se ... então" fora da consulta → `IF/ELSE`. "Exiba tal texto
conforme a faixa", dentro do `SELECT` → `CASE`/`IIF`. "Repita até" →
`WHILE`.*

```sql
IF (@salario < @media)
    BEGIN
        PRINT 'abaixo da média';
    END;
ELSE IF (@salario = @media)
    BEGIN  ...  END;
ELSE
    BEGIN  ...  END;
```

→ `BEGIN/END` é obrigatório quando o bloco tem mais de um comando. Com um
comando só pode omitir — e é aí que se erra, porque o segundo comando
passa a rodar sempre, fora do `IF`.

```sql
SELECT F.Pnome,
       IIF(F.Salario < 20000, 'Baixo', 'Alto') AS 'Nivel',
    CASE
        WHEN F.Salario <= 10000 THEN 'Baixo'
        WHEN F.Salario <= 30000 THEN 'Medio'
        ELSE 'Alto'
    END AS 'Nivel salarial'
FROM FUNCIONARIO AS F;
```

→ `IF/ELSE` é **controle de fluxo**: decide qual comando roda, e vive fora
do `SELECT`. `IIF`/`CASE` são **expressão**: viram um valor numa coluna,
e vivem dentro do `SELECT`. Confundir os dois é pegadinha clássica.

→ `CASE` não tem `BEGIN`, mas o `END` é obrigatório. Ordem das `WHEN`
importa: a primeira verdadeira ganha, então vá da faixa mais restrita
para a mais ampla.

```sql
WHILE @contador < 10
BEGIN
    SET @contador = @contador + 1;
    IF @contador % 2 = 0  CONTINUE;      -- BREAK encerra o laço
    PRINT CAST(@contador AS VARCHAR(3));
END
```

→ Se o `SET` que avança o contador ficar **depois** de um `CONTINUE`, o
laço nunca termina.

---

## 7. Funções

*Gatilho: "crie uma função que receba X e retorne Y". Retorna um valor por
linha → escalar. Retorna uma lista → tabela.*

→ **Fracione:** escreva primeiro o `SELECT` solto que resolve o miolo,
confira o resultado, e só então embrulhe trocando os valores fixos pelos
`@parâmetros`. Escrever `CREATE FUNCTION` direto é resolver a lógica e a
forma ao mesmo tempo — é onde trava.

**Escalar** — um valor:

```sql
CREATE OR ALTER FUNCTION fn_x (@p DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @p * 2;
END
GO
SELECT dbo.fn_x(250);
SELECT F.Pnome, dbo.fn_x(F.Salario) AS 'Dobro' FROM FUNCIONARIO AS F;
```

**Inline** — uma tabela, um `SELECT` só:

```sql
CREATE FUNCTION fn_x (@p VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT ... FROM ... WHERE ... = @p
);
GO
SELECT * FROM dbo.fn_x('Pesquisa');
```

**Multi-statement** — tabela montada em etapas:

```sql
CREATE FUNCTION fn_x ()
RETURNS @saida TABLE (c1 VARCHAR(100), c2 DECIMAL(10,2))
AS
BEGIN
    INSERT INTO @saida
    SELECT ... FROM ...;
    RETURN;
END
GO
SELECT * FROM dbo.fn_x();
```

→ A diferença entre as três está no `RETURNS`, e é onde mais se erra por
analogia: escalar devolve **um tipo** e tem `BEGIN/END`; inline devolve
`TABLE` e **não tem `BEGIN/END`** — o `RETURN` vem antes do parêntese, a
consulta é o corpo inteiro; multi-statement devolve `@saida TABLE (...)`
com a estrutura declarada, tem `BEGIN/END`, preenche com
`INSERT INTO @saida` e fecha com um `RETURN` sozinho, sem valor.

→ Escalar se chama **dentro** do `SELECT` com `dbo.`; as de tabela vão no
`FROM`.

---

## 8. Stored Procedures — última aula

*Gatilho: "crie uma procedure que insira / atualize / liste".*

```sql
CREATE OR ALTER PROCEDURE sp_x (
    @a VARCHAR(50),
    @b DECIMAL(10,2) = 500)          -- valor default
AS
BEGIN
    UPDATE FUNCIONARIO
    SET Salario = Salario + @b
    WHERE Cpf = @a;
END
GO

EXEC sp_x '98765432100', 1000;
EXEC sp_x @a = '98765432100';        -- @b assume o default
```

**Verificar antes de inserir** — o padrão da última aula:

```sql
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
```

→ `SELECT 1` porque o `EXISTS` só quer saber **se veio linha** — o
conteúdo não importa. O `RETURN` abandona a procedure na hora.

→ **Função × procedure**, a distinção mais provável de cair: a função é
*obrigada* a retornar, é chamada dentro de `SELECT/WHERE/FROM` com `dbo.`,
e **não pode** fazer `INSERT/UPDATE/DELETE` em tabela do banco. A procedure
tem retorno opcional, é chamada com `EXEC`, e pode fazer DML — é pra isso
que ela existe.

→ `OUTPUT` **não cai na prova** (nota da Aula 08). Não gaste linha.
