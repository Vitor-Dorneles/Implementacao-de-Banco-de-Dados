// Data: 05/11/2026
# Exercícios — Prova 02

Os exercícios do professor são o conteúdo principal. A seção 4 (Aula 13) é
minha: a aula de revisão não deixou lista, e é dela que vem o "pode cair". O
recorte para o papel está em [[Cola_A4_Prova02]].

Só enunciados. Resolva escrevendo **antes** de rodar e anote o que esperava;
o que divergir vira `## Erro que cometi` na nota da aula e uma linha `→` na
cola.

---

## Trilha curta — pouco tempo

O que vai cair, segundo um colega: **transação, trigger, view, restrição de
integridade, cascade e comprovar que funciona**. Oito exercícios dentro dessa
lista, escolhidos pelos mais difíceis e pelos que repetem os meus erros da
Prova 01 (bloco 8 da cola). Nesta ordem; pare onde o tempo acabar.

| # | Exercício | Por que este | Erro da P01 que treina |
|---|---|---|---|
| 1 | Trigger **3** (seção 2) | `INSTEAD OF DELETE` + a ordem do DML (FK antes do AFTER); comparar com `ON DELETE CASCADE` | ON pela chave certa (`DELETED` × filho) |
| 2 | **I2** e **I5** (seção 4) | Cascade e `SET NULL`, com prova antes/depois | — |
| 3 | Transação **5** (seção 1) | O enunciado já pede "comprove atomicidade" | — |
| 4 | View **3** (seção 3) | Três tabelas + `COUNT` por grupo: é a Q9 de novo | "Todas as X", FROM e LEFT JOIN |
| 5 | Trigger **15** | `INSERTED` e `DELETED` no mesmo comando | ON com três tabelas |
| 6 | Trigger **9** | Limite com várias linhas: `GROUP BY`/`HAVING` dentro do `EXISTS` | Faixa e contagem |
| 7 | **I1** e **I3** (seção 4) | Uma violação por restrição, com o erro esperado; `ALTER TABLE` | Tipo e tamanho das colunas |
| 8 | Transação **6** | `TRY…CATCH` + `XACT_STATE()` | — |

Fora da lista do colega, só se sobrar tempo: **P1** e **P3** (a nota da
revisão diz que usuário + `db_datareader` pode cair).

Regra para cada um: escrever no papel primeiro, como na prova, **com os
comandos que provam que funciona** (bloco 9 da cola), e só depois rodar. No
fim, conferir com os erros da Prova 01 no bloco 8.

---

## 1. Transações — banco EMPRESA

Fonte: `Aula-11_Transacoes/Transações.md`, seção "Exercícios".

- [x] 1. Autocommit × transação explícita
- [x] 2. SAVEPOINT e ROLLBACK parcial
- [ ] 3. UPDATE com conferência e decisão
- [ ] 4. SAVEPOINT antes de UPDATE em massa
- [ ] 5. INSERT + UPDATE tudo-ou-nada
- [ ] 6. TRY…CATCH e `XACT_STATE()`

---

## 2. Triggers — banco BIBLIOTECA

Fonte: `Aula-12_TriggersEviews/Triggers/Exercicios/Triggers - Banco Biblioteca.pdf`.
Banco: `Aula-12_TriggersEviews/Triggers/Exercicios/BIBLIOTECA.sql`.

> O banco não tem `total_livros` (Categoria), `total_livros_escritos` (Autor),
> as tabelas de log/auditoria nem a de editoras proibidas. Os exercícios 4, 6,
> 7, 10, 14, 16, 17 e 18 começam com um `ALTER TABLE ... ADD` ou `CREATE TABLE`.

Agrupados pelos 4 padrões do bloco 4 da cola. Faça primeiro os marcados com ⚑
(um de cada padrão), depois o resto.

| Padrão | Exercícios |
|---|---|
| Bloquear | 1 ⚑, 5, 8 ⚑, 9, 12, 16 |
| Completar | 2 ⚑, 4, 7, 10, 15 ⚑, 17 |
| Propagar exclusão | 3 ⚑, 11, 13 |
| Log/auditoria | 6, 14 ⚑, 18 |

- [ ] Para o 1 e o 5: resolver das **duas** formas (`INSTEAD OF` e `AFTER` +
  `ROLLBACK`) e explicar a diferença.
- [ ] Para o 3: explicar, antes de escrever, por que `AFTER DELETE` não serve.
- [ ] Para qualquer um: testar com um `INSERT` de **duas linhas** de uma vez.

