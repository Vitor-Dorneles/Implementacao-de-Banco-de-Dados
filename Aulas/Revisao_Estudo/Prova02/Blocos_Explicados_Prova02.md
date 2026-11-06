// Data: 05/11/2026

Mesma ordem da [[Cola_A4_Prova02]]. Cada bloco tem **Na cola** (o que já está no A4, copiado aqui) e **Complemento** (o que explica e o que ficou de fora). Em cada tópico do complemento, `[cola?]` marca o que pode entrar no A4 se eu quiser; sem marca é só para entender. Para decidir o que entra: leio o complemento e anoto em **Minhas anotações**.

---

## 1. Transação (banco CAIXA)

### Na cola

*"tudo ou nada", "confira e decida", transferência*

```sql
BEGIN TRAN;                                        -- abre a transação: nada é definitivo ainda
DECLARE @erro INT, @linhas INT;                    -- variáveis para guardar os dois contadores
UPDATE conta SET Saldo = Saldo + 10000 WHERE Nome = 'Maria';  -- o comando que vamos conferir
SELECT @erro = @@ERROR, @linhas = @@ROWCOUNT;      -- guarda na hora: o próximo comando zera os dois
                                                   -- (numa linha só, senão o 1º SELECT já zera o outro)
IF @erro <> 0 OR @linhas <> 1  ROLLBACK TRAN;      -- erro, ou linhas ≠ 1: desfaz (Maria tem 2 contas = 2 linhas)
ELSE                           COMMIT TRAN;        -- tudo certo: grava
```

```sql
CREATE OR ALTER PROCEDURE usp_transferencia        -- cria a procedure (ou troca se já existe)
    @id_origem INT, @id_destino INT, @valor MONEY  -- parâmetros: de quem sai, para quem vai, quanto
AS
BEGIN
    BEGIN TRAN;                                    -- os dois UPDATE valem juntos ou nenhum
    UPDATE conta SET Saldo = Saldo - @valor WHERE id = @id_origem;    -- FAZ: tira da origem
    UPDATE conta SET Saldo = Saldo + @valor WHERE id = @id_destino;   -- FAZ: põe no destino
    IF (SELECT Saldo FROM conta WHERE id = @id_origem) < 0            -- CONFERE: a origem ficou negativa?
    BEGIN ROLLBACK TRAN; PRINT 'Saldo Insuficiente'; END              -- DECIDE: sim, desfaz os dois UPDATE
    ELSE  BEGIN COMMIT TRAN;  PRINT 'Transferencia realizada'; END    -- DECIDE: não, grava os dois
END
```

→ `@@ERROR`/`@@ROWCOUNT` mudam no próximo comando · erro não fecha a transação · ACID.

### Complemento

**Lendo o gatilho**
- *"tudo ou nada"*: atomicidade, as operações valem todas ou nenhuma.
- *"confira e decida"*: executa, confere o resultado e escolhe `COMMIT` ou `ROLLBACK`.
- *transferência*: dois `UPDATE` (débito e crédito) que não podem ficar pela metade.

**Como o professor fez**
- Tabela `conta(id, Nome, Saldo)`: Maria (10), João (20), Maria (30), Paulo (40).
- `BEGIN TRAN` abre a transação: até o `COMMIT`/`ROLLBACK` nada é definitivo.
- O `UPDATE` em `'Maria'` mexe em **2 linhas**, porque existem duas Marias; `@@ROWCOUNT <> 1` desfaz.
- `@@ERROR`: número do erro do último comando (0 = sem erro). Na primeira transação ele somou os erros dos dois `INSERT`; o segundo repetia a PK 10.
- `@@TRANCOUNT`: quantas transações estão abertas (0 = nenhuma). `[cola?]`
- Procedure: **faz** os dois `UPDATE`, **confere** o saldo da origem e **decide**.

**O que engana**
- `@@ERROR`/`@@ROWCOUNT` são zerados pelo comando seguinte, por isso o `SELECT @erro = …, @linhas = …` numa linha só.
- Em procedure a conferência é uma consulta (`saldo < 0`, `COUNT > 1`), não `@@ERROR`.

**ACID**
- **A**tomicidade: tudo ou nada.
- **C**onsistência: de estado válido para estado válido, respeitando as constraints.
- **I**solamento: uma transação não vê o que outra não confirmou.
- **D**urabilidade: depois do `COMMIT` fica, mesmo se o servidor cair.

