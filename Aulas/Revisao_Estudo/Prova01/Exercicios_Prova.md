# Exercícios do professor — revisão focada
> aqui — isso já está em `EMPRESA.sql` e `BIBLIOTECA.sql`, use os scripts
> existentes pra montar o banco antes de resolver).

---

## Mapa dos conteúdos fundamentais

Tudo o que foi dado até a Aula 08, organizado por dependência — cada ramo
assume que o anterior já está firme. A prova pesa mais nos ramos marcados
com ⚑, segundo a nota de aula.

```
SQL
├── DDL  (CREATE / ALTER)          — EMPRESA.sql / BIBLIOTECA.sql
├── DML  (INSERT / UPDATE / DELETE)
├── DQL  (SELECT) ⚑
│   ├── Ordem de execução
│   │   ├── 1º FROM / JOIN
│   │   ├── 2º WHERE        — não aceita função de agregação
│   │   ├── 3º GROUP BY
│   │   ├── 4º HAVING       — aceita agregação
│   │   ├── 5º SELECT
│   │   └── 6º ORDER BY
│   ├── Funções de agregação        — AVG / COUNT / SUM / MIN / MAX + GROUP BY
│   ├── JOINs ⚑
│   │   ├── INNER JOIN      — só o que casa nas duas tabelas
│   │   ├── LEFT JOIN + WHERE x IS NULL  — "o que não tem" ⚑
│   │   └── SELF JOIN       — ex.: funcionário/supervisor
│   ├── UNION / INTERSECT / EXCEPT  — precisa padronizar as colunas das duas consultas
│   └── Subqueries
│       ├── Escalar         — compara com 1 valor
│       └── Lista           — IN
├── Variáveis e controle de fluxo ⚑
│   ├── DECLARE / SET / SELECT @var = ...
│   ├── IF / ELSE / IIF / CASE
│   ├── WHILE
│   └── CAST / CONVERT
├── Funções ⚑
│   ├── Escalar              — sempre retorna 1 valor
│   ├── Inline table-valued  — vira 1 SELECT só
│   └── Multi-statement table-valued
└── Stored Procedures — última aula ⚑
    ├── IF EXISTS antes de INSERT
    ├── pode fazer DML         — função não pode
    └── OUTPUT                 — não cai na prova
```

Leitura da árvore, ligando com as dicas da nota de prova:

- **DQL/SELECT** é o tronco mais cobrado: 4 a 5 questões de marcar são sobre
  a ordem e o papel de cada cláusula (`WHERE` vs. `HAVING`, o que cada uma
  aceita).
- **JOINs**, dentro de DQL, é onde mora a pergunta de montar consulta mais
  citada: `LEFT JOIN` + `WHERE ... IS NULL` para "o que não tem" (editora
  sem livro, departamento sem funcionário — mesmo padrão, tabelas diferentes).
- **Funções** puxam de volta variáveis e subqueries — uma função escalar
  quase sempre embute uma subquery escalar por dentro.
- **Stored Procedures** é o ramo mais novo (última aula) e o único que soma
  DML — é onde a diferença função-vs-procedure mais é cobrada.

### O que ficou de fora e por quê

- **DCL (`GRANT`/`REVOKE`)** — tirei do mapa: não achei nenhuma menção em
  nenhum material do professor (`Aula-01` a `Aula-08`), então incluir passaria
  a falsa impressão de que caiu em aula.
- **`UNION`/`INTERSECT`/`EXCEPT`** — confirmado em `Aula-04_JOINS/CONSULTAS_JOIN.SQL`
  e na nota da `Aula05.md` ("## EXCEPT"), por isso entrou como ramo próprio.
- **`SELF JOIN`** — confirmado no mesmo arquivo da Aula 04, exemplo
  funcionário/supervisor — bate com a função `fn_NomeSupervisor` da Aula 07.

---

## 1. Consultas — banco BIBLIOTECA

Fonte: `Aula-02_MySqlConsultas/Exercicio/Aula 01 - Atividade - Nivelamento.pdf`,
questões 7 a 10.

7. Crie uma consulta para relacionar todos os dados disponíveis de todos os
   livros existentes na biblioteca em ordem alfabética de título.
8. Crie uma consulta para relacionar todos os dados disponíveis de todos os
   livros existentes na biblioteca em ordem alfabética de autor.
9. Crie uma consulta para relacionar todos os dados disponíveis dos livros da
   categoria de Literatura Juvenil em ordem de ano.
10. Crie uma consulta para relacionar todos os dados disponíveis dos livros de
    humor ou ficção científica com ano entre 2000 e 2010.

---

## 2. Variáveis, condicionais, loop — banco EMPRESA

Fonte: `Aula-06_LacosEcondicionais/Exercicios/exerciciosSQL.md`.

1.4. Declare três variáveis: `@SalarioBase` (`DECIMAL(10,2)`), `@Bonus`
(`DECIMAL(10,2)`) e `@SalarioTotal` (`DECIMAL(10,2)`). Atribua os valores
5000.00 e 800.00 a `@SalarioBase` e `@Bonus`, calcule `@SalarioTotal` somando
os dois e exiba o resultado.

2.4. Declare uma variável `@DataNascimento` do tipo `VARCHAR(10)` e atribua a
ela o valor `'15/08/1990'`. Converta essa variável para o tipo `DATE`
utilizando `CONVERT` e exiba o resultado.

3.2. Crie uma variável `@NotaFinal` e atribua um valor entre 0 e 100. Utilize
um bloco `IF/ELSE` para exibir: "Aprovado com Excelência" (nota ≥ 90),
"Aprovado" (nota ≥ 70 e < 90), "Em Recuperação" (nota ≥ 50 e < 70) ou
"Reprovado" (nota < 50).

