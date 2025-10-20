--COMANDO PARA INSERIR NOVO CAMINHO DE SALVAMENTO ARQUIVO AFD

SELECT * FROM DBO.ArquivoAFD;



--COMANDO PARA INSERIR NOVAS LINHAS DE LOCAL DE SALVAMENTOS DOS ARQUIVOS AFDs PARA AS LOJAS

INSERT INTO DBO.ArquivoAFD (localArquivo, repId, tipoArquivo, formato, diasPeriodo, adicionarData, urlServidor, usuarioServidor, senhaServidor, tokenAtual, urlColeta)
SELECT
    'M:\Antirion\AFD\Nova pasta', repId, tipoArquivo, formato, diasPeriodo, adicionarData, urlServidor, usuarioServidor, senhaServidor, tokenAtual, urlColeta
FROM
    DBO.ArquivoAFD;


--CASO PRECISE DELETAR TODOS OS REGISTROS COM O NOME DO ARQUIVO ESPECIFICADO

DELETE FROM DBO.ArquivoAFD
WHERE localArquivo = 'M:\Antirion\AFD\Nova pasta';


--CASO PRECISE SOMENTE ALTERAR

UPDATE DBO.ArquivoAFD
SET localArquivo = 'M:\Antirion\AFD\Nova pasta'
WHERE arquivoBilheteId = 145