### Minhas anotações

---

## 2. Savepoint e TRY…CATCH (banco CAIXA)

### Na cola

*"desfaça só a parte 2" · "trate o erro"*

```sql
BEGIN TRAN;                                         -- abre a transação
INSERT INTO conta VALUES (50, 'Pedro', 50);         -- parte 1: queremos manter
SAVE TRAN pedroOk;                                  -- checkpoint: dá para voltar até aqui
INSERT INTO conta VALUES (10, 'Juca', -200);        -- parte 2: PK 10 já existe, erro 2627
IF @@ERROR <> 0                                     -- o último comando deu erro?
BEGIN  ROLLBACK TRAN pedroOk;  COMMIT TRAN;  END    -- desfaz só a parte 2; a transação segue aberta, então COMMIT grava o Pedro
ELSE   COMMIT TRAN;                                 -- sem erro: grava tudo
```

```sql
BEGIN TRY                                           -- tenta executar o que está aqui
    BEGIN TRAN;
    INSERT INTO conta VALUES (60, 'José', 50);      -- este passa
    INSERT INTO conta VALUES (10, 'Juca', -200);    -- erro: pula direto para o CATCH
    COMMIT TRAN;                                    -- COMMIT no fim do TRY: só chega aqui se não houve erro
END TRY
BEGIN CATCH                                         -- roda só se algo falhou no TRY
    IF XACT_STATE() <> 0 ROLLBACK TRAN;             -- 1 = pode commit · -1 = só ROLLBACK · 0 = sem transação
    PRINT 'Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));  -- número do erro (o que vai para o backend)
    PRINT 'Mensagem: ' + ERROR_MESSAGE();           -- texto do erro
END CATCH
```

→ `ROLLBACK TRAN nome` não fecha a transação: ainda precisa de `COMMIT`.

### Complemento

**Lendo o gatilho**
- *"desfaça só a parte 2"*: voltar até um ponto, não até o começo.
- *"trate o erro"*: capturar o erro em vez de deixar o lote quebrar.

**Savepoint**
- `SAVE TRAN pedroOk` marca um ponto, como um checkpoint.
- `ROLLBACK TRAN pedroOk` desfaz só o que veio depois dele (o Juca); o Pedro continua.
- `ROLLBACK` sem nome desfaz a transação inteira, mesmo com `SAVE TRAN` antes. `[cola?]`

**TRY…CATCH**
- `TRY`: tenta; na primeira linha com erro, o resto do `TRY` é pulado (o `PRINT 'NÃO CHEGUEI AQUI'` não roda).
- `CATCH`: roda só se houve erro.
- `ERROR_NUMBER()` é o número que vai para o backend; `ERROR_MESSAGE()` é o texto. Servem para consultar a documentação.
- Com transação: `COMMIT` no fim do `TRY`, `ROLLBACK` no `CATCH`.
- `XACT_STATE()`: 1 = aberta, pode dar `COMMIT`; -1 = condenada, só `ROLLBACK`; 0 = não há transação (daí o `IF … <> 0`).

### Minhas anotações

---

## 3. Trigger — anatomia (banco EMPRESA_2026)

### Na cola

*"automaticamente", "sempre que", "impeça", "registre"*

```sql
CREATE OR ALTER TRIGGER trg_after_insert_dpt   -- nome do trigger (OR ALTER troca o corpo se já existe)
ON DEPARTAMENTO                                -- tabela vigiada
AFTER INSERT                                   -- evento e momento · FOR = AFTER · INSTEAD OF = no lugar do comando
AS
BEGIN
    DECLARE @nome VARCHAR(40);                 -- variável para guardar o nome inserido
    SELECT @nome = I.Dnome FROM inserted AS I; -- inserted = linhas novas (guarda SÓ UMA se vierem várias)
    PRINT 'Novo departamento: ' + @nome        -- ação do trigger
END;
```

```
         INSERTED   DELETED                    -- tabelas virtuais, só existem dentro do trigger
INSERT   novas      —
UPDATE   nova       antiga                     -- no UPDATE: antes em DELETED, depois em INSERTED
DELETE   —          apagadas
Ordem: tipo/NULL → INSTEAD OF (para aqui) → PK, CHECK, FK → DML → AFTER
       (NULL e tipo barram antes · INSTEAD OF vem antes das constraints · AFTER só roda se tudo passou)
```

