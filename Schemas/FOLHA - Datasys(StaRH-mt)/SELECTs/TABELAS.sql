TABELA 1

create table NL.GRZ_LOJAS_TAMANHO_BASE(SISLOGWEB.GRZ_LOJAS_TAMANHO_BASE@NLGRZ)
(
  COD_EMP               NUMBER(4) not null,
  COD_UNIDADE           NUMBER(4) not null,
  CAMINHO_BASE          VARCHAR2(150),
  TAMANHO_BASE_MB       NUMBER(15,2) not null,
  IP_ATUALIZACAO        VARCHAR2(20),
  DTA_ATUALIZACAO_LOJA  DATE,
  IP_LOJA               VARCHAR2(20),
  DTA_ULT_REORGANIZACAO DATE,
  DES_NOME_LOJA         VARCHAR2(200),
  DES_ENDERECO          VARCHAR2(500),
  DES_UF                VARCHAR2(10)
)

TABELA 2 

create table SELORG_FPRE0021A
(
  COD_ORGANOGRAMA     NUMBER(15) not null,
  NOME_ORGANOGRAMA    VARCHAR2(50),
  NOME_ORGANOGRAMA_E  VARCHAR2(70),
  NOME_ORGANOGRAMA_C  VARCHAR2(70),
  COD_ORGANOGRAMA_SUB NUMBER(15),
  EDICAO              VARCHAR2(80),
  EDI1                VARCHAR2(10),
  EDI2                VARCHAR2(10),
  EDI3                VARCHAR2(10),
  EDI4                VARCHAR2(10),
  EDI5                VARCHAR2(10),
  EDI6                VARCHAR2(10),
  EDI7                VARCHAR2(10),
  EDI8                VARCHAR2(10),
  COD1                NUMBER(15),
  COD2                NUMBER(15),
  COD3                NUMBER(15),
  COD4                NUMBER(15),
  COD5                NUMBER(15),
  COD6                NUMBER(15),
  COD7                NUMBER(15),
  COD8                NUMBER(15),
  NOME1               VARCHAR2(50),
  NOME2               VARCHAR2(50),
  NOME3               VARCHAR2(50),
  NOME4               VARCHAR2(50),
  NOME5               VARCHAR2(50),
  NOME6               VARCHAR2(50),
  NOME7               VARCHAR2(50),
  NOME8               VARCHAR2(50),
  IND_SEL             NUMBER(1) not null
)


TABELA 5

create table PESSOA
(
  COD_PESSOA   NUMBER(15) not null,
  NOME_PESSOA  VARCHAR2(60) not null,
  TIPO_PESSOA  VARCHAR2(1) not null,
  NOME_EXTENSO VARCHAR2(250)
)

TABELA 6 

create table RHFP0401
(
  COD_ORGANOGRAMA     NUMBER(15) not null,
  DATA_INICIO         DATE not null,
  DATA_FIM            DATE,
  COD_ORGANOGRAMA_SUB NUMBER(15),
  EDICAO_ORG          VARCHAR2(10),
  IND_LANCAMENTO      VARCHAR2(1),
  COD_NIVEL1          NUMBER(15),
  COD_NIVEL2          NUMBER(15),
  COD_NIVEL3          NUMBER(15),
  COD_NIVEL4          NUMBER(15),
  COD_NIVEL5          NUMBER(15),
  COD_NIVEL6          NUMBER(15),
  COD_NIVEL7          NUMBER(15),
  COD_NIVEL8          NUMBER(15),
  EDICAO_NIVEL1       VARCHAR2(10),
  EDICAO_NIVEL2       VARCHAR2(10),
  EDICAO_NIVEL3       VARCHAR2(10),
  EDICAO_NIVEL4       VARCHAR2(10),
  EDICAO_NIVEL5       VARCHAR2(10),
  EDICAO_NIVEL6       VARCHAR2(10),
  EDICAO_NIVEL7       VARCHAR2(10),
  EDICAO_NIVEL8       VARCHAR2(10)
)

TABELA 7 

create table RHFP0306
(
  COD_CONTRATO        NUMBER(15) not null,
  DATA_INICIO         DATE not null,
  DATA_FIM            DATE not null,
  COD_CAUSA_AFAST     NUMBER(15),
  COD_MOTIVO          NUMBER(15),
  HORAS_AFASTAMENTO   VARCHAR2(4),
  DATA_INICIO_FRE     DATE not null,
  DATA_FIM_FRE        DATE not null,
  OBSERVACOES         LONG RAW,
  IND_SUSP_MOV        VARCHAR2(1),
  COD_ATO_LEGAL       NUMBER(15),
  DESCRICAO_ATO_LEGAL VARCHAR2(2000),
  MEIO_DIA            NUMBER(15,6),
  IND_SOBREPOSICAO    VARCHAR2(1),
  IND_ABRE_VAGA       VARCHAR2(1) default 'S' not null,
  DATA_PERICIA        DATE,
  COD_CID_10          VARCHAR2(15),
  COD_PESSOA          NUMBER(15),
  IND_ACID_TRANSITO   VARCHAR2(1) default 'N' not null,
  TIPO_ACID_TRANSITO  VARCHAR2(1),
  COD_ESPECIALIDADE   NUMBER(15),
  COD_ROTINA_INI      NUMBER(15),
  COD_ROTINA_FIM      NUMBER(15),
  NR_RECIBO           VARCHAR2(23),
  ORIG_RETIF          NUMBER(1),
  NR_PROC             VARCHAR2(21),
  DATA_RETIF          DATE,
  DATA_INC            DATE,
  DATA_ALT            DATE
)

TABELA 8 

create table RHFP0310
(
  COD_CONTRATO       NUMBER(15) not null,
  DATA_INICIO        DATE not null,
  DATA_FIM           DATE not null,
  COD_ORGANOGRAMA    NUMBER(15),
  COD_MOTIVO         NUMBER(15),
  COD_CAUSA_DEMISSAO NUMBER(15),
  COD_NIVEL2         NUMBER(15),
  SEQ                NUMBER(4),
  DATA_INCLUSAO      DATE
)