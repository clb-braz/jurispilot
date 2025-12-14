// Animações ao Scroll - JurisPilot

// Intersection Observer para animações
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
}, observerOptions);

// Observar todos os elementos com scroll-fade-in
document.addEventListener('DOMContentLoaded', () => {
    const elements = document.querySelectorAll('.scroll-fade-in');
    elements.forEach(el => observer.observe(el));
});

// Header scroll effect
let lastScroll = 0;
const header = document.getElementById('header');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;
    
    if (currentScroll > 100) {
        header.classList.add('scrolled');
    } else {
        header.classList.remove('scrolled');
    }
    
    lastScroll = currentScroll;
});

// Counter Animation para Métricas
function animateCounter(element) {
    const target = parseInt(element.getAttribute('data-target'));
    const duration = 2000;
    const increment = target / (duration / 16);
    let current = 0;
    
    const updateCounter = () => {
        current += increment;
        if (current < target) {
            element.textContent = Math.floor(current) + '%';
            requestAnimationFrame(updateCounter);
        } else {
            element.textContent = target + '%';
        }
    };
    
    updateCounter();
}

// Observar métricas
const metricObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const valueElement = entry.target.querySelector('.metric__value');
            if (valueElement && !valueElement.classList.contains('animated')) {
                valueElement.classList.add('animated');
                animateCounter(valueElement);
            }
        }
    });
}, { threshold: 0.5 });

document.addEventListener('DOMContentLoaded', () => {
    const metricCards = document.querySelectorAll('.metric__card');
    metricCards.forEach(card => metricObserver.observe(card));
});

// Process Tabs
document.addEventListener('DOMContentLoaded', () => {
    const tabs = document.querySelectorAll('.process__tab');
    const steps = document.querySelectorAll('.process__step');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const stepNumber = tab.getAttribute('data-step');
            
            // Remove active de todos
            tabs.forEach(t => t.classList.remove('active'));
            steps.forEach(s => s.classList.remove('active'));
            
            // Adiciona active no selecionado
            tab.classList.add('active');
            const targetStep = document.querySelector(`.process__step[data-step="${stepNumber}"]`);
            if (targetStep) {
                targetStep.classList.add('active');
            }
        });
    });
});

// FAQ Accordion
document.addEventListener('DOMContentLoaded', () => {
    const faqItems = document.querySelectorAll('.faq__item');
    
    faqItems.forEach(item => {
        const question = item.querySelector('.faq__question');
        question.addEventListener('click', () => {
            const isActive = item.classList.contains('active');
            
            // Fecha todos
            faqItems.forEach(i => i.classList.remove('active'));
            
            // Abre o clicado se não estava ativo
            if (!isActive) {
                item.classList.add('active');
            }
        });
    });
});

// Smooth Scroll
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const headerHeight = document.getElementById('header').offsetHeight;
            const targetPosition = target.offsetTop - headerHeight;
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

