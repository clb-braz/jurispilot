# Configuração do Formulário de Contato

## Método Atual: FormSubmit.co (Já Configurado)

O formulário está configurado para usar **FormSubmit.co**, um serviço gratuito que funciona imediatamente sem configuração.

**Email de destino:** `ispautopilot@gmail.com`

**Status:** ✅ Funcionando

---

## Método Alternativo: EmailJS (Opcional)

Se preferir usar EmailJS (mais controle, mas requer configuração):

### Passo 1: Criar conta no EmailJS
1. Acesse: https://www.emailjs.com/
2. Crie uma conta gratuita
3. Crie um serviço de email (Gmail, Outlook, etc.)
4. Crie um template de email

### Passo 2: Configurar no código
1. Abra `js/form.js`
2. Substitua `YOUR_PUBLIC_KEY` pelo seu Public Key do EmailJS
3. Substitua `YOUR_SERVICE_ID` pelo ID do seu serviço
4. Substitua `YOUR_TEMPLATE_ID` pelo ID do seu template

### Passo 3: Adicionar script no HTML
Adicione antes do fechamento de `</body>` em `index.html`:
```html
<script src="https://cdn.emailjs.com/dist/email.min.js"></script>
<script>
    emailjs.init("YOUR_PUBLIC_KEY");
</script>
```

---

## Método Alternativo: Backend Próprio

Se tiver um backend próprio:

1. Modifique `js/form.js`
2. Substitua a função de envio por uma chamada à sua API
3. Exemplo:
```javascript
const response = await fetch('https://sua-api.com/contato', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData)
});
```

---

## Teste do Formulário

Para testar se está funcionando:

1. Abra o site
2. Preencha o formulário de contato
3. Envie
4. Verifique o email `ispautopilot@gmail.com`

**Nota:** Com FormSubmit.co, você receberá um email de confirmação primeiro. Clique no link de confirmação para ativar o recebimento.

