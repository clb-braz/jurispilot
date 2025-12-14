# Site Institucional JurisPilot

## 🚀 Como Usar

### Visualizar o Site

1. **Método Simples (Recomendado para Teste)**
   - Navegue até a pasta `site`
   - Dê duplo clique em `index.html`
   - O site abrirá no seu navegador

2. **Método com Servidor (Recomendado para Produção)**
   ```bash
   cd D:\JurisPilot\site
   python -m http.server 8000
   ```
   - Acesse: `http://localhost:8000`

### Formulário de Contato

O formulário está configurado para enviar emails para **ispautopilot@gmail.com** usando FormSubmit.co (serviço gratuito).

**Como funciona:**
- O formulário envia automaticamente via FormSubmit.co
- Não requer configuração adicional
- Funciona imediatamente após upload

**Se quiser usar outro método:**
- EmailJS: Configure em `js/form.js`
- Backend próprio: Modifique `js/form.js` para enviar para sua API

### Estrutura de Arquivos

```
site/
├── index.html          # Página principal
├── css/
│   ├── style.css      # Estilos principais
│   └── animations.css # Animações CSS
├── js/
│   ├── main.js        # JavaScript principal
│   ├── animations.js  # Animações ao scroll
│   └── form.js        # Lógica do formulário
└── assets/            # Imagens e recursos (se houver)
```

### Funcionalidades

✅ Design responsivo (mobile, tablet, desktop)  
✅ Animações suaves ao scroll  
✅ Formulário de contato funcional  
✅ Chat widget flutuante  
✅ Processo de desenvolvimento interativo  
✅ FAQ accordion  
✅ Métricas animadas  
✅ Header fixo com blur effect  

### Personalização

**Cores:**
- Edite as variáveis CSS em `css/style.css` (linha 4-30)

**Conteúdo:**
- Edite `index.html` para alterar textos e seções

**Formulário:**
- Email de destino: `ispautopilot@gmail.com` (em `js/form.js`)

### Deploy

1. Faça upload de toda a pasta `site/` para seu servidor
2. Certifique-se de que `index.html` está na raiz
3. O formulário funcionará automaticamente

### Suporte

Para dúvidas sobre o site, consulte a documentação principal do projeto.

