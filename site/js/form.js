// Formulário de Contato - JurisPilot
// Integração com FormSubmit.co (gratuito e sem configuração)

// Formulário Principal
const contactForm = document.getElementById('contactForm');
const formMessage = document.getElementById('formMessage');

if (contactForm) {
    // Configurar action do formulário para FormSubmit
    contactForm.action = 'https://formsubmit.co/ispautopilot@gmail.com';
    contactForm.method = 'POST';
    
    // Adicionar campos hidden necessários
    const addHiddenField = (name, value) => {
        let field = contactForm.querySelector(`input[name="${name}"]`);
        if (!field) {
            field = document.createElement('input');
            field.type = 'hidden';
            field.name = name;
            contactForm.appendChild(field);
        }
        field.value = value;
    };
    
    addHiddenField('_subject', 'Novo Contato - JurisPilot');
    addHiddenField('_captcha', 'false');
    addHiddenField('_template', 'box');
    addHiddenField('_next', window.location.href + '?success=true');
    
    contactForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        // Validar campos
        const nome = document.getElementById('nome').value.trim();
        const telefone = document.getElementById('telefone').value.trim();
        const email = document.getElementById('email').value.trim();
        const mensagem = document.getElementById('mensagem').value.trim();
        
        if (!nome || !telefone || !email || !mensagem) {
            formMessage.textContent = 'Por favor, preencha todos os campos.';
            formMessage.className = 'form__message error';
            formMessage.style.display = 'block';
            return;
        }
        
        // Validar email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            formMessage.textContent = 'Por favor, insira um email válido.';
            formMessage.className = 'form__message error';
            formMessage.style.display = 'block';
            return;
        }
        
        const submitButton = contactForm.querySelector('button[type="submit"]');
        const buttonText = submitButton.querySelector('.btn__text');
        const buttonLoader = submitButton.querySelector('.btn__loader');
        
        // Mostrar loading
        buttonText.style.display = 'none';
        buttonLoader.style.display = 'inline-block';
        submitButton.disabled = true;
        formMessage.style.display = 'none';
        
        // Criar FormData
        const formData = new FormData(contactForm);
        formData.append('Nome', nome);
        formData.append('Telefone', telefone);
        formData.append('Email', email);
        formData.append('Mensagem', mensagem);
        
        try {
            // Enviar via FormSubmit
            const response = await fetch('https://formsubmit.co/ajax/ispautopilot@gmail.com', {
                method: 'POST',
                body: formData,
                headers: {
                    'Accept': 'application/json'
                }
            });
            
            const result = await response.json();
            
            if (result.success) {
                // Sucesso
                formMessage.textContent = 'Mensagem enviada com sucesso! Entraremos em contato em breve.';
                formMessage.className = 'form__message success';
                formMessage.style.display = 'block';
                contactForm.reset();
                
                // Scroll para mensagem
                formMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            } else {
                throw new Error('Erro ao enviar');
            }
            
        } catch (error) {
            console.error('FormSubmit error:', error);
            
            // Fallback: usar action normal do form (submete a página)
            formMessage.textContent = 'Enviando formulário...';
            formMessage.className = 'form__message success';
            formMessage.style.display = 'block';
            
            // Submeter formulário normalmente (vai redirecionar)
            setTimeout(() => {
                contactForm.submit();
            }, 500);
        } finally {
            // Restaurar botão após delay
            setTimeout(() => {
                buttonText.style.display = 'inline';
                buttonLoader.style.display = 'none';
                submitButton.disabled = false;
            }, 2000);
        }
    });
}

// Formulário do Chat Widget
const chatForm = document.getElementById('chatForm');

