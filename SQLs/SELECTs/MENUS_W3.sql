DELETE MENU
WHERE COD_PRODUTO = 'WW'
  AND COD_MODULO = 'W3';
  
DELETE RHWW0040
WHERE COD_PRODUTO = 'WW'
  AND COD_MODULO = 'W3';
  
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miCLEncerramento', 'MA', 'Encerramento de Eventos', 
    'sbCLCalculo', 9);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miCLSequencia', 'CS', 'Sequencia de Cálculo', 
    'sbCLCalculo', 15);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miCODependentes', 'MA', 'Dependentes', 
    'sbCOContratos', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miCOHistoricos', 'MA', 'Alterações de Históricos', 
    'sbCOContratos', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miMOMovimentos', 'ES', 'Movimentos', 
    'sbMOMovimentacoes', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miPCResp', 'MA', 'Responder Pesquisas', 
    'sbPCPesq', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miRLEsocAss', 'MA', 'Assinatura XML', 
    'sbRLObrLegais', 6);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miRLEsocEnv', 'MA', 'Envio e Recebimento de Lotes', 
    'sbRLObrLegais', 7);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miRLEsocExec', 'MA', 'Executar eSocial', 
    'sbRLObrLegais', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miVTValesCt', 'MA', 'Vales do Contrato', 
    'sbVTValeTrans', 11);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3201', 'MA', 'Dados Pessoais', 
    'sbCOContratos', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3202', 'CS', 'Contracheque', 
    'sbCOContratos', 5);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3204', 'ES', 'Consulta Férias', 
    'sbMOMovimentacoes', 5);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3206', 'ES', 'Aniversariantes', 
    'sbEmp', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3207', 'MA', 'Horários Efetuados', 
    'sbAF', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3208', 'CS', 'Ocorrências Diárias', 
    'sbAF', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3209', 'CS', 'Total de Ocorrências', 
    'sbAF', 5);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3210', 'CS', 'Horários com Divergências', 
    'sbAF', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3211', 'CS', 'Horário de Trabalho', 
    'sbAF', 6);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3215', 'CS', 'Consulta Cargos', 
    'sbCS', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3217', 'ES', 'Missão', 
    'sbEmp', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3218', 'ES', 'Notícias', 
    'sbEmp', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3221', 'ES', 'Estatísticas WebCenter', 
    'sbEmp', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3223', 'MA', 'Horário Alternativo', 
    'sbAF', 8);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3224', 'MA', 'Programação das Férias', 
    'sbMOMovimentacoes', 6);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3230', 'MA', 'Afastamentos', 
    'sbMOMovimentacoes', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3231', 'MA', 'Digitação', 
    'miMOMovimentos', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3237', 'ES', 'Alterar Senha', 
    'tshWebCenter3', 23);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3238', 'MA', 'Currículo do Contrato', 
    'sbDP', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3239', 'CS', 'Espelho do Ponto', 
    'sbAF', 9);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3245', 'CS', 'Comprovante de Rendimentos', 
    'sbCOContratos', 10);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3246', 'CS', 'Links', 
    'tshWebCenter3', 22);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3247', 'ES', 'Tarefas do Usuário', 
    'sbWF', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3248', 'ES', 'Andamento dos Processos', 
    'sbWF', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3249', 'MA', 'Iniciar Execução de Processos', 
    'sbWF', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3250', 'CS', 'Avaliações Programadas', 
    'sbCS', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3251', 'CS', 'Consulta Avaliações do Contrato', 
    'sbCS', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3252', 'MA', 'Avaliação Contrato de Experiência', 
    'sbCOContratos', 11);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3253', 'MA', 'PDI do Contrato', 
    'sbCS', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3255', 'MA', 'Requisição de Pessoal', 
    'sbRS', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3256', 'MA', 'Solicitação de Desligamento', 
    'sbRS', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3257', 'MA', 'Solicitação de Movimento', 
    'sbRS', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3261', 'CS', 'Consulta Estrutura do Organograma', 
    'sbCACadastros', 12);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3264', 'CS', 'Férias Programadas no Período', 
    'sbCOContratos', 6);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3269', 'CS', 'Consulta Acessos STARH Mobile', 
    'sbMB', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3270', 'MA', 'Notificações STARH Mobile', 
    'sbMB', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3271', 'MA', 'Execução de Relatórios', 
    'sbRE', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3272', 'ES', 'Consultas', 
    'sbRE', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3278', 'MA', 'Enviar Solicitação', 
    'sbRVRhVirtual', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3279', 'MA', 'Consultar Solicitações', 
    'sbRVRhVirtual', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3281', 'MA', 'Gerenciar Solicitações', 
    'sbRVRhVirtual', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3282', 'MA', 'Tipos de Solicitacões', 
    'sbRVRhVirtual', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3283', 'MA', 'Solicitação de Férias', 
    'sbCOContratos', 8);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3284', 'ES', 'Gerenciar Solicitações de Férias', 
    'sbCOContratos', 9);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3285', 'CS', 'Extrato do Banco de Horas', 
    'sbAF', 10);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3286', 'CS', 'Consulta Valores Gerados', 
    'sbVTValeTrans', 14);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3287', 'CS', 'Consulta Escala de Folga', 
    'sbAF', 12);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3288', 'CS', 'Geolocalização dos Organogramas', 
    'sbMB', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3289', 'CS', 'Espelho do Ponto Oficial', 
    'sbAF', 9);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3290', 'CS', 'Consulta Contratos por Grupo Folga', 
    'sbAF', 13);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3291', 'CS', 'Consulta Ocorrências por Grupo Folga', 
    'sbAF', 14);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3292', 'CS', 'Consulta Permutas Horários', 
    'sbAF', 16);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3294', 'CS', 'Dashboard (1)', 
    'sbRE', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3295', 'CS', 'Dashboard (2)', 
    'sbRE', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3298', 'CS', 'Pesquisa Candidatos', 
    'sbRS', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3301', 'MA', 'Consulta Registro Ponto Mobile', 
    'sbAF', 11);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3307', 'CS', 'Tempo de Empresa', 
    'sbEmp', 5);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3320', 'CS', 'Documentos do Organograma', 
    'sbGD', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3330', 'CS', 'Documentos por Pessoa', 
    'sbGD', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3380', 'MA', 'Consulta Falhas Ponto', 
    'sbMB', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3395', 'MA', 'Permuta de Horário', 
    'sbAF', 15);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3400', 'CS', 'Controle de Horários', 
    'sbAF', 7);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3405', 'CS', 'Contratos com Horários', 
    'sbAF', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3410', 'CA', 'Importação', 
    'miMOMovimentos', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3590', 'CS', 'Consulta Atestado de Saúde', 
    'sbMS', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3595', 'CS', 'Ficha de EPIs', 
    'sbMS', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3600', 'MA', 'Pessoas Físicas', 
    'sbCACadastros', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3601', 'CS', 'Consulta Contratos', 
    'sbCOContratos', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3602', 'MA', 'Cadastramento de Contrato', 
    'sbCOContratos', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3603', 'MA', 'Programação de Rescisão', 
    'sbMOMovimentacoes', 7);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3604', 'MA', 'Mestres de Cálculo', 
    'sbCLCalculo', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3605', 'CA', 'Execução do Cálculo', 
    'sbCLCalculo', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3606', 'CA', 'Elimina Contratos Calculados', 
    'sbCLCalculo', 13);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3607', 'CS', 'Valores Calculados', 
    'sbCLCalculo', 7);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3608', 'CS', 'Valores Calculados por Contrato', 
    'sbCLCalculo', 8);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3609', 'CS', 'Consulta Financeiro', 
    'sbCLCalculo', 11);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3610', 'CS', 'Consulta Financeiro por Contrato', 
    'sbCLCalculo', 12);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3611', 'MA', 'Organograma', 
    'miCOHistoricos', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3612', 'MA', 'Cargo', 
    'miCOHistoricos', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3613', 'MA', 'Salário', 
    'miCOHistoricos', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3614', 'MA', 'Turno', 
    'miCOHistoricos', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3615', 'MA', 'Carga Horária', 
    'miCOHistoricos', 5);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3616', 'MA', 'Sindicato', 
    'miCOHistoricos', 6);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3617', 'MA', 'Cargos', 
    'sbCACadastros', 5);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3618', 'MA', 'Sindicatos', 
    'sbCACadastros', 10);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3619', 'MA', 'Organogramas', 
    'sbCACadastros', 7);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3620', 'MA', 'Turnos', 
    'sbCACadastros', 9);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3621', 'MA', 'Pessoas Jurídicas', 
    'sbCACadastros', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3622', 'MA', 'Vencimentos e Descontos', 
    'sbCACadastros', 11);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3700', 'MA', 'Mestre de Distribuição', 
    'sbVTValeTrans', 7);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3701', 'MA', 'Linhas', 
    'sbVTValeTrans', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3702', 'MA', 'Geração para Folha de Pagamento', 
    'sbVTValeTrans', 12);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3703', 'MA', 'Tarifas das Linhas', 
    'sbVTValeTrans', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3704', 'MA', 'Distribuição', 
    'sbVTValeTrans', 8);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3705', 'CS', 'Consulta Geração', 
    'sbVTValeTrans', 13);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3706', 'MA', 'Linhas do Contrato', 
    'sbVTValeTrans', 6);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3707', 'MA', 'Consulta Distribuição', 
    'sbVTValeTrans', 10);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3800', 'MA', 'Identificação', 
    'sbRLObrLegais', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'miW3801', 'CS', 'Consulta Execuções', 
    'sbRLObrLegais', 5);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbAF', 'ES', 'Administração de Frequência', 
    'tshWebCenter3', 8);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbCACadastros', 'ES', 'Cadastros Diversos', 
    'tshWebCenter3', 1);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbCLCalculo', 'ES', 'Cálculo', 
    'tshWebCenter3', 5);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbCOContratos', 'ES', 'Contratos', 
    'tshWebCenter3', 2);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbCS', 'ES', 'Cargos e Salários', 
    'tshWebCenter3', 10);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbDP', 'ES', 'Desenvolvimento de Pessoal', 
    'tshWebCenter3', 11);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbEmp', 'ES', 'A Empresa', 
    'tshWebCenter3', 18);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbGD', 'ES', 'G.E.D.', 
    'tshWebCenter3', 20);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbMB', 'ES', 'Mobile', 
    'tshWebCenter3', 19);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbMOMovimentacoes', 'ES', 'Movimentações', 
    'tshWebCenter3', 3);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbMS', 'ES', 'Medicina e Segurança', 
    'tshWebCenter3', 12);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbPCPesq', 'ES', 'Pesquisas de Clima', 
    'tshWebCenter3', 17);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbRE', 'ES', 'Relatórios e Indicadores', 
    'tshWebCenter3', 13);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbRLObrLegais', 'ES', 'eSocial', 
    'tshWebCenter3', 6);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbRS', 'ES', 'Recrutamento e Seleção', 
    'tshWebCenter3', 9);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbRVRhVirtual', 'ES', 'RH Virtual', 
    'tshWebCenter3', 16);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbVTValeTrans', 'ES', 'Benefícios e Convênios', 
    'tshWebCenter3', 4);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    COD_MENU_SUB, ORDEM)
 Values
   ('WW', 'W3', 'sbWF', 'ES', 'Workflow', 
    'tshWebCenter3', 15);
