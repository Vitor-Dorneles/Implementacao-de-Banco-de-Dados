// Data: 05/11/2026
# Cola A4 — Prova 02

Frente = transação e trigger (1–4) · verso = view, integridade, base e prova
(5–9). Cada bloco: *gatilho*, **exemplo da aula** (banco do professor), `→` o que
engana. Explicação de cada bloco: [[Blocos_Explicados_Prova02]]. Treino:
[[Exercicios_Prova02]].

Bancos: **CAIXA** (`conta`) · **EMPRESA_2026** (`FUNCIONARIO`, `DEPARTAMENTO`) ·
**BIBLIOTECA** (`Livro`, `Categoria`, `LivroAutor`) · **LOJA** (`PRODUTO`).

---

## 1. Transação — CAIXA

*"tudo ou nada", "confira e decida", transferência*

```sql
BEGIN TRAN;
DECLARE @erro INT, @linhas INT;
UPDATE conta SET Saldo = Saldo + 10000 WHERE Nome = 'Maria';
SELECT @erro = @@ERROR, @linhas = @@ROWCOUNT;      -- na hora, numa linha só
IF @erro <> 0 OR @linhas <> 1  ROLLBACK TRAN;      -- Maria tem 2 contas: 2 ≠ 1
ELSE                           COMMIT TRAN;
```

```sql
CREATE OR ALTER PROCEDURE usp_transferencia
    @id_origem INT, @id_destino INT, @valor MONEY
AS
BEGIN
    BEGIN TRAN;
    UPDATE conta SET Saldo = Saldo - @valor WHERE id = @id_origem;    -- faz
    UPDATE conta SET Saldo = Saldo + @valor WHERE id = @id_destino;
    IF (SELECT Saldo FROM conta WHERE id = @id_origem) < 0            -- confere
    BEGIN ROLLBACK TRAN; PRINT 'Saldo Insuficiente'; END              -- decide
    ELSE  BEGIN COMMIT TRAN;  PRINT 'Transferencia realizada'; END
END
```

→ `@@ERROR`/`@@ROWCOUNT` mudam no próximo comando (até `SET`/`IF`).

→ Erro não fecha a transação. Em procedure: faz, confere (`saldo < 0`,
`COUNT > 1`), decide.

→ A tudo ou nada · C válido → válido · I não vê o não commitado · D fica.

---

## 2. Savepoint e TRY…CATCH — CAIXA

*"desfaça só a parte 2" · "trate o erro"*

```sql
BEGIN TRAN;
INSERT INTO conta VALUES (50, 'Pedro', 50);
SAVE TRAN pedroOk;                                  -- checkpoint
INSERT INTO conta VALUES (10, 'Juca', -200);        -- PK repetida: erro 2627
IF @@ERROR <> 0
BEGIN  ROLLBACK TRAN pedroOk;  COMMIT TRAN;  END    -- volta ao ponto, Pedro fica
ELSE   COMMIT TRAN;
```

```sql
BEGIN TRY
    BEGIN TRAN;
    INSERT INTO conta VALUES (60, 'José', 50);
    INSERT INTO conta VALUES (10, 'Juca', -200);    -- erro: pula para o CATCH
    COMMIT TRAN;                                    -- COMMIT no fim do TRY
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN;             -- 1 ok · -1 só ROLLBACK · 0 nada
    PRINT 'Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Mensagem: ' + ERROR_MESSAGE();
END CATCH
```

→ `ROLLBACK TRAN nome` não fecha a transação: ainda precisa de `COMMIT`.
`ROLLBACK` sem nome desfaz tudo.

---

## 3. Trigger — anatomia — EMPRESA_2026

*"automaticamente", "sempre que", "impeça", "registre"*

```sql
CREATE OR ALTER TRIGGER trg_after_insert_dpt
ON DEPARTAMENTO
AFTER INSERT                          -- FOR = AFTER · INSTEAD OF DELETE
AS
BEGIN
    DECLARE @nome VARCHAR(40);
    SELECT @nome = I.Dnome FROM inserted AS I;
    PRINT 'Novo departamento: ' + @nome
END;
```

```
         INSERTED   DELETED
INSERT   novas      —
UPDATE   nova       antiga
DELETE   —          apagadas
Ordem: tipo/NULL → INSTEAD OF (para aqui) → PK, CHECK, FK → DML → AFTER
```