---

## 3. Views — banco Northwind

Fonte: `Aula-12_TriggersEviews/Views/Exercicios/Exercicios.md`. Banco:
`Aula-12_TriggersEviews/Views/Exercicios/MICROSOFT.sql` (script `instnwnd` do PDF).

- [ ] 1. Funcionários que não são chefes ⚑
- [ ] 2. Quantidade vendida de cada produto
- [ ] 3. Territórios e quantos vendedores em cada
- [ ] 4. Nome do cliente da venda de maior valor ⚑
- [ ] 5. Vendedores ordenados pela lucratividade ⚑
- [ ] 6. Produtos com fornecedor, categoria, preço e descontinuado, com estoque

---

## 4. Integridade e permissões — banco LOJA

Banco: rode `Aula-13_RevisaoProva02/SQL/RESTRICOES_INTEGRIDADE.sql` inteiro
antes. Não abra esse arquivo nem o `PERMISSOES.sql` enquanto resolve.

### Integridade

- [ ] **I1.** Crie a tabela `CLIENTE`: `id` gerado automaticamente a partir
  de 1; `nome` obrigatório; `email` que não pode se repetir; `data_cadastro`
  que, se não for informada, recebe a data atual; `situacao` que só aceita
  'Ativo' ou 'Bloqueado'. Todas as restrições com nome. Depois, escreva um
  `INSERT` que viole cada restrição e anote a mensagem de erro de cada um.
- [ ] **I2.** Crie a tabela `VENDA` (cliente, produto, quantidade, data)
  ligada a `CLIENTE` e `PRODUTO`, com estas regras: excluir um cliente que
  tem vendas deve ser **recusado**; excluir um produto deve **manter** a venda,
  sem produto; quantidade sempre maior que zero. Antes de rodar, escreva o
  que espera de um `DELETE` em cada tabela pai.
- [ ] **I3.** Sem recriar a tabela, adicione a `PRODUTO` a coluna
  `estoque_minimo`, obrigatória, com padrão 5 e que não aceita negativo. Em
  seguida, remova o valor padrão de `situacao` (o que foi criado sem nome).
- [ ] **I4.** Regra: "uma venda não pode ter quantidade maior que o estoque
  do produto". Explique por que um `CHECK` não resolve e implemente do jeito
  que resolve. Depois, classifique cada regra de I1 a I4 em declarativa ou
  procedural e no tipo de integridade (domínio, vazio, chave, referencial,
  usuário).
- [ ] **I5.** Previsão, sem rodar: com o estado atual de `CATEGORIA` e
  `PRODUTO`, quantas linhas somem de cada tabela em `DELETE FROM CATEGORIA
  WHERE id = 11`? E o que a mensagem do SQL Server vai dizer? Rode e compare.

### Permissões

- [ ] **P1.** Crie o login e o usuário `Maria` no banco LOJA com permissão
  de **só leitura** em todas as tabelas. Conectado como Maria, teste um
  `SELECT` e um `INSERT` e anote o resultado de cada um.
- [ ] **P2.** Maria agora precisa **inserir** em `VENDA`, mas **não pode
  ler** `FORNECEDOR`, mesmo continuando com leitura no resto. Faça e confira
  com a consulta de permissões em `sys.database_permissions`.
- [ ] **P3.** Previsão, sem rodar: Maria continua na role de leitura. Depois
  de cada linha abaixo, ela consegue ler `PRODUTO`? Escreva sim/não e o
  porquê; rode e compare.
  ```
  GRANT SELECT ON dbo.PRODUTO TO Maria;
  DENY SELECT ON dbo.PRODUTO TO Maria;
  GRANT SELECT ON dbo.PRODUTO TO Maria;
  DENY SELECT ON dbo.PRODUTO TO Maria;
  REVOKE SELECT ON dbo.PRODUTO FROM Maria;
  ```
- [ ] **P4.** Crie uma view com nome e preço dos produtos ativos (sem
  fornecedor) e um usuário `Jose`, **sem** role nenhuma, que só pode consultar
  essa view. Teste um `SELECT` na view e outro direto em `PRODUTO`.

---

## Ordem sugerida

1. Os ⚑ das seções 2 e 3, mais as transações 3 e 6.
2. A seção 4 inteira (integridade, cascade e permissões).
3. O resto dos triggers, um padrão por dia.
4. Refazer do zero, dois dias depois, os que exigiram mais de uma tentativa.
