// Data: 30/10/2026

## Revisão da aula passada (Triggers e Views)
O que foi visto na aula passada:
- Trigger
  - DML: INSERT, UPDATE e DELETE
    - E.C.A: evento, condição e ação
      - Evento = o comando DML; condição = o teste no corpo do trigger (`IF`); ação = o que ele executa.
  - AFTER ou FOR: ocorre no final da transação, ou seja, já tenho os dados/alteração no banco, só faltando realizar oficialmente as alterações
    - Roda depois do comando, ainda dentro da transação dele: o "oficialmente" é o `COMMIT` (visto na Aula 11, Transações).
  - INSTEAD OF
    - Roda no lugar do comando; o comando original não executa.
  - INSERTED
    - Tabela virtual do trigger com as linhas novas (`INSERT`) ou a versão nova (`UPDATE`).
  - DELETED
    - Linhas removidas (`DELETE`) ou a versão antiga (`UPDATE`).
  - **UPDATE(colunaA): retorna verdadeiro se a coluna estava no comando (no `SET` do UPDATE ou no INSERT) e falso se não estava**
    - Não compara valores: `SET preco = preco` também retorna verdadeiro, mesmo sem o dado mudar.
    - Usado dentro do trigger: `IF UPDATE(preco) ...` só executa a ação quando o comando mexeu naquela coluna.
- Views
  - Tabela virtual
  - Consulta SQL
    - A view guarda só o `SELECT`; os dados vêm das tabelas a cada uso (visto na Aula 12, Triggers e Views).

## Diferença entre AFTER e INSTEAD OF (Triggers)
A principal diferença entre AFTER e INSTEAD OF está no momento em que o trigger é executado e na sua relação com a operação que o disparou.

- **AFTER (Depois):** O trigger é executado somente depois que a operação no banco de dados foi concluída com sucesso (INSERT, UPDATE ou DELETE).
  - **Quando utilizar:** quando deseja executar uma ação complementar após uma alteração na tabela.
  - **Exemplo:** após cadastrar um novo cliente, registrar essa operação em uma tabela de auditoria ou atualizar um histórico.
  - Se o comando viola uma constraint (PK, FK, CHECK), dá erro antes e o AFTER nem roda.
- **INSTEAD OF (No lugar de):** O trigger é executado no lugar da operação original, ou seja, substitui a ação que seria realizada no banco de dados.
  - **Quando utilizar:** quando deseja controlar, modificar ou personalizar como uma operação será executada.
  - **Exemplo:** ao tentar inserir dados em uma VIEW, o trigger recebe a operação e realiza os INSERTs necessários nas tabelas de origem.
  - Roda antes das constraints: dá para validar os dados e só então refazer o comando (ou recusar).
  - View só aceita INSTEAD OF; AFTER só existe em tabela.

**Comparação prática**

| AFTER | INSTEAD OF |
|---|---|
| Executa depois da operação original. | Executa no lugar da operação original. |
| A operação original já foi realizada. | A operação original não é executada automaticamente. |
| Utilizado para ações complementares. | Utilizado para substituir ou controlar operações. |
| Exemplo: registrar alterações em uma auditoria. | Exemplo: permitir INSERT em uma VIEW. |

**Resumindo para memorizar**
- **AFTER:** primeiro o banco realiza a operação, depois executa o trigger.
- **INSTEAD OF:** o banco executa o trigger no lugar da operação original.

> Dica: use AFTER quando quiser fazer algo depois de uma alteração e INSTEAD OF quando quiser definir como a alteração deve acontecer, substituindo a operação padrão.

## Restrição de Integridade
A integridade de dados é a manutenção e garantia da consistência e precisão dos dados, sendo aspecto crítico. A integridade é atingida por meio da aplicação de **restrições de integridade**.

