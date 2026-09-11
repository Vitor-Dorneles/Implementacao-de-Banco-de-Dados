## Exercícios

#### 1. **Variáveis no SQL Server**
   1.1. **Declaração de Variáveis**  
   Declare três variáveis no SQL Server: uma para armazenar o nome de um produto (tipo `VARCHAR`), outra para armazenar a quantidade em estoque (tipo `INT`) e a última para armazenar o preço do produto (tipo `DECIMAL(10,2)`).

   1.2. **Atribuição de Valores**  
   Atribua os seguintes valores às variáveis declaradas:
   - Nome do Produto: "Notebook"
   - Quantidade em Estoque: 15
   - Preço do Produto: 2999.99

   1.3. **Exibição de Valores**  
   Exiba os valores atribuídos às variáveis utilizando tanto o comando `PRINT` quanto o comando `SELECT`.

   1.4. **Cálculo utilizando Variáveis**  
   Declare três variáveis: `@SalarioBase` (tipo `DECIMAL(10,2)`), `@Bonus` (tipo `DECIMAL(10,2)`) e `@SalarioTotal` (tipo `DECIMAL(10,2)`). Atribua valores de 5000.00 e 800.00 às variáveis `@SalarioBase` e `@Bonus`, respectivamente. Em seguida, calcule o valor total do salário somando `@SalarioBase` e `@Bonus` e armazene o resultado em `@SalarioTotal`. Exiba o valor de `@SalarioTotal`.

Essas questões adicionais aprofundam a compreensão dos tópicos abordados, oferecendo uma prática extra para manipulação de variáveis, conversões, estruturas condicionais e loops no SQL Server.

#### 2. **Conversão de Dados**
   2.1. **CAST**  
   Converta a data atual (`GETDATE()`) para o formato `VARCHAR(10)` utilizando a função `CAST` e exiba o resultado.

   2.2. **CONVERT**  
   Converta o número 12345.67 para o tipo `INT` utilizando a função `CONVERT` e exiba o resultado.

   2.3. **Exercício Prático**  
   Crie uma variável para armazenar um número decimal e outra para armazenar um número inteiro. Atribua valores a essas variáveis e utilize `CAST` e `CONVERT` para converter o decimal para inteiro e vice-versa, exibindo os resultados.

   2.4. **Conversão de String para Data**  
   Declare uma variável `@DataNascimento` do tipo `VARCHAR(10)` e atribua a ela o valor '15/08/1990'. Em seguida, converta essa variável para o tipo `DATE` utilizando a função `CONVERT` e exiba o resultado.


#### 3. **Estruturas Condicionais no SQL**
   3.1. **IF / ELSE Básico**  
   Crie uma variável chamada `@Idade` e atribua a ela um valor inteiro. Escreva um bloco `IF / ELSE` que exiba "Maior de Idade" se a idade for maior ou igual a 18, e "Menor de Idade" caso contrário.

   3.2. **IF / ELSE com Múltiplas Condições**  
   Crie uma variável chamada `@NotaFinal` e atribua um valor entre 0 e 100. Utilize um bloco `IF / ELSE` para exibir as seguintes mensagens baseadas no valor da nota:
   - Nota >= 90: "Aprovado com Excelência"
   - Nota >= 70 e < 90: "Aprovado"
   - Nota >= 50 e < 70: "Em Recuperação"
   - Nota < 50: "Reprovado"

  3.3. **IF / ELSE com Operadores Lógicos**  
   Crie uma variável `@Ano` do tipo `INT` e atribua a ela um valor. Escreva um bloco `IF / ELSE` que exiba "Ano Bissexto" se o ano for divisível por 4, mas não divisível por 100, ou se for divisível por 400. Caso contrário, exiba "Ano Comum".


#### 4. **Loops no SQL**
   4.1. **While Simples**  
   Crie um loop `WHILE` que exiba os números de 1 a 10, incrementando uma variável chamada `@Contador` a cada iteração.

   4.2. **While com Condição Complexa**  
   Escreva um loop `WHILE` que comece com uma variável `@Valor` igual a 100 e a cada iteração subtraia 5 de `@Valor`. O loop deve continuar até que `@Valor` seja menor que 50. Exiba o valor de `@Valor` a cada iteração.

   4.3. **Exercício Prático**  
   Crie um loop `WHILE` que percorra uma lista de produtos armazenada em uma tabela chamada `Produtos` e exiba o nome de cada produto cujo preço seja maior que 100. Utilize uma variável `@Indice` para controlar o loop e uma variável `@PrecoLimite` para armazenar o valor de 100.

   4.4. **Loop While com Incremento Condicional**  
   Crie uma variável `@Numero` com valor inicial igual a 2. Escreva um loop `WHILE` que continue a dobrar o valor de `@Numero` até que ele ultrapasse 1000. Exiba o valor de `@Numero` a cada iteração.


#### 5. **Exercício de Integração - DESAFIO**
   5.1. **Procedimento Armazenado com Variáveis, Condicional e Loop**
   Crie um procedimento armazenado chamado `CalcularDesconto` que:
   - Receba como parâmetros o preço original de um produto e a quantidade comprada.
   - Calcule o desconto baseado na quantidade comprada (10% de desconto se a quantidade for maior que 10).
   - Retorne o preço final após o desconto.
   - Utilize variáveis para armazenar o preço original, a quantidade, o desconto e o preço final.
   - Utilize um bloco `IF / ELSE` para determinar o desconto.
   - Se a quantidade comprada for menor que 5, utilize um loop `WHILE` para aplicar um desconto adicional de 1% por unidade acima de 1, até atingir a quantidade comprada.