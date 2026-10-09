-- 5.1 (desafio). Crie um procedimento armazenado chamado `CalcularDesconto`
-- que: receba como parâmetros o preço original de um produto e a quantidade
-- comprada; calcule o desconto baseado na quantidade (10% se a quantidade for
-- maior que 10); retorne o preço final após o desconto; utilize variáveis para
-- armazenar preço original, quantidade, desconto e preço final; utilize um
-- bloco `IF/ELSE` para determinar o desconto; se a quantidade comprada for
-- menor que 5, utilize um loop `WHILE` para aplicar um desconto adicional de 1%
-- por unidade acima de 1, até atingir a quantidade comprada.

CREATE OR ALTER PROCEDURE sp_CalcularDesconto(@precoOg DECIMAL(10,2), @qtd int)
AS
BEGIN
DECLARE @precoFinal DECIMAL(10,2) = @precoOg;
    IF(@qtd > 10)
        BEGIN
            -- CALCULO DO DESCONTO
            DECLARE @desconto FLOAT = 0.10;
            SET @precoFinal = @precoOg- (@precoOg * @desconto)
            PRINT CAST (@precoFinal AS VARCHAR (14));
        END;
    ELSE IF (@qtd < 5)
        BEGIN
            DECLARE @i INT = 2;
            DECLARE @descontoAcumulativo FLOAT = 0.00;
            WHILE (@i <= @qtd)
                BEGIN
                    SET @descontoAcumulativo = @descontoAcumulativo + (0.01);
                    set @precoFinal = @precoOg - (@precoOG * @descontoAcumulativo)
                    SET @i = @i + 1;
                END;
            PRINT CAST (@precoFinal AS VARCHAR (14));
        END;
    ELSE
        BEGIN
            PRINT 'sem desconto';
            
            PRINT CAST(@precoFinal AS VARCHAR(14))
        END;
END;
GO

EXEC sp_CalcularDesconto 30.50, 3;


EXEC sp_help 'FUNCIONARIO';