**Declarativa:** define restrições de consistência diretamente na estrutura das tabelas usando comandos DDL no SQL. Dessa forma, o próprio banco de dados automatiza a validação dos dados por meio de chaves (PK e FK), obrigatoriedade de campos (NOT NULL) e tipos de dados.
- Também são declarativas: `UNIQUE`, `CHECK` e `DEFAULT`.
- O comando que viola a restrição falha com erro e não altera nada.

**Procedural:** procedural valida os dados por meio de códigos programados diretamente no banco, como triggers, stored procedures e assertions. Essa abordagem traduz as regras de negócio do cliente em rotinas automatizadas, geralmente desenvolvidas por analistas ou programadores especialistas no SGBD.
- Usada quando a regra não cabe numa constraint: depende de outra tabela ou de várias linhas (ex.: não vender mais que o estoque).
- Assertion é do SQL padrão; o SQL Server não implementa `CREATE ASSERTION`.

**Tipos de integridade:**

**Integridade de Domínio**
As restrições de domínio especificam que dentro da definição definida os valores não podem ultrapassar. Por exemplo: cadastrar produtos que aceita valores negativos ou ficar zerado. Esse tipo de integridade normalmente é declarativo (tipo de dado, `CHECK`, `DEFAULT`, `NOT NULL`); o trigger só entra quando o `CHECK` não dá conta da regra.
- Domínio = o conjunto de valores válidos da coluna: o tipo (`DECIMAL`), a faixa (`CHECK (preco > 0)`) ou a lista (`CHECK (situacao IN ('Ativo','Inativo'))`).

**Integridade Referencial**
Assegura que valores de uma coluna em uma tabela são válidos baseados nos valores em uma outra tabela relacionada.
- **Exemplo:** Se um produto de ID 435 foi cadastrado em uma tabela de Vendas, então um produto com o ID 435 deve existir na tabela de Produtos relacionada.
- Quem garante é a FK: o banco recusa um `id_categoria` que não exista em `CATEGORIA`.

**Atualização e exclusão:** se um registro for excluído em uma tabela, então os registros relacionados da tabela, o próprio banco indicará erro, pois não pode apagar dados que estão relacionados na tabela. A partir daí entra o conceito `CASCADE`:
- Sem regra na FK vale o padrão `NO ACTION`: o banco recusa o `DELETE`/`UPDATE` do registro referenciado.
- Se um registro for excluído em uma tabela (operação DELETE), então os registros relacionados em outras tabelas que o referenciam talvez precisem ser excluídos. Caso contrário ocorrerá erro. O mesmo se dá com a atualização de registros (operação UPDATE).
  - on delete cascade
    - Apagar a categoria apaga os produtos dela.
  - on update cascade
    - Mudar o `id` da categoria atualiza o `id_categoria` dos produtos.
  - Outras opções: `SET NULL` (a FK vira NULL; a coluna precisa aceitar NULL) e `SET DEFAULT`.
  - `TRUNCATE` não propaga `CASCADE`: é recusado em qualquer tabela referenciada por FK.

**Integridade de Vazio**
Se a coluna vai aceitar null ou not null.
- `NULL` = ausência de valor (não é zero nem texto vazio); `NOT NULL` obriga a informar.

**Integridade de Chave**
Os valores inseridos na coluna de chave primária (PK) devem ser sempre únicos, não admitindo-se repetições nesses valores. Desta forma, as tuplas (registros) serão sempre distintas. Os valores de chave primária também não podem ser nulos.
- `UNIQUE` também impede repetição, mas aceita NULL (no SQL Server, um só) e a tabela pode ter vários.

**Integridade definida pelo Usuário**
O usuário permite definir regras comerciais que não se encaixam em outras categorias de integridade. Todas as categorias de integridade oferecem suporte à integridade definida pelo usuário.
- Na prática vira `CHECK`, trigger ou procedure, conforme a regra caiba ou não numa constraint.

## Praticando (banco LOJA)
Quando quiser declarar unique pode utilizar o CONSTRAINT, fica mais usual
- Com `CONSTRAINT nome` a restrição ganha nome próprio: aparece na mensagem de erro e se remove com `ALTER TABLE ... DROP CONSTRAINT nome`.