→ 1 disparo por comando: `INSERTED` pode ter várias linhas. Use `JOIN`/`IN`,
não `@var` (`@nome` acima guarda só uma).

→ `AFTER DELETE` com FK sem `CASCADE` não roda (a FK barra antes) →
`INSTEAD OF`.

→ `ROLLBACK` no trigger desfaz o comando. Coluna que falta: `ALTER TABLE ADD`.

---

## 4. Trigger — 4 padrões

**Bloquear** — *"impeça", "não permita", "máximo de N"* — EMPRESA_2026

```sql
-- gerente administra no máximo 2 departamentos
CREATE OR ALTER TRIGGER trg_after_dpt_gerente
ON DEPARTAMENTO
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM DEPARTAMENTO AS D
               WHERE D.Cpf_gerente IN (SELECT I.Cpf_gerente FROM inserted AS I)
               GROUP BY D.Cpf_gerente HAVING COUNT(*) > 2)
    BEGIN
        RAISERROR('Máximo de 2 departamentos por gerente', 16, 1);
        ROLLBACK TRAN;
    END
END;
```

```sql
-- salário só pode subir: novo < antigo
IF EXISTS (SELECT 1 FROM inserted AS I JOIN deleted AS D ON I.Cpf = D.Cpf
           WHERE I.Salario < D.Salario)
BEGIN RAISERROR('O salário não pode diminuir', 16, 1); ROLLBACK TRAN; END
```

→ No `AFTER` a nova já está: duplicado = `> 1`. Sem `ROLLBACK` o erro só
avisa. Coluna fixa: `IF UPDATE(col)`.

**Completar** — *"atualize / calcule automaticamente"* — BIBLIOTECA

```sql
-- AFTER INSERT ON Livro: recontar a categoria
UPDATE C
SET C.total_livros = (SELECT COUNT(*) FROM Livro AS L WHERE L.fk_categoria = C.id)
FROM Categoria AS C
WHERE C.id IN (SELECT I.fk_categoria FROM inserted AS I);
```

→ Total: recontar com `COUNT(*)`, não `+ 1` (o insert pode ter várias linhas).
Reverter: `SET col = D.col` com `JOIN DELETED`.

**Propagar exclusão** — *"ao excluir X, exclua Y"* — `INSTEAD OF DELETE`

```sql
DELETE LA FROM LivroAutor AS LA JOIN deleted AS D ON LA.fk_livro = D.isbn; -- filhos antes
DELETE L  FROM Livro      AS L  JOIN deleted AS D ON L.isbn = D.isbn;      -- refaz
```

→ `INSTEAD OF` não executa o original: sem refazer, nada acontece.

**Log** — *"registre", "com data e hora"* — EMPRESA_2026

```sql
INSERT INTO LOG_FUNCIONARIO (cpf, operacao)         -- data_hora: DEFAULT GETDATE()
SELECT D.Cpf, 'DELETE' FROM deleted AS D;
```

→ Três num só: as duas com linhas = UPDATE · só INSERTED = INSERT · só
DELETED = DELETE.

---

> **vira a folha**

---

## 5. View — EMPRESA_2026

*"crie uma visão", "só algumas colunas"*

```sql
GO
CREATE OR ALTER VIEW vw_rh_funcionario_dpt AS      -- ALTER VIEW · DROP VIEW
SELECT CONCAT(F.Pnome, ' ', F.Unome) AS 'Nome',
       DATEDIFF(YEAR, F.Datanasc, GETDATE()) AS 'Idade',
       D.Dnome AS 'Departamento'
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D ON F.Dnr = D.Dnumero;
GO
SELECT * FROM vw_rh_funcionario_dpt WHERE Departamento = 'Matriz' ORDER BY Nome;
```

→ Guarda só a consulta (dado sempre atual). Calculada precisa de apelido.
`ORDER BY` só fora (dentro, só com `TOP`). Teste o `SELECT` solto antes de
embrulhar.

```sql
LEFT JOIN B ON B.fk = A.id WHERE B.id IS NULL    -- "os que não têm"
EMP AS E JOIN EMP AS C ON E.chefe = C.id         -- chefe: 2 apelidos
GROUP BY ... HAVING COUNT(*) > 1                 -- "quantos cada"
TOP 1 ... ORDER BY valor DESC                    -- "o de maior"
IIF(cond, 'Sim', 'Não') · CASE WHEN .. THEN .. ELSE .. END
```