→ 1 disparo por comando (`JOIN`/`IN`, não `@var`) · `AFTER DELETE` com FK barra antes → `INSTEAD OF` · `ROLLBACK` desfaz o comando.

### Complemento

**Lendo o gatilho**
- *"automaticamente"*, *"sempre que"*: acontece sem ninguém chamar, no `INSERT`/`UPDATE`/`DELETE`.
- *"impeça"*, *"registre"*: a ação do trigger é barrar (`ROLLBACK`) ou gravar (log).

**Como o professor definiu**
- Trigger é uma Stored Procedure que dispara sozinha. O modelo é **ECA**: **E**vento (o comando DML), **C**ondição (o `IF`), **A**ção (log, `RAISERROR`, `ROLLBACK` ou refazer o comando).
- Quase sempre vinculado a uma tabela; em view, só `INSTEAD OF`. `[cola?]`
- **AFTER** (ou `FOR`): depois que o comando executou e passou nas constraints.
- **INSTEAD OF**: no lugar do comando; o `DELETE` original não acontece, por isso o teste só imprimiu "NÃO DELETEI O REGISTRO".
- `inserted`/`deleted`: tabelas virtuais que só existem dentro do trigger; no `UPDATE`, `deleted` é a versão antiga e `inserted` a nova.
- O `INSERT` com `Dnumero` NULL deu erro antes do trigger: o NULL é barrado no passo 2 do fluxo.

**Fluxo de um comando DML**
1. `IDENTITY INSERT` → 2. NULL → 3. tipos → 4. **INSTEAD OF** (o DML para aqui; não é recursivo) → 5. PK → 6. CHECK → 7. FK → 8. DML e log de transações → 9. **AFTER** → 10. commit.
- O `AFTER` só roda se 5 a 7 passaram: por isso não serve para `DELETE` barrado por FK.

**O que engana**
- `SELECT @nome = I.Dnome FROM inserted` guarda **só uma linha**; um `INSERT` de várias linhas dispara o trigger uma vez só.
- `ROLLBACK` dentro do trigger desfaz o comando inteiro.
- Faltou coluna para guardar o resultado? `ALTER TABLE … ADD`.
- Gerenciar: `ALTER TABLE T DISABLE TRIGGER nome` / `ENABLE TRIGGER`; `EXEC sp_helptrigger T` lista os da tabela. `[cola?]`

### Minhas anotações

---

## 4. Trigger — os 4 padrões

### 4.1 Bloquear (EMPRESA_2026)

#### Na cola

*"impeça", "não permita", "máximo de N"*

```sql
CREATE OR ALTER TRIGGER trg_after_dpt_gerente
ON DEPARTAMENTO
AFTER INSERT, UPDATE                            -- um gerente novo pode entrar por INSERT ou por UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM DEPARTAMENTO AS D  -- olha a tabela inteira (a linha nova já está nela)
               WHERE D.Cpf_gerente IN (SELECT I.Cpf_gerente FROM inserted AS I)  -- só os gerentes que acabaram de entrar
               GROUP BY D.Cpf_gerente HAVING COUNT(*) > 2)  -- quantos departamentos cada um tem: mais de 2?
    BEGIN
        RAISERROR('Máximo de 2 departamentos por gerente', 16, 1);  -- mostra o erro
        ROLLBACK TRAN;                          -- desfaz o INSERT/UPDATE; sem isso a linha fica gravada
    END
END;
```

```sql
-- dentro de um trigger AFTER UPDATE em FUNCIONARIO
IF EXISTS (SELECT 1 FROM inserted AS I JOIN deleted AS D ON I.Cpf = D.Cpf  -- junta a versão nova com a antiga da mesma pessoa
           WHERE I.Salario < D.Salario)         -- novo menor que o antigo
BEGIN RAISERROR('O salário não pode diminuir', 16, 1); ROLLBACK TRAN; END
```

→ No `AFTER` a nova já está: duplicado = `> 1` · sem `ROLLBACK` só avisa · `IF UPDATE(col)`.

#### Complemento

