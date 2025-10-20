--======---======--======--======--=====--=====--=====--=====--
--INSERINDO DADOS DAS EQUIPES NA TAMBELA GRZ_EQUIPES_SETORES
--======---======--======--======--

SELECT * FROM GRZ_EQUIPES_SETORES





---INICIO > TI---
INSERT INTO GRZ_EQUIPES_SETORES (COD_CONTRATO, DES_PESSOA, CPF, COD_FUNCAO, DES_FUNCAO, COD_ORGANOGRAMA, COD_UNIDADE, DES_UNIDADE, CPF_GESTOR, COD_UNIDADE_SUB, DES_UNIDADE_SUB)
--EQUIPE DIRLEI >> HELP DESK 
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '283'
           AND B.COD_UNIDADE = 768
           AND ROWNUM = 1) AS CPF_GESTOR, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT B.COD_UNIDADE_SUB
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '283' 
           AND B.COD_UNIDADE_SUB = 7681
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
        'TI - HELP DESK' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 768
   AND A.COD_CONTRATO IN (377414, 379901, 379995, 389250, 390125, 256897)

UNION ALL

--EQUIPE FABIO >> ANALISE DE SISTEMAS
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 768
           AND ROWNUM = 1) AS CPF_GESTOR, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT B.COD_UNIDADE_SUB
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7682
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
        'TI - ANALISE DE SISTEMAS' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 768
   AND A.COD_CONTRATO IN (385752, 388070, 389622, 352683)

UNION ALL

--EQUIPE FRAN H. >> SUPORTE
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '137'
           AND B.COD_UNIDADE = 768
           AND ROWNUM = 1) AS CPF_GESTOR, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT B.COD_UNIDADE_SUB
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '137' 
           AND B.COD_UNIDADE_SUB = 7683
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
        'TI - SUPORTE' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 768
   AND A.COD_CONTRATO IN (387775, 388907, 389304, 389512, 391534, 391897, 392684, 
                          393193, 393390, 394222, 394414, 394844, 322644)

UNION ALL

--EQUIPE MARCOS S. >> INFRA. E SEGURANÇA
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 768
           AND ROWNUM = 1) AS CPF_GESTOR, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT B.COD_UNIDADE_SUB
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7684
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
        'TI - INFRA. E SEGURANÇA' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 768
   AND A.COD_CONTRATO IN (291498, 390837, 390828, 391532, 392821, 390296)


UNION ALL

--EQUIPE IGOR >> DESENVOLVIMENTO
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 769
           AND ROWNUM = 1) AS CPF_GESTOR, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT B.COD_UNIDADE_SUB
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7691
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'TI - DESENVOLVIMENTO' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 769
   AND A.COD_CONTRATO IN (383197, 387692, 387772, 388164, 388575, 389902, 389947, 
                          391149, 391411, 391940, 392358, 393947, 394260, 394289)

---FIM TI---

--==========--
UNION ALL
--==========--

---INICIO RH---

--EQUIPE Elisangela >> DERES
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 781
           AND ROWNUM = 1) AS CPF_GESTOR, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT B.COD_UNIDADE_SUB
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7811
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'RH - DERES' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 781
   AND A.COD_CONTRATO IN (392663, 382420, 386191, 390291, 340774)
   
UNION ALL

   
--EQUIPE Karine >> DETRE
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 783
           AND ROWNUM = 1) AS CPF_GESTOR, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT B.COD_UNIDADE_SUB
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7831
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'RH - DETRE' AS DES_UNIDADE_SUB    
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 783
   AND A.COD_CONTRATO IN (384461, 394783, 393331, 379135, 388941, 393398, 389266)

UNION ALL

--EQUIPE Ariane >> DECOM
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 784
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF           
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7841
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'RH - DECOM' AS DES_UNIDADE_SUB    
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 784
   AND A.COD_CONTRATO IN (393727,  381482, 393297, 392524)


UNION ALL

--EQUIPE Fernanda >> DEPES
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE_SUB = 7861
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE = 786
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'RH - DEPES' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 786
   AND A.COD_CONTRATO IN (388645, 353906, 388573, 391906, 383495, 382675, 
                          393726, 332852, 290424, 391286, 388584, 392823)
   
---FIM RH---

--==========--
UNION ALL
--==========--

---INICIO FINANCEIRO---

--EQUIPE Jenison >> DECRE
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '128'
           AND B.COD_UNIDADE = 763
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '128' 
           AND B.COD_UNIDADE_SUB = 7631
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
        'FINANCEIRO - DECRE' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 763
   AND A.COD_CONTRATO IN (394244, 393642, 394901, 393870, 393946, 393695, 390893, 391954, 363405)

UNION ALL

