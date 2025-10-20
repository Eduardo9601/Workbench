          /* =============================================
		    ====== VERSÃO ALTERNATIVA DO TURNOVER ========
			============================================== */
		  
		  
		  SELECT TABELA.EDICAO_FILIAL,
           (SUM(CASE
                  WHEN TABELA.DATA_FIM BETWEEN TABELA.DATA_INI_MOV AND
                       TABELA.DATA_FIM_MOV THEN
                   1
                  ELSE
                   0
                END)) DEM,
           (SUM(DECODE(NVL(TABELA.COD_CONTRATO, 0), 0, 0, 1)) -
           SUM(CASE
                  WHEN TABELA.DATA_INICIO BETWEEN TABELA.DATA_INI_MOV AND
                       TABELA.DATA_FIM_MOV THEN
                   1
                  ELSE
                   0
                END)) EFINI
            --INTO WDEMISSOES, EFETIVOINI
            FROM (
                  
                  SELECT CON_CON.COD_CONTRATO,
                          CON_FUN.NOME_FUNCIONARIO,
                          CON_SAL.VALOR_SALARIO,
                          CON_CON.DATA_INICIO,
                          CON_CLH.NOME_CLH,
                          CON_EMP.COD_NIVEL4,
                          CON_EMP.COD_NIVEL5,
                          CON_EMP.COD_NIVEL6,
                          CON_ORG.NOME_ORGANOGRAMA,
                          CON_FUN.SEXO,
                          CON_EMP.EDICAO_COMPOSTA_FILIAL,
                          CON_EMP.EDICAO_COMPOSTA_EMPRESA,
                          CON_STACON.STATUS_CONTRATO,
                          CON_EMP.EDICAO_COMPOSTA_NIVEL6,
                          CON_EMP.EDICAO_COMPOSTA_NIVEL4,
                          CON_EMP.NOME_NIVEL4,
                          CON_EMP.EDICAO_COMPOSTA_NIVEL5,
                          CON_EMP.NOME_NIVEL5,
                          CON_CON.DATA_FIM,
                          CON_EMP.COD_FILIAL,
                          CON_EMP.NOME_FILIAL,
                          CON_EMP.EDICAO_FILIAL,
                          CON_STAAFA.STATUS_AFASTAMENTO,
                          CON_FIL_OUT.COD_CAMPO,
                          CON_FIL_OUT.DESCRICAO,
                          CON_FIL_OUT.VALOR,
                          CON_CUSTO.COD_CUSTO_N3,
                          CON_CUSTO.EDICAO_NIVEL3,
                          CON_VDS.COD_EVENTO,
                          CON_VDS.DATA_FIM_MOV,
                          CON_VDS.DATA_INI_MOV,
                          CON_CLH.COD_CLH
                    FROM RHFP0300 RHFP0300,
                          (
                           
                           SELECT RHFP0300.COD_CONTRATO,
                                   RHFP0200.COD_FUNC,
                                   RHFP0200.COD_GRAU_INSTRUCAO,
                                   RHFP0200.COD_ESTADO_CIVIL,
                                   RHFP0200.COD_NACIONALIDADE,
                                   RHFP0200.COD_PESSOA_PARENTE,
                                   RHFP0200.COD_PESSOA_PAI,
                                   RHFP0200.COD_NACION_PAI,
                                   RHFP0200.COD_PESSOA_MAE,
                                   RHFP0200.COD_NACION_MAE,
                                   RHFP0200.COD_PESSOA_CONJUGE,
                                   RHFP0200.COD_NACION_CONJUGE,
                                   RHFP0200.DATA_NASCIMENTO,
                                   TRUNC(MONTHS_BETWEEN(SYSDATE,
                                                        RHFP0200.DATA_NASCIMENTO) / 12) AS IDADE,
                                   TO_CHAR(RHFP0200.DATA_NASCIMENTO, 'DD') AS DIA_NASCIMENTO,
                                   TO_CHAR(RHFP0200.DATA_NASCIMENTO, 'MM') AS MES_NASCIMENTO,
                                   TO_CHAR(RHFP0200.DATA_NASCIMENTO, 'YYYY') AS ANO_NASCIMENTO,
                                   RHFP0200.SEXO,
                                   RHFP0200.COD_MUNIC_NASCIMENTO,
                                   RHFP0200.COD_UF_NASCIMENTO,
                                   RHFP0200.NRO_PIS_PASEP,
                                   RHFP0200.DATA_PIS_PASEP,
                                   RHFP0200.NRO_CONT_INDIVIDUAL,
                                   RHFP0200.DATA_CONT_INDIVIDUAL,
                                   RHFP0200.NRO_CTPS,
                                   RHFP0200.NRO_SERIE_CTPS,
                                   RHFP0200.DATA_EXP_CTPS,
                                   RHFP0200.COD_UF_CTPS,
                                   RHFP0200.NRO_TITULO,
                                   RHFP0200.NRO_ZONA_TITULO,
                                   RHFP0200.NRO_SECAO_TITULO,
                                   RHFP0200.DATA_EMISSAO_TITULO,
                                   RHFP0200.COD_UF_TITULO,
                                   RHFP0200.COD_MUN_TITULO,
                                   RHFP0200.NRO_HABILITACAO,
                                   RHFP0200.NRO_PRONTUARIO_HAB,
                                   RHFP0200.DATA_EMISSAO_HAB,
                                   RHFP0200.COD_CATEGORIA_HAB,
                                   RHFP0200.DATA_VALIDADE_HAB,
                                   RHFP0200.NRO_IDENTIDADE,
                                   RHFP0200.COD_ORG_IDENTIDADE,
                                   RHFP0200.DATA_EMI_IDENTIDADE,
                                   RHFP0200.COD_UF_IDENTIDADE,
                                   RHFP0200.NRO_RESERVISTA,
                                   RHFP0200.SERVICO_MILITAR,
                                   RHFP0200.NRO_PASSAPORTE,
                                   RHFP0200.DATA_EMI_PASSAPORTE,
                                   RHFP0200.DATA_VAL_PASSAPORTE,
                                   RHFP0200.ORGAO_EMISSOR_PASSAP,
                                   RHFP0200.COD_CONSELHO,
                                   RHFP0200.COD_ESCOLA,
                                   RHFP0200.DATA_DIPLOMACAO,
                                   RHFP0200.DATA_VALIDADE,
                                   RHFP0200.NRO_REGISTRO,
                                   RHFP0200.NRO_LIVRO,
                                   RHFP0200.NRO_FOLHA,
                                   RHFP0200.NRO_DOCUMENTO_01,
                                   RHFP0200.NRO_DOCUMENTO_02,
                                   RHFP0200.DATA_CASAMENTO,
                                   RHFP0200.DATA_APOSENTADORIA,
                                   RHFP0200.COD_TIPO_APOSENT,
                                   RHFP0145.NOME_TIPO_APOSENT,
                                   RHFP0200.NRO_BENEFICIO_INSS,
                                   RHFP0200.COD_DEFICIENCIA,
                                   RHFP0132.NOME_DEFICIENCIA,
                                   PESSOA_1.NOME_PESSOA AS NOME_FUNCIONARIO,
                                   PESSOA_2.NOME_PESSOA AS NOME_PARENTE,
                                   PESSOA_3.NOME_PESSOA AS NOME_PAI,
                                   PESSOA_4.NOME_PESSOA AS NOME_MAE,
                                   PESSOA_5.NOME_PESSOA AS NOME_CONJUGE,
                                   PESSOA_6.NOME_PESSOA AS NOME_ORGAO_IDENTIDADE,
                                   RHFP0104.NOME_ESTADO_CIVIL,
                                   RHFP0105.NOME_GRAU_INSTRUCAO,
                                   RHFP0105.NOME_RESUMIDO,
                                   RHFP0107_1.NOME_NACIONALIDADE AS NOME_NACIONALIDADE,
                                   RHFP0107_2.NOME_NACIONALIDADE AS NOME_NACIONALIDADE_PAI,
                                   RHFP0107_3.NOME_NACIONALIDADE AS NOME_NACIONALIDADE_MAE,
                                   RHFP0107_4.NOME_NACIONALIDADE AS NOME_NACIONALIDADE_CONJUGE,
                                   UF_1.NOME_UF AS NOME_UF_NASCIMENTO,
                                   MUNICI_1.NOME_MUNIC AS NOME_MUNIC_NASCIMENTO,
                                   UF_2.NOME_UF AS NOME_UF_CTPS,
                                   UF_3.NOME_UF AS NOME_UF_TITULO,
                                   MUNICI_1.NOME_MUNIC AS NOME_MUNIC_TITULO,
                                   UF_4.NOME_UF AS NOME_UF_IDENTIDADE,
                                   RHFP0130.NOME_RACA_COR,
                                   RHFP0200.COD_TITULACAO,
                                   RHFP0139.NOME_TITULACAO,
                                   FISICA.CPF,
                                   PESSOA_7.NOME_PESSOA AS NOME_CONSELHO_REGIONAL,
                                   PESSOA_8.NOME_PESSOA AS NOME_ENTIDADE_ENSINO,
                                   NVL(DEPS.NRO_DEPENDENTES, 0) AS NRO_DEPENDENTES,
                                   FISCONJ.DT_NASC AS DATA_NASC_CONJUGE,
                                   FISCONJ.SEXO AS SEXO_CONJUGE,
                                   FISICA.MATRICULA_NASC,
                                   FISICA.COD_DNV,
                                   FISICA.NRO_CARTAO_SUS,
                                   FISICA.TIPO_SANGUE,
                                   FISICA.FATOR_RH,
                                   RHFP0200.NRO_CARTEIRA_ESTRANG,
                                   RHFP0200.COD_ORGAO_RNE,
                                   RHFP0200.DATA_EMI_RNE,
                                   PESRNE.NOME_PESSOA AS NOME_ORGAO_RNE
                             FROM RHFP0200 RHFP0200,
                                   RHFP0300 RHFP0300,
                                   PESSOA PESSOA_1,
                                   PESSOA PESSOA_2,
                                   PESSOA PESSOA_3,
                                   PESSOA PESSOA_4,
                                   PESSOA PESSOA_5,
                                   PESSOA PESSOA_6,
                                   PESSOA PESSOA_7,
                                   PESSOA PESSOA_8,
                                   RHFP0104 RHFP0104,
                                   RHFP0105 RHFP0105,
                                   RHFP0107 RHFP0107_1,
                                   RHFP0107 RHFP0107_2,
                                   RHFP0107 RHFP0107_3,
                                   RHFP0107 RHFP0107_4,
                                   MUNICI MUNICI_1,
                                   UF UF_1,
                                   UF UF_2,
                                   UF UF_3,
                                   MUNICI MUNICI_3,
                                   UF UF_4,
                                   RHFP0130 RHFP0130,
                                   FISICA FISICA,
                                   FISICA FISCONJ,
                                   JURIDICA JURRNE,
                                   PESSOA PESRNE,
                                   RHFP0132 RHFP0132,
                                   RHFP0139 RHFP0139,
                                   RHFP0145 RHFP0145,
                                   (SELECT COD_FUNC, COUNT(*) AS NRO_DEPENDENTES
                                      FROM RHFP0202
                                     WHERE '31/12/2024' BETWEEN
                                           RHFP0202.DATA_INICIO AND
                                           RHFP0202.DATA_FIM
                                     GROUP BY COD_FUNC) DEPS
                            WHERE (RHFP0200.COD_FUNC = RHFP0300.COD_FUNC)
                              AND (RHFP0200.COD_FUNC = PESSOA_1.COD_PESSOA(+))
                              AND (RHFP0200.COD_PESSOA_PARENTE =
                                  PESSOA_2.COD_PESSOA(+))
                              AND (RHFP0200.COD_PESSOA_PAI =
                                  PESSOA_3.COD_PESSOA(+))
                              AND (RHFP0200.COD_PESSOA_MAE =
                                  PESSOA_4.COD_PESSOA(+))
                              AND (RHFP0200.COD_PESSOA_CONJUGE =
                                  PESSOA_5.COD_PESSOA(+))
                              AND (RHFP0200.COD_ORG_IDENTIDADE =
                                  PESSOA_6.COD_PESSOA(+))
                              AND (RHFP0200.COD_ESTADO_CIVIL =
                                  RHFP0104.COD_ESTADO_CIVIL(+))
                              AND (RHFP0200.COD_GRAU_INSTRUCAO =
                                  RHFP0105.COD_GRAU_INSTRUCAO(+))
                              AND (RHFP0200.COD_NACIONALIDADE =
                                  RHFP0107_1.COD_NACIONALIDADE(+))
                              AND (RHFP0200.COD_NACION_PAI =
                                  RHFP0107_2.COD_NACIONALIDADE(+))
                              AND (RHFP0200.COD_NACION_MAE =
                                  RHFP0107_3.COD_NACIONALIDADE(+))
                              AND (RHFP0200.COD_NACION_CONJUGE =
                                  RHFP0107_4.COD_NACIONALIDADE(+))
                              AND (RHFP0200.COD_UF_NASCIMENTO =
                                  MUNICI_1.COD_UF(+))
                              AND (RHFP0200.COD_MUNIC_NASCIMENTO =
                                  MUNICI_1.COD_MUNIC(+))
                              AND (RHFP0200.COD_UF_NASCIMENTO = UF_1.COD_UF(+))
                              AND (RHFP0200.COD_UF_CTPS = UF_2.COD_UF(+))
                              AND (RHFP0200.COD_UF_TITULO = UF_3.COD_UF(+))
                              AND (RHFP0200.COD_UF_TITULO = MUNICI_3.COD_UF(+))
                              AND (RHFP0200.COD_MUN_TITULO =
                                  MUNICI_3.COD_MUNIC(+))
                              AND (RHFP0200.COD_UF_IDENTIDADE = UF_4.COD_UF(+))
                              AND (RHFP0200.COD_RACA_COR =
                                  RHFP0130.COD_RACA_COR(+))
                              AND (RHFP0200.COD_FUNC = FISICA.COD_PESSOA(+))
                              AND (RHFP0200.COD_DEFICIENCIA =
                                  RHFP0132.COD_DEFICIENCIA(+))
                              AND (RHFP0200.COD_TITULACAO =
                                  RHFP0139.COD_TITULACAO(+))
                              AND (RHFP0200.COD_CONSELHO =
                                  PESSOA_7.COD_PESSOA(+))
                              AND (RHFP0200.COD_ESCOLA = PESSOA_8.COD_PESSOA(+))
                              AND (RHFP0200.COD_FUNC = DEPS.COD_FUNC(+))
                              AND (RHFP0200.COD_PESSOA_CONJUGE =
                                  FISCONJ.COD_PESSOA(+))
                              AND (RHFP0200.COD_TIPO_APOSENT =
                                  RHFP0145.COD_TIPO_APOSENT(+))
                              AND (RHFP0200.COD_ORGAO_RNE = JURRNE.COD_PESSOA(+))
                              AND (JURRNE.COD_PESSOA = PESRNE.COD_PESSOA(+))) CON_FUN,
                          (SELECT SALARIO.COD_CONTRATO,
                                  SALARIO.DATA_INICIO_SALARIO,
                                  SALARIO.DATA_FIM_SALARIO,
                                  SALARIO.COD_MOTIVO,
                                  SALARIO.NOME_MOTIVO,
                                  SALARIO.COD_TIPO_MOTIVO,
                                  SALARIO.NOME_TIPO_MOTIVO,
                                  SALARIO.COD_INF_SALARIAL,
                                  SALARIO.NOME_INF_SALARIAL,
                                  SALARIO.COD_TAB_SALARIAL,
                                  SALARIO.COD_FAIXA,
                                  SALARIO.COD_NIVEL,
                                  SALARIO.NOME_TAB_SALARIAL_FAIXA,
                                  SALARIO.DATA_INICIO_TAB_SALARIAL_FAIXA,
                                  SALARIO.DATA_FIM_TAB_SALARIAL_FAIXA,
                                  SALARIO.NOME_FAIXA,
                                  SALARIO.NOME_TAB_SALARIAL_NIVEL,
                                  SALARIO.DATA_INICIO_TAB_SALARIAL_NIVEL,
                                  SALARIO.DATA_FIM_TAB_SALARIAL_NIVEL,
                                  SALARIO.NOME_NIVEL,
                                  SALARIO.VALOR_SALARIO,
                                  SALARIO.DATA_INICIO_QUARTIL,
                                  SALARIO.DATA_FIM_QUARTIL,
                                  SALARIO.TIPO_SALARIO,
                                  SALARIO.NOME_TIPO_SALARIO
                             FROM (SELECT RHFP0608.COD_CONTRATO,
                                          RHFP0608.DATA_INICIO AS DATA_INICIO_SALARIO,
                                          RHFP0608.DATA_FIM AS DATA_FIM_SALARIO,
                                          RHFP0608.COD_MOTIVO,
                                          RHFP0323.NOME_MOTIVO,
                                          RHFP0323.COD_TIPO_MOTIVO,
                                          RHFP0115.NOME_TIPO_MOTIVO,
                                          RHFP0608.COD_INF_SALARIAL,
                                          RHFP0118.NOME_INF_SALARIAL,
                                          RHFP0608.COD_TAB_SALARIAL,
                                          RHFP0608.COD_FAIXA,
                                          RHFP0608.COD_NIVEL,
                                          RHFP0600_FAIXA.NOME_TAB_SALARIAL AS NOME_TAB_SALARIAL_FAIXA,
                                          RHFP0600_FAIXA.DATA_INICIO AS DATA_INICIO_TAB_SALARIAL_FAIXA,
                                          RHFP0600_FAIXA.DATA_FIM AS DATA_FIM_TAB_SALARIAL_FAIXA,
                                          RHFP0601.NOME_FAIXA,
                                          RHFP0600_NIVEL.NOME_TAB_SALARIAL AS NOME_TAB_SALARIAL_NIVEL,
                                          RHFP0600_NIVEL.DATA_INICIO AS DATA_INICIO_TAB_SALARIAL_NIVEL,
                                          RHFP0600_NIVEL.DATA_FIM AS DATA_FIM_TAB_SALARIAL_NIVEL,
                                          RHFP0602.NOME_NIVEL,
                                          RHFP0608.VALOR_SALARIO,
                                          RHFP0608.DATA_INICIO AS DATA_INICIO_QUARTIL,
                                          RHFP0608.DATA_FIM AS DATA_FIM_QUARTIL,
                                          RHFP0608.TIPO_SALARIO,
                                          DECODE(RHFP0608.TIPO_SALARIO,
                                                 'M',
                                                 'MÊS',
                                                 'H',
                                                 'HORA',
                                                 '') AS NOME_TIPO_SALARIO
                                     FROM RHFP0608 RHFP0608,
                                          RHFP0605 RHFP0605,
                                          RHFP0606 RHFP0606,
                                          RHFP0600 RHFP0600_FAIXA,
                                          RHFP0600 RHFP0600_NIVEL,
                                          RHFP0601 RHFP0601,
                                          RHFP0602 RHFP0602,
                                          RHFP0323 RHFP0323,
                                          RHFP0115 RHFP0115,
                                          RHFP0118 RHFP0118
                                    WHERE RHFP0608.COD_INF_SALARIAL = 3
                                      AND '31/12/2024' BETWEEN
                                          RHFP0608.DATA_INICIO AND
                                          RHFP0608.DATA_FIM
                                      AND RHFP0608.COD_MOTIVO =
                                          RHFP0323.COD_MOTIVO(+)
                                      AND RHFP0323.COD_TIPO_MOTIVO =
                                          RHFP0115.COD_TIPO_MOTIVO(+)
                                      AND RHFP0608.COD_INF_SALARIAL =
                                          RHFP0118.COD_INF_SALARIAL(+)
                                      AND RHFP0608.COD_TAB_SALARIAL =
                                          RHFP0605.COD_TAB_SALARIAL(+)
                                      AND RHFP0608.COD_FAIXA =
                                          RHFP0605.COD_FAIXA(+)
                                      AND RHFP0608.COD_TAB_SALARIAL =
                                          RHFP0606.COD_TAB_SALARIAL(+)
                                      AND RHFP0608.COD_NIVEL =
                                          RHFP0606.COD_NIVEL(+)
                                      AND RHFP0605.COD_TAB_SALARIAL =
                                          RHFP0600_FAIXA.COD_TAB_SALARIAL(+)
                                      AND RHFP0605.COD_FAIXA =
                                          RHFP0601.COD_FAIXA(+)
                                      AND RHFP0606.COD_TAB_SALARIAL =
                                          RHFP0600_NIVEL.COD_TAB_SALARIAL(+)
                                      AND RHFP0606.COD_NIVEL =
                                          RHFP0602.COD_NIVEL(+)
                                   
                                   UNION ALL
                                   
                                   SELECT RHFP0608.COD_CONTRATO,
                                          RHFP0608.DATA_INICIO AS DATA_INICIO_SALARIO,
                                          RHFP0608.DATA_FIM AS DATA_FIM_SALARIO,
                                          RHFP0608.COD_MOTIVO,
                                          RHFP0323.NOME_MOTIVO,
                                          RHFP0323.COD_TIPO_MOTIVO,
                                          RHFP0115.NOME_TIPO_MOTIVO,
                                          RHFP0608.COD_INF_SALARIAL,
                                          RHFP0118.NOME_INF_SALARIAL,
                                          RHFP0608.COD_TAB_SALARIAL,
                                          RHFP0608.COD_FAIXA,
                                          RHFP0608.COD_NIVEL,
                                          RHFP0600_FAIXA.NOME_TAB_SALARIAL AS NOME_TAB_SALARIAL_FAIXA,
                                          RHFP0600_FAIXA.DATA_INICIO AS DATA_INICIO_TAB_SALARIAL_FAIXA,
                                          RHFP0600_FAIXA.DATA_FIM AS DATA_FIM_TAB_SALARIAL_FAIXA,
                                          RHFP0601.NOME_FAIXA,
                                          RHFP0600_NIVEL.NOME_TAB_SALARIAL AS NOME_TAB_SALARIAL_NIVEL,
                                          RHFP0600_NIVEL.DATA_INICIO AS DATA_INICIO_TAB_SALARIAL_NIVEL,
                                          RHFP0600_NIVEL.DATA_FIM AS DATA_FIM_TAB_SALARIAL_NIVEL,
                                          RHFP0602.NOME_NIVEL,
                                          RHFP0607.VALOR_QUARTIL AS VALOR_SALARIO,
                                          RHFP0607.DATA_INICIO AS DATA_INICIO_QUARTIL,
                                          RHFP0607.DATA_FIM AS DATA_FIM_QUARTIL,
                                          RHFP0608.TIPO_SALARIO,
                                          DECODE(RHFP0608.TIPO_SALARIO,
                                                 'M',
                                                 'MÊS',
                                                 'H',
                                                 'HORA',
                                                 '') AS NOME_TIPO_SALARIO
                                     FROM RHFP0608 RHFP0608,
                                          RHFP0607 RHFP0607,
                                          RHFP0606 RHFP0606,
                                          RHFP0605 RHFP0605,
                                          RHFP0600 RHFP0600_FAIXA,
                                          RHFP0600 RHFP0600_NIVEL,
                                          RHFP0601 RHFP0601,
                                          RHFP0602 RHFP0602,
                                          RHFP0323 RHFP0323,
                                          RHFP0115 RHFP0115,
                                          RHFP0118 RHFP0118
                                    WHERE RHFP0608.COD_INF_SALARIAL <> 3
                                      AND '31/12/2024' BETWEEN
                                          RHFP0608.DATA_INICIO AND
                                          RHFP0608.DATA_FIM
                                      AND RHFP0608.COD_TAB_SALARIAL =
                                          RHFP0607.COD_TAB_SALARIAL(+)
                                      AND RHFP0608.COD_FAIXA =
                                          RHFP0607.COD_FAIXA(+)
                                      AND RHFP0608.COD_NIVEL =
                                          RHFP0607.COD_NIVEL(+)
                                      AND '31/12/2024' BETWEEN
                                          RHFP0607.DATA_INICIO(+) AND
                                          RHFP0607.DATA_FIM(+)
                                         -- AND DECODE(RHYKUTILS.MAIOR_DATA(RHFP0608.DATA_INICIO,RHFP0607.DATA_INICIO),RHFP0608.DATA_INICIO,RHFP0608.COD_MOTIVO,RHFP0607.COD_MOTIVO) = RHFP0323.COD_MOTIVO
                                      AND RHFP0323.COD_TIPO_MOTIVO =
                                          RHFP0115.COD_TIPO_MOTIVO(+)
                                      AND RHFP0608.COD_INF_SALARIAL =
                                          RHFP0118.COD_INF_SALARIAL(+)
                                      AND RHFP0608.COD_TAB_SALARIAL =
                                          RHFP0605.COD_TAB_SALARIAL(+)
                                      AND RHFP0608.COD_FAIXA =
                                          RHFP0605.COD_FAIXA(+)
                                      AND RHFP0608.COD_TAB_SALARIAL =
                                          RHFP0606.COD_TAB_SALARIAL(+)
                                      AND RHFP0608.COD_NIVEL =
                                          RHFP0606.COD_NIVEL(+)
                                      AND RHFP0605.COD_TAB_SALARIAL =
                                          RHFP0600_FAIXA.COD_TAB_SALARIAL(+)
                                      AND RHFP0605.COD_FAIXA =
                                          RHFP0601.COD_FAIXA(+)
                                      AND RHFP0606.COD_TAB_SALARIAL =
                                          RHFP0600_NIVEL.COD_TAB_SALARIAL(+)
                                      AND RHFP0606.COD_NIVEL =
                                          RHFP0602.COD_NIVEL(+)
                                      AND '31/12/2024' BETWEEN
                                          RHFP0600_FAIXA.DATA_INICIO AND
                                          RHFP0600_FAIXA.DATA_FIM
                                      AND '31/12/2024' BETWEEN
                                          RHFP0600_NIVEL.DATA_INICIO AND
                                          RHFP0600_NIVEL.DATA_FIM) SALARIO) CON_SAL,
                          (
                           
                           SELECT VDS.COD_CONTRATO,
                                   VDS.COD_MESTRE_EVENTO,
                                   VDS.DATA_REFERENCIA,
                                   VDS.COD_EVENTO,
                                   VDS.DATA_PAGAMENTO,
                                   VDS.DATA_INI_MOV,
                                   VDS.DATA_FIM_MOV,
                                   VDS.DATA_PROCESSO,
                                   VDS.DATA_INCORPORACAO,
                                   VDS.SITUACAO_PROCESSO,
                                   VDS.IND_CONTABIL,
                                   VDS.DATA_APROPRIACAO,
                                   VDS.COD_ORGANOGRAMA,
                                   VDS.NOME_MESTRE_EVENTO,
                                   VDS.NOME_EVENTO
                           
                             FROM (SELECT FIN.COD_CONTRATO,
                                           FIN.COD_MESTRE_EVENTO,
                                           FIN.DATA_REFERENCIA,
                                           FIN.COD_EVENTO,
                                           FIN.DATA_PAGAMENTO,
                                           FIN.DATA_INI_MOV,
                                           FIN.DATA_FIM_MOV,
                                           FIN.DATA_PROCESSO,
                                           FIN.DATA_INCORPORACAO,
                                           FIN.SITUACAO_PROCESSO,
                                           FIN.IND_CONTABIL,
                                           FIN.DATA_APROPRIACAO,
                                           FIN.COD_ORGANOGRAMA,
                                           FIN.NOME_MESTRE_EVENTO,
                                           FIN.NOME_EVENTO
                                    
                                      FROM (SELECT RHFP1005.COD_CONTRATO,
                                                   RHFP1005.COD_MESTRE_EVENTO,
                                                   MESTRE.DATA_REFERENCIA,
                                                   MESTRE.COD_EVENTO,
                                                   MESTRE.DATA_PAGAMENTO,
                                                   MESTRE.DATA_INI_MOV,
                                                   MESTRE.DATA_FIM_MOV,
                                                   MESTRE.DATA_PROCESSO,
                                                   MESTRE.DATA_INCORPORACAO,
                                                   MESTRE.SITUACAO_PROCESSO,
                                                   MESTRE.IND_CONTABIL,
                                                   MESTRE.DATA_APROPRIACAO,
                                                   MESTRE.COD_ORGANOGRAMA,
                                                   MESTRE.NOME_MESTRE_EVENTO,
                                                   MESTRE.NOME_EVENTO
                                              FROM RHFP1005 RHFP1005,
                                                   (SELECT RHFP1003.COD_MESTRE_EVENTO,
                                                           RHFP1003.DATA_REFERENCIA,
                                                           RHFP1003.COD_EVENTO,
                                                           RHFP1003.DATA_PAGAMENTO,
                                                           RHFP1003.DATA_INI_MOV,
                                                           RHFP1003.DATA_FIM_MOV,
                                                           RHFP1003.DATA_PROCESSO,
                                                           RHFP1003.DATA_INCORPORACAO,
                                                           RHFP1003.SITUACAO_PROCESSO,
                                                           RHFP1003.IND_CONTABIL,
                                                           RHFP1003.DATA_APROPRIACAO,
                                                           RHFP1003.COD_ORGANOGRAMA,
                                                           RHFP1003.NOME_MESTRE_EVENTO,
                                                           RHFP1002.NOME_EVENTO
                                                      FROM RHFP1003 RHFP1003,
                                                           RHFP1002 RHFP1002
                                                     WHERE RHFP1003.SITUACAO_PROCESSO = 'C'
                                                       AND RHFP1003.COD_EVENTO =
                                                           RHFP1002.COD_EVENTO
                                                       AND RHFP1003.DATA_REFERENCIA BETWEEN
                                                           '01/01/' ||
                                                           SUBSTR('31/12/2024', 7, 4) AND
                                                           '31/12/2024') MESTRE
                                             WHERE MESTRE.COD_MESTRE_EVENTO =
                                                   RHFP1005.COD_MESTRE_EVENTO
                                             GROUP BY RHFP1005.COD_CONTRATO,
                                                      RHFP1005.COD_MESTRE_EVENTO,
                                                      MESTRE.DATA_REFERENCIA,
                                                      MESTRE.COD_EVENTO,
                                                      MESTRE.DATA_PAGAMENTO,
                                                      MESTRE.DATA_INI_MOV,
                                                      MESTRE.DATA_FIM_MOV,
                                                      MESTRE.DATA_PROCESSO,
                                                      MESTRE.DATA_INCORPORACAO,
                                                      MESTRE.SITUACAO_PROCESSO,
                                                      MESTRE.IND_CONTABIL,
                                                      MESTRE.DATA_APROPRIACAO,
                                                      MESTRE.COD_ORGANOGRAMA,
                                                      MESTRE.NOME_MESTRE_EVENTO,
                                                      MESTRE.NOME_EVENTO
                                            UNION
                                            SELECT RHFP1006.COD_CONTRATO,
                                                   RHFP1006.COD_MESTRE_EVENTO,
                                                   MESTRE.DATA_REFERENCIA,
                                                   MESTRE.COD_EVENTO,
                                                   MESTRE.DATA_PAGAMENTO,
                                                   MESTRE.DATA_INI_MOV,
                                                   MESTRE.DATA_FIM_MOV,
                                                   MESTRE.DATA_PROCESSO,
                                                   MESTRE.DATA_INCORPORACAO,
                                                   MESTRE.SITUACAO_PROCESSO,
                                                   MESTRE.IND_CONTABIL,
                                                   MESTRE.DATA_APROPRIACAO,
                                                   MESTRE.COD_ORGANOGRAMA,
                                                   MESTRE.NOME_MESTRE_EVENTO,
                                                   MESTRE.NOME_EVENTO
                                              FROM RHFP1006 RHFP1006,
                                                   (SELECT RHFP1003.COD_MESTRE_EVENTO,
                                                           RHFP1003.DATA_REFERENCIA,
                                                           RHFP1003.COD_EVENTO,
                                                           RHFP1003.DATA_PAGAMENTO,
                                                           RHFP1003.DATA_INI_MOV,
                                                           RHFP1003.DATA_FIM_MOV,
                                                           RHFP1003.DATA_PROCESSO,
                                                           RHFP1003.DATA_INCORPORACAO,
                                                           RHFP1003.SITUACAO_PROCESSO,
                                                           RHFP1003.IND_CONTABIL,
                                                           RHFP1003.DATA_APROPRIACAO,
                                                           RHFP1003.COD_ORGANOGRAMA,
                                                           RHFP1003.NOME_MESTRE_EVENTO,
                                                           RHFP1002.NOME_EVENTO
                                                      FROM RHFP1003 RHFP1003,
                                                           RHFP1002 RHFP1002
                                                     WHERE RHFP1003.SITUACAO_PROCESSO = 'I'
                                                       AND RHFP1003.COD_EVENTO =
                                                           RHFP1002.COD_EVENTO
                                                       AND RHFP1003.DATA_REFERENCIA BETWEEN
                                                           '01/01/' ||
                                                           SUBSTR('31/12/2024', 7, 4) AND
                                                           '31/12/2024') MESTRE
                                             WHERE MESTRE.COD_MESTRE_EVENTO =
                                                   RHFP1006.COD_MESTRE_EVENTO
                                             GROUP BY RHFP1006.COD_CONTRATO,
                                                      RHFP1006.COD_MESTRE_EVENTO,
                                                      MESTRE.DATA_REFERENCIA,
                                                      MESTRE.COD_EVENTO,
                                                      MESTRE.DATA_PAGAMENTO,
                                                      MESTRE.DATA_INI_MOV,
                                                      MESTRE.DATA_FIM_MOV,
                                                      MESTRE.DATA_PROCESSO,
                                                      MESTRE.DATA_INCORPORACAO,
                                                      MESTRE.SITUACAO_PROCESSO,
                                                      MESTRE.IND_CONTABIL,
                                                      MESTRE.DATA_APROPRIACAO,
                                                      MESTRE.COD_ORGANOGRAMA,
                                                      MESTRE.NOME_MESTRE_EVENTO,
                                                      MESTRE.NOME_EVENTO) FIN,
                                           (SELECT RHFP1005.COD_CONTRATO,
                                                   RHFP1005.COD_MESTRE_EVENTO,
                                                   ROUND(RHFP1005.VALOR_VD, 2) AS VALOR_VD,
                                                   ROUND(RHFP1005.QTDE_VD, 2) AS QTDE_VD,
                                                   RHFP1005.COD_VD
                                              FROM RHFP1005 RHFP1005,
                                                   (SELECT RHFP1003.COD_MESTRE_EVENTO,
                                                           RHFP1003.DATA_REFERENCIA,
                                                           RHFP1003.COD_EVENTO,
                                                           RHFP1003.DATA_PAGAMENTO,
                                                           RHFP1003.DATA_INI_MOV,
                                                           RHFP1003.DATA_FIM_MOV,
                                                           RHFP1003.DATA_PROCESSO,
                                                           RHFP1003.DATA_INCORPORACAO,
                                                           RHFP1003.SITUACAO_PROCESSO,
                                                           RHFP1003.IND_CONTABIL,
                                                           RHFP1003.DATA_APROPRIACAO,
                                                           RHFP1003.COD_ORGANOGRAMA,
                                                           RHFP1003.NOME_MESTRE_EVENTO,
                                                           RHFP1002.NOME_EVENTO
                                                      FROM RHFP1003 RHFP1003,
                                                           RHFP1002 RHFP1002
                                                     WHERE RHFP1003.SITUACAO_PROCESSO = 'C'
                                                       AND RHFP1003.COD_EVENTO =
                                                           RHFP1002.COD_EVENTO
                                                       AND RHFP1003.DATA_REFERENCIA BETWEEN
                                                           '01/01/' ||
                                                           SUBSTR('31/12/2024', 7, 4) AND
                                                           '31/12/2024') MESTRE
                                             WHERE MESTRE.COD_MESTRE_EVENTO =
                                                   RHFP1005.COD_MESTRE_EVENTO
                                            UNION
                                            SELECT RHFP1006.COD_CONTRATO,
                                                   RHFP1006.COD_MESTRE_EVENTO,
                                                   ROUND(RHFP1006.VALOR_VD, 2) AS VALOR_VD,
                                                   ROUND(RHFP1006.QTDE_VD, 2) AS QTDE_VD,
                                                   RHFP1006.COD_VD
                                              FROM RHFP1006 RHFP1006,
                                                   (SELECT RHFP1003.COD_MESTRE_EVENTO,
                                                           RHFP1003.DATA_REFERENCIA,
                                                           RHFP1003.COD_EVENTO,
                                                           RHFP1003.DATA_PAGAMENTO,
                                                           RHFP1003.DATA_INI_MOV,
                                                           RHFP1003.DATA_FIM_MOV,
                                                           RHFP1003.DATA_PROCESSO,
                                                           RHFP1003.DATA_INCORPORACAO,
                                                           RHFP1003.SITUACAO_PROCESSO,
                                                           RHFP1003.IND_CONTABIL,
                                                           RHFP1003.DATA_APROPRIACAO,
                                                           RHFP1003.COD_ORGANOGRAMA,
                                                           RHFP1003.NOME_MESTRE_EVENTO,
                                                           RHFP1002.NOME_EVENTO
                                                      FROM RHFP1003 RHFP1003,
                                                           RHFP1002 RHFP1002
                                                     WHERE RHFP1003.SITUACAO_PROCESSO = 'I'
                                                       AND RHFP1003.COD_EVENTO =
                                                           RHFP1002.COD_EVENTO
                                                       AND RHFP1003.DATA_REFERENCIA BETWEEN
                                                           '01/01/' ||
                                                           SUBSTR('31/12/2024', 7, 4) AND
                                                           '31/12/2024') MESTRE
                                             WHERE MESTRE.COD_MESTRE_EVENTO =
                                                   RHFP1006.COD_MESTRE_EVENTO) VDS
                                     WHERE FIN.COD_CONTRATO = VDS.COD_CONTRATO(+)
                                       AND FIN.COD_MESTRE_EVENTO =
                                           VDS.COD_MESTRE_EVENTO(+)
                                     GROUP BY FIN.COD_CONTRATO,
                                              FIN.COD_MESTRE_EVENTO,
                                              FIN.DATA_REFERENCIA,
                                              FIN.COD_EVENTO,
                                              FIN.DATA_PAGAMENTO,
                                              FIN.DATA_INI_MOV,
                                              FIN.DATA_FIM_MOV,
                                              FIN.DATA_PROCESSO,
                                              FIN.DATA_INCORPORACAO,
                                              FIN.SITUACAO_PROCESSO,
                                              FIN.IND_CONTABIL,
                                              FIN.DATA_APROPRIACAO,
                                              FIN.COD_ORGANOGRAMA,
                                              FIN.NOME_MESTRE_EVENTO,
                                              FIN.NOME_EVENTO) VDS) CON_VDS,
                          (SELECT RHFP0340.COD_CONTRATO,
                                  RHFP0340.DATA_INICIO,
                                  RHFP0340.DATA_FIM,
                                  RHFP0340.COD_CLH,
                                  RHFP0500.NOME_CLH,
                                  RHFP0500.COD_CBO,
                                  RHFP0500.COD_CBO_2002,
                                  RHFP0500.SEQUENCIA_CBO_2002,
                                  RHFP0500.EDICAO_CLH,
                                  RHFP0103.NOME_CBO,
                                  RHFP0137.NOME_CBO_2002,
                                  RHFP0340.COD_MOTIVO,
                                  RHFP0323.NOME_MOTIVO,
                                  RHFP0323.COD_TIPO_MOTIVO,
                                  RHFP0115.NOME_TIPO_MOTIVO,
                                  RHFP0340.COD_FUN_CARGO,
                                  RHFP0514.NOME_FUN_CARGO,
                                  RHFP0500.COD_GRUPO_OCUP,
                                  RHFP0609.NOME_GRUPO_OCUP,
                                  RHCS0530.COD_CARREIRA,
                                  RHCS0530.NOME_CARREIRA,
                                  RHCS0530.NIVEL_CARREIRA,
                                  DECODE(RHCS0530.NIVEL_CARREIRA,
                                         'F',
                                         'FUNDAMENTAL',
                                         'M',
                                         'MÉDIO',
                                         'S',
                                         'SUPERIOR') AS DESC_NIVEL_CARREIRA,
                                  ROUND((MONTHS_BETWEEN(DECODE(RHFP0340.DATA_FIM,
                                                               TO_DATE('31/12/2999'),
                                                               DECODE(RHFP0300.DATA_FIM,
                                                                      NULL,
                                                                      '31/12/2024',
                                                                      RHFP0300.DATA_FIM),
                                                               RHFP0340.DATA_FIM),
                                                        RHFP0340.DATA_INICIO) / 12),
                                        2) AS ANOS_CARGO_BASE10,
                                  TRUNC(MONTHS_BETWEEN(DECODE(RHFP0340.DATA_FIM,
                                                              TO_DATE('31/12/2999'),
                                                              DECODE(RHFP0300.DATA_FIM,
                                                                     NULL,
                                                                     '31/12/2024',
                                                                     RHFP0300.DATA_FIM),
                                                              RHFP0340.DATA_FIM),
                                                       RHFP0340.DATA_INICIO) / 12) AS ANOS_CARGO,
                                  ROUND(MONTHS_BETWEEN(DECODE(RHFP0340.DATA_FIM,
                                                              TO_DATE('31/12/2999'),
                                                              DECODE(RHFP0300.DATA_FIM,
                                                                     NULL,
                                                                     '31/12/2024',
                                                                     RHFP0300.DATA_FIM),
                                                              RHFP0340.DATA_FIM),
                                                       RHFP0340.DATA_INICIO)) AS MESES_CARGO,
                                  NVL(RHCS0196.IND_FC_TOTAL, 'N') AS FORA_CLASSE,
                                  NVL(RHCS0196.IND_FC_HORIZ, 'N') AS FORA_CLASSE_HORIZ
                             FROM RHFP0300 RHFP0300,
                                  RHFP0340 RHFP0340,
                                  RHFP0323 RHFP0323,
                                  RHFP0115 RHFP0115,
                                  RHFP0500 RHFP0500,
                                  RHFP0103 RHFP0103,
                                  RHFP0137 RHFP0137,
                                  RHFP0514 RHFP0514,
                                  RHFP0609 RHFP0609,
                                  RHCS0530,
                                  RHCS0196
                            WHERE RHFP0340.COD_MOTIVO = RHFP0323.COD_MOTIVO(+)
                              AND RHFP0500.COD_CARREIRA =
                                  RHCS0530.COD_CARREIRA(+)
                              AND RHFP0340.COD_CONTRATO =
                                  RHCS0196.COD_CONTRATO(+)
                              AND RHFP0500.COD_GRUPO_OCUP =
                                  RHFP0609.COD_GRUPO_OCUP(+)
                              AND RHFP0323.COD_TIPO_MOTIVO =
                                  RHFP0115.COD_TIPO_MOTIVO(+)
                              AND RHFP0340.COD_CLH = RHFP0500.COD_CLH(+)
                              AND RHFP0500.COD_CBO = RHFP0103.COD_CBO(+)
                              AND RHFP0500.COD_CBO_2002 =
                                  RHFP0137.COD_CBO_2002(+)
                              AND RHFP0500.SEQUENCIA_CBO_2002 =
                                  RHFP0137.SEQUENCIA(+)
                              AND RHFP0340.COD_FUN_CARGO =
                                  RHFP0514.COD_FUN_CARGO(+)
                              AND RHFP0340.COD_CONTRATO = RHFP0300.COD_CONTRATO
                              AND '31/12/2024' BETWEEN RHFP0340.DATA_INICIO AND
                                  RHFP0340.DATA_FIM) CON_CLH,
                          (SELECT RHFP0300.COD_CONTRATO,
                                  RHFP0300.COD_FUNC,
                                  RHFP0300.DATA_INICIO,
                                  RHFP0300.DATA_FIM,
                                  RHFP0300.COD_CAUSA_DEMISSAO,
                                  RHFP0102.NOME_CAUSA_DEMISSAO,
                                  RHFP0102.COD_CAGED AS COD_CAGED_DEMISSAO,
                                  RHFP0102.COD_SAQUE,
                                  RHFP0300.COD_CLASSE_CONTRATO,
                                  RHFP0239.NOME_CLASSE_CONTRATO,
                                  RHFP0300.COD_VINCULO_EMPREG,
                                  RHFP0110.NOME_VINCULO_EMPREG,
                                  RHFP0300.COD_TIPO_ADMISSAO,
                                  RHFP0114.NOME_TIPO_ADMISSAO,
                                  RHFP0114.COD_CAGED AS COD_CAGED_ADMISSAO,
                                  RHFP0300.COD_OPC_PGTO,
                                  RHFP0112.NOME_OPCAO_PGTO,
                                  RHFP0300.COD_FORMA_PGTO,
                                  RHFP0111.NOME_FORMA_PGTO,
                                  RHFP0300.COD_BCO_PGTO,
                                  BANCO_PGTO.COD_FEBRABAN AS COD_FEBRABAN_PGTO,
                                  PESSOA_BCO_PGTO.NOME_PESSOA AS NOME_BCO_PGTO,
                                  RHFP0300.COD_AGE_PGTO,
                                  AGENCIA_PGTO.DIGITO AS DIGITO_AGENCIA_PGTO,
                                  PESSOA_AGE_PGTO.NOME_PESSOA AS NOME_AGE_PGTO,
                                  RHFP0300.NRO_CONTA_PGTO,
                                  TRIM(SUBSTR(TRIM(RHFP0300.NRO_CONTA_PGTO),
                                              1,
                                              LENGTH(TRIM(RHFP0300.NRO_CONTA_PGTO)) - 1)) AS NRO_CONTA_PAGAMENTO,
                                  TRIM(SUBSTR(TRIM(RHFP0300.NRO_CONTA_PGTO),
                                              LENGTH(TRIM(RHFP0300.NRO_CONTA_PGTO)),
                                              1)) AS DIGITO_CONTA_PAGAMENTO,
                                  RHFP0300.DATA_OPCAO_FGTS,
                                  RHFP0300.COD_BCO_FGTD,
                                  BANCO_FGTS.COD_FEBRABAN AS COD_FEBRABAN_FGTS,
                                  PESSOA_BCO_FGTS.NOME_PESSOA AS NOME_BCO_FGTS,
                                  RHFP0300.COD_AGE_FGTS,
                                  PESSOA_AGE_FGTS.NOME_PESSOA AS NOME_AGE_FGTS,
                                  RHFP0300.NRO_CONTA_FGTS,
                                  RHFP0300.COD_TIPO_CONTRATO,
                                  RHFP0116.NOME_TIPO_CONTRATO,
                                  RHFP0116.DURACAO_CONTRATO,
                                  RHFP0116.ATUALIZA_AUTOMATICO,
                                  RHFP0116.NOVO_TIPO_CONTRATO,
                                  RHFP0300.MAO_OBRA,
                                  RHFP0300.COD_SITUACAO,
                                  RHFP0113.NOME_SITUACAO,
                                  RHFP0300.COD_CATEGORIA_TRAB,
                                  RHFP0128.NOME_CATEGORIA_TRAB,
                                  RHFP0300.COD_CLASSE_CONTRIB,
                                  RHFP0804.VALOR_CONTRIBUICAO,
                                  RHFP0300.IND_VINCULO_MULT,
                                  RHFP0300.IND_AGENTES_NOCIVOS,
                                  RHFP0300.IND_CONT_PREV,
                                  RHFP0300.DATA_AVANCO,
                                  '31/12/2024' AS DATA_REFERENCIA,
                                  TO_NUMBER(TO_CHAR(RHFP0300.DATA_AVANCO, 'DD'),
                                            '99') AS DIA_AVANCO,
                                  TO_NUMBER(TO_CHAR(RHFP0300.DATA_AVANCO, 'MM'),
                                            '99') AS MES_AVANCO,
                                  TO_NUMBER(TO_CHAR(RHFP0300.DATA_AVANCO,
                                                    'YYYY'),
                                            '9999') AS ANO_AVANCO,
                                  TO_NUMBER(TO_CHAR(RHFP0300.DATA_INICIO, 'DD'),
                                            '99') AS DIA_ADMISSAO,
                                  TO_NUMBER(TO_CHAR(RHFP0300.DATA_INICIO, 'MM'),
                                            '99') AS MES_ADMISSAO,
                                  TO_NUMBER(TO_CHAR(RHFP0300.DATA_INICIO,
                                                    'YYYY'),
                                            '9999') AS ANO_ADMISSAO,
                                  0 AS CHECK_UNIBANCO,
                                  RHAF1112.IND_ESPELHO,
                                  RHAF1112.IND_FREQUENCIA,
                                  RHAF1112.IND_HORARIO_AUTO,
                                  RHAF1112.IND_OCORRENCIAS,
                                  RHAF1112.IND_REFEITORIO,
                                  RHCS0196.DATA_ADESAO,
                                  RHCS0196.IND_ADERIU,
                                  RHCS0196.NRO_PROTOCOLO,
                                  RHFP0300.DATA_REINTEGRACAO
                             FROM PESSOA   PESSOA_BCO_PGTO,
                                  PESSOA   PESSOA_AGE_PGTO,
                                  PESSOA   PESSOA_BCO_FGTS,
                                  PESSOA   PESSOA_AGE_FGTS,
                                  RHFP0300 RHFP0300,
                                  BANCO    BANCO_PGTO,
                                  AGENCIA  AGENCIA_PGTO,
                                  BANCO    BANCO_FGTS,
                                  AGENCIA  AGENCIA_FGTS,
                                  RHFP0102 RHFP0102,
                                  RHFP0239 RHFP0239,
                                  RHFP0110 RHFP0110,
                                  RHFP0114 RHFP0114,
                                  RHFP0112 RHFP0112,
                                  RHFP0111 RHFP0111,
                                  RHFP0116 RHFP0116,
                                  RHFP0113 RHFP0113,
                                  RHFP0128 RHFP0128,
                                  RHFP0804 RHFP0804,
                                  RHAF1112 RHAF1112,
                                  RHCS0196 RHCS0196
                            WHERE RHFP0300.COD_CAUSA_DEMISSAO =
                                  RHFP0102.COD_CAUSA_DEMISSAO(+)
                              AND RHFP0300.COD_CLASSE_CONTRATO =
                                  RHFP0239.COD_CLASSE_CONTRATO(+)
                              AND RHFP0300.COD_VINCULO_EMPREG =
                                  RHFP0110.COD_VINCULO_EMPREG(+)
                              AND RHFP0300.COD_TIPO_ADMISSAO =
                                  RHFP0114.COD_TIPO_ADMISSAO(+)
                              AND RHFP0300.COD_OPC_PGTO =
                                  RHFP0112.COD_OPCAO_PGTO(+)
                              AND RHFP0300.COD_FORMA_PGTO =
                                  RHFP0111.COD_FORMA_PGTO(+)
                              AND RHFP0300.COD_BCO_PGTO =
                                  BANCO_PGTO.COD_BANCO(+)
                              AND BANCO_PGTO.COD_PESSOA =
                                  PESSOA_BCO_PGTO.COD_PESSOA(+)
                              AND RHFP0300.COD_BCO_PGTO =
                                  AGENCIA_PGTO.COD_BANCO(+)
                              AND RHFP0300.COD_AGE_PGTO =
                                  AGENCIA_PGTO.COD_AGENCIA(+)
                              AND AGENCIA_PGTO.COD_PESSOA =
                                  PESSOA_AGE_PGTO.COD_PESSOA(+)
                              AND RHFP0300.COD_BCO_FGTD =
                                  BANCO_FGTS.COD_BANCO(+)
                              AND BANCO_FGTS.COD_PESSOA =
                                  PESSOA_BCO_FGTS.COD_PESSOA(+)
                              AND RHFP0300.COD_BCO_FGTD =
                                  AGENCIA_FGTS.COD_BANCO(+)
                              AND RHFP0300.COD_AGE_FGTS =
                                  AGENCIA_FGTS.COD_AGENCIA(+)
                              AND AGENCIA_FGTS.COD_PESSOA =
                                  PESSOA_AGE_FGTS.COD_PESSOA(+)
                              AND RHFP0300.COD_TIPO_CONTRATO =
                                  RHFP0116.COD_TIPO_CONTRATO(+)
                              AND RHFP0300.COD_SITUACAO =
                                  RHFP0113.COD_SITUACAO(+)
                              AND RHFP0300.COD_CATEGORIA_TRAB =
                                  RHFP0128.COD_CATEGORIA_TRAB(+)
                              AND RHFP0300.COD_CLASSE_CONTRIB =
                                  RHFP0804.COD_CLASSE_CONTRIB(+)
                              AND RHFP0300.COD_CONTRATO =
                                  RHAF1112.COD_CONTRATO(+)
                              AND '31/12/2024' BETWEEN RHAF1112.DATA_INICIO(+) AND
                                  RHAF1112.DATA_FIM(+)
                              AND RHFP0300.COD_CONTRATO =
                                  RHCS0196.COD_CONTRATO(+)) CON_CON,
                          (SELECT RHFP0300.COD_CONTRATO,
                                  NVL(RHFP0306.COD_CAUSA_AFAST, 0) AS STATUS_AFASTAMENTO
                             FROM RHFP0306 RHFP0306,
                                  RHFP0300 RHFP0300
                            WHERE RHFP0300.COD_CONTRATO =
                                  RHFP0306.COD_CONTRATO(+)
                              AND '31/12/2024' BETWEEN RHFP0306.DATA_INICIO(+) AND
                                  RHFP0306.DATA_FIM(+)) CON_STAAFA,
                          (
                           
                           SELECT RHFP0310.COD_CONTRATO,
                                   RHFP0310.DATA_INICIO,
                                   RHFP0310.DATA_FIM,
                                   RHFP0310.COD_MOTIVO,
                                   RHFP0323.NOME_MOTIVO,
                                   RHFP0401.COD_NIVEL2 AS COD_EMPRESA,
                                   RHFP0401.COD_NIVEL3 AS COD_FILIAL,
                                   RHFP0401.COD_NIVEL4,
                                   RHFP0401.COD_NIVEL5,
                                   RHFP0401.COD_NIVEL6,
                                   RHFP0401.COD_NIVEL7,
                                   RHFP0401.COD_NIVEL8,
                                   (RHFP0401.EDICAO_NIVEL4) AS EDICAO_COMSEMP_NIVEL4,
                                   (RHFP0401.EDICAO_NIVEL4 || '.' ||
                                   RHFP0401.EDICAO_NIVEL5) AS EDICAO_COMSEMP_NIVEL5,
                                   (RHFP0401.EDICAO_NIVEL4 || '.' ||
                                   RHFP0401.EDICAO_NIVEL5 || '.' ||
                                   RHFP0401.EDICAO_NIVEL6) AS EDICAO_COMSEMP_NIVEL6,
                                   (RHFP0401.EDICAO_NIVEL4 || '.' ||
                                   RHFP0401.EDICAO_NIVEL5 || '.' ||
                                   RHFP0401.EDICAO_NIVEL6 || '.' ||
                                   RHFP0401.EDICAO_NIVEL7) AS EDICAO_COMSEMP_NIVEL7,
                                   (RHFP0401.EDICAO_NIVEL4 || '.' ||
                                   RHFP0401.EDICAO_NIVEL5 || '.' ||
                                   RHFP0401.EDICAO_NIVEL6 || '.' ||
                                   RHFP0401.EDICAO_NIVEL7 || '.' ||
                                   RHFP0401.EDICAO_NIVEL8) AS EDICAO_COMSEMP_NIVEL8,
                                   RHFP0401.EDICAO_NIVEL2 AS EDICAO_COMPOSTA_EMPRESA,
                                   (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                   RHFP0401.EDICAO_NIVEL3) AS EDICAO_COMPOSTA_FILIAL,
                                   (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                   RHFP0401.EDICAO_NIVEL3 || '.' ||
                                   RHFP0401.EDICAO_NIVEL4) AS EDICAO_COMPOSTA_NIVEL4,
                                   (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                   RHFP0401.EDICAO_NIVEL3 || '.' ||
                                   RHFP0401.EDICAO_NIVEL4 || '.' ||
                                   RHFP0401.EDICAO_NIVEL5) AS EDICAO_COMPOSTA_NIVEL5,
                                   (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                   RHFP0401.EDICAO_NIVEL3 || '.' ||
                                   RHFP0401.EDICAO_NIVEL4 || '.' ||
                                   RHFP0401.EDICAO_NIVEL5 || '.' ||
                                   RHFP0401.EDICAO_NIVEL6) AS EDICAO_COMPOSTA_NIVEL6,
                                   (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                   RHFP0401.EDICAO_NIVEL3 || '.' ||
                                   RHFP0401.EDICAO_NIVEL4 || '.' ||
                                   RHFP0401.EDICAO_NIVEL5 || '.' ||
                                   RHFP0401.EDICAO_NIVEL6 || '.' ||
                                   RHFP0401.EDICAO_NIVEL7) AS EDICAO_COMPOSTA_NIVEL7,
                                   (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                   RHFP0401.EDICAO_NIVEL3 || '.' ||
                                   RHFP0401.EDICAO_NIVEL4 || '.' ||
                                   RHFP0401.EDICAO_NIVEL5 || '.' ||
                                   RHFP0401.EDICAO_NIVEL6 || '.' ||
                                   RHFP0401.EDICAO_NIVEL7 || '.' ||
                                   RHFP0401.EDICAO_NIVEL8) AS EDICAO_COMPOSTA_NIVEL8,
                                   RHFP0401.EDICAO_NIVEL2 AS EDICAO_EMPRESA,
                                   RHFP0401.EDICAO_NIVEL3 AS EDICAO_FILIAL,
                                   RHFP0401.EDICAO_NIVEL4,
                                   RHFP0401.EDICAO_NIVEL5,
                                   RHFP0401.EDICAO_NIVEL6,
                                   RHFP0401.EDICAO_NIVEL7,
                                   RHFP0401.EDICAO_NIVEL8,
                                   
                                   PESEMP.COD_PESSOA  AS COD_PESSOA_EMPRESA,
                                   PESFIL.COD_PESSOA  AS COD_PESSOA_FILIAL,
                                   PESN04.COD_PESSOA  AS COD_PESSOA_NIVEL4,
                                   PESN05.COD_PESSOA  AS COD_PESSOA_NIVEL5,
                                   PESEMP.NOME_PESSOA AS RAZAO_SOCIAL_EMPRESA,
                                   PESFIL.NOME_PESSOA AS RAZAO_SOCIAL_FILIAL,
                                   PESN04.NOME_PESSOA AS RAZAO_SOCIAL_NIVEL4,
                                   PESN05.NOME_PESSOA AS RAZAO_SOCIAL_NIVEL5,
                                   
                                   RESPEMP.COD_PESSOA  AS COD_RESP_EMPRESA,
                                   RESPEMP.NOME_PESSOA AS NOME_RESP_EMPRESA,
                                   RESPFIL.COD_PESSOA  AS COD_RESP_FILIAL,
                                   RESPFIL.NOME_PESSOA AS NOME_RESP_FILIAL,
                                   
                                   EMP400.NOME_ORGANOGRAMA AS NOME_EMPRESA,
                                   FIL400.NOME_ORGANOGRAMA AS NOME_FILIAL,
                                   JURFIL.FANTASIA         AS NOME_FANTASIA_FILIAL,
                                   N4.NOME_ORGANOGRAMA     AS NOME_NIVEL4,
                                   N5.NOME_ORGANOGRAMA     AS NOME_NIVEL5,
                                   N6.NOME_ORGANOGRAMA     AS NOME_NIVEL6,
                                   N7.NOME_ORGANOGRAMA     AS NOME_NIVEL7,
                                   N8.NOME_ORGANOGRAMA     AS NOME_NIVEL8,
                                   LOGEMP.NOME_LOGRA       AS LOGRADOURO_EMPRESA,
                                   JUREMP.NUMERO           AS NUMERO_EMPRESA,
                                   JUREMP.COMPLEMENTO      AS COMPLEMENTO_EMPRESA,
                                   BAIEMP.NOME_BAIRRO      AS BAIRRO_EMPRESA,
                                   MUNEMP.NOME_MUNIC       AS MUNICIPIO_EMPRESA,
                                   JUREMP.CEP              AS CEP_EMPRESA,
                                   JUREMP.COD_UF           AS UF_EMPRESA,
                                   JUREMP.CGC              AS CGC_EMPRESA,
                                   JUREMP.TIP_LOGRA        AS TIPO_LOG_EMPRESA,
                                   
                                   LOGFIL.NOME_LOGRA  AS LOGRADOURO_FILIAL,
                                   JURFIL.NUMERO      AS NUMERO_FILIAL,
                                   JURFIL.COMPLEMENTO AS COMPLEMENTO_FILIAL,
                                   BAIFIL.NOME_BAIRRO AS BAIRRO_FILIAL,
                                   MUNFIL.NOME_MUNIC  AS MUNICIPIO_FILIAL,
                                   JURFIL.CEP         AS CEP_FILIAL,
                                   JURFIL.COD_UF      AS UF_FILIAL,
                                   JURFIL.CGC         AS CGC_FILIAL,
                                   JURFIL.TIP_LOGRA   AS TIPO_LOG_FILIAL,
                                   JURFIL.DDD         AS DDD_FILIAL,
                                   JURFIL.FONE        AS FONE_FILIAL,
                                   
                                   LOGN4.NOME_LOGRA  AS LOGRADOURO_NIVEL4,
                                   JURN4.NUMERO      AS NUMERO_NIVEL4,
                                   JURN4.COMPLEMENTO AS COMPLEMENTO_NIVEL4,
                                   BAIN4.NOME_BAIRRO AS BAIRRO_NIVEL4,
                                   MUNN4.NOME_MUNIC  AS MUNICIPIO_NIVEL4,
                                   JURN4.CEP         AS CEP_NIVEL4,
                                   JURN4.COD_UF      AS UF_NIVEL4,
                                   JURN4.CGC         AS CGC_NIVEL4,
                                   JURN4.TIP_LOGRA   AS TIPO_LOG_NIVEL4,
                                   
                                   LOGN5.NOME_LOGRA  AS LOGRADOURO_NIVEL5,
                                   JURN5.NUMERO      AS NUMERO_NIVEL5,
                                   JURN5.COMPLEMENTO AS COMPLEMENTO_NIVEL5,
                                   BAIN5.NOME_BAIRRO AS BAIRRO_NIVEL5,
                                   MUNN5.NOME_MUNIC  AS MUNICIPIO_NIVEL5,
                                   JURN5.CEP         AS CEP_NIVEL5,
                                   JURN5.COD_UF      AS UF_NIVEL5,
                                   JURN5.CGC         AS CGC_NIVEL5,
                                   JURN5.TIP_LOGRA   AS TIPO_LOG_NIVEL5,
                                   
                                   R430EMP.BANCO_DEBITO AS ESTEMP_BANCO_DEBITO,
                                   R430EMP.CODAGE_DEBITO AS ESTEMP_CODAGE_DEBITO,
                                   R430EMP.DIGAGE_DEBITO AS ESTEMP_DIGAGE_DEBITO,
                                   R430EMP.CONTA_DEBITO AS ESTEMP_CONTA_DEBITO,
                                   R430EMP.TIPO_INSCRICAO AS ESTEMP_TIPO_INSCRICAO,
                                   R430EMP.CPF AS ESTEMP_CPF,
                                   R430EMP.COD_CEI AS ESTEMP_COD_CEI,
                                   JUREMP.CGC AS ESTEMP_CNPJ,
                                   SUBSTR(JUREMP.CGC, 9, 6) AS ESTEMP_COMP_CNPJ,
                                   
                                   R430FIL.BANCO_DEBITO AS ESTFIL_BANCO_DEBITO,
                                   R430FIL.CODAGE_DEBITO AS ESTFIL_CODAGE_DEBITO,
                                   R430FIL.DIGAGE_DEBITO AS ESTFIL_DIGAGE_DEBITO,
                                   R430FIL.CONTA_DEBITO AS ESTFIL_CONTA_DEBITO,
                                   R430FIL.TIPO_INSCRICAO AS ESTFIL_TIPO_INSCRICAO,
                                   R430FIL.CPF AS ESTFIL_CPF,
                                   R430FIL.COD_CEI AS ESTFIL_COD_CEI,
                                   JURFIL.CGC AS ESTFIL_CNPJ,
                                   SUBSTR(JURFIL.CGC, 9, 6) AS ESTFIL_COMP_CNPJ,
                                   
                                   PESBANEMP.NOME_PESSOA AS ESTEMP_NOME_BANCO_DEBITO,
                                   PESBANFIL.NOME_PESSOA AS ESTFIL_NOME_BANCO_DEBITO,
                                   PESAGEEMP.NOME_PESSOA AS ESTEMP_NOME_AGENCIA_DEBITO,
                                   PESAGEFIL.NOME_PESSOA AS ESTFIL_NOME_AGENCIA_DEBITO,
                                   
                                   ANTERIOR.COD_EMPRESA             AS ANT_COD_EMPRESA,
                                   ANTERIOR.DATA_INICIO             AS ANT_DATA_INICIO,
                                   ANTERIOR.DATA_FIM                AS ANT_DATA_FIM,
                                   ANTERIOR.COD_MOTIVO              AS ANT_COD_MOTIVO,
                                   ANTERIOR.NOME_MOTIVO             AS ANT_NOME_MOTIVO,
                                   ANTERIOR.COD_FILIAL              AS ANT_COD_FILIAL,
                                   ANTERIOR.COD_NIVEL4              AS ANT_COD_NIVEL4,
                                   ANTERIOR.COD_NIVEL5              AS ANT_COD_NIVEL5,
                                   ANTERIOR.COD_NIVEL6              AS ANT_COD_NIVEL6,
                                   ANTERIOR.COD_NIVEL7              AS ANT_COD_NIVEL7,
                                   ANTERIOR.COD_NIVEL8              AS ANT_COD_NIVEL8,
                                   ANTERIOR.EDICAO_COMSEMP_NIVEL4   AS ANT_EDICAO_COMSEMP_NIVEL4,
                                   ANTERIOR.EDICAO_COMSEMP_NIVEL5   AS ANT_EDICAO_COMSEMP_NIVEL5,
                                   ANTERIOR.EDICAO_COMSEMP_NIVEL6   AS ANT_EDICAO_COMSEMP_NIVEL6,
                                   ANTERIOR.EDICAO_COMSEMP_NIVEL7   AS ANT_EDICAO_COMSEMP_NIVEL7,
                                   ANTERIOR.EDICAO_COMSEMP_NIVEL8   AS ANT_EDICAO_COMSEMP_NIVEL8,
                                   ANTERIOR.EDICAO_COMPOSTA_EMPRESA AS ANT_EDICAO_COMPOSTA_EMPRESA,
                                   ANTERIOR.EDICAO_COMPOSTA_FILIAL  AS ANT_EDICAO_COMPOSTA_FILIAL,
                                   ANTERIOR.EDICAO_COMPOSTA_NIVEL4  AS ANT_EDICAO_COMPOSTA_NIVEL4,
                                   ANTERIOR.EDICAO_COMPOSTA_NIVEL5  AS ANT_EDICAO_COMPOSTA_NIVEL5,
                                   ANTERIOR.EDICAO_COMPOSTA_NIVEL6  AS ANT_EDICAO_COMPOSTA_NIVEL6,
                                   ANTERIOR.EDICAO_COMPOSTA_NIVEL7  AS ANT_EDICAO_COMPOSTA_NIVEL7,
                                   ANTERIOR.EDICAO_COMPOSTA_NIVEL8  AS ANT_EDICAO_COMPOSTA_NIVEL8,
                                   ANTERIOR.EDICAO_EMPRESA          AS ANT_EDICAO_EMPRESA,
                                   ANTERIOR.EDICAO_FILIAL           AS ANT_EDICAO_FILIAL,
                                   ANTERIOR.EDICAO_NIVEL4           AS ANT_EDICAO_NIVEL4,
                                   ANTERIOR.EDICAO_NIVEL5           AS ANT_EDICAO_NIVEL5,
                                   ANTERIOR.EDICAO_NIVEL6           AS ANT_EDICAO_NIVEL6,
                                   ANTERIOR.EDICAO_NIVEL7           AS ANT_EDICAO_NIVEL7,
                                   ANTERIOR.EDICAO_NIVEL8           AS ANT_EDICAO_NIVEL8,
                                   
                                   ANTERIOR.COD_PESSOA_EMPRESA AS ANT_COD_PESSOA_EMPRESA,
                                   ANTERIOR.COD_PESSOA_FILIAL  AS ANT_COD_PESSOA_FILIAL,
                                   ANTERIOR.COD_PESSOA_NIVEL4  AS ANT_COD_PESSOA_NIVEL4,
                                   ANTERIOR.COD_PESSOA_NIVEL5  AS ANT_COD_PESSOA_NIVEL5,
                                   
                                   ANTERIOR.RAZAO_SOCIAL_EMPRESA AS ANT_RAZAO_SOCIAL_EMPRESA,
                                   ANTERIOR.RAZAO_SOCIAL_FILIAL  AS ANT_RAZAO_SOCIAL_FILIAL,
                                   ANTERIOR.RAZAO_SOCIAL_NIVEL4  AS ANT_RAZAO_SOVIAL_NIVEL4,
                                   ANTERIOR.RAZAO_SOCIAL_NIVEL5  AS ANT_RAZAO_SOVIAL_NIVEL5,
                                   
                                   ANTERIOR.COD_RESP_EMPRESA  AS ANT_COD_RESP_EMPRESA,
                                   ANTERIOR.NOME_RESP_EMPRESA AS ANT_NOME_RESP_EMPRESA,
                                   ANTERIOR.COD_RESP_FILIAL   AS ANT_COD_RESP_FILIAL,
                                   ANTERIOR.NOME_RESP_FILIAL  AS ANT_NOME_RESP_FILIAL,
                                   
                                   ANTERIOR.NOME_EMPRESA AS ANT_NOME_EMPRESA,
                                   ANTERIOR.NOME_FILIAL  AS ANT_NOME_FILIAL,
                                   ANTERIOR.NOME_NIVEL4  AS ANT_NOME_NIVEL4,
                                   ANTERIOR.NOME_NIVEL5  AS ANT_NOME_NIVEL5,
                                   ANTERIOR.NOME_NIVEL6  AS ANT_NOME_NIVEL6,
                                   ANTERIOR.NOME_NIVEL7  AS ANT_NOME_NIVEL7,
                                   ANTERIOR.NOME_NIVEL8  AS ANT_NOME_NIVEL8,
                                   
                                   ANTERIOR.LOGRADOURO_EMPRESA  AS ANT_LOGRADOURO_EMPRESA,
                                   ANTERIOR.NUMERO_EMPRESA      AS ANT_NUMERO_EMPRESA,
                                   ANTERIOR.COMPLEMENTO_EMPRESA AS ANT_COMPLEMENTO_EMPRESA,
                                   ANTERIOR.BAIRRO_EMPRESA      AS ANT_BAIRRO_EMPRESA,
                                   ANTERIOR.MUNICIPIO_EMPRESA   AS ANT_MUNICIPIO_EMPRESA,
                                   ANTERIOR.CEP_EMPRESA         AS ANT_CEP_EMPRESA,
                                   ANTERIOR.UF_EMPRESA          AS ANT_UF_EMPRESA,
                                   ANTERIOR.CGC_EMPRESA         AS ANT_CGC_EMPRESA,
                                   ANTERIOR.TIPO_LOG_EMPRESA    AS ANT_TIPO_LOG_EMPRESA,
                                   
                                   ANTERIOR.LOGRADOURO_FILIAL  AS ANT_LOGRADOURO_FILIAL,
                                   ANTERIOR.NUMERO_FILIAL      AS ANT_NUMERO_FILIAL,
                                   ANTERIOR.COMPLEMENTO_FILIAL AS ANT_COMPLEMENTO_FILIAL,
                                   ANTERIOR.BAIRRO_FILIAL      AS ANT_BAIRRO_FILIAL,
                                   ANTERIOR.MUNICIPIO_FILIAL   AS ANT_MUNICIPIO_FILIAL,
                                   ANTERIOR.CEP_FILIAL         AS ANT_CEP_FILIAL,
                                   ANTERIOR.UF_FILIAL          AS ANT_UF_FILIAL,
                                   ANTERIOR.CGC_FILIAL         AS ANT_CGC_FILIAL,
                                   ANTERIOR.TIPO_LOG_FILIAL    AS ANT_TIPO_LOG_FILIAL,
                                   
                                   ANTERIOR.LOGRADOURO_NIVEL4  AS ANT_LOGRADOURO_NIVEL4,
                                   ANTERIOR.NUMERO_NIVEL4      AS ANT_NUMERO_NIVEL4,
                                   ANTERIOR.COMPLEMENTO_NIVEL4 AS ANT_COMPLEMENTO_NIVEL4,
                                   ANTERIOR.BAIRRO_NIVEL4      AS ANT_BAIRRO_NIVEL4,
                                   ANTERIOR.MUNICIPIO_NIVEL4   AS ANT_MUNICIPIO_NIVEL4,
                                   ANTERIOR.CEP_NIVEL4         AS ANT_CEP_NIVEL4,
                                   ANTERIOR.UF_NIVEL4          AS ANT_UF_NIVEL4,
                                   ANTERIOR.CGC_NIVEL4         AS ANT_CGC_NIVEL4,
                                   ANTERIOR.TIPO_LOG_NIVEL4    AS ANT_TIPO_LOG_NIVEL4,
                                   
                                   ANTERIOR.LOGRADOURO_NIVEL5  AS ANT_LOGRADOURO_NIVEL5,
                                   ANTERIOR.NUMERO_NIVEL5      AS ANT_NUMERO_NIVEL5,
                                   ANTERIOR.COMPLEMENTO_NIVEL5 AS ANT_COMPLEMENTO_NIVEL5,
                                   ANTERIOR.BAIRRO_NIVEL5      AS ANT_BAIRRO_NIVEL5,
                                   ANTERIOR.MUNICIPIO_NIVEL5   AS ANT_MUNICIPIO_NIVEL5,
                                   ANTERIOR.CEP_NIVEL5         AS ANT_CEP_NIVEL5,
                                   ANTERIOR.UF_NIVEL5          AS ANT_UF_NIVEL5,
                                   ANTERIOR.CGC_NIVEL5         AS ANT_CGC_NIVEL5,
                                   ANTERIOR.TIPO_LOG_NIVEL5    AS ANT_TIPO_LOG_NIVEL5,
                                   
                                   ANTERIOR.ESTEMP_BANCO_DEBITO   AS ANT_ESTEMP_BANCO_DEBITO,
                                   ANTERIOR.ESTEMP_CODAGE_DEBITO  AS ANT_ESTEMP_CODAGE_DEBITO,
                                   ANTERIOR.ESTEMP_DIGAGE_DEBITO  AS ANT_ESTEMP_DIGAGE_DEBITO,
                                   ANTERIOR.ESTEMP_CONTA_DEBITO   AS ANT_ESTEMP_CONTA_DEBITO,
                                   ANTERIOR.ESTEMP_TIPO_INSCRICAO AS ANT_ESTEMP_TIPO_INSCRICAO,
                                   ANTERIOR.ESTEMP_CPF            AS ANT_ESTEMP_CPF,
                                   ANTERIOR.ESTEMP_COD_CEI        AS ANT_ESTEMP_COD_CEI,
                                   ANTERIOR.ESTEMP_CNPJ           AS ANT_ESTEMP_CNPJ,
                                   
                                   ANTERIOR.ESTFIL_BANCO_DEBITO   AS ANT_ESTFIL_BANCO_DEBITO,
                                   ANTERIOR.ESTFIL_CODAGE_DEBITO  AS ANT_ESTFIL_CODAGE_DEBITO,
                                   ANTERIOR.ESTFIL_DIGAGE_DEBITO  AS ANT_ESTFIL_DIGAGE_DEBITO,
                                   ANTERIOR.ESTFIL_CONTA_DEBITO   AS ANT_ESTFIL_CONTA_DEBITO,
                                   ANTERIOR.ESTFIL_TIPO_INSCRICAO AS ANT_ESTFIL_TIPO_INSCRICAO,
                                   ANTERIOR.ESTFIL_CPF            AS ANT_ESTFIL_CPF,
                                   ANTERIOR.ESTFIL_COD_CEI        AS ANT_ESTFIL_COD_CEI,
                                   ANTERIOR.ESTFIL_CNPJ           AS ANT_ESTFIL_CNPJ,
                                   
                                   ANTERIOR.ESTEMP_NOME_BANCO_DEBITO   AS ANT_ESTEMP_NOME_BANCO_DEBITO,
                                   ANTERIOR.ESTFIL_NOME_BANCO_DEBITO   AS ANT_ESTFIL_NOME_BANCO_DEBITO,
                                   ANTERIOR.ESTEMP_NOME_AGENCIA_DEBITO AS ANT_ESTEMP_NOME_AGENCIA_DEBITO,
                                   ANTERIOR.ESTFIL_NOME_AGENCIA_DEBITO AS ANT_ESTFIL_NOME_AGENCIA_DEBITO
                           
                             FROM RHFP0310 RHFP0310,
                                   RHFP0401 RHFP0401,
                                   RHFP0400 EMP400,
                                   RHFP0400 FIL400,
                                   RHFP0400 N4,
                                   RHFP0400 N5,
                                   RHFP0400 N6,
                                   RHFP0400 N7,
                                   RHFP0400 N8,
                                   
                                   PESSOA PESEMP,
                                   PESSOA PESFIL,
                                   PESSOA PESN04,
                                   PESSOA PESN05,
                                   PESSOA RESPEMP,
                                   PESSOA RESPFIL,
                                   
                                   LOGRA       LOGEMP,
                                   JURIDICA JUREMP,
                                   MUNICI   MUNEMP,
                                   BAIRRO      BAIEMP,
                                   
                                   LOGRA       LOGFIL,
                                   JURIDICA JURFIL,
                                   MUNICI   MUNFIL,
                                   BAIRRO      BAIFIL,
                                   
                                   LOGRA       LOGN4,
                                   JURIDICA JURN4,
                                   MUNICI   MUNN4,
                                   BAIRRO      BAIN4,
                                   
                                   LOGRA       LOGN5,
                                   JURIDICA JURN5,
                                   MUNICI   MUNN5,
                                   BAIRRO      BAIN5,
                                   
                                   RHFP0430 R430EMP,
                                   RHFP0430 R430FIL,
                                   
                                   BANCO   BANEMP,
                                   AGENCIA AGEEMP,
                                   BANCO   BANFIL,
                                   AGENCIA AGEFIL,
                                   
                                   PESSOA PESBANEMP,
                                   PESSOA PESBANFIL,
                                   PESSOA PESAGEEMP,
                                   PESSOA PESAGEFIL,
                                   RHFP0323 RHFP0323,
                                   (SELECT RHFP0310.COD_CONTRATO,
                                           RHFP0310.DATA_INICIO,
                                           RHFP0310.DATA_FIM,
                                           RHFP0310.COD_MOTIVO,
                                           RHFP0323.NOME_MOTIVO,
                                           RHFP0401.COD_NIVEL2 AS COD_EMPRESA,
                                           RHFP0401.COD_NIVEL3 AS COD_FILIAL,
                                           RHFP0401.COD_NIVEL4,
                                           RHFP0401.COD_NIVEL5,
                                           RHFP0401.COD_NIVEL6,
                                           RHFP0401.COD_NIVEL7,
                                           RHFP0401.COD_NIVEL8,
                                           (RHFP0401.EDICAO_NIVEL4) AS EDICAO_COMSEMP_NIVEL4,
                                           (RHFP0401.EDICAO_NIVEL4 || '.' ||
                                           RHFP0401.EDICAO_NIVEL5) AS EDICAO_COMSEMP_NIVEL5,
                                           (RHFP0401.EDICAO_NIVEL4 || '.' ||
                                           RHFP0401.EDICAO_NIVEL5 || '.' ||
                                           RHFP0401.EDICAO_NIVEL6) AS EDICAO_COMSEMP_NIVEL6,
                                           (RHFP0401.EDICAO_NIVEL4 || '.' ||
                                           RHFP0401.EDICAO_NIVEL5 || '.' ||
                                           RHFP0401.EDICAO_NIVEL6 || '.' ||
                                           RHFP0401.EDICAO_NIVEL7) AS EDICAO_COMSEMP_NIVEL7,
                                           (RHFP0401.EDICAO_NIVEL4 || '.' ||
                                           RHFP0401.EDICAO_NIVEL5 || '.' ||
                                           RHFP0401.EDICAO_NIVEL6 || '.' ||
                                           RHFP0401.EDICAO_NIVEL7 || '.' ||
                                           RHFP0401.EDICAO_NIVEL8) AS EDICAO_COMSEMP_NIVEL8,
                                           RHFP0401.EDICAO_NIVEL2 AS EDICAO_COMPOSTA_EMPRESA,
                                           (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                           RHFP0401.EDICAO_NIVEL3) AS EDICAO_COMPOSTA_FILIAL,
                                           (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                           RHFP0401.EDICAO_NIVEL3 || '.' ||
                                           RHFP0401.EDICAO_NIVEL4) AS EDICAO_COMPOSTA_NIVEL4,
                                           (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                           RHFP0401.EDICAO_NIVEL3 || '.' ||
                                           RHFP0401.EDICAO_NIVEL4 || '.' ||
                                           RHFP0401.EDICAO_NIVEL5) AS EDICAO_COMPOSTA_NIVEL5,
                                           (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                           RHFP0401.EDICAO_NIVEL3 || '.' ||
                                           RHFP0401.EDICAO_NIVEL4 || '.' ||
                                           RHFP0401.EDICAO_NIVEL5 || '.' ||
                                           RHFP0401.EDICAO_NIVEL6) AS EDICAO_COMPOSTA_NIVEL6,
                                           (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                           RHFP0401.EDICAO_NIVEL3 || '.' ||
                                           RHFP0401.EDICAO_NIVEL4 || '.' ||
                                           RHFP0401.EDICAO_NIVEL5 || '.' ||
                                           RHFP0401.EDICAO_NIVEL6 || '.' ||
                                           RHFP0401.EDICAO_NIVEL7) AS EDICAO_COMPOSTA_NIVEL7,
                                           (RHFP0401.EDICAO_NIVEL2 || '.' ||
                                           RHFP0401.EDICAO_NIVEL3 || '.' ||
                                           RHFP0401.EDICAO_NIVEL4 || '.' ||
                                           RHFP0401.EDICAO_NIVEL5 || '.' ||
                                           RHFP0401.EDICAO_NIVEL6 || '.' ||
                                           RHFP0401.EDICAO_NIVEL7 || '.' ||
                                           RHFP0401.EDICAO_NIVEL8) AS EDICAO_COMPOSTA_NIVEL8,
                                           RHFP0401.EDICAO_NIVEL2 AS EDICAO_EMPRESA,
                                           RHFP0401.EDICAO_NIVEL3 AS EDICAO_FILIAL,
                                           RHFP0401.EDICAO_NIVEL4,
                                           RHFP0401.EDICAO_NIVEL5,
                                           RHFP0401.EDICAO_NIVEL6,
                                           RHFP0401.EDICAO_NIVEL7,
                                           RHFP0401.EDICAO_NIVEL8,
                                           
                                           PESEMP.COD_PESSOA  AS COD_PESSOA_EMPRESA,
                                           PESFIL.COD_PESSOA  AS COD_PESSOA_FILIAL,
                                           PESN04.COD_PESSOA  AS COD_PESSOA_NIVEL4,
                                           PESN05.COD_PESSOA  AS COD_PESSOA_NIVEL5,
                                           PESEMP.NOME_PESSOA AS RAZAO_SOCIAL_EMPRESA,
                                           PESFIL.NOME_PESSOA AS RAZAO_SOCIAL_FILIAL,
                                           PESN04.NOME_PESSOA AS RAZAO_SOCIAL_NIVEL4,
                                           PESN05.NOME_PESSOA AS RAZAO_SOCIAL_NIVEL5,
                                           
                                           EMP400.NOME_ORGANOGRAMA AS NOME_EMPRESA,
                                           FIL400.NOME_ORGANOGRAMA AS NOME_FILIAL,
                                           N4.NOME_ORGANOGRAMA     AS NOME_NIVEL4,
                                           N5.NOME_ORGANOGRAMA     AS NOME_NIVEL5,
                                           N6.NOME_ORGANOGRAMA     AS NOME_NIVEL6,
                                           N7.NOME_ORGANOGRAMA     AS NOME_NIVEL7,
                                           N8.NOME_ORGANOGRAMA     AS NOME_NIVEL8,
                                           
                                           RESPEMP.COD_PESSOA  AS COD_RESP_EMPRESA,
                                           RESPEMP.NOME_PESSOA AS NOME_RESP_EMPRESA,
                                           RESPFIL.COD_PESSOA  AS COD_RESP_FILIAL,
                                           RESPFIL.NOME_PESSOA AS NOME_RESP_FILIAL,
                                           
                                           LOGEMP.NOME_LOGRA  AS LOGRADOURO_EMPRESA,
                                           JUREMP.NUMERO      AS NUMERO_EMPRESA,
                                           JUREMP.COMPLEMENTO AS COMPLEMENTO_EMPRESA,
                                           BAIEMP.NOME_BAIRRO AS BAIRRO_EMPRESA,
                                           MUNEMP.NOME_MUNIC  AS MUNICIPIO_EMPRESA,
                                           JUREMP.CEP         AS CEP_EMPRESA,
                                           JUREMP.COD_UF      AS UF_EMPRESA,
                                           JUREMP.CGC         AS CGC_EMPRESA,
                                           JUREMP.TIP_LOGRA   AS TIPO_LOG_EMPRESA,
                                           
                                           LOGFIL.NOME_LOGRA  AS LOGRADOURO_FILIAL,
                                           JURFIL.NUMERO      AS NUMERO_FILIAL,
                                           JURFIL.COMPLEMENTO AS COMPLEMENTO_FILIAL,
                                           BAIFIL.NOME_BAIRRO AS BAIRRO_FILIAL,
                                           MUNFIL.NOME_MUNIC  AS MUNICIPIO_FILIAL,
                                           JURFIL.CEP         AS CEP_FILIAL,
                                           JURFIL.COD_UF      AS UF_FILIAL,
                                           JURFIL.CGC         AS CGC_FILIAL,
                                           JURFIL.TIP_LOGRA   AS TIPO_LOG_FILIAL,
                                           
                                           LOGN4.NOME_LOGRA  AS LOGRADOURO_NIVEL4,
                                           JURN4.NUMERO      AS NUMERO_NIVEL4,
                                           JURN4.COMPLEMENTO AS COMPLEMENTO_NIVEL4,
                                           BAIN4.NOME_BAIRRO AS BAIRRO_NIVEL4,
                                           MUNN4.NOME_MUNIC  AS MUNICIPIO_NIVEL4,
                                           JURN4.CEP         AS CEP_NIVEL4,
                                           JURN4.COD_UF      AS UF_NIVEL4,
                                           JURN4.CGC         AS CGC_NIVEL4,
                                           JURN4.TIP_LOGRA   AS TIPO_LOG_NIVEL4,
                                           
                                           LOGN5.NOME_LOGRA  AS LOGRADOURO_NIVEL5,
                                           JURN5.NUMERO      AS NUMERO_NIVEL5,
                                           JURN5.COMPLEMENTO AS COMPLEMENTO_NIVEL5,
                                           BAIN5.NOME_BAIRRO AS BAIRRO_NIVEL5,
                                           MUNN5.NOME_MUNIC  AS MUNICIPIO_NIVEL5,
                                           JURN5.CEP         AS CEP_NIVEL5,
                                           JURN5.COD_UF      AS UF_NIVEL5,
                                           JURN5.CGC         AS CGC_NIVEL5,
                                           JURN5.TIP_LOGRA   AS TIPO_LOG_NIVEL5,
                                           
                                           R430EMP.BANCO_DEBITO   AS ESTEMP_BANCO_DEBITO,
                                           R430EMP.CODAGE_DEBITO  AS ESTEMP_CODAGE_DEBITO,
                                           R430EMP.DIGAGE_DEBITO  AS ESTEMP_DIGAGE_DEBITO,
                                           R430EMP.CONTA_DEBITO   AS ESTEMP_CONTA_DEBITO,
                                           R430EMP.TIPO_INSCRICAO AS ESTEMP_TIPO_INSCRICAO,
                                           R430EMP.CPF            AS ESTEMP_CPF,
                                           R430EMP.COD_CEI        AS ESTEMP_COD_CEI,
                                           JUREMP.CGC             AS ESTEMP_CNPJ,
                                           
                                           R430FIL.BANCO_DEBITO   AS ESTFIL_BANCO_DEBITO,
                                           R430FIL.CODAGE_DEBITO  AS ESTFIL_CODAGE_DEBITO,
                                           R430FIL.DIGAGE_DEBITO  AS ESTFIL_DIGAGE_DEBITO,
                                           R430FIL.CONTA_DEBITO   AS ESTFIL_CONTA_DEBITO,
                                           R430FIL.TIPO_INSCRICAO AS ESTFIL_TIPO_INSCRICAO,
                                           R430FIL.CPF            AS ESTFIL_CPF,
                                           R430FIL.COD_CEI        AS ESTFIL_COD_CEI,
                                           JURFIL.CGC             AS ESTFIL_CNPJ,
                                           
                                           PESBANEMP.NOME_PESSOA AS ESTEMP_NOME_BANCO_DEBITO,
                                           PESBANFIL.NOME_PESSOA AS ESTFIL_NOME_BANCO_DEBITO,
                                           PESAGEEMP.NOME_PESSOA AS ESTEMP_NOME_AGENCIA_DEBITO,
                                           PESAGEFIL.NOME_PESSOA AS ESTFIL_NOME_AGENCIA_DEBITO
                                    
                                      FROM RHFP0310 RHFP0310,
                                           RHFP0401 RHFP0401,
                                           
                                           RHFP0400 EMP400,
                                           RHFP0400 FIL400,
                                           RHFP0400 N4,
                                           RHFP0400 N5,
                                           RHFP0400 N6,
                                           RHFP0400 N7,
                                           RHFP0400 N8,
                                           
                                           LOGRA       LOGEMP,
                                           JURIDICA JUREMP,
                                           MUNICI   MUNEMP,
                                           BAIRRO      BAIEMP,
                                           
                                           LOGRA       LOGFIL,
                                           JURIDICA JURFIL,
                                           MUNICI   MUNFIL,
                                           BAIRRO      BAIFIL,
                                           
                                           LOGRA       LOGN4,
                                           JURIDICA JURN4,
                                           MUNICI   MUNN4,
                                           BAIRRO      BAIN4,
                                           
                                           LOGRA       LOGN5,
                                           JURIDICA JURN5,
                                           MUNICI   MUNN5,
                                           BAIRRO      BAIN5,
                                           
                                           RHFP0430 R430EMP,
                                           RHFP0430 R430FIL,
                                           
                                           BANCO   BANEMP,
                                           AGENCIA AGEEMP,
                                           BANCO   BANFIL,
                                           AGENCIA AGEFIL,
                                           
                                           PESSOA PESBANEMP,
                                           PESSOA PESBANFIL,
                                           PESSOA PESAGEEMP,
                                           PESSOA PESAGEFIL,
                                           
                                           PESSOA PESEMP,
                                           PESSOA PESFIL,
                                           PESSOA PESN04,
                                           PESSOA PESN05,
                                           PESSOA RESPEMP,
                                           PESSOA RESPFIL,
                                           
                                           RHFP0323 RHFP0323
                                    
                                     WHERE RHFP0310.COD_ORGANOGRAMA =
                                           RHFP0401.COD_ORGANOGRAMA
                                       AND RHFP0310.DATA_INICIO BETWEEN
                                           RHFP0401.DATA_INICIO AND
                                           RHFP0401.DATA_FIM
                                       AND RHFP0401.COD_NIVEL2 =
                                           R430EMP.COD_ESTABELECIMENTO(+)
                                       AND RHFP0401.COD_NIVEL3 =
                                           R430FIL.COD_ESTABELECIMENTO(+)
                                          
                                       AND R430EMP.BANCO_DEBITO =
                                           BANEMP.COD_BANCO(+)
                                       AND R430FIL.BANCO_DEBITO =
                                           BANFIL.COD_BANCO(+)
                                       AND R430EMP.BANCO_DEBITO =
                                           AGEEMP.COD_BANCO(+)
                                       AND R430EMP.CODAGE_DEBITO =
                                           AGEEMP.COD_AGENCIA(+)
                                       AND R430FIL.BANCO_DEBITO =
                                           AGEFIL.COD_BANCO(+)
                                       AND R430FIL.CODAGE_DEBITO =
                                           AGEFIL.COD_AGENCIA(+)
                                          
                                       AND R430EMP.COD_RESPONSAVEL =
                                           RESPEMP.COD_PESSOA(+)
                                       AND R430FIL.COD_RESPONSAVEL =
                                           RESPFIL.COD_PESSOA(+)
                                          
                                       AND BANEMP.COD_PESSOA =
                                           PESBANEMP.COD_PESSOA(+)
                                       AND BANFIL.COD_PESSOA =
                                           PESBANFIL.COD_PESSOA(+)
                                       AND AGEEMP.COD_PESSOA =
                                           PESAGEEMP.COD_PESSOA(+)
                                       AND AGEFIL.COD_PESSOA =
                                           PESAGEFIL.COD_PESSOA(+)
                                          
                                       AND RHFP0401.COD_NIVEL2 =
                                           EMP400.COD_ORGANOGRAMA
                                       AND RHFP0401.COD_NIVEL3 =
                                           FIL400.COD_ORGANOGRAMA
                                       AND RHFP0401.COD_NIVEL4 =
                                           N4.COD_ORGANOGRAMA(+)
                                       AND RHFP0401.COD_NIVEL5 =
                                           N5.COD_ORGANOGRAMA(+)
                                       AND RHFP0401.COD_NIVEL6 =
                                           N6.COD_ORGANOGRAMA(+)
                                       AND RHFP0401.COD_NIVEL7 =
                                           N7.COD_ORGANOGRAMA(+)
                                       AND RHFP0401.COD_NIVEL8 =
                                           N8.COD_ORGANOGRAMA(+)
                                          
                                       AND EMP400.COD_PESSOA =
                                           PESEMP.COD_PESSOA(+)
                                       AND FIL400.COD_PESSOA =
                                           PESFIL.COD_PESSOA(+)
                                       AND N4.COD_PESSOA = PESN04.COD_PESSOA(+)
                                       AND N5.COD_PESSOA = PESN05.COD_PESSOA(+)
                                          
                                       AND EMP400.COD_PESSOA =
                                           JUREMP.COD_PESSOA(+)
                                       AND FIL400.COD_PESSOA =
                                           JURFIL.COD_PESSOA(+)
                                       AND N4.COD_PESSOA = JURN4.COD_PESSOA(+)
                                       AND N5.COD_PESSOA = JURN5.COD_PESSOA(+)
                                          
                                       AND JUREMP.COD_LOGRA = LOGEMP.COD_LOGRA(+)
                                       AND JUREMP.COD_MUNIC = LOGEMP.COD_MUNIC(+)
                                       AND JUREMP.COD_UF = LOGEMP.COD_UF(+)
                                       AND JUREMP.COD_MUNIC = MUNEMP.COD_MUNIC(+)
                                       AND JUREMP.COD_UF = MUNEMP.COD_UF(+)
                                       AND JUREMP.COD_BAIRRO =
                                           BAIEMP.COD_BAIRRO(+)
                                       AND JUREMP.COD_MUNIC = BAIEMP.COD_MUNIC(+)
                                       AND JUREMP.COD_UF = BAIEMP.COD_UF(+)
                                          
                                       AND JURFIL.COD_LOGRA = LOGFIL.COD_LOGRA(+)
                                       AND JURFIL.COD_MUNIC = LOGFIL.COD_MUNIC(+)
                                       AND JURFIL.COD_UF = LOGFIL.COD_UF(+)
                                       AND JURFIL.COD_MUNIC = MUNFIL.COD_MUNIC(+)
                                       AND JURFIL.COD_UF = MUNFIL.COD_UF(+)
                                       AND JURFIL.COD_BAIRRO =
                                           BAIFIL.COD_BAIRRO(+)
                                       AND JURFIL.COD_MUNIC = BAIFIL.COD_MUNIC(+)
                                       AND JURFIL.COD_UF = BAIFIL.COD_UF(+)
                                          
                                       AND JURN4.COD_LOGRA = LOGN4.COD_LOGRA(+)
                                       AND JURN4.COD_MUNIC = LOGN4.COD_MUNIC(+)
                                       AND JURN4.COD_UF = LOGN4.COD_UF(+)
                                       AND JURN4.COD_MUNIC = MUNN4.COD_MUNIC(+)
                                       AND JURN4.COD_UF = MUNN4.COD_UF(+)
                                       AND JURN4.COD_BAIRRO = BAIN4.COD_BAIRRO(+)
                                       AND JURN4.COD_MUNIC = BAIN4.COD_MUNIC(+)
                                       AND JURN4.COD_UF = BAIN4.COD_UF(+)
                                          
                                       AND JURN5.COD_LOGRA = LOGN5.COD_LOGRA(+)
                                       AND JURN5.COD_MUNIC = LOGN5.COD_MUNIC(+)
                                       AND JURN5.COD_UF = LOGN5.COD_UF(+)
                                       AND JURN5.COD_MUNIC = MUNN5.COD_MUNIC(+)
                                       AND JURN5.COD_UF = MUNN5.COD_UF(+)
                                       AND JURN5.COD_BAIRRO = BAIN5.COD_BAIRRO(+)
                                       AND JURN5.COD_MUNIC = BAIN5.COD_MUNIC(+)
                                       AND JURN5.COD_UF = BAIN5.COD_UF(+)
                                          
                                       AND RHFP0310.COD_MOTIVO =
                                           RHFP0323.COD_MOTIVO(+)
                                    
                                    ) ANTERIOR
                           
                            WHERE RHFP0310.COD_ORGANOGRAMA =
                                  RHFP0401.COD_ORGANOGRAMA
                              AND '31/12/2024' BETWEEN RHFP0401.DATA_INICIO AND
                                  RHFP0401.DATA_FIM
                              AND '31/12/2024' BETWEEN RHFP0310.DATA_INICIO AND
                                  RHFP0310.DATA_FIM
                                 
                              AND RHFP0401.COD_NIVEL2 =
                                  R430EMP.COD_ESTABELECIMENTO(+)
                              AND RHFP0401.COD_NIVEL3 =
                                  R430FIL.COD_ESTABELECIMENTO(+)
                              AND R430EMP.BANCO_DEBITO = BANEMP.COD_BANCO(+)
                              AND R430FIL.BANCO_DEBITO = BANFIL.COD_BANCO(+)
                              AND R430EMP.BANCO_DEBITO = AGEEMP.COD_BANCO(+)
                              AND R430EMP.CODAGE_DEBITO = AGEEMP.COD_AGENCIA(+)
                              AND R430FIL.BANCO_DEBITO = AGEFIL.COD_BANCO(+)
                              AND R430FIL.CODAGE_DEBITO = AGEFIL.COD_AGENCIA(+)
                                 
                              AND EMP400.COD_PESSOA = PESEMP.COD_PESSOA(+)
                              AND FIL400.COD_PESSOA = PESFIL.COD_PESSOA(+)
                              AND N4.COD_PESSOA = PESN04.COD_PESSOA(+)
                              AND N5.COD_PESSOA = PESN05.COD_PESSOA(+)
                                 
                              AND R430EMP.COD_RESPONSAVEL =
                                  RESPEMP.COD_PESSOA(+)
                              AND R430FIL.COD_RESPONSAVEL =
                                  RESPFIL.COD_PESSOA(+)
                                 
                              AND BANEMP.COD_PESSOA = PESBANEMP.COD_PESSOA(+)
                              AND BANFIL.COD_PESSOA = PESBANFIL.COD_PESSOA(+)
                              AND AGEEMP.COD_PESSOA = PESAGEEMP.COD_PESSOA(+)
                              AND AGEFIL.COD_PESSOA = PESAGEFIL.COD_PESSOA(+)
                                 
                              AND RHFP0401.COD_NIVEL2 = EMP400.COD_ORGANOGRAMA
                              AND RHFP0401.COD_NIVEL3 = FIL400.COD_ORGANOGRAMA
                              AND RHFP0401.COD_NIVEL4 = N4.COD_ORGANOGRAMA(+)
                              AND RHFP0401.COD_NIVEL5 = N5.COD_ORGANOGRAMA(+)
                              AND RHFP0401.COD_NIVEL6 = N6.COD_ORGANOGRAMA(+)
                              AND RHFP0401.COD_NIVEL7 = N7.COD_ORGANOGRAMA(+)
                              AND RHFP0401.COD_NIVEL8 = N8.COD_ORGANOGRAMA(+)
                                 
                              AND EMP400.COD_PESSOA = JUREMP.COD_PESSOA(+)
                              AND FIL400.COD_PESSOA = JURFIL.COD_PESSOA(+)
                              AND N4.COD_PESSOA = JURN4.COD_PESSOA(+)
                              AND N5.COD_PESSOA = JURN5.COD_PESSOA(+)
                                 
                              AND JUREMP.COD_LOGRA = LOGEMP.COD_LOGRA(+)
                              AND JUREMP.COD_MUNIC = LOGEMP.COD_MUNIC(+)
                              AND JUREMP.COD_UF = LOGEMP.COD_UF(+)
                              AND JUREMP.COD_MUNIC = MUNEMP.COD_MUNIC(+)
                              AND JUREMP.COD_UF = MUNEMP.COD_UF(+)
                              AND JUREMP.COD_BAIRRO = BAIEMP.COD_BAIRRO(+)
                              AND JUREMP.COD_MUNIC = BAIEMP.COD_MUNIC(+)
                              AND JUREMP.COD_UF = BAIEMP.COD_UF(+)
                                 
                              AND JURFIL.COD_LOGRA = LOGFIL.COD_LOGRA(+)
                              AND JURFIL.COD_MUNIC = LOGFIL.COD_MUNIC(+)
                              AND JURFIL.COD_UF = LOGFIL.COD_UF(+)
                              AND JURFIL.COD_MUNIC = MUNFIL.COD_MUNIC(+)
                              AND JURFIL.COD_UF = MUNFIL.COD_UF(+)
                              AND JURFIL.COD_BAIRRO = BAIFIL.COD_BAIRRO(+)
                              AND JURFIL.COD_MUNIC = BAIFIL.COD_MUNIC(+)
                              AND JURFIL.COD_UF = BAIFIL.COD_UF(+)
                                 
                              AND JURN4.COD_LOGRA = LOGN4.COD_LOGRA(+)
                              AND JURN4.COD_MUNIC = LOGN4.COD_MUNIC(+)
                              AND JURN4.COD_UF = LOGN4.COD_UF(+)
                              AND JURN4.COD_MUNIC = MUNN4.COD_MUNIC(+)
                              AND JURN4.COD_UF = MUNN4.COD_UF(+)
                              AND JURN4.COD_BAIRRO = BAIN4.COD_BAIRRO(+)
                              AND JURN4.COD_MUNIC = BAIN4.COD_MUNIC(+)
                              AND JURN4.COD_UF = BAIN4.COD_UF(+)
                                 
                              AND JURN5.COD_LOGRA = LOGN5.COD_LOGRA(+)
                              AND JURN5.COD_MUNIC = LOGN5.COD_MUNIC(+)
                              AND JURN5.COD_UF = LOGN5.COD_UF(+)
                              AND JURN5.COD_MUNIC = MUNN5.COD_MUNIC(+)
                              AND JURN5.COD_UF = MUNN5.COD_UF(+)
                              AND JURN5.COD_BAIRRO = BAIN5.COD_BAIRRO(+)
                              AND JURN5.COD_MUNIC = BAIN5.COD_MUNIC(+)
                              AND JURN5.COD_UF = BAIN5.COD_UF(+)
                                 
                              AND RHFP0310.COD_CONTRATO =
                                  ANTERIOR.COD_CONTRATO(+)
                              AND RHFP0310.DATA_INICIO - 1 =
                                  ANTERIOR.DATA_FIM(+)
                              AND RHFP0310.COD_MOTIVO = RHFP0323.COD_MOTIVO(+)
                           
                           ) CON_EMP,
                          (
                           
                           SELECT CAMPOS.*
                             FROM (SELECT CTR.COD_CONTRATO,
                                           CTR.DATA_INICIO,
                                           CTR.DATA_FIM,
                                           CTR.COD_CUSTO_CONTABIL,
                                           RHFP0402.CUSTO_CONTABIL,
                                           RHFP0402.NOME_CUSTO_CONTABIL,
                                           RHFP0402.COD_CUSTO_N1,
                                           RHFP0402.COD_CUSTO_N2,
                                           RHFP0402.COD_CUSTO_N3,
                                           RHFP0402.COD_CUSTO_N4,
                                           RHFP0402.COD_CUSTO_N5,
                                           RHFP0402.COD_CUSTO_N6,
                                           RHFP0402.COD_CUSTO_N7,
                                           RHFP0402.COD_CUSTO_N8,
                                           RHFP0402.COD_CUSTO_SUB,
                                           CS.NOME_CUSTO_CONTABIL AS NOME_CUSTO_SUB,
                                           RHFP0402.COD_NIVEL_CONTABIL,
                                           RHFP0402.EDICAO_CUSTO_CONT,
                                           RHFP0402.EDICAO_NIVEL1,
                                           RHFP0402.EDICAO_NIVEL2,
                                           RHFP0402.EDICAO_NIVEL3,
                                           RHFP0402.EDICAO_NIVEL4,
                                           RHFP0402.EDICAO_NIVEL5,
                                           RHFP0402.EDICAO_NIVEL6,
                                           RHFP0402.EDICAO_NIVEL7,
                                           RHFP0402.EDICAO_NIVEL8,
                                           SUBSTR(RHYF0034(RHFP0402.COD_CUSTO_CONTABIL,
                                                                           1,
                                                                           'E'),
                                                  1,
                                                  120) AS EDICAO_COMPOSTA_NIVEL1,
                                           SUBSTR(RHYF0034(RHFP0402.COD_CUSTO_CONTABIL,
                                                                           2,
                                                                           'E'),
                                                  1,
                                                  120) AS EDICAO_COMPOSTA_NIVEL2,
                                           SUBSTR(RHYF0034(RHFP0402.COD_CUSTO_CONTABIL,
                                                                           3,
                                                                           'E'),
                                                  1,
                                                  120) AS EDICAO_COMPOSTA_NIVEL3,
                                           SUBSTR(RHYF0034(RHFP0402.COD_CUSTO_CONTABIL,
                                                                           4,
                                                                           'E'),
                                                  1,
                                                  120) AS EDICAO_COMPOSTA_NIVEL4,
                                           SUBSTR(RHYF0034(RHFP0402.COD_CUSTO_CONTABIL,
                                                                           5,
                                                                           'E'),
                                                  1,
                                                  120) AS EDICAO_COMPOSTA_NIVEL5,
                                           SUBSTR(RHYF0034(RHFP0402.COD_CUSTO_CONTABIL,
                                                                           6,
                                                                           'E'),
                                                  1,
                                                  120) AS EDICAO_COMPOSTA_NIVEL6,
                                           SUBSTR(RHYF0034(RHFP0402.COD_CUSTO_CONTABIL,
                                                                           7,
                                                                           'E'),
                                                  1,
                                                  120) AS EDICAO_COMPOSTA_NIVEL7,
                                           SUBSTR(RHYF0034(RHFP0402.COD_CUSTO_CONTABIL,
                                                                           8,
                                                                           'E'),
                                                  1,
                                                  120) AS EDICAO_COMPOSTA_NIVEL8
                                      FROM RHFP0402 RHFP0402,
                                           RHFP0402 CS,
                                           (SELECT RHFP0310.COD_CONTRATO,
                                                   RHFP0400.COD_CUSTO_CONTABIL,
                                                   RHFP0310.DATA_INICIO,
                                                   RHFP0310.DATA_FIM
                                              FROM RHFP0310 RHFP0310,
                                                   RHFP0400 RHFP0400
                                             WHERE RHFP0310.COD_ORGANOGRAMA =
                                                   RHFP0400.COD_ORGANOGRAMA
                                               AND '31/12/2024' BETWEEN
                                                   RHFP0310.DATA_INICIO AND
                                                   RHFP0310.DATA_FIM
                                               AND RHFP0310.COD_CONTRATO NOT IN
                                                   (SELECT RHFP0313.COD_CONTRATO
                                                      FROM RHFP0313 RHFP0313
                                                     WHERE '31/12/2024' BETWEEN
                                                           RHFP0313.DATA_INICIO AND
                                                           RHFP0313.DATA_FIM
                                                       AND RHFP0313.COD_CONTRATO =
                                                           RHFP0310.COD_CONTRATO)
                                            UNION ALL
                                            SELECT RHFP0313.COD_CONTRATO,
                                                   RHFP0313.COD_CUSTO_CONTABIL,
                                                   RHFP0313.DATA_INICIO,
                                                   RHFP0313.DATA_FIM
                                              FROM RHFP0313 RHFP0313
                                             WHERE '31/12/2024' BETWEEN
                                                   RHFP0313.DATA_INICIO AND
                                                   RHFP0313.DATA_FIM) CTR
                                     WHERE RHFP0402.COD_CUSTO_CONTABIL =
                                           CTR.COD_CUSTO_CONTABIL
                                       AND RHFP0402.COD_CUSTO_SUB =
                                           CS.COD_CUSTO_CONTABIL(+)) CAMPOS
                            WHERE 1 = 1
                           
                           ) CON_CUSTO,
                          (
                           
                           SELECT STACON.COD_CONTRATO,
                                   STACON.STATUS AS STATUS_CONTRATO
                             FROM (SELECT COD_CONTRATO, 0 AS STATUS
                                      FROM RHFP0300 RHFP0300
                                     WHERE (RHFP0300.DATA_FIM IS NULL OR
                                           RHFP0300.DATA_FIM >= '31/12/2024')
                                       AND (RHFP0300.DATA_INICIO <= '31/12/2024')
                                    UNION ALL
                                    SELECT COD_CONTRATO, 1 AS STATUS
                                      FROM RHFP0300 RHFP0300
                                     WHERE (RHFP0300.DATA_FIM IS NOT NULL AND
                                           RHFP0300.DATA_FIM < '31/12/2024')
                                       AND (RHFP0300.DATA_INICIO <= '31/12/2024')
                                    UNION ALL
                                    SELECT COD_CONTRATO, 1 AS STATUS
                                      FROM RHFP0300 RHFP0300
                                     WHERE (RHFP0300.DATA_INICIO > '31/12/2024')) STACON
                           
                           ) CON_STACON,
                          (
                           
                           SELECT RHFP0310.COD_CONTRATO,
                                   PE0002.COD_CAMPO,
                                   PE0001.DESCRICAO,
                                   PE0002.VALOR
                             FROM RHFP0310 RHFP0310,
                                   RHFP0400 RHFP0400,
                                   RHFP0401 RHFP0401,
                                   PE0002   PE0002,
                                   PE0001   PE0001
                            WHERE RHFP0310.COD_ORGANOGRAMA =
                                  RHFP0401.COD_ORGANOGRAMA
                              AND '31/12/2024' BETWEEN RHFP0310.DATA_INICIO AND
                                  RHFP0310.DATA_FIM
                              AND '31/12/2024' BETWEEN RHFP0401.DATA_INICIO AND
                                  RHFP0401.DATA_FIM
                              AND RHFP0401.COD_NIVEL3 = RHFP0400.COD_ORGANOGRAMA
                              AND RHFP0400.COD_PESSOA = PE0002.COD_PESSOA
                              AND PE0002.COD_CAMPO = PE0001.SEQUENCIA
                           
                           ) CON_FIL_OUT,
                          (
                           
                           SELECT RHFP0310.COD_CONTRATO,
                                   RHFP0310.DATA_INICIO AS DATA_INICIO_ORG,
                                   RHFP0310.DATA_FIM AS DATA_FIM_ORG,
                                   RHFP0310.COD_ORGANOGRAMA,
                                   SUBSTR(RHYF0002(RHFP0310.COD_ORGANOGRAMA,
                                                                   RHFP0400.COD_NIVEL_ORG,
                                                                   '31/12/2024'),
                                          1,
                                          80) AS EDICAO_ORGANOGRAMA,
                                   RHFP0400.NOME_ORGANOGRAMA,
                                   RHFP0400.COD_NIVEL_ORG,
                                   RHFP0117.NOME_NIVEL_ORG,
                                   RHFP0400.COD_PESSOA AS COD_EMPFIL,
                                   PESSOA_EMPFIL.NOME_PESSOA AS NOME_EMPRESA_FILIAL,
                                   RHFP0400.CLIENTE,
                                   RHFP0400.COD_DRT,
                                   PESSOA_DRT.NOME_PESSOA AS NOME_DRT,
                                   RHFP0400.ULTIMA_FICHA_REG,
                                   RHFP0400.COD_CUSTO_CONTABIL,
                                   RHFP0402.NOME_CUSTO_CONTABIL,
                                   RHFP0402.CUSTO_CONTABIL,
                                   RHFP0310.COD_MOTIVO,
                                   RHFP0323.NOME_MOTIVO,
                                   RHFP0323.COD_TIPO_MOTIVO,
                                   RHFP0115.NOME_TIPO_MOTIVO,
                                   RHFP0310.COD_CAUSA_DEMISSAO,
                                   RHFP0102.NOME_CAUSA_DEMISSAO,
                                   RHFP0401.DATA_INICIO AS DATA_INICIO_EST,
                                   RHFP0401.DATA_FIM AS DATA_FIM_EST,
                                   RHFP0401.COD_ORGANOGRAMA_SUB,
                                   RHFP0401.EDICAO_ORG,
                                   RHFP0401.IND_LANCAMENTO,
                                   RHFP0436.CCUST_RH,
                                   RHFP3170.LOTACAO_SIAPE,
                                   ANTERIOR.DATA_INICIO_ORG AS DATA_INICIO_ORG_ANT,
                                   ANTERIOR.DATA_FIM_ORG AS DATA_FIM_ORG_ANT,
                                   ANTERIOR.COD_ORGANOGRAMA AS COD_ORGANOGRAMA_ANT,
                                   ANTERIOR.NOME_ORGANOGRAMA AS NOME_ORGANOGRAMA_ANT,
                                   ANTERIOR.EDICAO_ORGANOGRAMA AS EDICAO_ORGANOGRAMA_ANT,
                                   ANTERIOR.COD_NIVEL_ORG AS COD_NIVEL_ORG_ANT,
                                   ANTERIOR.NOME_NIVEL_ORG AS NOME_NIVEL_ORG_ANT,
                                   ANTERIOR.COD_EMPFIL AS COD_EMPFIL_ANT,
                                   ANTERIOR.NOME_EMPRESA_FILIAL AS NOME_EMPRESA_FILIAL_ANT,
                                   ANTERIOR.CLIENTE AS CLIENTE_ANT,
                                   ANTERIOR.COD_DRT AS COD_DRT_ANT,
                                   ANTERIOR.NOME_DRT AS NOME_DRT_ANT,
                                   ANTERIOR.ULTIMA_FICHA_REG AS ULTIMA_FICHA_REF_ANT,
                                   ANTERIOR.COD_CUSTO_CONTABIL AS COD_CUSTO_CONTABIL_ANT,
                                   ANTERIOR.NOME_CUSTO_CONTABIL AS NOME_CUSTO_CONTABIL_ANT,
                                   ANTERIOR.CUSTO_CONTABIL AS CUSTO_CONTABIL_ANT,
                                   ANTERIOR.COD_MOTIVO AS COD_MOTIVO_ANT,
                                   ANTERIOR.NOME_MOTIVO AS NOME_MOTIVO_ANT,
                                   ANTERIOR.COD_TIPO_MOTIVO AS COD_TIPO_MOTIVO_ANT,
                                   ANTERIOR.NOME_TIPO_MOTIVO AS NOME_TIPO_MOTIVO_ANT,
                                   ANTERIOR.COD_CAUSA_DEMISSAO AS COD_CAUSA_DEMISSAO_ANT,
                                   ANTERIOR.NOME_CAUSA_DEMISSAO AS NOME_CAUSA_DEMISSAO_ANT,
                                   ANTERIOR.CCUST_RH AS CCUST_RH_ANT,
                                   ANTERIOR.LOTACAO_SIAPE AS LOTACAO_SIAPE_ANT,
                                   DECODE(ORESP.COD_CONTRATO_RESP,
                                          RHFP0310.COD_CONTRATO,
                                          'S',
                                          'N') AS IND_RESPONSAVEL
                             FROM RHFP0310 RHFP0310,
                                   RHFP0400 RHFP0400,
                                   RHFP0323 RHFP0323,
                                   RHFP0115 RHFP0115,
                                   RHFP0102 RHFP0102,
                                   RHFP0402 RHFP0402,
                                   RHFP0401 RHFP0401,
                                   RHFP0436 RHFP0436,
                                   RHFP3170 RHFP3170,
                                   PESSOA PESSOA_DRT,
                                   PESSOA PESSOA_EMPFIL,
                                   RHFP0117 RHFP0117,
                                   RHFP0397 ORESP,
                                   (
                                    
                                    SELECT RHFP0310.COD_CONTRATO,
                                            RHFP0310.DATA_INICIO AS DATA_INICIO_ORG,
                                            RHFP0310.DATA_FIM AS DATA_FIM_ORG,
                                            RHFP0310.COD_ORGANOGRAMA,
                                            RHFP0400.NOME_ORGANOGRAMA,
                                            SUBSTR(RHYF0002(RHFP0310.COD_ORGANOGRAMA,
                                                                            RHFP0400.COD_NIVEL_ORG,
                                                                            RHFP0310.DATA_INICIO),
                                                   1,
                                                   80) AS EDICAO_ORGANOGRAMA,
                                            RHFP0400.COD_NIVEL_ORG,
                                            RHFP0117.NOME_NIVEL_ORG,
                                            RHFP0400.COD_PESSOA AS COD_EMPFIL,
                                            PESSOA_EMPFIL.NOME_PESSOA AS NOME_EMPRESA_FILIAL,
                                            RHFP0400.CLIENTE,
                                            RHFP0400.COD_DRT,
                                            PESSOA_DRT.NOME_PESSOA AS NOME_DRT,
                                            RHFP0400.ULTIMA_FICHA_REG,
                                            RHFP0400.COD_CUSTO_CONTABIL,
                                            RHFP0402.NOME_CUSTO_CONTABIL,
                                            RHFP0402.CUSTO_CONTABIL,
                                            RHFP0310.COD_MOTIVO,
                                            RHFP0323.NOME_MOTIVO,
                                            RHFP0323.COD_TIPO_MOTIVO,
                                            RHFP0115.NOME_TIPO_MOTIVO,
                                            RHFP0310.COD_CAUSA_DEMISSAO,
                                            RHFP0102.NOME_CAUSA_DEMISSAO,
                                            RHFP0436.CCUST_RH,
                                            RHFP3170.LOTACAO_SIAPE
                                      FROM RHFP0310 RHFP0310,
                                            RHFP0400 RHFP0400,
                                            RHFP0323 RHFP0323,
                                            RHFP0115 RHFP0115,
                                            RHFP0102 RHFP0102,
                                            RHFP0402 RHFP0402,
                                            RHFP0436 RHFP0436,
                                            RHFP3170 RHFP3170,
                                            PESSOA   PESSOA_DRT,
                                            PESSOA   PESSOA_EMPFIL,
                                            RHFP0117 RHFP0117
                                     WHERE RHFP0310.COD_ORGANOGRAMA =
                                           RHFP0400.COD_ORGANOGRAMA
                                       AND RHFP0310.COD_MOTIVO =
                                           RHFP0323.COD_MOTIVO(+)
                                       AND RHFP0310.COD_CAUSA_DEMISSAO =
                                           RHFP0102.COD_CAUSA_DEMISSAO(+)
                                       AND RHFP0323.COD_TIPO_MOTIVO =
                                           RHFP0115.COD_TIPO_MOTIVO(+)
                                       AND RHFP0400.COD_CUSTO_CONTABIL =
                                           RHFP0402.COD_CUSTO_CONTABIL(+)
                                       AND RHFP0400.COD_PESSOA =
                                           PESSOA_EMPFIL.COD_PESSOA(+)
                                       AND RHFP0400.COD_DRT =
                                           PESSOA_DRT.COD_PESSOA(+)
                                       AND RHFP0400.COD_NIVEL_ORG =
                                           RHFP0117.COD_NIVEL_ORG(+)
                                       AND RHFP0310.COD_ORGANOGRAMA =
                                           RHFP0436.COD_ORGANOGRAMA(+)
                                       AND RHFP0310.COD_ORGANOGRAMA =
                                           RHFP3170.COD_ORGANOGRAMA(+)
                                    
                                    ) ANTERIOR
                            WHERE RHFP0310.COD_ORGANOGRAMA =
                                  RHFP0400.COD_ORGANOGRAMA
                              AND RHFP0310.COD_MOTIVO = RHFP0323.COD_MOTIVO(+)
                              AND RHFP0310.COD_CAUSA_DEMISSAO =
                                  RHFP0102.COD_CAUSA_DEMISSAO(+)
                              AND RHFP0323.COD_TIPO_MOTIVO =
                                  RHFP0115.COD_TIPO_MOTIVO(+)
                              AND RHFP0400.COD_ORGANOGRAMA =
                                  RHFP0401.COD_ORGANOGRAMA(+)
                              AND RHFP0400.COD_CUSTO_CONTABIL =
                                  RHFP0402.COD_CUSTO_CONTABIL(+)
                              AND RHFP0400.COD_PESSOA =
                                  PESSOA_EMPFIL.COD_PESSOA(+)
                              AND RHFP0400.COD_DRT = PESSOA_DRT.COD_PESSOA(+)
                              AND RHFP0400.COD_NIVEL_ORG =
                                  RHFP0117.COD_NIVEL_ORG(+)
                              AND '31/12/2024' BETWEEN RHFP0310.DATA_INICIO AND
                                  RHFP0310.DATA_FIM
                              AND RHFP0310.COD_CONTRATO =
                                  ANTERIOR.COD_CONTRATO(+)
                              AND RHFP0310.DATA_INICIO - 1 =
                                  ANTERIOR.DATA_FIM_ORG(+)
                              AND '31/12/2024' BETWEEN RHFP0401.DATA_INICIO AND
                                  RHFP0401.DATA_FIM
                              AND RHFP0310.COD_ORGANOGRAMA =
                                  RHFP0436.COD_ORGANOGRAMA(+)
                              AND RHFP0310.COD_ORGANOGRAMA =
                                  RHFP3170.COD_ORGANOGRAMA(+)
                              AND RHFP0310.COD_ORGANOGRAMA =
                                  ORESP.COD_ORGANOGRAMA(+)
                              AND '31/12/2024' BETWEEN ORESP.DATA_INICIO(+) AND
                                  ORESP.DATA_FIM(+)
                           
                           ) CON_ORG
                   WHERE RHFP0300.COD_CONTRATO = CON_EMP.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_ORG.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_FIL_OUT.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_SAL.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_STACON.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_CON.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_FUN.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_CLH.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_VDS.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_STAAFA.COD_CONTRATO(+)
                     AND RHFP0300.COD_CONTRATO = CON_CUSTO.COD_CONTRATO(+)
                     AND (CON_STACON.STATUS_CONTRATO IN (0, 1) /*AND
                         ((CON_CUSTO.EDICAO_NIVEL3 = WREDE AND PI_REDE <> 70) OR
                         (PI_REDE = 70))*/ /*AND CON_EMP.EDICAO_FILIAL = WFILIAL*/ AND
                         CON_VDS.COD_EVENTO IN (1, 17) AND
                         CON_CLH.COD_CLH NOT IN
                         (204, 175, 205, 51, 71, 5, 74) AND
                         CON_FIL_OUT.COD_CAMPO = 1)
                   ORDER BY CON_FIL_OUT.VALOR        ASC,
                             CON_EMP.EDICAO_FILIAL    ASC,
                             CON_FUN.NOME_FUNCIONARIO ASC
                  
                  ) TABELA
           GROUP BY TABELA.EDICAO_FILIAL