4.4. Crie uma variável `@Numero` com valor inicial igual a 2. Escreva um loop
`WHILE` que continue a dobrar o valor de `@Numero` até que ele ultrapasse
1000, exibindo o valor a cada iteração.

5.1 (desafio). Crie um procedimento armazenado chamado `CalcularDesconto`
que: receba como parâmetros o preço original de um produto e a quantidade
comprada; calcule o desconto baseado na quantidade (10% se a quantidade for
maior que 10); retorne o preço final após o desconto; utilize variáveis para
armazenar preço original, quantidade, desconto e preço final; utilize um
bloco `IF/ELSE` para determinar o desconto; se a quantidade comprada for
menor que 5, utilize um loop `WHILE` para aplicar um desconto adicional de 1%
por unidade acima de 1, até atingir a quantidade comprada.

---

## 3. Funções — banco EMPRESA

Fonte: `Aula-07_FuncoesStoreProcedure/Exercicios/Funcoes/Funções - Banco Empresa.pdf`,
questões 1 a 5 (as que batem no nível dado em aula).

1. Crie uma função `fn_ProjetosPorFuncionario` que receba o Cpf de um
   funcionário e retorne os nomes dos projetos nos quais ele trabalha
   (usando a tabela `TRABALHA_EM`).
2. Crie uma função `fn_ListarDependentes` que receba o Cpf de um funcionário
   e retorne uma tabela com os nomes e parentescos de todos os seus
   dependentes.
3. Crie uma função `fn_NomeSupervisor` que receba o Cpf de um funcionário e
   retorne o nome completo do seu supervisor (usando a coluna
   `Cpf_supervisor` da tabela `FUNCIONARIO`).
4. Crie uma função `fn_GanhaMaisQueSupervisor` que receba o Cpf de um
   funcionário e retorne 1 (verdadeiro) se o salário dele for maior que o
   salário de seu supervisor, ou 0 (falso) caso contrário.
5. Crie uma função `fn_AnoAposentadoria` que receba a data de nascimento de
   um funcionário e retorne o ano em que ele poderá se aposentar,
   considerando 65 anos como idade de aposentadoria.

---

## 4. Stored Procedures — banco BIBLIOTECA

Fonte: `Aula-07_FuncoesStoreProcedure/Exercicios/Store Procedure/Store Procedure - Banco Biblioteca.pdf`,
as mais pontuais: padrão `IF EXISTS` antes de inserir e o padrão
`LEFT JOIN + IS NULL` que a prova cobra ("que não têm").

1. Crie uma procedure que permita inserir uma nova categoria na tabela
   "Categoria".
4. Implemente uma procedure para excluir um autor e remover sua associação
   com os livros na tabela "LivroAutor".
5. Crie uma procedure que receba o nome de uma categoria e retorne todos os
   livros dentro dessa categoria.
19. Desenvolva uma procedure para listar livros que não têm autores
    associados na tabela "LivroAutor".
20. Implemente uma procedure para listar livros que não têm uma editora
    especificada.

---

## Como usar isto

- Resolve escrevendo a query antes de rodar — prever antes de rodar é o que
  treina leitura de erro quando a prova não deixar rodar nada.
- Marca os itens que exigiram mais de uma tentativa — viram material pra
  registrar depois como `## Erro que cometi` na nota da aula correspondente.

---

## Os 5 principais

Se sobrar pouco tempo, é nestes que eu focaria — cada um força uma combinação
de cláusulas diferente, não só uma sintaxe isolada.

1. **Consulta #10 (item 1, BIBLIOTECA)** — Crie uma consulta para relacionar
   todos os dados disponíveis dos livros de humor ou ficção científica com
   ano entre 2000 e 2010. Junta `WHERE` composto (`IN`/`OR` + `BETWEEN`) com
   `JOIN` de quatro tabelas e `ORDER BY` — é o exercício que mais cláusulas
   do `SELECT` obriga a usar juntas.
2. **Condicional 3.2 (item 2, EMPRESA)** — Crie uma variável `@NotaFinal` e
   atribua um valor entre 0 e 100. Utilize um bloco `IF/ELSE` para exibir:
   "Aprovado com Excelência" (nota ≥ 90), "Aprovado" (nota ≥ 70 e < 90), "Em
   Recuperação" (nota ≥ 50 e < 70) ou "Reprovado" (nota < 50). É o formato
   exato de questão "monte a consulta" que envolve faixas — o mesmo raciocínio
   do `CASE` de nível salarial que caiu em aula.
3. **Função `fn_GanhaMaisQueSupervisor` (item 4, EMPRESA)** — Crie uma função
   que receba o Cpf de um funcionário e retorne 1 (verdadeiro) se o salário
   dele for maior que o salário de seu supervisor, ou 0 (falso) caso
   contrário. Obriga a função escalar a comparar contra um valor buscado na
   mesma tabela (self-reference) — mais armadilha que uma função de cálculo
   direto.
4. **Stored Procedure #20 (item 4, BIBLIOTECA)** — Implemente uma procedure
   para listar livros que não têm uma editora especificada. É literalmente o
   padrão `LEFT JOIN + IS NULL` que a nota de prova aponta como a pergunta
   certa de cair ("me liste as editoras com nenhum livro atrelado a elas"),
   só que na direção contrária.
5. **Desafio `CalcularDesconto` (5.1, EMPRESA)** — o mais completo dos cinco:
   procedure + variáveis + `IF/ELSE` + `WHILE` num único exercício. Se sair
   dele sem travar, os outros quatro ficam mais fáceis por comparação.
