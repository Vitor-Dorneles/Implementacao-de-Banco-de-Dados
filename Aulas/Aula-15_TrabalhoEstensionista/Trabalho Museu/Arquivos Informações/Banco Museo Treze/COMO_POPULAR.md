# Como popular o banco

1. **Servidor** (uma vez por reinício do MySQL):
   ```sql
   SET GLOBAL local_infile = 1;
   ```
2. **Workbench**: Edit Connection → Advanced → Others: `OPT_LOCAL_INFILE=1` → reconectar.
3. **Caminho**: no `popular_banco.sql`, trocar `'misc/dados_museu.json'` pelo caminho absoluto (com `/`, sem acentos), se extrair na pasta downloads no lab é só usar o caminho: 'C:/Users/laboratorio/Downloads/Museu_Treze_de_Maio-main/Museu_Treze_de_Maio-main/misc/dados_museu.json'
4. Rodar `criar_banco.sql` e depois `popular_banco.sql`.
