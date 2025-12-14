# JurisPilot - Documentação de Automações

## Workflows Principais

### 1. Pré-Atendimento 24h

**Objetivo**: Capturar contato inicial e iniciar processo automatizado

**Fluxo**:
1. Webhook recebe mensagem via WhatsApp/Formulário
2. Cria registro de cliente no banco
3. Classifica tipo de demanda automaticamente
4. Cria caso no sistema
5. Gera checklist dinâmico
6. Gera link seguro para upload
7. Envia mensagem ao cliente com link

**Arquivo**: `n8n/workflows/pre_atendimento.json`

### 2. Triagem Jurídica Inteligente

**Objetivo**: Analisar caso e identificar tipo de ação específico

**Fluxo**:
1. Recebe caso para análise
2. Analisa descrição usando processamento de linguagem natural
3. Identifica tipo de ação (Cível, Família, Trabalhista, Empresarial)
4. Sugere juízo competente quando aplicável
5. Atualiza caso com informações identificadas
6. Gera checklist dinâmico baseado no tipo

**Arquivo**: `n8n/workflows/triagem_juridica.json`

### 3. Checklist Jurídico Dinâmico

**Objetivo**: Validar completude de documentos do caso

**Fluxo**:
1. Busca template de checklist por tipo de ação
2. Busca documentos já recebidos do caso
3. Valida quais documentos estão presentes
4. Calcula percentual de completude
5. Salva status de cada item do checklist
6. Se completo, dispara geração de resumo
7. Se incompleto, envia alerta com documentos faltantes

**Arquivo**: `n8n/workflows/checklist_dinamico.json`

### 4. Controle de Prazos

**Objetivo**: Monitorar e alertar sobre prazos processuais

**Fluxo**:
1. Executa periodicamente (a cada hora)
2. Busca prazos pendentes
3. Calcula dias restantes
4. Identifica prazos críticos (≤3 dias)
5. Atualiza status dos prazos
6. Cria eventos no Google Calendar
7. Envia alertas via WhatsApp para prazos críticos

**Arquivo**: `n8n/workflows/controle_prazos.json`

### 5. Organização Documental

**Objetivo**: Processar e organizar documentos recebidos

**Fluxo**:
1. Recebe documento via upload
2. Salva registro no banco
3. Chama script Python para processar documento
4. Atualiza documento com texto extraído e metadados
5. Classifica documento como prova
6. Extrai prazos do documento
7. Adiciona evento à linha do tempo
8. Revalida checklist do caso

**Arquivo**: `n8n/workflows/organizacao_documental.json`

## Workflows Específicos por Demanda Jurídica

### Cível/Consumidor

1. **Gratuidade de Justiça** (`gratuidade_justica.json`)
   - Valida IRPF, contracheque, extrato bancário, carteira de trabalho
   - Alertas de documentos faltantes

2. **Relação de Consumo - Juízo Competente** (`juizo_competente.json`)
   - Identifica domicílio do autor
   - Sugere juízo competente com justificativa jurídica

3. **Ação contra Companhia Aérea** (`acao_companhia_aerea.json`)
   - Organiza comprovantes, e-mails, prints, protocolos
   - Organização cronológica automática

4. **Cobrança Indevida** (`cobranca_indevida.json`)
   - Solicita faturas, comprovantes, contratos
   - Identifica repetição de indébito

5. **Negativação Indevida** (`negativacao_indevida.json`)
   - Solicita consultas SPC/Serasa
   - Gera linha do tempo automática

### Família

6. **Pensão Alimentícia** (`pensao_alimenticia.json`)
   - Valida certidão, comprovantes de renda, despesas
   - Gera resumo financeiro automático

7. **Divórcio** (`divorcio.json`)
   - Checklist dinâmico: consensual vs litigioso
   - Separação automática de bens, dívidas e provas

8. **Guarda** (`guarda.json`)
   - Solicita provas de vínculo, histórico escolar, relatórios médicos
   - Classificação por relevância

### Trabalhista

9. **Rescisão Indireta** (`rescisao_indireta.json`)
   - Valida contrato, holerites, extrato FGTS, provas de falta grave
   - Linha do tempo automatizada

10. **Horas Extras** (`horas_extras.json`)
    - Solicita cartões de ponto, contracheques, escalas
    - Gera quadro comparativo automático

### Empresarial/Contratual

11. **Descumprimento Contratual** (`descumprimento_contratual.json`)
    - Organiza contratos, aditivos, provas, comunicações

12. **Cobrança Empresarial** (`cobranca_empresarial.json`)
    - Organiza notas fiscais, boletos, comprovantes
    - Linha do tempo automática

## Automações de Alto Valor

### Validação de Prova Mínima

**Objetivo**: Analisar força probatória do caso

**Fluxo**:
1. Busca caso e todos os documentos
2. Calcula relevância média das provas
3. Identifica provas essenciais presentes
4. Analisa força probatória (alta/média/baixa)
5. Gera alertas sobre provas faltantes críticas
6. Sugere documentos adicionais
7. Atualiza status do caso

**Arquivo**: `n8n/workflows/validacao_prova_minima.json`

### Auditoria Operacional

**Objetivo**: Identificar gargalos e métricas de produtividade

**Fluxo**:
1. Executa diariamente
2. Coleta métricas de casos (tempo de triagem, documentos faltantes)
3. Analisa prazos (vencidos, pendentes)
4. Identifica gargalos operacionais
5. Calcula perdas estimadas (tempo e dinheiro)
6. Gera recomendações
7. Salva auditoria no banco

**Arquivo**: `n8n/workflows/auditoria_operacional.json`

## Como Usar os Workflows

1. Importe os workflows JSON no n8n
2. Configure as credenciais necessárias (PostgreSQL, WhatsApp, Google Calendar)
3. Ative os workflows
4. Configure webhooks se necessário
5. Monitore execuções no dashboard do n8n

