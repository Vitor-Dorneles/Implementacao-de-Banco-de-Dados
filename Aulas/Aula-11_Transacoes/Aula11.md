// Data: 09/10/2026
# Transações
É importante para planejarmos como iremos afetar o banco,
Transação é um conjunto de operações tratado como uma unidade: ou todas são aplicadas, ou nenhuma. É isso que permite planejar a alteração antes de ela valer de verdade, 
por exemplo numa transferência entre contas (debita uma, credita a outra): se a segunda falhar, o `ROLLBACK` devolve a primeira.
**comandos básicos:**
 - BEGIN TRANSACTION : inicia nova transação
 - COMMIT TRANSACTION: Confirma a transação
 - ROLLBACK TRANSACTION: Desfaz todas as operações realizadas desde o inicio

## SavePoint
como se fosse um checkpoint, podemos voltar para um estado definido

Correção: a ideia está certa, mas "checkpoint" no SGBD é outra coisa (gravação das páginas em memória no disco). O termo aqui é savepoint: um marcador dentro da transação. No SQL Server cria-se com `SAVE TRANSACTION nome` e volta-se com `ROLLBACK TRANSACTION nome`, que desfaz só o que veio depois do marcador. A transação continua aberta e ainda precisa de `COMMIT` ou `ROLLBACK` no fim. Um `ROLLBACK` sem nome desfaz tudo, savepoints incluídos.

## ex
No exemplo do `TRANSACOES.sql`: depois do `BEGIN TRAN`, o `INSERT` do id 10 viola a PK (já existe a Maria 10) e `@@ERROR` devolve o código do erro. Esse erro não fecha a transação: ela segue aberta, e quem decide é você, com `COMMIT` ou `ROLLBACK`. Por isso se testa o `@@ERROR` e, se for diferente de 0, faz-se o `ROLLBACK`.
 - `@@ROWCOUNT`, 
devolve quantas linhas o último comando afetou. Outro útil nas transações é `@@TRANCOUNT`, que diz quantas transações estão abertas na conexão (0 = nenhuma).
## Isolamento
Uma transação por vez
Isolamento é o "I" do ACID: cada transação enxerga o banco como se estivesse sozinha, sem ver as alterações não confirmadas (sem `COMMIT`) das outras. Isso evita que duas transações mexendo na mesma conta (ex.: saldo da tabela `conta`) se misturem e deixem o dado inconsistente.
"uma transação por vez" é o efeito que o isolamento garante, não o que o banco faz de fato. O SGBD executa várias transações ao mesmo tempo e usa bloqueios (locks) para que o resultado seja equivalente a rodá-las uma depois da outra. O quanto isso é rígido depende do nível de isolamento.

## prox aula
trigger

## Destilado


## Perguntas


## Erro que cometi
