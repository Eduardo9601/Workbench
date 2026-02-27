CREATE OR REPLACE PROCEDURE GRZ_MOAVI_VENDAS_SP IS
BEGIN
  DECLARE

    wFILIAL_COD  VARCHAR2(10);
    wSETOR       VARCHAR2(20);
    wDATA        VARCHAR2(50);
    wHORA        VARCHAR2(20);
    wFATURAMENTO VARCHAR2(20);
    wCUPONS      VARCHAR2(10);
    wITENS       VARCHAR2(10);

    SAIDA EXCEPTION;

    CURSOR c_moavi IS
      SELECT MVTO.COD_UNIDADE AS FILIAL_COD,
             'LOJA' AS SETOR,
             TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD') AS DATA,
             MVTO.HORA_MVTO AS HORA,
             REPLACE(TO_CHAR(SUM(MVTO.VLR_FATURAMENTO)), ',', '.') AS FATURAMENTO,
             SUM(MVTO.NRO_CUPONS) AS CUPONS,
             SUM(MVTO.NRO_ITENS) AS ITENS
        FROM (SELECT A.COD_UNIDADE,
                     A.DTA_EMISSAO DTA_MVTO,
                     NVL(TO_CHAR(A.DTH_FIM_VENDA, 'HH24'), '00') || ':00' HORA_MVTO,
                     SUM(B.VLR_OPERACAO) AS VLR_FATURAMENTO,
                     COUNT(DISTINCT(A.NUM_SEQ || A.COD_MAQUINA)) NRO_CUPONS,
                     COUNT(DISTINCT C.COD_ITEM) NRO_ITENS
                FROM NL.NS_NOTAS@NLGRZ A
                JOIN NL.NS_NOTAS_OPERACOES@NLGRZ B ON B.NUM_SEQ = A.NUM_SEQ
                                                   AND B.COD_MAQUINA = A.COD_MAQUINA
                JOIN NL.CE_DIARIOS@NLGRZ C ON C.NUM_SEQ_NS = B.NUM_SEQ
                                           AND C.COD_MAQ_NS = B.COD_MAQUINA
                                           AND C.NUM_SEQ_OPER_NS = B.NUM_SEQ_OPER
               WHERE B.COD_OPER IN
                     (300, 302, 305, 4300, 4302, 4305, 3000, 3050)
                 AND A.COD_EMP = 1
                 AND A.IND_STATUS = 1
                    --AND A.DTA_EMISSAO = '31/08/2023'
                 AND A.DTA_EMISSAO BETWEEN
                     TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM')
					 AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
               GROUP BY A.COD_UNIDADE,
                        A.DTA_EMISSAO,
                        NVL(TO_CHAR(A.DTH_FIM_VENDA, 'HH24'), '00') || ':00'

              UNION ALL

              SELECT A.COD_UNIDADE_PGTO COD_UNIDADE,
                     A.DTA_PAGAMENTO DTA_MVTO,
                     NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00' HORA_MVTO,
                     0 VLR_FATURAMENTO,
                     COUNT(DISTINCT(A.NUM_LCTO_INICIAL || A.NUM_DOC_CAIXA)) NRO_CUPONS,
                     COUNT(1) NRO_ITENS
                FROM NL.CR_HISTORICOS@NLGRZ A
               WHERE A.COD_EMP = 1
                 AND A.IND_DC = 2
                 AND A.IND_LANCAMENTO = 2
                    --AND A.DTA_PAGAMENTO = '31/08/2023'
                 AND A.DTA_PAGAMENTO BETWEEN
                     TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM')
					 AND LAST_DAY(ADD_MONTHS(SYSDATE, -1))
               GROUP BY A.COD_UNIDADE_PGTO,
                        A.DTA_PAGAMENTO,
                        NVL(TO_CHAR(A.DTA_SISTEMA, 'HH24'), '00') || ':00') MVTO,
             V_DADOS_LOJAS_AVT AVT
       WHERE AVT.COD_UNIDADE = MVTO.COD_UNIDADE
       GROUP BY MVTO.COD_UNIDADE,
                TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD'),
                MVTO.HORA_MVTO
       ORDER BY MVTO.COD_UNIDADE ASC,
                TO_CHAR(MVTO.DTA_MVTO, 'YYYY-MM-DD') ASC,
                MVTO.HORA_MVTO ASC;

    r_moavi c_moavi%ROWTYPE;

    file_handle1 UTL_FILE.FILE_TYPE;

    nome_arq  VARCHAR2(50);
    cabecalho VARCHAR2(200);

  BEGIN

    cabecalho := 'filial_cod;setor;data;hora;faturamento;cupons;itens';

    nome_arq     := 'INFO_VENDAS_' || TO_CHAR(SYSDATE, 'RRRRMMDDHH24MISS') ||'.txt';
    file_handle1 := UTL_FILE.FOPEN('/mnt/nlgestao/nlcomum/Moavi/Filiais',nome_arq,'W');
    UTL_FILE.PUT_LINE(file_handle1, cabecalho);

    OPEN c_moavi;
    FETCH c_moavi
      INTO r_moavi;
    WHILE c_moavi%FOUND LOOP

      BEGIN
        wFILIAL_COD  := TO_CHAR(r_moavi.FILIAL_COD);
        wSETOR       := TO_CHAR(r_moavi.SETOR);
        wDATA        := TO_CHAR(r_moavi.DATA);
        wHORA        := TO_CHAR(r_moavi.HORA);
        wFATURAMENTO := TRIM(TO_CHAR(r_moavi.FATURAMENTO));
        wCUPONS      := TO_CHAR(r_moavi.CUPONS);
        wITENS       := TO_CHAR(r_moavi.ITENS);

        UTL_FILE.PUT_LINE(file_handle1,
                          wFILIAL_COD || ';' || wSETOR || ';' || wDATA || ';' ||
                          wHORA || ';' || wFATURAMENTO || ';' || wCUPONS || ';' ||
                          wITENS);

      END;
      FETCH c_moavi
        INTO r_moavi;
    END LOOP;
    CLOSE c_moavi;

    UTL_FILE.FCLOSE(file_handle1);

  EXCEPTION
    WHEN SAIDA THEN
      NULL;
  END;
END GRZ_MOAVI_VENDAS_SP;


