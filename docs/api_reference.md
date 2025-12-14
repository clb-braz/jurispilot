# JurisPilot - API Reference

## Visão Geral

O JurisPilot utiliza n8n como núcleo de automação, que expõe webhooks para integração. Os scripts Python podem ser chamados via HTTP quando necessário.

## Webhooks n8n

### Pré-Atendimento

**Endpoint**: `POST /webhook/pre-atendimento`

**Body**:
```json
{
  "nome": "João Silva",
  "telefone": "+5511999999999",
  "email": "joao@example.com",
  "cpf_cnpj": "123.456.789-00",
  "descricao": "Preciso de ajuda com gratuidade de justiça"
}
```

**Resposta**: Status 200 com ID do caso criado

### Upload de Documento

**Endpoint**: `POST /webhook/upload-documento`

**Body**:
```json
{
  "caso_id": "uuid-do-caso",
  "nome_arquivo": "cpf.pdf",
  "caminho_arquivo": "/storage/documents/cpf.pdf",
  "tamanho_arquivo": 1024000,
  "mime_type": "application/pdf"
}
```

**Resposta**: Status 200 com ID do documento processado

### Triagem Jurídica

**Endpoint**: `POST /webhook/triagem-juridica`

**Body**:
```json
{
  "caso_id": "uuid-do-caso"
}
```

**Resposta**: Status 200 com tipo de ação identificado

### Validação de Checklist

**Endpoint**: `POST /webhook/checklist-dinamico`

**Body**:
```json
{
  "caso_id": "uuid-do-caso",
  "tipo_acao": "Gratuidade de Justiça"
}
```

**Resposta**: Status 200 com status de validação

## APIs Python (quando expostas via Flask)

### Processar Documento

**Endpoint**: `POST /api/document/process`

**Body**:
```json
{
  "documento_id": "uuid",
  "caminho_arquivo": "/path/to/file.pdf"
}
```

**Resposta**:
```json
{
  "tipo_documento": "cpf",
  "texto_extraido": "...",
  "data_documento": "2024-12-01",
  "metadados": {...}
}
```

### Classificar Prova

**Endpoint**: `POST /api/proof/classify`

**Body**:
```json
{
  "documento_info": {
    "tipo_documento": "cpf",
    "texto_extraido": "...",
    "validado": true
  }
}
```

**Resposta**:
```json
{
  "classificacao_prova": "documento_oficial",
  "relevancia": 10,
  "is_essencial": true
}
```

### Gerar Checklist

**Endpoint**: `POST /api/checklist/generate`

**Body**:
```json
{
  "tipo_acao": "Gratuidade de Justiça",
  "caso_id": "uuid"
}
```

**Resposta**:
```json
{
  "documentos_obrigatorios": ["IRPF", "Contracheque", ...],
  "documentos_recomendados": [...],
  "validacao_automatica": true
}
```

### Extrair Prazos

**Endpoint**: `POST /api/deadline/extract`

**Body**:
```json
{
  "documento_info": {...},
  "tipo_acao": "Cível"
}
```

**Resposta**:
```json
[
  {
    "tipo_prazo": "processual",
    "data_vencimento": "2024-12-25",
    "descricao": "15 dias para contestação"
  }
]
```

### Gerar Resumo Jurídico

**Endpoint**: `POST /api/caso/{caso_id}/gerar-resumo`

**Resposta**:
```json
{
  "resumo_texto": "...",
  "pontos_chave": [...],
  "pontos_fortes": [...],
  "pontos_fracos": [...],
  "alertas": [...]
}
```

## Autenticação

Atualmente, os webhooks do n8n podem ser protegidos com:
- API Keys
- Autenticação básica HTTP
- OAuth2 (para integrações específicas)

## Rate Limiting

Recomenda-se implementar rate limiting para evitar abuso:
- 100 requisições por minuto por IP
- 1000 requisições por hora por cliente

## Códigos de Status

- `200`: Sucesso
- `400`: Requisição inválida
- `404`: Recurso não encontrado
- `500`: Erro interno do servidor

## Exemplos de Uso

### cURL

```bash
curl -X POST https://seu-n8n.com/webhook/pre-atendimento \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "telefone": "+5511999999999",
    "email": "joao@example.com",
    "descricao": "Preciso de ajuda"
  }'
```

### Python

```python
import requests

response = requests.post(
    'https://seu-n8n.com/webhook/pre-atendimento',
    json={
        'nome': 'João Silva',
        'telefone': '+5511999999999',
        'email': 'joao@example.com',
        'descricao': 'Preciso de ajuda'
    }
)

print(response.json())
```

### JavaScript

```javascript
fetch('https://seu-n8n.com/webhook/pre-atendimento', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    nome: 'João Silva',
    telefone: '+5511999999999',
    email: 'joao@example.com',
    descricao: 'Preciso de ajuda'
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