---

## 6. Integridade e cascade — LOJA

*"não pode ser negativo", "padrão", "não repete", "ao excluir o pai"*

```
Declarativa = constraint · Procedural = trigger (regra entre tabelas)
Domínio tipo, CHECK, DEFAULT · Vazio NULL · Chave PK, UNIQUE · Ref. FK
```

```sql
CREATE TABLE PRODUTO(
  id INT IDENTITY(100,1) PRIMARY KEY,
  nome VARCHAR(80) NOT NULL,
  preco DECIMAL(10,2) NOT NULL,
  quantidade INT NOT NULL CONSTRAINT df_prod_qtde DEFAULT 0,
  id_categoria INT NOT NULL,
  id_fornecedor INT NULL,
  CONSTRAINT ck_produto_preco CHECK (preco > 0),
  CONSTRAINT fk_prod_categoria FOREIGN KEY (id_categoria)
    REFERENCES CATEGORIA (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_prod_fornecedor FOREIGN KEY (id_fornecedor)
    REFERENCES FORNECEDOR (id) ON DELETE SET NULL );
ALTER TABLE PRODUTO ADD CONSTRAINT uq_prod_nome UNIQUE (nome);  -- ADD/DROP CONSTRAINT
```

→ NO ACTION (padrão) recusa · CASCADE leva os filhos · SET NULL (aceita NULL).

→ CASCADE apaga sem aviso ("1 linha afetada" = só o pai). Sem nome, a
constraint ganha nome aleatório.

---

## 7. Permissões — revisão: pode cair

```sql
CREATE LOGIN Juca WITH PASSWORD = 'S@1';  CREATE USER Juca FOR LOGIN Juca;
ALTER ROLE db_datareader ADD MEMBER Juca;   -- só leitura
GRANT SELECT, INSERT ON dbo.CATEGORIA TO Juca;
DENY  INSERT ON dbo.CATEGORIA TO Juca;      -- DENY vence o GRANT e a role
REVOKE INSERT ON dbo.CATEGORIA TO Juca;     -- tira o DENY; fica sem permissão
```

→ DENY vence a role. REVOKE não tira o que vem da role.

---

## 8. Base: procedure e IF/ELSE

```sql
GO
CREATE OR ALTER PROCEDURE usp_x
    @p NVARCHAR(10), @n DECIMAL(4,2)          -- mesmo tipo da coluna
AS
BEGIN
    IF EXISTS (SELECT 1 FROM T WHERE col = @p)
        BEGIN PRINT 'Já existe'; RETURN; END
    ELSE IF (@n >= 5 AND @n < 7)              -- faixa = AND
        PRINT 'Nota: ' + CAST(@n AS VARCHAR(10));
    ELSE
        INSERT INTO T (col) VALUES (@p);
END
GO
EXEC usp_x 'CC101', 6.5;
```

→ `BEGIN/END` com mais de 1 comando. `GO` mata variáveis. Número no `PRINT`
precisa de `CAST`.

**Meus erros da Prova 01:**
- `ON` liga FK → PK, não nomes parecidos; nunca `D.x = D.x`.
- "Todas as X" = X no `FROM` + `LEFT JOIN`.
- `DECIMAL(p,s)`: p total, s decimais. Nota `(4,2)`; `(4,4)` estoura.
- Faixa com `AND`. Decidir o que `NULL` significa. Nada em branco.

---

## 9. Comprovar que funciona

```sql
BEGIN TRAN;  SELECT antes;  DML;  SELECT depois;  ROLLBACK TRAN;
```

```sql
SELECT * FROM conta WHERE id IN (10, 40);       -- antes
EXEC usp_transferencia 10, 20, 9999;            -- deve falhar: Saldo Insuficiente
SELECT * FROM conta WHERE id IN (10, 40);       -- depois: igual ao antes
```

→ Procedure com `ROLLBACK` dentro: não embrulhe em `BEGIN TRAN` de teste (o
`ROLLBACK` interno desfaz tudo e o seu dá erro 3903).

→ Um caso que passa + um que deve falhar, com o esperado comentado.
`515` NULL · `547` CHECK/FK · `2627` PK/UNIQUE.

→ Transação: falha no meio, nada ficou · Cascade: `COUNT` dos filhos antes e
depois · View: mude a tabela e consulte de novo.

→ Trigger com `ROLLBACK`: teste fora do `BEGIN TRAN`.