Insert into MENU
   (COD_PRODUTO, COD_MODULO, COD_MENU, TIPO_MENU, DESCRICAO, 
    ORDEM)
 Values
   ('WW', 'W3', 'tshWebCenter3', 'ES', 'Web Center 3', 
    46);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miCLEncerramento', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miCLSequencia', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miCODependentes', 'acessoInterno', 'Dependentes', 
    'Dependentes', 205);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miCOHistoricos', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miMOMovimentos', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miPCResp', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miRLEsocAss', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miRLEsocEnv', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miRLEsocExec', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miVTValesCt', 'acessoInterno', 'controller', 
    'Construcao', 999);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3201', 'acessoInterno', 'PessoasFunc', 
    'Pessoas', 201);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3202', 'acessoInterno', 'ContraCheque', 
    'ContraCheque', 202);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3204', 'acessoInterno', 'Ferias', 
    'Ferias', 204);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'miW3206', 'acessoInterno', 'controller', 
    'Aniversariantes', 206, 'ICONE_CALENDARIO.png', 'calendar-date');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3207', 'acessoInterno', 'Horario', 
    'HorarioEfetuado', 207);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3208', 'acessoInterno', 'OcorrenciaDiaria', 
    'OcorrenciasDiarias', 208);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3209', 'acessoInterno', 'OcorrenciaDiaria', 
    'OcorrenciasTotais', 209);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3210', 'acessoInterno', 'Horario', 
    'HorarioDivergencia', 210);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3211', 'acessoInterno', 'Horario', 
    'HorarioTrabalho', 211);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3215', 'acessoInterno', 'Cargos', 
    'ConsultaCargos', 215);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3217', 'acessoInterno', 'controller', 
    'Missao', 217);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3218', 'acessoInterno', 'Noticia', 
    'Noticias', 218);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3221', 'acessoInterno', 'Estatistica', 
    'EstatisticasWebCenter', 221);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3223', 'acessoInterno', 'Horario', 
    'HorarioAlternativo', 223);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3224', 'acessoInterno', 'Ferias', 
    'ConsultaProgramacaoFerias', 224);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3230', 'acessoInterno', 'Afastamentos', 
    'ContratoAfast', 230);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3231', 'acessoInterno', 'MovimentoContrato', 
    'ContratoMovs', 231);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'miW3237', 'acessoInterno', 'Login', 
    'AlteraSenha', 237, 'ICONE_ALTERARSENHA.png', 'key');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3238', 'acessoInterno', 'Curriculo', 
    'CurriculoContrato', 238);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3239', 'acessoInterno', 'EspelhoPonto', 
    'EspelhoPonto', 239);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3245', 'acessoInterno', 'ComprovanteRendimento', 
    'ComprovanteRendLista', 245);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'miW3246', 'acessoInterno', 'controller', 
    'Links', 246, 'ICONE_LINKS.png', 'link');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3247', 'acessoInterno', 'Workflow', 
    'ConsultaTarefaUsuario', 247);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3248', 'acessoInterno', 'Workflow', 
    'ConsultaAndamentoProcesso', 248);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3249', 'acessoInterno', 'Workflow', 
    'ExecucaoProcesso', 249);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3250', 'acessoInterno', 'AvaliacaoDesempenho', 
    'AgendaDeAvaliacoes', 250);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3251', 'acessoInterno', 'AvaliacaoDesempenho', 
    'ConsultaAvaliacaoContrato', 251);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3252', 'acessoInterno', 'AvaliacaoContratoExperiencia', 
    'ConsultaAvaliacaoPendente', 252);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3253', 'acessoInterno', 'PDI', 
    'PDIdoContrato', 253);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3255', 'acessoInterno', 'RequisicaoPessoal', 
    'ConsultaRequisicaoPessoal', 255);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3256', 'acessoInterno', 'SolicitacaoDesligamento', 
    'ConsultaSolicitacaoDesligamento', 256);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3257', 'acessoInterno', 'SolicitacaoMovimento', 
    'ConsultaSolicitacaoMovimento', 257);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3261', 'acessoInterno', 'EstruturaOrganograma', 
    'ConsultaEstruturaOrganograma', 261);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3264', 'acessoInterno', 'FeriasProgramadas', 
    'ConsultaFeriasProgramadas', 264);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3269', 'acessoInterno', 'Mobile', 
    'ConsultaAcessoMobile', 269);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3270', 'acessoInterno', 'Mobile', 
    'NotificacaoMobile', 270);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3271', 'acessoInterno', 'Relatorio', 
    'RelatorioSistema', 271);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3272', 'acessoInterno', 'ConsultaSistema', 
    'ConsultaSistema', 272);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3278', 'acessoInterno', 'Solicitacao', 
    'EnviarSolicitacao', 278);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3279', 'acessoInterno', 'Solicitacao', 
    'SolicitacoesEnviadas', 279);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3281', 'acessoInterno', 'Solicitacao', 
    'GerenciarSolicitacao', 281);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3282', 'acessoInterno', 'Solicitacao', 
    'TipoSolicitacao', 282);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3283', 'acessoInterno', 'SolicitacaoFerias', 
    'ConsultaSolicitacaoFerias', 283);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3284', 'acessoInterno', 'SolicitacaoFerias', 
    'GerenciarSolicitacaoFerias', 284);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3285', 'acessoInterno', 'BancoHora', 
    'ConsultaExtratoContas', 285);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3286', 'acessoInterno', 'BeneficioConvenio', 
    'ConsultaValorGerado', 286);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3287', 'acessoInterno', 'EscalaFolga', 
    'ConsultaEscalaFolga', 287);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3288', 'acessoInterno', 'Mobile', 
    'GeolocalizacaoOrganograma', 288);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3289', 'acessoInterno', 'EspelhoPonto', 
    'EspelhoPontoOficial', 289);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3290', 'acessoInterno', 'GrupoFolga', 
    'ConsultaContratoGrupoFolga', 290);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3291', 'acessoInterno', 'GrupoFolga', 
    'ConsultaOcorrenciaGrupoFolga', 291);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3292', 'acessoInterno', 'GrupoFolga', 
    'ConsultaPermutaHorario', 292);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE)
 Values
   ('WW', 'W3', 'miW3294', 'acessoInterno', 'Dashboard', 
    'ConsultaDashboard2', 294, 'ICONE_DASHBOARD.png');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE)
 Values
   ('WW', 'W3', 'miW3295', 'acessoInterno', 'Dashboard', 
    'ConsultaDashboard', 295, 'ICONE_DASHBOARD.png');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3298', 'acessoInterno', 'PesquisaCandidato', 
    'PesquisaCandidatos', 298);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3301', 'acessoInterno', 'PontoMobile', 
    'ConsultaPontoMobile', 301);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'miW3307', 'acessoInterno', 'controller', 
    'TempoEmpresa', 307, 'TEMPO_EMPRESA.png', 'hourglass');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3320', 'acessoInterno', 'GED', 
    'ConsultaDocumentosOrganograma', 320);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3330', 'acessoInterno', 'GED', 
    'ConsultaDocumentos', 330);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3380', 'acessoInterno', 'PontoMobile', 
    'ConsultafalhaPonto', 380);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3395', 'acessoInterno', 'PermutaHorario', 
    'PermutaHorario', 395);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3400', 'acessoInterno', 'Horario', 
    'HorarioControle', 400);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3405', 'acessoInterno', 'Horario', 
    'ContratosComHorarios', 405);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3410', 'acessoInterno', 'MovimentoContrato', 
    'DigitacaoMovs', 410);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3590', 'acessoInterno', 'Medicina', 
    'ConsultaASO', 590);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3595', 'acessoInterno', 'Medicina', 
    'ConsultaEPI', 595);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3600', 'acessoInterno', 'PessoasFisicas', 
    'PessoasFisicas', 600);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3601', 'acessoInterno', 'DadosPessoais', 
    'DadosPessoais', 601);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3602', 'acessoInterno', 'ContratosTrab', 
    'Contratos', 602);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3603', 'acessoInterno', 'Rescisao', 
    'Rescisao', 603);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3604', 'acessoInterno', 'Mestres', 
    'Mestres', 604);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3605', 'acessoInterno', 'Calculos', 
    'FiltrosExecucao', 605);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3606', 'acessoInterno', 'Calculos', 
    'FiltrosExclusao', 606);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3607', 'acessoInterno', 'Calculos', 
    'ConsultaResultadoCalculo', 607);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3608', 'acessoInterno', 'Calculos', 
    'ConsultaResultadoCalculoContrato', 608);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3609', 'acessoInterno', 'Financeiro', 
    'ConsultaFinanceiro', 609);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3610', 'acessoInterno', 'Financeiro', 
    'ConsultaFinanceiroContrato', 610);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3611', 'acessoInterno', 'HistOrganograma', 
    'ConsultaOrganogramas', 611);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3612', 'acessoInterno', 'HistCargo', 
    'ConsultaCargos', 612);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3613', 'acessoInterno', 'HistSalario', 
    'ConsultaSalarios', 613);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3614', 'acessoInterno', 'HistTurno', 
    'ConsultaTurnos', 614);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3615', 'acessoInterno', 'HistCargaHoraria', 
    'ConsultaCargasHorarias', 615);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3616', 'acessoInterno', 'HistSindicato', 
    'ConsultaSindicatos', 616);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3617', 'acessoInterno', 'Cargos', 
    'Cargos', 617);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3618', 'acessoInterno', 'Sindicatos', 
    'Sindicatos', 618);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3619', 'acessoInterno', 'Organogramas', 
    'Organogramas', 619);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3620', 'acessoInterno', 'Turnos', 
    'Turnos', 620);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3621', 'acessoInterno', 'PessoasJuridicas', 
    'PessoasJuridicas', 621);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3622', 'acessoInterno', 'VencimentosDescontos', 
    'ListaVds', 622);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3700', 'acessoInterno', 'VTMestre', 
    'VTMestre', 700);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3701', 'acessoInterno', 'VTLinha', 
    'VTLinha', 701);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3702', 'acessoInterno', 'VTGeracao', 
    'VTGeracao', 702);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3703', 'acessoInterno', 'VTHistTarifasLinha', 
    'VTConsultaTarifasLinha', 703);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3704', 'acessoInterno', 'VTDistribuicao', 
    'VTDistribuicao', 704);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3705', 'acessoInterno', 'VTGeracao', 
    'VTConsultaGeracao', 705);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3706', 'acessoInterno', 'VTHistLinha', 
    'ConsultaLinhas', 706);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3707', 'acessoInterno', 'VTDistribuicao', 
    'VTConsultaDistribuicao', 707);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3800', 'acessoInterno', 'ESocial', 
    'Identificacao', 800);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM)
 Values
   ('WW', 'W3', 'miW3801', 'acessoInterno', 'ESocial', 
    'ConsultaExecucao', 801);
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbAF', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'clock');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbCACadastros', '0', '0', 
    '0', 0, 'ICONE_SOLICITACAO.png', 'pencil-square');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbCLCalculo', '0', '0', 
    '0', 0, 'ICONE_CARGOSAL.png', 'calculator');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbCOContratos', '0', '0', 
    '0', 0, 'ICONE_RECSEL.png', 'person-workspace');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbCS', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'cash-coin');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbDP', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'mortarboard');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbEmp', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'house');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbGD', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'files');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbMB', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'phone');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbMOMovimentacoes', '0', '0', 
    '0', 0, 'ICONE_DESPES.png', 'recycle');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbMS', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'exclamation-triangle');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbPCPesq', 'acessoInterno', '0', 
    '0', 0, 'ICONE_EMPRESA.png', 'question-square');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbRE', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'bar-chart-line');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbRLObrLegais', '0', '0', 
    '0', 0, 'ICONE_EMPRESA.png', 'building');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbRS', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'people');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbRVRhVirtual', 'acessoInterno', '0', 
    '0', 0, 'ICONE_EMPRESA.png', 'person-badge');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbVTValeTrans', '0', '0', 
    '0', 0, 'ICONE_BENCONV.png', 'gift');
Insert into RHWW0040
   (COD_PRODUTO, COD_MODULO, COD_MENU, ACTION, SERVLET, 
    NOME_FORM, COD_FORM, ICONE, CLASSE_WEBCENTER3)
 Values
   ('WW', 'W3', 'sbWF', '0', '0', 
    '0', 0, 'ICONE_FREQUENCIA.png', 'stack-overflow');
COMMIT;
