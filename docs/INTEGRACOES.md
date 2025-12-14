# 🔗 JurisPilot - Guia de Integrações

Documentação completa para configurar integrações externas do JurisPilot.

## Índice

1. [WhatsApp](#whatsapp)
2. [Google Calendar](#google-calendar)
3. [Email SMTP](#email-smtp)

---

## WhatsApp

O JurisPilot suporta múltiplas APIs de WhatsApp. Escolha a que melhor se adequa ao seu caso.

### Opção 1: Evolution API (Recomendado)

Evolution API é uma solução open-source e auto-hospedada.

#### Instalação

```bash
# Via Docker (recomendado)
docker run -d \
  --name evolution-api \
  -p 8080:8080 \
  -e AUTHENTICATION_API_KEY=sua_chave_aqui \
  atendai/evolution-api:latest
```

#### Configuração no JurisPilot

No arquivo `.env`:

```env
WHATSAPP_API_TYPE=evolution
WHATSAPP_API_URL=http://localhost:8080
WHATSAPP_API_KEY=sua_chave_aqui
WHATSAPP_INSTANCE_NAME=jurispilot
WHATSAPP_WEBHOOK_URL=http://localhost:5678/webhook/whatsapp
```

#### Configurar Webhook no n8n

1. Acesse o n8n: http://localhost:5678
2. Crie um workflow com Webhook node
3. Configure a URL: `/webhook/whatsapp`
4. Conecte ao workflow de pré-atendimento

### Opção 2: WhatsApp Business API (Oficial)

API oficial do Meta/Facebook.

#### Requisitos

- Conta Business no Facebook
- Aplicativo criado no Facebook Developers
- Token de acesso

#### Configuração no JurisPilot

No arquivo `.env`:

```env
WHATSAPP_API_TYPE=official
WHATSAPP_BUSINESS_ACCOUNT_ID=seu_account_id
WHATSAPP_ACCESS_TOKEN=seu_token
WHATSAPP_PHONE_NUMBER_ID=seu_phone_id
WHATSAPP_VERIFY_TOKEN=seu_verify_token
```

#### Configurar Webhook

1. No Facebook Developers, configure webhook
2. URL: `https://seu-dominio.com/webhook/whatsapp`
3. Verify Token: use o mesmo do `.env`

### Opção 3: Twilio WhatsApp

Solução comercial com suporte oficial.

#### Configuração no JurisPilot

No arquivo `.env`:

```env
WHATSAPP_API_TYPE=twilio
TWILIO_ACCOUNT_SID=seu_account_sid
TWILIO_AUTH_TOKEN=seu_auth_token
TWILIO_WHATSAPP_FROM=whatsapp:+14155238886
```

---

## Google Calendar

Integração completa com Google Calendar para controle de prazos.

### 1. Criar Projeto no Google Cloud

1. Acesse: https://console.cloud.google.com/
2. Crie um novo projeto ou selecione existente
3. Ative a API do Google Calendar

### 2. Criar Credenciais OAuth 2.0

1. Vá em **APIs & Services** > **Credentials**
2. Clique em **Create Credentials** > **OAuth client ID**
3. Tipo: **Web application**
4. Adicione URI de redirecionamento:
   ```
   http://localhost:5000/auth/google/callback
   ```
5. Copie **Client ID** e **Client Secret**

### 3. Configurar no JurisPilot

No arquivo `.env`:

```env
GOOGLE_CALENDAR_ENABLED=true
GOOGLE_CALENDAR_CLIENT_ID=seu_client_id.apps.googleusercontent.com
GOOGLE_CALENDAR_CLIENT_SECRET=seu_client_secret
GOOGLE_CALENDAR_REDIRECT_URI=http://localhost:5000/auth/google/callback
GOOGLE_CALENDAR_SCOPES=https://www.googleapis.com/auth/calendar
```

### 4. Obter Refresh Token

1. Execute o script de autenticação (a ser criado)
2. Autorize o acesso no navegador
3. O refresh token será salvo automaticamente

### 5. Configurar no n8n

1. No n8n, adicione credencial **Google Calendar OAuth2**
2. Use o mesmo Client ID e Client Secret
3. Configure os scopes necessários

### 6. Testar Integração

Crie um workflow de teste no n8n que:
1. Detecta um prazo
2. Cria evento no Google Calendar
3. Envia notificação

---

## Email SMTP

Configuração de email para envio de notificações.

### Gmail

#### 1. Criar Senha de App

1. Acesse: https://myaccount.google.com/
2. Vá em **Segurança**
3. Ative **Verificação em duas etapas**
4. Crie **Senha de app**
5. Copie a senha gerada

#### 2. Configurar no JurisPilot

No arquivo `.env`:

```env
EMAIL_ENABLED=true
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_SMTP_USER=seu_email@gmail.com
EMAIL_SMTP_PASSWORD=senha_de_app_gerada
EMAIL_SMTP_TLS=true
EMAIL_FROM_NAME=JurisPilot
EMAIL_FROM_ADDRESS=noreply@jurispilot.com.br
```

### Outlook/Office 365

```env
EMAIL_SMTP_HOST=smtp.office365.com
EMAIL_SMTP_PORT=587
EMAIL_SMTP_USER=seu_email@outlook.com
EMAIL_SMTP_PASSWORD=sua_senha
EMAIL_SMTP_TLS=true
```

### Servidor SMTP Personalizado

```env
EMAIL_SMTP_HOST=mail.seudominio.com.br
EMAIL_SMTP_PORT=587
EMAIL_SMTP_USER=usuario@seudominio.com.br
EMAIL_SMTP_PASSWORD=sua_senha
EMAIL_SMTP_TLS=true
```

### Configurar no n8n

1. Adicione credencial **SMTP**
2. Configure com as mesmas credenciais do `.env`
3. Teste envio de email

---

## Testando Integrações

### Teste WhatsApp

1. Envie mensagem para o número configurado
2. Verifique se webhook recebe no n8n
3. Verifique resposta automática

### Teste Google Calendar

1. Execute workflow que cria evento
2. Verifique no Google Calendar
3. Teste notificações

### Teste Email

1. Execute workflow que envia email
2. Verifique caixa de entrada
3. Verifique spam (se necessário)

---

## Troubleshooting

### WhatsApp não recebe mensagens

- Verifique se webhook está configurado
- Verifique URL do webhook no n8n
- Verifique logs do n8n

### Google Calendar não cria eventos

- Verifique refresh token válido
- Verifique scopes configurados
- Re-autentique se necessário

### Email não envia

- Verifique credenciais SMTP
- Verifique firewall/porta
- Teste conexão SMTP manualmente

---

**JurisPilot** - Automação Jurídica Operacional