--EQUIPE Laura >> DECOB
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 764
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF           
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7641
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'FINANCEIRO - DECOB' AS DES_UNIDADE_SUB    
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 764
   AND A.COD_CONTRATO IN (393298, 391290, 394464, 393912, 389904, 394465, 392284, 385182, 
                          392770, 393328, 391195, 394270, 390546, 393639, 394847, 390132)

UNION ALL

--EQUIPE Ana Paula >> CONTABIL
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '275'
           AND B.COD_UNIDADE_SUB = 7701
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '275' 
           AND B.COD_UNIDADE = 770
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'FINANCEIRO - CONTABIL' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 770
   AND A.COD_CONTRATO IN (392519, 394611, 384586, 385353, 
                          393597, 394392, 390225, 389249)
   AND A.COD_CONTRATO NOT IN (389764)

UNION ALL

--EQUIPE Tatiane >> PAGAMENTOS
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '373'
           AND B.COD_UNIDADE_SUB = 7711
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '373' 
           AND B.COD_UNIDADE = 771
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'FINANCEIRO - PAGAMENTOS' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 771
   AND A.COD_CONTRATO IN (380380, 380580, 390831)

UNION ALL

--EQUIPE Angelica >> RECEBIMENTOS
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '374'
           AND B.COD_UNIDADE = 772
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '374' 
           AND B.COD_UNIDADE_SUB = 7721
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'FINANCEIRO - RECEBIMENTOS' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 772
   AND A.COD_CONTRATO IN (393629, 392594, 393539, 385327, 381617, 388445, 392634, 386665)
                          
---FIM FINANCEIRO---

--==========--
UNION ALL
--==========--

---INICIO ADMINISTRATIVO---

--EQUIPE Alan >> EXPANSAO
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 709
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF           
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7091
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'ADMIN - EXPANSÃO' AS DES_UNIDADE_SUB    
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 709
   AND A.COD_CONTRATO IN (393724, 392277, 388542, 386162, 385858, 
                          384965, 376528, 376310, 324400, 272116)





--EQUIPE CARLA >> JURIDICO 1
/*SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE = 762
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF           
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE_SUB = 7621
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'ADMIN - JURIDICO 1' AS DES_UNIDADE_SUB    
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 762
   AND A.COD_CONTRATO IN (366765, 384903, 386717, 389986, 
                          391687, 392853, 392922, 393725, 394285)
   AND A.COD_CONTRATO NOT IN (384903) --?--*/



---FIM ADMINISTRATIVO---

--==========--
UNION ALL
--==========--

---INICIO COMERCIAL---

--EQUIPE Francieli C. >> MARKETING
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '299'
           AND B.COD_UNIDADE_SUB = 7211
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '299' 
           AND B.COD_UNIDADE = 721
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'COMPRAS - MARKETING' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 721
   AND A.COD_CONTRATO IN (393192, 391785, 391093, 391068, 390655, 390412, 
                          390382, 389197, 388700, 377333, 313190, 393561)
   AND A.COD_CONTRATO NOT IN (313190)

UNION ALL

--EQUIPE Jackson >> E-COMMERCE
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '345'
           AND B.COD_UNIDADE = 907
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '345' 
           AND B.COD_UNIDADE_SUB = 9071
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'E-COMMERCE' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 907
   AND A.COD_CONTRATO IN (382595, 382989, 387186, 387267, 388108, 
                          390501, 390733, 391069, 393536, 393643)

---FIM COMERCIAL---

--==========--
UNION ALL
--==========--

---INICIO VIP

--EQUIPE Fran Segat >> AUDITORIA
SELECT A.COD_CONTRATO,
       A.DES_PESSOA,
       A.CPF,
       A.COD_FUNCAO,
       A.DES_FUNCAO,
       A.COD_ORGANOGRAMA,
       A.COD_UNIDADE,
       A.DES_UNIDADE,       
       (SELECT B.CPF
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14'
           AND B.COD_UNIDADE_SUB = 7611
           AND ROWNUM = 1) AS CPF, -- Garante que apenas uma linha seja retornada para CPF
       (SELECT TO_CHAR(B.COD_UNIDADE_SUB)
          FROM GRZ_GESTORES_GRUPO_ADM B
         WHERE B.COD_FUNCAO = '14' 
           AND B.COD_UNIDADE = 761
           AND ROWNUM = 1) AS COD_UNIDADE_SUB, -- Garante que apenas uma linha seja retornada para COD_UNIDADE_SUB
       'VIP - AUDITORIA' AS DES_UNIDADE_SUB
  FROM V_DADOS_COLAB_AVT A
 WHERE A.STATUS = 0
   AND A.COD_UNIDADE = 761
   AND A.COD_CONTRATO IN (379392, 385140, 385761, 355879, 385788, 
                          387168, 387258, 391729, 394766)
                          

---FIM VIP---
--======---======--======--======--=====--=====--=====--=====--