- Regra de negócio que constraint não expressa: conta linhas de outra tabela ou compara valor antigo com novo.
- O `IN (SELECT … FROM inserted)` limita a contagem aos gerentes que acabaram de entrar.
- Mesma estrutura para nome duplicado (`> 1`) e "salário só sobe" (`JOIN deleted`, `I.Salario < D.Salario`).
- `IF UPDATE(Dnome)` é verdadeiro se a coluna estava no `SET`, **mesmo sem mudar o valor**.
- Versão `INSTEAD OF`: verifica **antes** com `IF EXISTS`; se estiver tudo certo, o próprio trigger refaz o `INSERT … SELECT … FROM inserted` (com as colunas na mesma ordem da lista). `[cola?]`
- Teste de trigger com `ROLLBACK`: o lote termina com o erro 3609 ("The transaction ended in the trigger"), então teste **fora** do `BEGIN TRAN`.

#### Minhas anotações

### 4.2 Completar (BIBLIOTECA)

#### Na cola

*"atualize / calcule automaticamente"*

```sql
-- corpo de um trigger AFTER INSERT ON Livro: recontar a categoria
UPDATE C
SET C.total_livros = (SELECT COUNT(*) FROM Livro AS L WHERE L.fk_categoria = C.id)  -- recontar do zero, não "+ 1"
FROM Categoria AS C
WHERE C.id IN (SELECT I.fk_categoria FROM inserted AS I);  -- só as categorias dos livros inseridos
```

→ Recontar com `COUNT(*)`, não `+ 1` · reverter: `SET col = D.col` com `JOIN DELETED`.

#### Complemento

- `ALTER TABLE Categoria ADD total_livros INT NOT NULL DEFAULT 0` cria a coluna antes do trigger.
- Um `UPDATE` único acerta os totais que já existem; o trigger só cuida dos novos.
- Recontar é mais seguro que `+ 1`: o `INSERT` pode trazer várias linhas, e um `DELETE`/`UPDATE` também muda o total.

#### Minhas anotações

### 4.3 Propagar exclusão (BIBLIOTECA)

#### Na cola

*"ao excluir X, exclua Y" — `INSTEAD OF DELETE`*

```sql
-- corpo de um trigger INSTEAD OF DELETE ON Livro (o DELETE original não acontece)
DELETE LA FROM LivroAutor AS LA JOIN deleted AS D ON LA.fk_livro = D.isbn; -- 1º os filhos (senão a FK barra)
DELETE L  FROM Livro      AS L  JOIN deleted AS D ON L.isbn = D.isbn;      -- 2º refaz o DELETE do pai, só dos livros pedidos
```

→ `INSTEAD OF` não executa o original: sem refazer, nada acontece.

#### Complemento

- `AFTER` não serve: a FK de `LivroAutor` barra o `DELETE` do livro antes de o trigger rodar.
- Os filhos saem **antes** do pai, senão a FK recusa.
- Teste dentro de `BEGIN TRAN`: `COUNT` de `LivroAutor` antes (1) e depois (0), `ROLLBACK` no fim.
- Variação do exercício 5: em vez de apagar os filhos, **barrar** se existirem (`IF EXISTS … RAISERROR ELSE DELETE`). `[cola?]`

#### Minhas anotações

### 4.4 Log (EMPRESA_2026)

#### Na cola

*"registre", "com data e hora"*

```sql
-- corpo de um trigger FOR DELETE ON FUNCIONARIO
INSERT INTO LOG_FUNCIONARIO (cpf, operacao)         -- não informa data_hora: o DEFAULT GETDATE() preenche
SELECT D.Cpf, 'DELETE' FROM deleted AS D;           -- deleted = linhas apagadas (várias linhas viram várias linhas de log)
```

→ Três num só: as duas com linhas = UPDATE · só INSERTED = INSERT · só DELETED = DELETE.

#### Complemento

- Tabela de log: `LOG_FUNCIONARIO(log_id IDENTITY, cpf, operacao, data_hora DATETIME DEFAULT GETDATE())`; o trigger não informa a hora, o `DEFAULT` preenche.
- Um trigger por operação (`FOR INSERT` com `inserted`, `FOR DELETE` com `deleted`) ou um só `FOR INSERT, UPDATE, DELETE` com `IF EXISTS` nas duas tabelas virtuais. `[cola?]`
- Ao trocar três triggers por um, `DROP TRIGGER` nos três antes, senão cada operação é registrada duas vezes.
- O log é desfeito junto se o comando der `ROLLBACK`: o trigger roda na mesma transação.

#### Minhas anotações

---

## 5. View (banco EMPRESA_2026)

