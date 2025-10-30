WITH
CONTRATOS AS (
  SELECT DISTINCT CT.STATUS,
                  CT.DES_STATUS,
                  CT.COD_CONTRATO,
                  CT.DES_PESSOA,
                  CT.DATA_ADMISSAO,
                  CT.DATA_DEMISSAO,
                  -- Tempo de empresa individual
                  TRUNC(MONTHS_BETWEEN(:DATA_FIM, CT.DATA_AVANCO) / 12) ||
                  ' ano(s)' || ' e ' ||
                  TRUNC(MOD(MONTHS_BETWEEN(:DATA_FIM, CT.DATA_AVANCO), 12)) ||
                  ' mês(es)' AS TEMPO_EMPRESA,
                  CT.DATA_NASCIMENTO,
                  CT.IDADE,
                  FN.COD_FUNCAO,
                  FN.DES_FUNCAO,
                  HR.HR_BASE_MES,
                  CT.IND_DEFICIENCIA,
                  CT.SEXO,
                  CT.CPF,
                  CT.DDD || CT.CELULAR AS CELULAR,
                  /*CASE
                      WHEN CT.DDD IS NOT NULL THEN
                       '(' || CT.DDD || ')' || CT.CELULAR
                      ELSE
                       NULL
                  END AS CELULAR,*/
                  CT.EMAIL,
                  CT.DES_TIPO_LOGRA,
                  CT.DES_LOGRA,
                  CT.NUMERO,
                  CT.DES_BAIRRO,
                  CT.DES_CIDADE,
                  CT.COD_UF,
                  CT.CEP,
                  ORG.COD_EMP,
                  ORG.EDICAO_EMP,
                  ORG.DES_EMP,
                  ORG.COD_ORGANOGRAMA,
                  ORG.COD_UNIDADE,
                  ORG.DES_UNIDADE,
                  ORG.NOME_ORGANOGRAMA,
                  CASE
                      WHEN ORG.COD_TIPO = 2 THEN
                       ORG.EDICAO_ORG_3
                      WHEN ORG.COD_TIPO = 3 THEN
                       ORG.EDICAO_ORG_3
                      ELSE
                       ORG.COD_UNIDADE
                  END AS COD_FILIAL,
                  CASE
                      WHEN ORG.COD_TIPO = 2 THEN
                       ORG.NOME3
                      WHEN ORG.COD_TIPO = 3 THEN
                       ORG.NOME3
                      ELSE
                       ORG.DES_UNIDADE
                  END AS DES_FILIAL,
                  CASE
                      WHEN ORG.COD_TIPO = 2 THEN
                       ORG.EDICAO_ORG_4
                      WHEN ORG.COD_TIPO = 3 THEN
                       ORG.EDICAO_ORG_4
                      ELSE
                       ORG.COD_UNIDADE
                  END AS COD_DIVISAO,
                  CASE
                      WHEN ORG.COD_TIPO = 2 THEN
                       ORG.NOME4
                      WHEN ORG.COD_TIPO = 3 THEN
                       ORG.NOME4
                      ELSE
                       ORG.DES_UNIDADE
                  END AS DES_DIVISAO,
                  ORG.EDICAO,
                  ORG.COD_REDE,
                  ORG.DES_REDE,
                  ORG.COD_TIPO,
                  ORG.DES_TIPO
  FROM V_DADOS_CONTRATO_AVT CT,
         VH_EST_ORG_CONTRATO_AVT ORG,
         VH_HIST_HORAS_COLAB_AVT HR,
         VH_CARGO_CONTRATO_AVT FN
   WHERE CT.COD_CONTRATO = ORG.COD_CONTRATO
     AND CT.COD_CONTRATO = HR.COD_CONTRATO
     AND CT.COD_CONTRATO = FN.COD_CONTRATO
     AND ((:DATA_FIM BETWEEN CT.DATA_ADMISSAO AND CT.DATA_DEMISSAO) OR
          (CT.DATA_ADMISSAO <= :DATA_FIM AND CT.DATA_DEMISSAO IS NULL))
     AND :DATA_FIM BETWEEN ORG.DATA_INI_ORG AND ORG.DATA_FIM_ORG
     AND :DATA_FIM BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH
     AND :DATA_FIM BETWEEN HR.DATA_INI_HR AND HR.DATA_FIM_HR
     AND ORG.COD_EMP = 8
     --AND (ORG.COD_TIPO = :TIPO OR :TIPO = 0)
     AND (ORG.COD_UNIDADE = :UNIDADE OR :UNIDADE = 0)
     --AND (ORG.COD_REDE = :REDE OR :REDE = 0)
     AND ORG.EDICAO_ORG_4 IS NOT NULL
     --AND ORG.COD_UNIDADE = 580
   ORDER BY ORG.COD_TIPO, ORG.COD_REDE, ORG.COD_UNIDADE, CT.COD_CONTRATO
),


