USE MICROSOFT;
GO

-- 1) Funcionários que não são chefes
CREATE OR ALTER VIEW vw_funcionarios_nao_chefes
AS
SELECT E.EmployeeID, CONCAT(E.FirstName, ' ', E.LastName) AS 'NOME', E.Title AS 'Cargo'
FROM Employees AS E
WHERE E.EmployeeID NOT IN (
    SELECT S.ReportsTo
    FROM Employees AS S
    WHERE S.ReportsTo IS NOT NULL); -- com NULL o NOT IN não retorna nada
GO

SELECT * FROM vw_funcionarios_nao_chefes;
GO

-- 2) Quanto cada produto foi vendido
CREATE OR ALTER VIEW vw_vendas_produto
AS
SELECT P.ProductID, P.ProductName AS 'Produto', SUM(OD.Quantity) AS 'Quantidade'
FROM Products AS P
JOIN [Order Details] AS OD
ON OD.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName;
GO

SELECT * FROM vw_vendas_produto;
GO

-- 3) Territórios e quantidade de vendedores
CREATE OR ALTER VIEW vw_territorio_vendedores
AS
SELECT T.TerritoryID, T.TerritoryDescription AS 'Territorio', COUNT(ET.EmployeeID) AS 'Vendedores'
FROM Territories AS T
LEFT JOIN EmployeeTerritories AS ET
ON ET.TerritoryID = T.TerritoryID
GROUP BY T.TerritoryID, T.TerritoryDescription;
GO

SELECT * FROM vw_territorio_vendedores;
GO

-- 4) Cliente da venda de maior valor
CREATE OR ALTER VIEW vw_cliente_maior_venda
AS
SELECT TOP 1 C.CompanyName AS 'Cliente', O.OrderID,
    CAST(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)) AS DECIMAL(10,2)) AS 'Valor' -- Discount é REAL, sem CAST sai float
FROM Customers AS C
JOIN Orders AS O
ON O.CustomerID = C.CustomerID
JOIN [Order Details] AS OD
ON OD.OrderID = O.OrderID
GROUP BY C.CompanyName, O.OrderID
ORDER BY Valor DESC;
GO

SELECT * FROM vw_cliente_maior_venda;
GO

-- 5) Vendedores por lucratividade (total vendido)
CREATE OR ALTER VIEW vw_vendedores_lucro
AS
SELECT E.EmployeeID, CONCAT(E.FirstName, ' ', E.LastName) AS 'Vendedor',
    CAST(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)) AS DECIMAL(10,2)) AS 'Total'
FROM Employees AS E
JOIN Orders AS O
ON O.EmployeeID = E.EmployeeID
JOIN [Order Details] AS OD
ON OD.OrderID = O.OrderID
GROUP BY E.EmployeeID, E.FirstName, E.LastName;
GO

-- view não aceita ORDER BY sem TOP, ordena na consulta
SELECT *
FROM vw_vendedores_lucro
ORDER BY Total DESC;
GO

-- 6) Produtos com estoque
CREATE OR ALTER VIEW vw_produtos_estoque
AS
SELECT P.ProductName AS 'Produto', S.CompanyName AS 'Fornecedor', C.CategoryName AS 'Categoria',
    P.UnitPrice AS 'Preco',
    CASE WHEN P.Discontinued = 1 THEN 'Sim' ELSE 'Não' END AS 'Descontinuado'
FROM Products AS P
LEFT JOIN Suppliers AS S -- SupplierID e CategoryID aceitam NULL
ON S.SupplierID = P.SupplierID
LEFT JOIN Categories AS C
ON C.CategoryID = P.CategoryID
WHERE P.UnitsInStock > 0;
GO

SELECT * FROM vw_produtos_estoque;
GO
