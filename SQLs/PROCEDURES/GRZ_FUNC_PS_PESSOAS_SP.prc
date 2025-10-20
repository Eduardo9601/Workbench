CREATE OR REPLACE PROCEDURE NL."GRZ_FUNC_PS_PESSOAS_SP"(PI_OPCAO IN VARCHAR2,
                                                          PO_ERRO  OUT VARCHAR2) IS

BEGIN
  /* V.1.000- GRZ_FUNC_PS_PESSOAS_SP */
  DECLARE

    /****parametros de entrada****/
    PI_nome_arq VARCHAR2(20);
    PI_dir      VARCHAR2(50);

    /****variaveis de trabalho****/
    Wi NUMBER;
    Wf NUMBER;

    wdig_pessoa        NUMBER(01);
    wcod_completo      VARCHAR2(10);
    wcod_editado       VARCHAR2(11);
    wcod_mascara       NUMBER;
    wregistro          VARCHAR2(1000);
    wlin               NUMBER;
    wExiste            NUMBER;
    wCodFixo           VARCHAR2(02);
    wNpspessoas        NUMBER;
    wNpscolunas        NUMBER;
    wNpsmascaras       NUMBER;
    wNpsrepresentantes NUMBER;
    wNpsclientes       NUMBER;
    wApspessoas        NUMBER;

    wCOD_EMP         NUMBER(03);
    wCOD_GU          NUMBER(03);
    wCOD_PESSOA_GRZ  VARCHAR2(08);
    wCOD_PESSOA      NUMBER(08);
    wDES_PESSOA      VARCHAR2(50);
    wDES_FANTASIA    VARCHAR2(20);
    wDES_ENDERECO    VARCHAR2(50);
    wCOD_REGIAO      NUMBER(04);
    wDES_BAIRRO      VARCHAR2(20);
    wNUM_CEP         VARCHAR2(20);
    wCOD_CIDADE      NUMBER(04);
    wCOD_UNIDADE     VARCHAR2(04);
    wCOD_ATIVIDADE   NUMBER(04);
    wTIP_PESSOA      NUMBER(01);
    wDTA_CADASTRO    DATE;
    wIND_MALA_DIRETA NUMBER(01);
    wIND_INATIVO     NUMBER(01);
    wCOD_CCUSTO      VARCHAR2(04);
    wDTA_DEMISSAO    VARCHAR2(10);
    wNUM_CPF         VARCHAR2(11);
    wDES_FUNCAO      VARCHAR2(30);
    wCOD_BLOQ        VARCHAR2(04);
    wCOD_C_CUSTO     VARCHAR2(30);
    wDES_EMP         VARCHAR2(20);
    wDES_COMPLEMENTO VARCHAR2(50);

    out_file Utl_File.File_Type;

    SAIDA EXCEPTION;

  begin

    /****desmembra os par??metros de entrada****/
    wi          := INSTR(pi_opcao, '#', 1, 1);
    PI_nome_arq := SUBSTR(pi_opcao, 1, (wi - 1));
    wf          := INSTR(pi_opcao, '#', 1, 2);
    PI_Dir      := SUBSTR(pi_opcao, (wi + 1), (wf - wi - 1));

    /****Abre e l?? o arquivo de origem****/
    BEGIN
      out_file := Utl_File.fopen(PI_dir, PI_nome_arq, 'r');
    EXCEPTION
      WHEN OTHERS THEN
        PO_ERRO := 'PS-Erro na abertura do arquivo: ' || PI_dir ||
                   PI_nome_arq;
        raise_application_error(-20001,
                                'PS-Erro na abertura do arquivo: ' ||
                                PI_dir || PI_nome_arq);
    END;

    wlin               := 0;
    wCodFixo           := '01';
    wNpsmascaras       := 0;
    wNpspessoas        := 0;
    wNpsrepresentantes := 0;
    wNpsclientes       := 0;
    wApspessoas        := 0;
    LOOP
      BEGIN
        UTL_FILE.GET_LINE(out_file, wregistro);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          EXIT;
      END;
      wlin := wlin + 1;

      /****passa os valores encontrados no arquivo para variveis de trabalho****/
      wCOD_GU          := 1;
      wCOD_EMP         := TO_NUMBER(LTRIM(RTRIM(SUBSTR(wregistro, 1, 3))));
      wCOD_PESSOA_GRZ  := lpad(LTRIM(RTRIM(SUBSTR(wregistro, 5, 7))),
                               8,
                               '0');
      wDES_PESSOA      := LTRIM(RTRIM(SUBSTR(wregistro, 13, 50)));
      wDES_FANTASIA    := LTRIM(RTRIM(SUBSTR(wregistro, 64, 20)));
      wDES_ENDERECO    := LTRIM(RTRIM(REPLACE(SUBSTR(wregistro, 85, 50),
                                              '     ',
                                              ' ')));
      wDES_ENDERECO    := REPLACE(wDES_ENDERECO, '    ', ' ');
      wDES_ENDERECO    := REPLACE(wDES_ENDERECO, '   ', ' ');
      wDES_ENDERECO    := REPLACE(wDES_ENDERECO, '  ', ' ');
      wDES_COMPLEMENTO := LTRIM(RTRIM(SUBSTR(wregistro, 255, 30)));
      wDES_ENDERECO    := SUBSTR(wDES_ENDERECO || ' ' || wDES_COMPLEMENTO,
                                 1,
                                 50);
      wCOD_REGIAO      := TO_NUMBER(SUBSTR(wregistro, 136, 4));
      wDES_BAIRRO      := LTRIM(RTRIM(SUBSTR(wregistro, 141, 20)));
      wNUM_CEP         := LTRIM(RTRIM(SUBSTR(wregistro, 162, 08)));
      wCOD_UNIDADE     := (SUBSTR(wregistro, 171, 4));
      wCOD_ATIVIDADE   := TO_NUMBER(SUBSTR(wregistro, 176, 2));
      wTIP_PESSOA      := TO_NUMBER(SUBSTR(wregistro, 179, 1));
      wDTA_CADASTRO    := TO_DATE(SUBSTR(wregistro, 181, 10), 'DD/MM/YYYY');
      wIND_MALA_DIRETA := TO_NUMBER(SUBSTR(wregistro, 192, 1));
      wIND_INATIVO     := TO_NUMBER(SUBSTR(wregistro, 194, 1));
      wCOD_CCUSTO      := (SUBSTR(wregistro, 196, 4));
      wDTA_DEMISSAO    := (SUBSTR(wregistro, 201, 10));
      wNUM_CPF         := (SUBSTR(wregistro, 212, 11));
      wDES_FUNCAO      := (SUBSTR(wregistro, 224, 30));
      IF wCOD_EMP = 008 THEN
        wDES_EMP := 'GRAZZIOTIN';
      ELSIF wCOD_EMP = 004 THEN
        wDES_EMP := 'GZT';
      ELSIF wCOD_EMP = 276 THEN
        wDES_EMP := 'CENTRO SHOPPING';
      ELSIF wCOD_EMP = 280 THEN
        wDES_EMP := 'CAULESPAR';
      ELSIF wCOD_EMP = 282 THEN
        wDES_EMP := 'FINANCIADORA';
      ELSIF wCOD_EMP = 002 THEN
        wDES_EMP := 'VR';
      ELSIF wCOD_EMP = 006 THEN
        wDES_EMP := 'GRATO';
      ELSE
        wDES_EMP := 'GRAZZIOTIN';
      END IF;
      wCOD_C_CUSTO := wCOD_UNIDADE || '-' || wCOD_CCUSTO || '-' || wDES_EMP;
      if wDTA_DEMISSAO = '0000000000' then
        wDTA_DEMISSAO := null;
        wCOD_BLOQ     := null;
      else
        wCOD_BLOQ    := '9990';
        wIND_INATIVO := 1;
      end if;

      begin
        wExiste := 0;
        Select 1, a.cod_pessoa
          into wExiste, wCOD_PESSOA
          From ps_mascaras a, ps_pessoas p
         Where a.cod_pessoa = p.cod_pessoa
           and p.ind_inativo = 0
           and a.cod_completo = wCodFixo || wCOD_PESSOA_GRZ
           and a.cod_mascara = 50
           and rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          wExiste     := 0;
          wCOD_PESSOA := 0;
      end;

      if (wCOD_UNIDADE = '0001') OR (wCOD_UNIDADE = '0013') then
        wCOD_UNIDADE := '0044';
      end if;

      if not wcod_unidade = '0492' then
        begin
          wcod_cidade := 0;
          select cod_cidade
            into wcod_cidade
            from ps_pessoas
           where cod_pessoa = wCOD_UNIDADE
             AND COD_GU = wCOD_GU;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            PO_ERRO := 'Unidade nao encontrada :' || wCOD_UNIDADE ||
                       '. Processo Interrompido!';
            RAISE SAIDA;
        end;
      else
        wcod_cidade := 203;
      end if;

      if (wExiste = 0) Then
        begin

          /****seleciona o ultimo valor do codigo pessoa sequencial e incrementa****/

          -- comentado o bloco abaixo em 03/11/2017 e alterado para buscar da fun????o da NL
          /* begin
               wCOD_PESSOA := 0;
               select max(cod_pessoa)
                 into wCOD_PESSOA
               from ps_pessoas
              where COD_PESSOA > 6620999
               AND COD_PESSOA < 8480001;
               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
            PO_ERRO := 'N??o foi poss??vel selecionar <cod_pessoa> da tabela <ps_pessoas> :'||wCOD_PESSOA;
            RAISE SAIDA;
          end;

          wCOD_PESSOA := wCOD_PESSOA + 1;

          wdig_pessoa := nl_dig_mod11_sp(wCOD_PESSOA); */

          ps_busca_cod_sp(1, 0, wcod_pessoa, wdig_pessoa);

          /****insere na tabela ps_pessoas****/
          BEGIN
            INSERT INTO ps_pessoas
              (cod_gu,
               cod_pessoa,
               dig_pessoa,
               des_pessoa,
               des_fantasia,
               des_endereco,
               cod_regiao,
               des_bairro,
               num_cep,
               cod_cidade,
               cod_atividade,
               tip_pessoa,
               dta_cadastro,
               ind_mala_direta,
               ind_inativo,
               des_ponto_referencia,
               dta_afastamento,
               dta_bloq,
               cod_bloq
               -- ,des_home_page
               --  ,des_email_cel
               )
            VALUES
              (wCOD_GU,
               wCOD_PESSOA,
               wdig_pessoa,
               wDES_PESSOA,
               wDES_FANTASIA,
               wDES_ENDERECO,
               wCOD_REGIAO,
               wDES_BAIRRO,
               wNUM_CEP,
               wcod_cidade,
               wCOD_ATIVIDADE,
               wTIP_PESSOA,
               wDTA_CADASTRO,
               wIND_MALA_DIRETA,
               wIND_INATIVO,
               wCOD_C_CUSTO,
               wDTA_DEMISSAO,
               wDTA_DEMISSAO,
               wCOD_BLOQ
               -- ,wDES_FUNCAO
               --  ,wNUM_CPF
               );
            wNpspessoas := wNpspessoas + 1;
          EXCEPTION
            WHEN OTHERS THEN
              PO_ERRO := 'Erro ao inserir na tabela' || SQLCODE || '-' ||
                         SQLERRM;
              RAISE SAIDA;
          END;

          -- implantada as ps_colunas em 15/07/2022

          /****insere na tabela ps_colunas ****/
          BEGIN
            INSERT INTO ps_colunas
              (cod_pessoa, SEQ_COLUNA, VLR_COLUNA)
            VALUES
              (wCOD_PESSOA, 35, wNUM_CPF);
            wNpscolunas := wNpscolunas + 1;
          EXCEPTION
            WHEN OTHERS THEN
              PO_ERRO := 'Erro ao inserir na tabela' || SQLCODE || '-' ||
                         SQLERRM;
              RAISE SAIDA;
          END;

          /****insere na tabela ps_colunas ****/
          BEGIN
            INSERT INTO ps_colunas
              (cod_pessoa, SEQ_COLUNA, VLR_COLUNA)
            VALUES
              (wCOD_PESSOA, 37, wDES_FUNCAO);
            wNpscolunas := wNpscolunas + 1;
          EXCEPTION
            WHEN OTHERS THEN
              PO_ERRO := 'Erro ao inserir na tabela' || SQLCODE || '-' ||
                         SQLERRM;
              RAISE SAIDA;
          END;

          /****insere na tabela ps_mascaras****/
          BEGIN
            INSERT INTO ps_mascaras
              (cod_pessoa,
               cod_mascara,
               cod_completo,
               cod_niv0,
               cod_niv1,
               cod_niv2,
               cod_editado)
            VALUES
              (wCOD_PESSOA,
               50,
               wCodFixo || wCOD_PESSOA_GRZ,
               '1',
               wCodFixo,
               wCOD_PESSOA_GRZ,
               wCodFixo || '.' || wCOD_PESSOA_GRZ);
            wNpsmascaras := wNpsmascaras + 1;
          EXCEPTION
            WHEN OTHERS THEN
              PO_ERRO := 'Erro ao inserir na tabela' || SQLCODE || '-' ||
                         SQLERRM;
              RAISE SAIDA;
          END;

          /****insere na tabela ps_representantes****/
          BEGIN
            INSERT INTO ps_representantes
              (COD_GU,
               COD_PESSOA,
               DES_PESSOA,
               DIG_PESSOA,
               IND_SENHA,
               COD_TIP_REPR,
               IND_INATIVO,
               IND_COMISSIONADO)
            VALUES
              (wCOD_GU, wCOD_PESSOA, wDES_PESSOA, wdig_pessoa, 0, 1, 0, 0);
            wNpsrepresentantes := wNpsrepresentantes + 1;
          EXCEPTION
            WHEN OTHERS THEN
              PO_ERRO := 'Erro ao inserir na tabela' || SQLCODE || '-' ||
                         SQLERRM;
              RAISE SAIDA;
          END;
          /****insere na tabela ps_clientes****/
          BEGIN
            INSERT INTO ps_clientes
              (COD_GU,
               COD_PESSOA,
               DIG_PESSOA,
               DES_PESSOA,
               TIP_ABC,
               TIP_END_CORRESP,
               IND_FAT_PARCIAL,
               TIP_ACEITE_ENTR,
               IND_INATIVO,
               IND_ISSQN)
            VALUES
              (wCOD_GU,
               wCOD_PESSOA,
               wDIG_PESSOA,
               wDES_PESSOA,
               1,
               0,
               1,
               0,
               0,
               0);
            wNpsclientes := wNpsclientes + 1;
          EXCEPTION
            WHEN OTHERS THEN
              PO_ERRO := 'Erro ao inserir na tabela' || SQLCODE || '-' ||
                         SQLERRM;
              RAISE SAIDA;
          END;
        end;
      else
        BEGIN
          update ps_pessoas
             set des_pessoa           = wDES_PESSOA,
                 des_fantasia         = wDES_FANTASIA,
                 des_endereco         = wDES_ENDERECO,
                 cod_regiao           = wCOD_REGIAO,
                 des_bairro           = wDES_BAIRRO,
                 num_cep              = wNUM_CEP,
                 cod_cidade           = wcod_cidade,
                 cod_atividade        = wCOD_ATIVIDADE,
                 tip_pessoa           = wTIP_PESSOA,
                 dta_cadastro         = wDTA_CADASTRO,
                 ind_mala_direta      = wIND_MALA_DIRETA,
                 ind_inativo          = wIND_INATIVO,
                 des_ponto_referencia = wCOD_C_CUSTO,
                 dta_afastamento      = wDTA_DEMISSAO,
                 dta_bloq             = wDTA_DEMISSAO,
                 cod_bloq             = wCOD_BLOQ,
                 des_home_page        = wDES_FUNCAO
                 --des_email_cel        = wNUM_CPF
           where cod_pessoa = wCOD_PESSOA
             and cod_gu = wCOD_GU
             and cod_atividade = 99;
        EXCEPTION
          WHEN OTHERS THEN
            PO_ERRO := 'Erro ao atualizar a tabela' || SQLCODE || '-' ||
                       SQLERRM;
            RAISE SAIDA;
        END;
        wApspessoas := wApspessoas + 1;

        /****atualiza a tabela ps_colunas ****/
        BEGIN
          INSERT INTO ps_colunas
            (cod_pessoa, SEQ_COLUNA, VLR_COLUNA)
          VALUES
            (wCOD_PESSOA, 35, wNUM_CPF);
          wNpscolunas := wNpscolunas + 1;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE ps_colunas
                 SET VLR_COLUNA = wNUM_CPF
               WHERE cod_pessoa = wCOD_PESSOA
                 AND SEQ_COLUNA = 35;
            EXCEPTION
              WHEN OTHERS THEN
                PO_ERRO := 'Erro ao atualizar a tabela' || SQLCODE || '-' ||
                           SQLERRM;
                RAISE SAIDA;
            END;

        END;

        /****insere na tabela ps_colunas ****/
        BEGIN
          INSERT INTO ps_colunas
            (cod_pessoa, SEQ_COLUNA, VLR_COLUNA)
          VALUES
            (wCOD_PESSOA, 37, wDES_FUNCAO);
          wNpscolunas := wNpscolunas + 1;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE ps_colunas
                 SET VLR_COLUNA = wDES_FUNCAO
               WHERE cod_pessoa = wCOD_PESSOA
                 AND SEQ_COLUNA = 37;
            EXCEPTION
              WHEN OTHERS THEN
                PO_ERRO := 'Erro ao atualizar a tabela' || SQLCODE || '-' ||
                           SQLERRM;
                RAISE SAIDA;
            end;
        END;

        if wIND_INATIVO = 1 then

          BEGIN
            update ge_usuarios
               set ind_bloqueado = 1, dta_vencimento = wDTA_DEMISSAO
             where cod_usuario = wCOD_PESSOA_GRZ;
          EXCEPTION
            WHEN OTHERS THEN
              PO_ERRO := 'Erro ao atualizar a tabela' || SQLCODE || '-' ||
                         SQLERRM;
              RAISE SAIDA;
          END;
        end if;

      end if;
    END LOOP;
    COMMIT;

    /****fecha arquivo de origem****/
    BEGIN
      UTL_FILE.FCLOSE(out_file);
    END;

    PO_ERRO := 'Total de registros incluidos: ' || 'ps_pessoas:' ||
               to_char(wNpspessoas) || ' - ps_colunas:' ||
               to_char(wNpscolunas) || ' - ps_mascaras:' ||
               to_char(wNpsmascaras) || ' - ps_representantes:' ||
               to_char(wNpsrepresentantes) || ' - ps_clientes:' ||
               to_char(wNpsclientes) ||
               '. Total de registros atualizados: ' || 'ps_pessoas:' ||
               to_char(wApspessoas);

  EXCEPTION
    WHEN SAIDA THEN
      NULL;

  END;
END GRZ_FUNC_PS_PESSOAS_SP;
/
