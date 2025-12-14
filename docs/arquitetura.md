# JurisPilot - Arquitetura do Sistema

## Visão Geral

O JurisPilot é um sistema de automação jurídica operacional que elimina tarefas administrativas repetitivas em escritórios de advocacia. A arquitetura centraliza o n8n como orquestrador principal, com scripts Python para processamento avançado e PostgreSQL para persistência de dados.

## Componentes Principais

### 1. n8n (Núcleo de Automação)

O n8n funciona como o orquestrador central do sistema, gerenciando todos os workflows de automação:

- **Workflows Principais**: Pré-atendimento, triagem jurídica, checklist dinâmico, controle de prazos, organização documental
- **Workflows Específicos**: 12 workflows para demandas jurídicas específicas
- **Workflows de Alto Valor**: Validação de prova mínima, auditoria operacional

### 2. Python Scripts

Scripts especializados para processamento avançado:

- `document_processor.py`: Extração de texto, metadados e identificação de tipos
- `proof_classifier.py`: Classificação automática de provas jurídicas
- `legal_summary.py`: Geração de resumos jurídicos estruturados
- `deadline_extractor.py`: Extração e identificação de prazos
- `checklist_generator.py`: Geração dinâmica de checklists
- `timeline_generator.py`: Construção de linha do tempo cronológica

### 3. PostgreSQL

Banco de dados estruturado com as seguintes tabelas principais:

- `clientes`: Dados dos clientes
- `casos`: Informações dos casos jurídicos
- `checklists_juridicos`: Templates de checklists por tipo de ação
- `checklists_caso`: Instâncias de checklists por caso
- `documentos`: Documentos processados e classificados
- `prazos`: Controle de prazos processuais e administrativos
- `linha_tempo`: Eventos cronológicos do caso
- `resumos_juridicos`: Resumos gerados automaticamente
- `auditoria_operacional`: Métricas e análises operacionais

### 4. Site Institucional

Site HTML/CSS/JS estático para apresentação do produto, sem necessidade de backend.

## Fluxo de Dados Principal

1. **Cliente inicia contato** via WhatsApp/Formulário
2. **n8n captura** e cria registro no PostgreSQL
3. **Triagem jurídica** identifica tipo de ação automaticamente
4. **Checklist dinâmico** é gerado baseado no tipo de ação
5. **Link seguro** é enviado para upload de documentos
6. **Documentos são processados** por scripts Python
7. **Classificação e organização** automática de provas
8. **Validação de completude** do checklist
9. **Geração de resumo jurídico** estruturado
10. **Criação de linha do tempo** cronológica
11. **Extração e controle de prazos** automático
12. **Alertas automáticos** configurados
13. **Advogado recebe caso** pronto para análise estratégica

## Integrações

### WhatsApp
- Recebimento de mensagens iniciais
- Envio de links de upload
- Alertas de prazos
- Notificações de status

### Google Calendar
- Criação automática de eventos de prazos
- Sincronização bidirecional
- Lembretes configuráveis

### E-mail
- Envio de resumos jurídicos
- Notificações de documentos recebidos
- Alertas críticos

## Segurança

- Armazenamento seguro de documentos
- Links temporários para upload
- Validação de tipos de arquivo
- Backup automático do banco de dados
- Logs de auditoria
- Tratamento de erros robusto

## Escalabilidade

O sistema foi projetado para escalar horizontalmente:

- n8n pode ser executado em múltiplas instâncias
- Scripts Python são stateless e podem ser executados em paralelo
- PostgreSQL suporta replicação e sharding
- Storage de documentos pode usar S3 ou similar

