/*PROCESSO PARA AJUSTAR INTEGRAÇÃO MOAVI - BASE DO REP*/


SELECT * 
FROM dbo.ArquivoAFD
where localArquivo = '\\192.168.200.62\nlgestao\nlcomum\Moavi\Batidas'


select * 
from dbo.ColetaAutomatica



UPDATE dbo.ColetaAutomatica
SET 
    coletaProgHorario1 = '08:30',
    coletaProgHorario2 = '13:00',
    coletaProgHorario3 = '17:00',
    coletaProgHorario4 = '20:00'



INSERT INTO dbo.ArquivoAFD (
    localArquivo,
    repId,
    tipoArquivo,
    formato,
    diasPeriodo,
    AdicionarData,
    urlServidor,
    usuarioServidor,
    senhaServidor,
    tokenAtual,
    urlColeta
)
SELECT
    '\\192.168.200.62\nlgestao\nlcomum\Moavi\Batidas' AS localArquivo,
    origem.repId,
    origem.tipoArquivo,
    origem.formato,
    origem.diasPeriodo,
    origem.AdicionarData,
    origem.urlServidor,
    origem.usuarioServidor,
    origem.senhaServidor,
    origem.tokenAtual,
    origem.urlColeta
FROM dbo.ArquivoAFD AS origem
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ArquivoAFD AS destino
    WHERE destino.repId = origem.repId
      AND destino.localArquivo = '\\192.168.200.62\nlgestao\nlcomum\Moavi\Batidas'
)
