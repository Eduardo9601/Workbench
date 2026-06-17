/*SQL QUE MAPEIA ESPAÇOS E/OU CARACTERES INCORRETOS NOS E-MAILS DAS PESSOAS*/

SELECT COD_PESSOA,
       COD_CONTRATO,
       DES_PESSOA,
       DES_UNIDADE,
       DES_EMAIL
FROM V_DADOS_COLAB_AVT
WHERE STATUS = 0
  AND (
      -- Verificar se contém espaços
      INSTR(DES_EMAIL, ' ') > 0
      OR
      -- Verificar se não corresponde ao padrão de e-mail (básico)
      NOT REGEXP_LIKE(DES_EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
  );