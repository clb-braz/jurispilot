# JurisPilot - Sistema de Automação Jurídica Operacional

![Windows](https://img.shields.io/badge/Windows-Supported-0078D6?logo=windows)
![macOS](https://img.shields.io/badge/macOS-Supported-000000?logo=apple)
![Linux](https://img.shields.io/badge/Linux-Supported-FCC624?logo=linux)

> Um escritório que nunca esquece documentos, nunca perde prazo e nunca atende mal um cliente.

## 🎯 Visão Geral

O JurisPilot é um sistema completo de automação jurídica operacional projetado para eliminar tarefas administrativas repetitivas em escritórios de advocacia. O sistema substitui funções humanas administrativas, eliminando gargalos operacionais que destroem produtividade, geram erro e causam prejuízo jurídico.

## 🏗️ Arquitetura

- **n8n**: Núcleo de automação e orquestração de workflows
- **Python**: Scripts especializados para processamento de documentos, classificação, resumos e validações
- **PostgreSQL**: Banco de dados estruturado para clientes, casos, documentos e prazos
- **Site Institucional**: Apresentação do produto (HTML/CSS/JS estático)

## 🚀 Funcionalidades Principais

### Automações Core

- ✅ **Pré-atendimento 24h**: Captura inicial via WhatsApp/Formulário, sem necessidade de secretária
- ✅ **Triagem Jurídica Inteligente**: Identificação automática do tipo de ação e sugestão de juízo competente
- ✅ **Checklist Jurídico Dinâmico**: Geração automática baseada no tipo de ação
- ✅ **Organização Documental**: Classificação automática de provas e organização em pastas estruturadas
- ✅ **Controle Absoluto de Prazos**: Leitura automática de datas, alertas e integração Google Calendar
- ✅ **Resumo Jurídico Automático**: Processamento completo entregue ao advogado antes do atendimento

### 20 Automações Jurídicas Específicas

#### Cível/Consumidor
1. Gratuidade de Justiça
2. Relação de Consumo - Juízo Competente
3. Ação contra Companhia Aérea
4. Cobrança Indevida
5. Negativação Indevida

#### Família
6. Pensão Alimentícia
7. Divórcio (Consensual e Litigioso)
8. Guarda

#### Trabalhista
9. Rescisão Indireta
10. Horas Extras

#### Empresarial/Contratual
11. Descumprimento Contratual
12. Cobrança Empresarial

### Automações de Alto Valor

- **Validação de Prova Mínima**: Análise automática de força probatória do caso
- **Auditoria Operacional**: Identificação de gargalos e métricas de produtividade

## 📁 Estrutura do Projeto

```
D:\JurisPilot\
├── docs\                    # Documentação completa
│   ├── arquitetura.md
│   ├── automações.md
│   ├── checklists_juridicos.md
│   └── api_reference.md
├── n8n\                     # Workflows n8n
│   ├── workflows\           # 20+ workflows JSON
│   ├── credentials\
│   └── config\
├── python\                   # Scripts Python
│   ├── src\
│   │   ├── document_processor.py
│   │   ├── proof_classifier.py
│   │   ├── legal_summary.py
│   │   ├── deadline_extractor.py
│   │   ├── checklist_generator.py
│   │   └── timeline_generator.py
│   ├── requirements.txt
│   └── tests\
├── database\                 # Banco de dados
│   ├── schema.sql
│   ├── migrations\
│   └── seeds\
│       └── checklists_seed.sql
├── site\                     # Site institucional
│   ├── index.html
│   ├── css\
│   ├── js\
│   └── assets\
├── storage\                  # Armazenamento de documentos
│   ├── documents\
│   └── uploads\
└── scripts\                  # Scripts de setup/deploy
    ├── setup.sh
    └── deploy.sh
```

## 🛠️ Instalação

### ⚡ Início Rápido (5 minutos)

Consulte o [**QUICKSTART.md**](QUICKSTART.md) para começar rapidamente.

### Pré-requisitos

- PostgreSQL 12+
- Python 3.8+
- Node.js 16+ (para n8n)
- Git
- Tesseract OCR (opcional, para processamento de imagens)

### Setup Completo

1. **Clone o repositório**
   ```bash
   git clone https://github.com/clb-braz/jurispilot.git
   cd jurispilot
   ```

2. **Configure variáveis de ambiente**

   **Windows PowerShell:**
   ```powershell
   Copy-Item .env.example .env
   ```

   **Mac/Linux:**
   ```bash
   cp .env.example .env
   ```

   Edite o arquivo `.env` com suas credenciais.

3. **Execute o setup**

   **Windows PowerShell:**
   ```powershell
   .\scripts\setup.ps1
   ```

   **Mac/Linux:**
   ```bash
   chmod +x scripts/*.sh
   ./scripts/setup.sh
   ```

   **Ou use o wrapper universal (detecta OS automaticamente):**
   ```bash
   ./scripts/setup
   ```

4. **Configure o banco de dados**

   **Windows PowerShell:**
   ```powershell
   .\scripts\setup-database.ps1
   ```

   **Mac/Linux:**
   ```bash
   ./scripts/setup-database.sh
   ```

5. **Inicie o n8n**
   ```bash
   n8n start
   ```

6. **Importe os workflows**

   **Windows PowerShell:**
   ```powershell
   .\scripts\import-workflows.ps1
   ```

   **Mac/Linux:**
   ```bash
   ./scripts/import-workflows.sh
   ```

7. **Inicie a API Python**

   **Windows PowerShell:**
   ```powershell
   .\scripts\start-api.ps1
   ```

   **Mac/Linux:**
   ```bash
   ./scripts/start-api.sh
   ```

### Documentação Completa

- 📖 [Guia Rápido](QUICKSTART.md) - Comece em 5 minutos
- 📚 [Configuração Completa](docs/CONFIGURACAO_COMPLETA.md) - Guia detalhado
- 🔗 [Integrações](docs/INTEGRACOES.md) - WhatsApp, Google Calendar, Email

### Guias por Plataforma

- 🪟 [Instalação no Windows](docs/INSTALACAO_WINDOWS.md) - Guia completo para Windows
- 🍎 [Instalação no macOS](docs/INSTALACAO_MAC.md) - Guia completo para macOS
- 🐧 [Instalação no Linux](docs/INSTALACAO_LINUX.md) - Guia completo para Linux

## 📚 Documentação

- [Arquitetura do Sistema](docs/arquitetura.md)
- [Documentação de Automações](docs/automações.md)
- [Checklists Jurídicos](docs/checklists_juridicos.md)
- [API Reference](docs/api_reference.md)

## 🔄 Fluxo de Dados

1. Cliente inicia contato via WhatsApp/Formulário
2. n8n captura e cria registro no PostgreSQL
3. Triagem jurídica identifica tipo de ação
4. Checklist dinâmico é gerado automaticamente
5. Link seguro é enviado para upload de documentos
6. Documentos são processados por scripts Python
7. Classificação e organização automática
8. Validação de completude do checklist
9. Geração de resumo jurídico
10. Criação de linha do tempo
11. Extração e controle de prazos
12. Alertas automáticos configurados
13. Advogado recebe caso pronto para análise estratégica

## 🎯 Resultado Esperado

> "Isso resolveria 90% do caos do meu escritório."

- **Escritório pequeno** opera como médio
- **Escritório médio** opera como grande
- **Escritório grande** reduz custo operacional drasticamente

## 🔒 Segurança

- Armazenamento seguro de documentos
- Links temporários para upload
- Validação de tipos de arquivo
- Backup automático do banco de dados
- Logs de auditoria
- Tratamento de erros robusto

## 📝 Licença

Este projeto é proprietário. Todos os direitos reservados.

## 🤝 Suporte

ispautopilot@gmail.com

---

**JurisPilot** - Automação Jurídica Operacional