### Na cola

*"crie uma visão", "só algumas colunas"*

```sql
GO                                                 -- CREATE VIEW precisa ser o 1º comando do lote
CREATE OR ALTER VIEW vw_rh_funcionario_dpt AS      -- cria ou troca · ALTER VIEW só altera · DROP VIEW apaga
SELECT CONCAT(F.Pnome, ' ', F.Unome) AS 'Nome',    -- coluna calculada: precisa de apelido
       DATEDIFF(YEAR, F.Datanasc, GETDATE()) AS 'Idade',  -- anos de diferença (conta virada de ano)
       D.Dnome AS 'Departamento'
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D ON F.Dnr = D.Dnumero;       -- liga FK (Dnr) com PK (Dnumero)
GO
SELECT * FROM vw_rh_funcionario_dpt WHERE Departamento = 'Matriz' ORDER BY Nome;  -- usa como tabela; WHERE/ORDER BY ficam fora da view
```

```sql
-- padrões que aparecem nos exercícios de view
LEFT JOIN B ON B.fk = A.id WHERE B.id IS NULL    -- "os que não têm": os A sem nenhum B (IS NULL, nunca = NULL)
EMP AS E JOIN EMP AS C ON E.chefe = C.id         -- chefe: mesma tabela duas vezes, 2 apelidos
GROUP BY ... HAVING COUNT(*) > 1                 -- "quantos cada": agrupa e filtra o grupo
TOP 1 ... ORDER BY valor DESC                    -- "o de maior": ordena do maior e pega 1
IIF(cond, 'Sim', 'Não') · CASE WHEN .. THEN .. ELSE .. END   -- escolhe um valor conforme a condição
```

→ Guarda só a consulta · calculada precisa de apelido · `ORDER BY` só fora.

### Complemento

**Lendo o gatilho**
- *"crie uma visão"*: `CREATE VIEW`.
- *"só algumas colunas"*: a view libera só o que eu listar no `SELECT`, sem dar acesso à tabela inteira.

**Como o professor definiu**
- Um `SELECT` complexo transformado em tabela virtual: guarda **só a consulta**, os dados vêm das tabelas a cada uso (sempre atuais).
- Vantagens: consultas recorrentes já prontas, `JOIN` complexo vira um nome, controle de acesso por colunas.
- Fica em *Exibições* no SSMS.
- Usada como tabela: `WHERE` e `ORDER BY` ficam na consulta de fora.

**O que engana**
- Coluna calculada (`CONCAT`, `DATEDIFF`) precisa de apelido.
- `ORDER BY` dentro da view só é aceito com `TOP`.
- `CREATE VIEW` precisa ser o primeiro comando do lote: `GO` antes. `CREATE OR ALTER` cria ou substitui.
- `DATEDIFF(YEAR, …)` conta virada de ano: a idade pode ficar 1 a mais antes do aniversário. `[cola?]`
- Teste o `SELECT` solto antes de embrulhar na view.

**Fora da cola (aparecem nos exercícios)**
- **Subconsulta**: `SELECT` dentro de outro, devolve valor, lista ou tabela. `[cola?]`
- **CTE**: `WITH nome AS (SELECT …) SELECT … FROM nome`, uma subconsulta com nome que vale só para a consulta logo abaixo. `[cola?]`
- `NOT IN` com `NULL` na lista não devolve nada; `COUNT(*)` conta linhas, `COUNT(col)` ignora `NULL` (muda com `LEFT JOIN`). `[cola?]`

### Minhas anotações

---

## 6. Integridade e cascade (banco LOJA)

### Na cola

*"não pode ser negativo", "padrão", "não repete", "ao excluir o pai"*

```
Declarativa = constraint · Procedural = trigger (regra entre tabelas)
Domínio tipo, CHECK, DEFAULT · Vazio NULL · Chave PK, UNIQUE · Ref. FK
```

