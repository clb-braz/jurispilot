-- JurisPilot - Seeds de Checklists Jurídicos
-- Insere templates de checklists para todos os tipos de ação

-- Cível/Consumidor

-- Gratuidade de Justiça
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('gratuidade_justica', 'IRPF', false, true, 1),
('gratuidade_justica', 'Contracheque', false, true, 2),
('gratuidade_justica', 'Extrato bancário (últimos 3 meses)', false, true, 3),
('gratuidade_justica', 'Carteira de trabalho', false, true, 4),
('gratuidade_justica', 'Comprovante de residência', true, true, 5),
('gratuidade_justica', 'Comprovante de despesas', true, true, 6),
('gratuidade_justica', 'Atestado médico (se aplicável)', true, true, 7);

-- Relação de Consumo
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('relacao_consumo', 'Comprovante de compra', false, true, 1),
('relacao_consumo', 'Comprovante de pagamento', false, true, 2),
('relacao_consumo', 'Contrato (se houver)', false, true, 3),
('relacao_consumo', 'Comunicação com fornecedor', false, true, 4),
('relacao_consumo', 'Nota fiscal', true, true, 5),
('relacao_consumo', 'Fotos do produto/serviço', true, true, 6),
('relacao_consumo', 'Histórico de comunicação', true, true, 7);

-- Ação contra Companhia Aérea
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('acao_companhia_aerea', 'Comprovante de compra', false, true, 1),
('acao_companhia_aerea', 'Comprovante de pagamento', false, true, 2),
('acao_companhia_aerea', 'E-mails da companhia', false, true, 3),
('acao_companhia_aerea', 'Prints de cancelamento', false, true, 4),
('acao_companhia_aerea', 'Protocolos', false, true, 5),
('acao_companhia_aerea', 'Comprovante de bagagem extraviada', true, true, 6),
('acao_companhia_aerea', 'Fotos de danos', true, true, 7),
('acao_companhia_aerea', 'Comunicação com atendimento', true, true, 8);

-- Cobrança Indevida
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('cobranca_indevida', 'Faturas', false, true, 1),
('cobranca_indevida', 'Comprovantes de pagamento', false, true, 2),
('cobranca_indevida', 'Contrato (se houver)', false, true, 3),
('cobranca_indevida', 'Histórico de comunicação', false, true, 4),
('cobranca_indevida', 'Extrato bancário', true, true, 5),
('cobranca_indevida', 'Comprovantes de cancelamento', true, true, 6),
('cobranca_indevida', 'Comunicação prévia', true, true, 7);

-- Negativação Indevida
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('negativacao_indevida', 'Consulta SPC/Serasa', false, true, 1),
('negativacao_indevida', 'Comprovantes de pagamento', false, true, 2),
('negativacao_indevida', 'Comunicação prévia', false, true, 3),
('negativacao_indevida', 'Extrato bancário', true, true, 4),
('negativacao_indevida', 'Comprovante de quitação', true, true, 5),
('negativacao_indevida', 'Histórico de relacionamento', true, true, 6);

-- Família

-- Pensão Alimentícia
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('pensao_alimenticia', 'Certidão de nascimento', false, true, 1),
('pensao_alimenticia', 'Comprovantes de renda', false, true, 2),
('pensao_alimenticia', 'Despesas do menor', false, true, 3),
('pensao_alimenticia', 'Extrato bancário', true, true, 4),
('pensao_alimenticia', 'Comprovante de despesas escolares', true, true, 5),
('pensao_alimenticia', 'Comprovante de despesas médicas', true, true, 6);

-- Divórcio Consensual
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('divorcio_consensual', 'Certidão de casamento', false, true, 1),
('divorcio_consensual', 'CPF de ambos', false, true, 2),
('divorcio_consensual', 'RG de ambos', false, true, 3),
('divorcio_consensual', 'Comprovante de residência', false, true, 4),
('divorcio_consensual', 'Acordo de divórcio', true, true, 5),
('divorcio_consensual', 'Comprovante de renda', true, true, 6);

-- Divórcio Litigioso
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('divorcio_litigioso', 'Certidão de casamento', false, true, 1),
('divorcio_litigioso', 'CPF de ambos', false, true, 2),
('divorcio_litigioso', 'RG de ambos', false, true, 3),
('divorcio_litigioso', 'Comprovante de residência', false, true, 4),
('divorcio_litigioso', 'Comprovantes de renda', false, true, 5),
('divorcio_litigioso', 'Documentos de bens', false, true, 6),
('divorcio_litigioso', 'Documentos de dívidas', false, true, 7),
('divorcio_litigioso', 'Extrato bancário', true, true, 8),
('divorcio_litigioso', 'Comprovante de imóveis', true, true, 9),
('divorcio_litigioso', 'Comprovante de veículos', true, true, 10);

-- Guarda
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('guarda', 'Certidão de nascimento', false, true, 1),
('guarda', 'Provas de vínculo', false, true, 2),
('guarda', 'Histórico escolar', false, true, 3),
('guarda', 'Relatórios médicos', true, true, 4),
('guarda', 'Fotos', true, true, 5),
('guarda', 'Comprovante de residência', true, true, 6);

-- Trabalhista

-- Rescisão Indireta
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('rescisao_indireta', 'Contrato de trabalho', false, true, 1),
('rescisao_indireta', 'Holerites', false, true, 2),
('rescisao_indireta', 'Extrato FGTS', false, true, 3),
('rescisao_indireta', 'Provas da falta grave', false, true, 4),
('rescisao_indireta', 'Comunicação com empresa', true, true, 5),
('rescisao_indireta', 'Testemunhas', true, true, 6),
('rescisao_indireta', 'Comprovantes de irregularidades', true, true, 7);

-- Horas Extras
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('horas_extras', 'Cartões de ponto', false, true, 1),
('horas_extras', 'Contracheques', false, true, 2),
('horas_extras', 'Escalas', false, true, 3),
('horas_extras', 'Contrato de trabalho', true, true, 4),
('horas_extras', 'Comunicação sobre horas extras', true, true, 5),
('horas_extras', 'Comprovantes de pagamento', true, true, 6);

-- Empresarial/Contratual

-- Descumprimento Contratual
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('descumprimento_contratual', 'Contrato', false, true, 1),
('descumprimento_contratual', 'Aditivos', false, true, 2),
('descumprimento_contratual', 'Provas de descumprimento', false, true, 3),
('descumprimento_contratual', 'Comunicações', false, true, 4),
('descumprimento_contratual', 'Notas fiscais', true, true, 5),
('descumprimento_contratual', 'Comprovantes de pagamento', true, true, 6),
('descumprimento_contratual', 'Correspondências', true, true, 7);

-- Cobrança Empresarial
INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem) VALUES
('cobranca_empresarial', 'Notas fiscais', false, true, 1),
('cobranca_empresarial', 'Boletos', false, true, 2),
('cobranca_empresarial', 'Comprovantes', false, true, 3),
('cobranca_empresarial', 'Contrato', true, true, 4),
('cobranca_empresarial', 'Histórico de relacionamento', true, true, 5),
('cobranca_empresarial', 'Comunicações', true, true, 6);

-- Confirma inserção
SELECT tipo_acao, COUNT(*) as total_documentos 
FROM checklists_juridicos 
GROUP BY tipo_acao 
ORDER BY tipo_acao;

