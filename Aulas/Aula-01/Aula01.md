// Data: 31/07/2026
## Apresentação da disciplina
### Unidade 1 - Bancos de dados ativos
1.1) Automatismos
1.2) Segurança e integridade
1.3) Procedimentos armazenados

### Unidade 2 - Otimização de consultas
2.1) Principais algoritmos
2.2) Indexação
2.3) Visões

### Unidade 3 - Processamento de Transações
3.1) Fundamentos
3.2) Controle de concorrência
3.3) Sistema de recuperação

### Unidade 4 - Banco de dados objeto-relacionais
4.1) Modelo relacional estendido
4.2) Utilização em um SGBD convencional
4.3) Banco de dados temporais

## Projeto da disciplina
Aplicaremos os conhecimentos aprendidos na disciplina e aplicaremos no projeto de extensão do museu 13 de maio

## Convenções SQL - Boas práticas
[[Boas práticas]]

## Como representar Modelo Entidade Relacionamento Conceitual (ER)
Por que usamos o Modelo de Entidade Relacionamento? Um dos Principais motivos é eliminar a duplicidade de informações (ex: cadastro de produtos duplicado), em uma tabela de banco de dados **não** podemos ter duas linhas iguais, duas linhas repetidas **tuplas**. Toda tabela precisa ter pelo menos um atributo, e um **campo único**, a **PK** 

A partir do modelo Conceitual, tomaremos decisões para construir o banco físico

- atributo composto: um atributo que tem mais de uma "característica", por ex: Endereço sendo o atributo e contendo os dados de Endereço(rua, cep, etc)
- Atributo multivalorado: um atributo que pode ter 1 ou mais valores para a mesma entidade (telefone)


## Exercício de Revisão
Exercício no BrModelo, 