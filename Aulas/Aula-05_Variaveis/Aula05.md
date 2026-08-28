// Data: 28/08/2026
## EXCEPT
A sua regra é sempre o primeiro select menos o segundo
## Declaração group BY
importante
é uma instrução que agrupa linhas com os mesmos valores em linhas de resumo, como: "Encontre o número de clientes em cada país"
A order by é bem importante, e ela geralmente precisa do JOIN entre duas tabelas 
```SQL
-- Media de horas trabalhadas por projeto
SELECT AVG(t.Horas) AS 'Horas Projeto', P.Projnome
FROM TRABALHA_EM AS T
JOIN PROJETO AS P
ON T.Pnr = P.Projnumero
GROUP BY P.Projnome
ORDER BY [Horas Projeto];
```
# Banco de dados Ativo
## Variáveis SQL
```SQL
DECLARE @VALOR INT; -- inicialiaza por padrão como NULL
SET @VALOR = 10;
```
### IF/ELSE - WHILE