```sql
CREATE TABLE PRODUTO(
  id INT IDENTITY(100,1) PRIMARY KEY,             -- IDENTITY(início, passo): o banco gera 100, 101...; PK = único e não nulo
  nome VARCHAR(80) NOT NULL,                      -- NOT NULL: não aceita vazio
  preco DECIMAL(10,2) NOT NULL,                   -- 10 dígitos no total, 2 depois da vírgula
  quantidade INT NOT NULL CONSTRAINT df_prod_qtde DEFAULT 0,  -- sem valor no INSERT, entra 0 (com nome para poder alterar)
  id_categoria INT NOT NULL,
  id_fornecedor INT NULL,                         -- NULL: aceita vazio (necessário para o SET NULL)
  CONSTRAINT ck_produto_preco CHECK (preco > 0),  -- CHECK: qualquer condição lógica; falha = erro 547
  CONSTRAINT fk_prod_categoria FOREIGN KEY (id_categoria)
    REFERENCES CATEGORIA (id) ON DELETE CASCADE ON UPDATE CASCADE,  -- apagar/mudar a categoria leva os produtos
  CONSTRAINT fk_prod_fornecedor FOREIGN KEY (id_fornecedor)
    REFERENCES FORNECEDOR (id) ON DELETE SET NULL );  -- apagar o fornecedor deixa o produto com NULL
ALTER TABLE PRODUTO ADD CONSTRAINT uq_prod_nome UNIQUE (nome);  -- UNIQUE: não repete (erro 2627) · ADD/DROP CONSTRAINT mudam depois
```

→ NO ACTION recusa · CASCADE leva os filhos · SET NULL (aceita NULL) · CASCADE apaga sem aviso.

### Complemento

**Como o professor definiu**
- **Declarativa**: a regra está na estrutura da tabela (constraint). **Procedural**: a regra está em código (trigger), para o que cruza tabelas.
- Quatro frentes: domínio (tipo, `CHECK`, `DEFAULT`), vazio (`NULL`/`NOT NULL`), chave (`PRIMARY KEY`, `UNIQUE`), referência (`FOREIGN KEY`).
- `IDENTITY(100,1)`: começa em 100 e soma 1; faz o papel do auto_increment, então o `INSERT` não informa o id.
- Sem `quantidade` no `INSERT`, entra o `DEFAULT 0`.

**Ações da FK**
- `NO ACTION` (padrão): recusa apagar/alterar o pai que tem filhos.
- `CASCADE`: leva os filhos junto (`ON DELETE` apaga, `ON UPDATE` propaga o novo id).
- `SET NULL`: zera a FK dos filhos; a coluna precisa aceitar `NULL`.
- Teste da aula: `UPDATE CATEGORIA SET id = 11` (propaga), `DELETE FROM FORNECEDOR` (produto fica com `NULL`), `DELETE FROM CATEGORIA` (apaga Caderno e Caneta).

**O que engana**
- `CASCADE` apaga sem aviso: diz "1 linha afetada" e foram várias. Por isso, `COUNT` dos filhos antes e depois.
- Constraint sem nome ganha nome aleatório (`DF__PRODUTO__situa__…`) e fica difícil de alterar. `[cola?]`
- `DEFAULT` e `CHECK` sem nome seguem a mesma regra.
- `SET NULL` com a coluna `NOT NULL` não funciona. `[cola?]`

### Minhas anotações

---

## 7. Permissões

### Na cola

```sql
CREATE LOGIN Juca WITH PASSWORD = 'S@1';    -- LOGIN: acesso ao servidor
CREATE USER Juca FOR LOGIN Juca;            -- USER: o mesmo login mapeado para o banco
ALTER ROLE db_datareader ADD MEMBER Juca;   -- role de só leitura: SELECT em tudo
GRANT SELECT, INSERT ON dbo.CATEGORIA TO Juca;  -- concede permissão no objeto
DENY  INSERT ON dbo.CATEGORIA TO Juca;      -- nega: vence o GRANT e a role
REVOKE INSERT ON dbo.CATEGORIA TO Juca;     -- remove o DENY: fica sem permissão (não volta o GRANT)
```

→ DENY vence a role · REVOKE não tira o que vem da role.

### Complemento

**Lendo o gatilho**: *"dê acesso de leitura"*, *"negue"*, *"retire a permissão"*.

**Como o professor fez**
- `LOGIN` é o acesso ao **servidor**; `USER … FOR LOGIN` mapeia para o **banco**.
- `db_datareader`: `SELECT` em todas as tabelas e views.
- `GRANT` concede, `DENY` nega, `REVOKE` remove o que foi concedido ou negado.
- Teste com `EXECUTE AS USER = 'Juca'` … `REVERT`.