Código em `SQL/RESTRICOES_INTEGRIDADE.sql` (banco `LOJA`):
- `IDENTITY (100,1)`: o `id` começa em 100 e soma 1 a cada produto, por isso o `INSERT` não informa o `id`.
- `DEFAULT`: coluna omitida no `INSERT` recebe o valor padrão (o "Fone de ouvido" entra com quantidade 0 e 'Ativo').
- `ON UPDATE CASCADE`: mudar a categoria 10 para 11 levou junto os 2 produtos de informática; a mensagem conta só a linha de `CATEGORIA`.
- `ON DELETE SET NULL`: apagar o fornecedor 1 deixou o "Mouse sem fio" com `id_fornecedor` NULL.
- `ON DELETE CASCADE`: apagar a categoria 20 apagou "Caderno" e "Caneta" sem aviso, por isso o cuidado com `CASCADE`.

## Gerenciamento de Acessos – SQL Server
- **Segurança:** Logons.
  - Login = acesso ao servidor (instância); usuário = acesso a um banco, ligado a um login.
- **Política de senha:** habilitar a opção Impor política de senha e exigir que o usuário altere a senha no primeiro acesso.
- **Funções do Servidor:** manter a função public com permissões básicas, evitando conceder acessos desnecessários para prevenir alterações indevidas, principalmente por usuários iniciantes ou estagiários.
  - Função (role) = grupo de permissões; quem entra nela herda todas.
- **Mapeamento de Usuário:** definir quais bancos de dados o usuário poderá acessar. Nas funções do banco, configurar:
  - *public:* permissões básicas.
  - *db_datareader:* permite realizar consultas (SELECT) nas tabelas e exibições do banco.
    - Exibições = views. Só lê: não dá `INSERT`, `UPDATE` nem `DELETE`.

Antes de aplicar as configurações: acessar a opção SCRIPT (primeira opção) para visualizar o script SQL gerado antes de executar as alterações. Foi rodado o script e criado outra conexão no banco, no `Conectar`.
- O script gerado faz `CREATE LOGIN` (no servidor), `CREATE USER ... FOR LOGIN` (no banco) e `ALTER ROLE db_datareader ADD MEMBER`.

## Permissões: GRANT, DENY e REVOKE (DCL)
- **GRANT:** concede uma permissão específica para o usuário ou função.
- **DENY:** impede que o usuário realize uma determinada ação, este comando nega explicitamente uma permissão e tem precedência sobre GRANT.
  - Vence até permissão herdada de role: um `DENY SELECT` bloqueia o Juca mesmo sendo `db_datareader`.
- **REVOKE:** remove um GRANT ou DENY que foi dado diretamente ao usuário, depois do REVOKE, pode ainda herdar permissões de um role.
  - Ex.: o `REVOKE SELECT` em `PRODUTO` tira o GRANT, mas o Juca continua lendo pelo `db_datareader`.
  - REVOKE não é DENY: só apaga a entrada; o que valer depois depende do que sobrou (role, `public`).

> Um GRANT depois de um DENY, na mesma permissão e no mesmo usuário, substitui o DENY. A negação é superior quando as duas vêm de origens diferentes (ex.: GRANT direto no usuário e DENY numa role dele).

**Coisa que pode cair:** criar um usuário e pode ser permissão disso aqui... tipo ler as informações de determinado banco, db_datareader (pode ler os dados do banco).

Código em `SQL/PERMISSOES.sql`:
- Forma geral: `GRANT permissão ON objeto TO usuário`; `DENY` igual; `REVOKE` aceita `TO` ou `FROM`.
- A consulta em `sys.database_permissions` lista as permissões do Juca por objeto: `state_desc` mostra GRANT ou DENY.
- Os comandos do Juca rodam numa conexão logada como ele; cada um passa ou dá erro conforme a permissão daquele momento.

## Destilado


## Perguntas


## Erro que cometi
