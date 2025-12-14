// JavaScript Principal - JurisPilot

// Mobile Menu Toggle
document.addEventListener('DOMContentLoaded', () => {
    const mobileToggle = document.getElementById('mobileToggle');
    const navMenu = document.querySelector('.nav__menu');
    
    if (mobileToggle && navMenu) {
        mobileToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');
            mobileToggle.classList.toggle('active');
        });
    }
    
    // Fechar menu ao clicar em link
    const navLinks = document.querySelectorAll('.nav__menu a');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            navMenu.classList.remove('active');
            mobileToggle.classList.remove('active');
        });
    });
});

// Parallax effect leve no hero
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const heroBackground = document.querySelector('.hero__background');
    if (heroBackground) {
        heroBackground.style.transform = `translateY(${scrolled * 0.5}px)`;
    }
});

// Lazy loading de imagens (se houver)
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                    observer.unobserve(img);
                }
            }
        });
    });
    
    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// Prevenir envio duplo de formulários
const forms = document.querySelectorAll('form');
forms.forEach(form => {
    let isSubmitting = false;
    
    form.addEventListener('submit', function(e) {
        if (isSubmitting) {
            e.preventDefault();
            return false;
        }
        
        isSubmitting = true;
        const submitButton = form.querySelector('button[type="submit"]');
        if (submitButton) {
            submitButton.disabled = true;
        }
        
        // Reabilitar após 3 segundos (caso de erro)
        setTimeout(() => {
            isSubmitting = false;
            if (submitButton) {
                submitButton.disabled = false;
            }
        }, 3000);
    });
});

// Adicionar classe ao body quando JS está ativo
document.body.classList.add('js-enabled');

// Console message
console.log('%cJurisPilot', 'font-size: 24px; font-weight: bold; color: #9b59b6;');
console.log('%cAutomação Jurídica Operacional', 'font-size: 14px; color: #86868b;');