STATUS_AFASTADOS AS (
SELECT DISTINCT
       ORG.COD_EMP,
       CT.COD_CONTRATO,
       PF.NOME_PESSOA,
       ORG.COD_UNIDADE,
       NVL(AF.COD_CAUSA_AFAST,0) AS STATUS_AFAST,
       NA.NOME_CAUSA_AFAST AS DES_AFAST,
       AF.DATA_INICIO AS DATA_INI_AFAST,
       AF.DATA_FIM AS DATA_FIM_AFAST
  FROM RHFP0306 AF,
       RHFP0300 CT,
       VH_EST_ORG_CONTRATO_AVT ORG,
       VH_CARGO_CONTRATO_AVT FN,
       RHFP0100 NA,
       PESSOA_FISICA PF
 WHERE CT.COD_CONTRATO = AF.COD_CONTRATO(+)
   AND CT.COD_CONTRATO = ORG.COD_CONTRATO(+)
   AND CT.COD_CONTRATO = FN.COD_CONTRATO(+)
   AND AF.COD_CAUSA_AFAST = NA.COD_CAUSA_AFAST(+)
   AND CT.COD_FUNC = PF.COD_PESSOA(+)
   AND ((:DATA_FIM BETWEEN CT.DATA_INICIO AND CT.DATA_FIM) OR
        (CT.DATA_INICIO <= :DATA_FIM AND CT.DATA_FIM IS NULL))
   AND AF.DATA_INICIO >= :DATA_INICIO AND AF.DATA_FIM >= :DATA_FIM
   --AND :DATA_FIM BETWEEN AF.DATA_INICIO(+) AND AF.DATA_FIM(+)
   AND :DATA_FIM BETWEEN ORG.DATA_INI_ORG(+) AND ORG.DATA_FIM_ORG(+)
   AND :DATA_FIM BETWEEN FN.DATA_INI_CLH AND FN.DATA_FIM_CLH(+)
   --AND (ORG.COD_TIPO = :TIPO OR :TIPO = 0)
   AND (ORG.COD_UNIDADE = :UNIDADE OR :UNIDADE = 0)
   --AND (ORG.COD_REDE = :REDE OR :REDE = 0)
   --AND (ORG.COD_EMP = :EMPRESA OR :EMPRESA = 0)
   --AND ORG.COD_UNIDADE = 580
   AND ORG.COD_EMP = 8
   
)

SELECT CASE
           WHEN B.STATUS_AFAST NOT IN (0, 7) THEN
            'AFASTADO'
           ELSE
            A.DES_STATUS
       END AS STATUS,
       A.COD_CONTRATO,
       A.DES_PESSOA,
       A.DATA_ADMISSAO,
       A.DES_FUNCAO,
       A.DES_UNIDADE,
       A.DES_REDE,
       A.IDADE,
       SUBSTR(A.CPF, 1, 3) || '.' ||
       SUBSTR(A.CPF, 4, 3) || '.' ||
       SUBSTR(A.CPF, 7, 3) || '-' ||
       SUBSTR(A.CPF, 10, 2) AS CPF,
       '(' || SUBSTR(A.CELULAR, 1, 2) || ') ' ||
       SUBSTR(A.CELULAR, 3, 5) || '-' ||
       SUBSTR(A.CELULAR, 8, 4) AS CELULAR,

       A.EMAIL,
       A.DES_LOGRA,
       A.NUMERO,
       A.DES_BAIRRO,
       A.DES_CIDADE,
       A.COD_UF,
       SUBSTR(A.CEP, 1, 5) || '-' || SUBSTR(A.CEP, 6, 3) AS CEP,

       B.STATUS_AFAST,
       B.DES_AFAST,
       B.DATA_INI_AFAST,
       B.DATA_FIM_AFAST,

       :DATA_INICIO || ' - ' || :DATA_FIM AS REFERENCIA
FROM CONTRATOS A
JOIN STATUS_AFASTADOS B ON A.COD_CONTRATO = B.COD_CONTRATO
WHERE (:COD_AFAST = '0' OR
       B.STATUS_AFAST IN
       (SELECT * FROM TABLE(SPLIT_CONTRACTS(:COD_AFAST))))

ORDER BY A.DES_UNIDADE