**O que engana**
- `REVOKE SELECT` tira só o `GRANT` do objeto: o Juca ainda lê pelo `db_datareader`.
- `REVOKE` sobre um `DENY` não concede nada: fica sem permissão.
- `UPDATE`/`DELETE` nunca concedidos dão erro sem precisar de `DENY`.

### Minhas anotações

---

## 8. Base: procedure e IF/ELSE

### Na cola

```sql
GO                                            -- CREATE PROCEDURE também começa um lote
CREATE OR ALTER PROCEDURE usp_x
    @p NVARCHAR(10), @n DECIMAL(4,2)          -- parâmetros com @, no mesmo tipo da coluna; (4,2) cabe 6.50
AS
BEGIN
    IF EXISTS (SELECT 1 FROM T WHERE col = @p)       -- já existe esse valor?
        BEGIN PRINT 'Já existe'; RETURN; END         -- BEGIN/END porque são 2 comandos; RETURN sai da procedure
    ELSE IF (@n >= 5 AND @n < 7)              -- faixa: as duas condições juntas, com AND
        PRINT 'Nota: ' + CAST(@n AS VARCHAR(10));    -- número no PRINT precisa de CAST para texto
    ELSE
        INSERT INTO T (col) VALUES (@p);      -- caso contrário, insere
END
GO                                            -- fecha o lote: variáveis declaradas antes somem
EXEC usp_x 'CC101', 6.5;                      -- chama a procedure (só roda quando chamada)
```

→ `BEGIN/END` com mais de 1 comando · `GO` mata variáveis · `CAST` no `PRINT`.

**Meus erros da Prova 01:** `ON` liga FK → PK · "todas as X" = X no `FROM` + `LEFT JOIN` · `DECIMAL(p,s)` · faixa com `AND`, decidir o que `NULL` significa, nada em branco.

### Complemento

**Lendo o gatilho**: *"crie uma procedure que receba…"*, *"se já existir, avise"*, *"nota entre 5 e 7"*.

- Parâmetros com `@` e o mesmo tipo da coluna; `EXEC usp_x v1, v2` chama.
- `IF EXISTS (SELECT 1 …)` testa antes de inserir; `RETURN` sai da procedure.
- `ELSE IF` encadeia faixas; `ELSE` cobre o resto.
- `DECIMAL(p,s)`: `p` total de dígitos, `s` decimais. Nota de 0 a 10 com 2 casas = `(4,2)`; `(4,4)` estoura ao receber 6,5.
- Faixa: `@n >= 5 AND @n < 7`; com `OR` toda nota passa.
- `GO` termina o lote: as variáveis declaradas antes dele deixam de existir.
- Procedure só roda quando alguém chama com `EXEC`; trigger dispara sozinho.

### Minhas anotações

---

## 9. Comprovar que funciona

### Na cola

```sql
BEGIN TRAN;  SELECT antes;  DML;  SELECT depois;  ROLLBACK TRAN;
-- mostra o estado antes, executa o comando, mostra o depois e desfaz: o teste roda de novo sem sujar o banco
```

```sql
-- procedure com ROLLBACK por dentro: sem BEGIN TRAN de teste em volta
SELECT * FROM conta WHERE id IN (10, 40);       -- antes: anota os saldos
EXEC usp_transferencia 10, 20, 9999;            -- caso que deve falhar: Maria (500) não tem 9999 → Saldo Insuficiente
SELECT * FROM conta WHERE id IN (10, 40);       -- depois: igual ao antes (o ROLLBACK da procedure desfez)
```

→ Procedure com `ROLLBACK` dentro: não embrulhe em `BEGIN TRAN` de teste · um caso que passa + um que falha · `515` NULL · `547` CHECK/FK · `2627` PK/UNIQUE · trigger com `ROLLBACK`: fora do `BEGIN TRAN`.

### Complemento

- A moldura `BEGIN TRAN … ROLLBACK` mostra o efeito e desfaz: o teste roda de novo sem sujar o banco.
- Sempre **dois casos**, com o resultado esperado em comentário.
- Procedure com `ROLLBACK` por dentro: o `ROLLBACK` interno desfaz tudo, e o seu, de fora, dá erro 3903.
- O que mostrar em cada assunto:
  - Transação: força a falha no meio e mostra que nada ficou gravado.
  - Cascade: `COUNT` dos filhos antes e depois.
  - View: altera a tabela e consulta a view de novo.
  - Trigger: o comando que passa e o que é barrado.

### Minhas anotações
