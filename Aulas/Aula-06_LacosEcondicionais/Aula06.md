// Data: 04/09/2026
Hoje já vimos sobre a função cast() e o CONVERT

## Condições IF/ELSE
IF condição
    BEGIN
        bloco de código
    END;
### iif
função de condição
IIF(F.Salario < 20000, 'Baixo', 'Alto') AS 'Nivel Salarial'

## Switch CASE
-- CASE
SELECT 
		F.Pnome,
		F.Unome,
		F.Salario,
	CASE
		WHEN F.Salario <= 10000 AND F.Salario > 0 THEN 'Baixo'
		WHEN F.Salario > 10000 AND F.Salario <=30000 THEN 'Medio'
		WHEN F.Salario > 30000 THEN 'Alto'
		ELSE 'ERRO'
	END AS 'Nivel salarial'
FROM FUNCIONARIO AS F;
## while
WHILE condição
    BEGIN
        bloco de códigos
    END


5 exercícios para fazer

aula que vem vamos aprender funções
## Destilado


## Perguntas


## Erro que cometi