if (chatForm) {
    chatForm.action = 'https://formsubmit.co/ispautopilot@gmail.com';
    chatForm.method = 'POST';
    
    chatForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const nome = chatForm.querySelector('input[name="nome"]').value.trim();
        const telefone = chatForm.querySelector('input[name="telefone"]').value.trim();
        const email = chatForm.querySelector('input[name="email"]').value.trim();
        
        if (!nome || !telefone || !email) {
            alert('Por favor, preencha todos os campos.');
            return;
        }
        
        const formData = new FormData();
        formData.append('_subject', 'Contato via Chat Widget - JurisPilot');
        formData.append('_captcha', 'false');
        formData.append('Nome', nome);
        formData.append('Telefone', telefone);
        formData.append('Email', email);
        formData.append('Origem', 'Chat Widget');
        
        try {
            const response = await fetch('https://formsubmit.co/ajax/ispautopilot@gmail.com', {
                method: 'POST',
                body: formData,
                headers: {
                    'Accept': 'application/json'
                }
            });
            
            const result = await response.json();
            
            if (result.success) {
                alert('Mensagem enviada! Entraremos em contato em breve.');
                chatForm.reset();
                toggleChat();
            } else {
                throw new Error('Erro ao enviar');
            }
        } catch (error) {
            console.error('FormSubmit error:', error);
            // Fallback: mailto
            const mailtoLink = `mailto:ispautopilot@gmail.com?subject=Contato JurisPilot (Chat)&body=Nome: ${encodeURIComponent(nome)}%0ATelefone: ${encodeURIComponent(telefone)}%0AEmail: ${encodeURIComponent(email)}`;
            window.location.href = mailtoLink;
        }
    });
}

// Validação em tempo real
function setupFormValidation() {
    const inputs = document.querySelectorAll('input, textarea');
    
    inputs.forEach(input => {
        input.addEventListener('blur', function() {
            validateField(this);
        });
        
        input.addEventListener('input', function() {
            if (this.classList.contains('error')) {
                validateField(this);
            }
        });
    });
}

function validateField(field) {
    const value = field.value.trim();
    let isValid = true;
    let errorMessage = '';
    
    // Remover erros anteriores
    field.classList.remove('error');
    const existingError = field.parentElement.querySelector('.field-error');
    if (existingError) {
        existingError.remove();
    }
    
    // Validações
    if (field.hasAttribute('required') && !value) {
        isValid = false;
        errorMessage = 'Este campo é obrigatório';
    } else if (field.type === 'email' && value) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value)) {
            isValid = false;
            errorMessage = 'Email inválido';
        }
    } else if (field.type === 'tel' && value) {
        const phoneRegex = /^[\d\s\(\)\-\+]+$/;
        if (!phoneRegex.test(value) || value.replace(/\D/g, '').length < 10) {
            isValid = false;
            errorMessage = 'Telefone inválido';
        }
    }
    
    if (!isValid) {
        field.classList.add('error');
        const errorDiv = document.createElement('div');
        errorDiv.className = 'field-error';
        errorDiv.textContent = errorMessage;
        errorDiv.style.color = '#ff3b30';
        errorDiv.style.fontSize = '0.875rem';
        errorDiv.style.marginTop = '0.25rem';
        field.parentElement.appendChild(errorDiv);
    }
    
    return isValid;
}

// Inicializar validação
document.addEventListener('DOMContentLoaded', setupFormValidation);

// Função para abrir formulário de contato
function openContactForm() {
    const contactSection = document.getElementById('contato');
    if (contactSection) {
        const headerHeight = document.getElementById('header').offsetHeight;
        const targetPosition = contactSection.offsetTop - headerHeight;
        window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
        });
        
        // Focar no primeiro campo após scroll
        setTimeout(() => {
            const firstInput = contactSection.querySelector('input');
            if (firstInput) {
                firstInput.focus();
            }
        }, 1000);
    }
}

// Função para toggle do chat
function toggleChat() {
    const chatPanel = document.getElementById('chatPanel');
    const chatMessage = document.getElementById('chatMessage');
    
    if (chatPanel) {
        chatPanel.classList.toggle('active');
        if (chatPanel.classList.contains('active')) {
            chatMessage.style.display = 'none';
        } else {
            setTimeout(() => {
                chatMessage.style.display = 'block';
            }, 300);
        }
    }
}

// Verificar se há parâmetro de sucesso na URL
document.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('success') === 'true') {
        if (formMessage) {
            formMessage.textContent = 'Mensagem enviada com sucesso! Entraremos em contato em breve.';
            formMessage.className = 'form__message success';
            formMessage.style.display = 'block';
            
            // Scroll para mensagem
            setTimeout(() => {
                formMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }, 100);
        }
        
        // Limpar URL
        window.history.replaceState({}, document.title, window.location.pathname);
    }
});

// Adicionar estilos para campos com erro
const style = document.createElement('style');
style.textContent = `
    input.error,
    textarea.error {
        border-color: #ff3b30 !important;
        box-shadow: 0 0 0 3px rgba(255, 59, 48, 0.1) !important;
    }
`;
document.head.appendChild(style);

