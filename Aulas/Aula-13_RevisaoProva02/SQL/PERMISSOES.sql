-- Criação do usuário: o que o botão SCRIPT da tela de Logon gera (aproximado)
USE master;
GO
CREATE LOGIN Juca WITH PASSWORD = 'Senha@123' MUST_CHANGE, -- troca a senha no primeiro acesso
	DEFAULT_DATABASE = LOJA,
	CHECK_EXPIRATION = ON, -- obrigatório para usar MUST_CHANGE
	CHECK_POLICY = ON; -- impor política de senha
GO
USE LOJA;
GO
CREATE USER Juca FOR LOGIN Juca; -- mapeamento: login (servidor) -> usuário (banco)
ALTER ROLE db_datareader ADD MEMBER Juca; -- pode dar SELECT em todas as tabelas e views
GO

-- Permissões por objeto
GRANT SELECT, INSERT ON [dbo].[CATEGORIA] TO Juca;
GRANT SELECT ON [dbo].[FORNECEDOR] TO Juca;
GRANT SELECT ON [dbo].[PRODUTO] TO Juca;

DENY INSERT ON [dbo].[CATEGORIA] TO Juca; -- substitui o GRANT INSERT acima

REVOKE SELECT ON [dbo].[PRODUTO] TO Juca; -- tira o GRANT, mas Juca ainda lê PRODUTO pelo db_datareader
REVOKE INSERT ON [dbo].[PRODUTO] TO Juca; -- nunca foi dado: não muda nada
REVOKE INSERT ON [dbo].[CATEGORIA] TO Juca; -- remove o DENY; INSERT fica sem permissão nenhuma

--Query para retonar as permissões que são dadas a nível de objetos
SELECT	state_desc, prmsn.permission_name as [Permission], sp.type_desc, sp.name,
		grantor_principal.name AS [Grantor], grantee_principal.name as [Grantee]
FROM sys.all_objects AS sp
	INNER JOIN sys.database_permissions AS prmsn
	ON prmsn.major_id = sp.object_id AND prmsn.minor_id=0 AND prmsn.class = 1 -- class 1 = objeto (tabela, view...)
	INNER JOIN sys.database_principals AS grantor_principal
	ON grantor_principal.principal_id = prmsn.grantor_principal_id
	INNER JOIN sys.database_principals AS grantee_principal
	ON grantee_principal.principal_id = prmsn.grantee_principal_id
WHERE grantee_principal.name = 'Juca'


--- comandos usando o usuario JUCa
-- outra conexão logada como Juca, ou nesta: EXECUTE AS USER = 'Juca'; ... REVERT;
SELECT *
FROM CATEGORIA; -- ok: GRANT SELECT e db_datareader

INSERT INTO CATEGORIA
VALUES (66,'Drogas'); -- erro: negado pelo DENY ou, depois do REVOKE, sem GRANT

UPDATE CATEGORIA
SET nome = 'Remedios'
WHERE id = 11; -- erro: nunca recebeu UPDATE

DELETE FROM CATEGORIA
WHERE id = 11; -- erro: nunca recebeu DELETE
