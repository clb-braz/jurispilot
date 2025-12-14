-- JurisPilot - Schema do Banco de Dados PostgreSQL
-- Sistema de Automação Jurídica Operacional

-- Extensões
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de Clientes
CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    cpf_cnpj VARCHAR(20) UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(255),
    endereco TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Casos
CREATE TABLE casos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    tipo_acao VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'em_triagem',
    descricao TEXT,
    juizo_competente VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Checklists Jurídicos (Templates)
CREATE TABLE checklists_juridicos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tipo_acao VARCHAR(100) NOT NULL,
    documento_obrigatorio VARCHAR(255) NOT NULL,
    documento_recomendado BOOLEAN DEFAULT FALSE,
    validacao_automatica BOOLEAN DEFAULT TRUE,
    ordem INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Checklists por Caso (Instâncias)
CREATE TABLE checklists_caso (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caso_id UUID NOT NULL REFERENCES casos(id) ON DELETE CASCADE,
    checklist_juridico_id UUID NOT NULL REFERENCES checklists_juridicos(id),
    documento_id UUID REFERENCES documentos(id),
    status VARCHAR(50) DEFAULT 'pendente', -- pendente, recebido, validado
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Documentos
CREATE TABLE documentos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caso_id UUID NOT NULL REFERENCES casos(id) ON DELETE CASCADE,
    tipo_documento VARCHAR(100),
    nome_arquivo VARCHAR(255) NOT NULL,
    caminho_arquivo TEXT NOT NULL,
    tamanho_arquivo BIGINT,
    mime_type VARCHAR(100),
    data_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validado BOOLEAN DEFAULT FALSE,
    classificacao_prova VARCHAR(50), -- documento_oficial, conversa, comprovante_financeiro, prova_tecnica
    relevancia INTEGER DEFAULT 5, -- 1-10
    data_documento DATE,
    texto_extraido TEXT,
    metadados JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Prazos
CREATE TABLE prazos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caso_id UUID NOT NULL REFERENCES casos(id) ON DELETE CASCADE,
    tipo_prazo VARCHAR(100) NOT NULL, -- processual, administrativo, contratual
    data_vencimento DATE NOT NULL,
    data_lembrete DATE,
    status VARCHAR(50) DEFAULT 'pendente', -- pendente, lembrado, vencido, cumprido
    descricao TEXT,
    documento_relacionado_id UUID REFERENCES documentos(id),
    google_calendar_event_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Linha do Tempo
CREATE TABLE linha_tempo (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caso_id UUID NOT NULL REFERENCES casos(id) ON DELETE CASCADE,
    evento VARCHAR(255) NOT NULL,
    data_evento DATE NOT NULL,
    documento_relacionado_id UUID REFERENCES documentos(id),
    descricao TEXT,
    tipo_evento VARCHAR(50), -- upload_documento, prazo_vencido, comunicacao, etc
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Resumos Jurídicos
CREATE TABLE resumos_juridicos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caso_id UUID NOT NULL REFERENCES casos(id) ON DELETE CASCADE,
    resumo_texto TEXT NOT NULL,
    pontos_chave JSONB,
    pontos_fortes TEXT[],
    pontos_fracos TEXT[],
    alertas TEXT[],
    gerado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    versao INTEGER DEFAULT 1
);

-- Tabela de Auditoria Operacional
CREATE TABLE auditoria_operacional (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caso_id UUID REFERENCES casos(id) ON DELETE SET NULL,
    tipo_metrica VARCHAR(100), -- tempo_triagem, documentos_faltantes, prazos_perdidos
    valor_metrica NUMERIC,
    descricao TEXT,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para performance
CREATE INDEX idx_casos_cliente_id ON casos(cliente_id);
CREATE INDEX idx_casos_tipo_acao ON casos(tipo_acao);
CREATE INDEX idx_casos_status ON casos(status);
CREATE INDEX idx_documentos_caso_id ON documentos(caso_id);
CREATE INDEX idx_documentos_tipo ON documentos(tipo_documento);
CREATE INDEX idx_prazos_caso_id ON prazos(caso_id);
CREATE INDEX idx_prazos_vencimento ON prazos(data_vencimento);
CREATE INDEX idx_prazos_status ON prazos(status);
CREATE INDEX idx_linha_tempo_caso_id ON linha_tempo(caso_id);
CREATE INDEX idx_linha_tempo_data_evento ON linha_tempo(data_evento);
CREATE INDEX idx_checklists_juridicos_tipo_acao ON checklists_juridicos(tipo_acao);
CREATE INDEX idx_checklists_caso_caso_id ON checklists_caso(caso_id);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_casos_updated_at BEFORE UPDATE ON casos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documentos_updated_at BEFORE UPDATE ON documentos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prazos_updated_at BEFORE UPDATE ON prazos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_checklists_caso_updated_at BEFORE UPDATE ON checklists_caso
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

