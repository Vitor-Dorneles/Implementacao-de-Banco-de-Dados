// Data: 23/10/2026

## ACID
- ATOMICIDADE
  - A transação é tudo ou nada: ou executa inteira ou é desfeita inteira.
- CONSISTÊNCIA
  - O banco sai de um estado válido para outro, respeitando as constraints.
- ISOLAMENTO
  - Uma transação não enxerga o que outra ainda não confirmou com `COMMIT`.
- DURABILIDADE
  - Depois do `COMMIT`, a alteração persiste mesmo se o servidor cair.
  - Visto na Aula 11 (Transações): o trigger roda dentro da transação do comando, por isso vale o ACID.

## Triggers
Trigger (ou gatilho) é um objeto de banco de dados associado a uma tabela ou visão, executado quando ocorre o **EVENTO CONDIÇÃO AÇÃO (ECA)**. Sua principal função é executar automaticamente uma série de instruções SQL em resposta a certos eventos, como operações de inserção (`INSERT`), atualização (`UPDATE`) ou exclusão (`DELETE`).
- **Evento:** normalmente operações de atualização do banco de dados que são aplicadas dentro do banco.
  - Na prática, o comando DML que dispara o trigger: `INSERT`, `UPDATE` ou `DELETE`.
- **Condição:** quando o evento tiver ocorrido, uma condição opcional pode ser avaliada. Se nenhuma condição for especificada, a ação será executada quando ocorrer o evento.
  - No código, a condição é o `IF` dentro do corpo do trigger.
- **Ação:** o que o trigger executa: gravar no log, mostrar erro (`RAISERROR`), desfazer (`ROLLBACK`) ou refazer o comando.

> Trigger (Gatilho) é um tipo especial de Stored Procedure que é executada automaticamente quando um usuário realiza uma operação de modificação de dados em uma tabela especificada.

Trigger: maioria das vezes vinculado a uma tabela
- Também pode ser vinculado a uma view, mas só com `INSTEAD OF`.
- Dispara sozinho no evento; a procedure só roda quando alguém chama com `EXEC`.

Trigger geralmente está atrelado a regras de negócio: exemplo, aumento de salário só pode ser maior que o já existente, nunca menor; uma pessoa pode administrar no máximo 2 setores.
- São regras que uma constraint não expressa sozinha, porque comparam o valor antigo com o novo ou contam linhas de outra tabela.

### Modos de disparo (tipos de trigger)
- **AFTER:** o código do trigger é executado após todas as ações terem sido completadas na tabela especificada.
  - Já tenho em memória a nova versão do banco, o after roda no final.
  - Roda depois que o comando executou e passou nas constraints; as linhas novas ficam em `inserted`, as removidas em `deleted`.
  - O trigger roda dentro da transação do comando: um `ROLLBACK` nele desfaz o comando inteiro (visto na Aula 11, Transações).
  - `FOR INSERT` é o mesmo que `AFTER INSERT`.
- **INSTEAD OF:** é executado no lugar da operação que causou seu disparo; substitui um comando (`INSERT`, `UPDATE` ou `DELETE`) pelo que está no trigger.
  - O comando original não executa: por isso o `DELETE` do teste só imprimiu a mensagem.
  - Para a operação acontecer de fato, o próprio trigger precisa refazê-la.

### Fluxo de execução de um comando DML
1. Verificação de IDENTITY INSERT
2. Restrição (Constraint) de Nulos (NULL)
3. Checagem de tipos de dados: depois de 1 a 3 estarem corretas vem para a 4
4. Execução de trigger INSTEAD OF (a execução do DML para aqui; esse trigger não é recursivo); caso não tenha INSTEAD OF, pula para a próxima etapa
5. Restrição de Chave Primária
6. Restrição "Check"
7. Restrição Chave Estrangeira
8. Execução do DML e atualização do log de transações
9. Execução do trigger AFTER
10. Commit da transação (Confirmação)
- O `INSTEAD OF` (4) vem antes das constraints (5–7): dá para validar os dados e só então refazer o comando.
- O `AFTER` (9) vem depois de tudo: se uma PK, CHECK ou FK falhar, ele nem chega a rodar.
- "Não é recursivo": o `INSERT` que o `INSTEAD OF INSERT` faz na própria tabela não dispara ele de novo.

### INSERTED e DELETED
Tabelas virtuais que só existem dentro do trigger; permitem recuperar os valores do comando.

|          | INSERTED          | DELETED              |
|----------|-------------------|----------------------|
| `INSERT` | linhas novas      | vazia                |
| `UPDATE` | versão nova       | versão antiga        |
| `DELETE` | vazia             | linhas apagadas      |

