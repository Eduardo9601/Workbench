SELECT * FROM dbo.Rep 
where repId = 102


SELECT a.nome,
       a.teclado,
	   a.cpf as cpf_rep,
	   b.cpf as cpf_folha,
	   b.data_admissao,
	   B.IND_BATE_PONTO
FROM dbo.Empregado a 
left join dbo.TB_COLABS_ADM_V2 b on a.teclado = b.cod_contrato
where a.empregadorId = 31
AND B.IND_BATE_PONTO IS NOT NULL
AND B.IND_BATE_PONTO = 'S'
ORDER BY a.nome ASC



SELECT * FROM dbo.Empregado
where empregadorId = 31
AND CPF IS NULL

SELECT *
INTO dbo.Empregado_BK
FROM dbo.Empregado
WHERE empregadorId = 31;






/*===========================================================*/



DELETE FROM dbo.Empregado
where empregadorId = 31
AND CPF IS NULL



DELETE FROM dbo.Empregado
WHERE empregadorId = 31
  AND teclado IN (
      SELECT a.teclado
      FROM dbo.Empregado a
      LEFT JOIN dbo.TB_COLABS_ADM b ON a.teclado = b.cod_contrato
      WHERE a.empregadorId = 31
        AND b.data_admissao IS NULL
  );



DELETE FROM dbo.Empregado
WHERE empregadorId = 31
  AND teclado IN (
      SELECT a.teclado
      FROM dbo.Empregado a
      LEFT JOIN dbo.TB_COLABS_ADM_V2 b ON a.teclado = b.cod_contrato
      WHERE a.empregadorId = 31
        AND b.IND_BATE_PONTO = 'N'
  );





/*===========================================================*/


/*UPDATE e
SET e.CPF = c.CPF
FROM dbo.Empregado e
INNER JOIN TB_COLABS_ADM c
    ON e.Teclado = c.COD_CONTRATO
WHERE e.EmpregadorId = 31;


UPDATE e
SET e.CPF = c.CPF
FROM dbo.Empregado e
INNER JOIN TB_COLABS_ADM c
    ON e.Teclado = c.COD_CONTRATO
WHERE e.EmpregadorId = 31
  AND e.CPF IS NULL;*/












INSERT INTO dbo.Rep
  (repId,
   terminalId,
   descricao,
   ip,
   porta,
   numero,
   sincronizado,
   chaveComunicacao,
   empregadorId,
   serial,
   formatoCartaoId,
   repIdSenior,
   repIdLeitoraSenior,
   repClient,
   ipServidor,
   mascaraRede,
   Gateway,
   portaServidor,
   tempoEspera,
   intervaloConexao,
   portaVariavel,
   nomeServidor,
   GrupoRepID,
   Rederemota,
   posMem,
   ultimoNSR,
   TipoConexao,
   NomeHost,
   ConfiguracaoLeitorCPF,
   ConfiguracaoLeitorDataHora,
   FormatoCartaoProxID,
   DNS,
   TipoConexaoDNS,
   NomeRep,
   envioNSR,
   portaNuvem,
   intervaloNuvem,
   habilitaNuvem,
   GMTRepA,
   VersaoFWCompleto)
VALUES
  (102,
   17,
   'ADMINISTRAÇÃO',
   '192.168.115.207',
   51000,
   1,
   1,
   'AUTENTICACAO',
   31,
   '00009003660008229',
   0,
   0,
   0,
   0,
   '192.168.115.50',
   '255.255.255.0',
   NULL,
   60000,
   0,
   5,
   1,
   NULL,
   0,
   0,
   '000 025 090 050',
   100915,
   0,
   NULL,
   '821.692.500-00',
   '2024-11-27',
   7,
   NULL,
   0,
   NULL,
   443,
   0,
   0,
   NULL,
   '4.51');