- Um comando que mexe em várias linhas dispara o trigger uma vez só, com todas elas em `inserted`/`deleted`.
- `SELECT @nome = I.Dnome FROM inserted AS I` guarda só uma das linhas; para várias, use `JOIN` ou `IN` com `inserted`.

### Função UPDATE()
`IF UPDATE(Dnome)` consegue verificar se foi alterado um campo específico na tabela.
- Retorna verdadeiro se a coluna estava no comando (no `SET` do `UPDATE` ou no `INSERT`), mesmo que o valor não tenha mudado.
- Junto com `deleted` (nome antigo) e `inserted` (nome novo), mostra o antes e o depois.

### Log
Principais usos de trigger = fazer log, por exemplo acompanhar as alterações de dados em uma tabela.
- O trigger copia de `inserted`/`deleted` para uma tabela de log (ex.: `LOG_FUNCIONARIO`, com CPF, operação e data/hora).
- `data_hora DATETIME DEFAULT GETDATE()`: o trigger não informa a hora, o `DEFAULT` preenche.
- Num trigger só para os três comandos, a operação se descobre pelas tabelas: as duas com linhas = `UPDATE`; só `inserted` = `INSERT`; só `deleted` = `DELETE`.

### Gerenciar triggers
Quando criado, o trigger fica numa pasta `GATILHO` (no SSMS: dentro da tabela, em *Gatilhos*).
- `ALTER TABLE DEPARTAMENTO DISABLE TRIGGER nome`: desabilita sem apagar (pode ser manualmente também); `ENABLE TRIGGER` religa.
- `EXEC sp_helptrigger DEPARTAMENTO`: mostra as informações dos triggers da tabela.

### Praticando (banco EMPRESA_2026)
Código em `Triggers/Triggers.sql`:
- `trg_after_insert_dpt`: primeiro trigger, só um `PRINT` depois do `INSERT`. O `INSERT` com `Dnumero` NULL dá erro antes de chegar no trigger, pois o campo é NOT NULL (passo 2 do fluxo).
- `trg_insteadof_delete_dpt`: só imprime "NÃO DELETEI o registro"; o departamento 88 continua na tabela.
- `trg_after_insert_dpt` com `INSERTED`: lê o nome inserido e imprime "Foi inserido um novo departamento".
- Nome duplicado com `INSTEAD OF INSERT`: verifica com `IF EXISTS` antes; se não existe, faz o `INSERT` a partir de `INSERTED`.
- Nome duplicado com `AFTER INSERT`: a linha nova já está na tabela, então duplicado = `COUNT > 1`, e o `ROLLBACK TRANSACTION` volta para o original e não salva.
- `trg_for_update_nome`: nome antigo em `DELETED`, novo em `INSERTED`, e `IF UPDATE(Dnome)` decide o que imprimir.
- Log: `LOG_FUNCIONARIO` + um trigger por operação e depois um só para `INSERT, UPDATE, DELETE`.

Exercícios (banco BIBLIOTECA) em `Triggers/Exercicios/`.

## Views (Exibição) e Subconsultas
Uma tabela virtual, podemos usar como um select normal (cláusulas normais), bom para simplificar o backend.
- Criação: `CREATE VIEW nome AS SELECT ...`; uso: `SELECT * FROM nome WHERE ...`.
- Fica em `EXIBIÇÕES` (no SSMS: pasta *Exibições* do banco).

Um SELECT COMPLEXO que transformamos em uma tabela virtual.
- A view guarda só a consulta, não os dados: o `SELECT` roda de novo a cada uso e traz sempre os dados atuais.
- `ORDER BY` fica na consulta que usa a view, não dentro dela (só com `TOP`).

- Vantagens
  - Consultas recorrentes: a consulta já está pronta, é só chamar a view.
  - Simplifica: um `JOIN` complexo vira um nome (ex.: `vw_rh_funcionario_dpt`).
  - Permite liberar só algumas colunas para quem consulta, sem dar acesso à tabela inteira.

**Subconsulta (subquery):** um `SELECT` dentro de outro; devolve um valor, uma lista ou uma tabela para a consulta de fora.

**CTE (Common Table Expression):** `WITH nome AS (SELECT ...) SELECT ... FROM nome`; uma subconsulta com nome, que vale só para a consulta logo abaixo.

Código em `Views/VIEW_SUBquery.sql`:
- `vw_rh_funcionario_dpt`: nome completo com `CONCAT`, idade com `DATEDIFF(YEAR, Datanasc, GETDATE())` e o departamento pelo `JOIN`.
- Depois a view é usada como tabela: com `ORDER BY 'Nome'` e com `WHERE Departamento = 'Matriz'`.

Exercícios (banco Northwind) em `Views/Exercicios/`.

## Destilado


## Perguntas


## Erro que cometi
