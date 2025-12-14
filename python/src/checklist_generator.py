"""
JurisPilot - Gerador de Checklists Dinâmicos
Gera checklists jurídicos baseados no tipo de ação e regras configuradas
"""

from typing import Dict, List, Optional
from loguru import logger
import json


class ChecklistGenerator:
    """Gera checklists jurídicos dinâmicos"""
    
    # Templates de checklists por tipo de ação
    CHECKLIST_TEMPLATES = {
        'gratuidade_justica': {
            'obrigatorios': [
                'IRPF',
                'Contracheque',
                'Extrato bancário (últimos 3 meses)',
                'Carteira de trabalho'
            ],
            'recomendados': [
                'Comprovante de residência',
                'Comprovante de despesas',
                'Atestado médico (se aplicável)'
            ],
            'validacao_automatica': True
        },
        'relacao_consumo': {
            'obrigatorios': [
                'Comprovante de compra',
                'Comprovante de pagamento',
                'Contrato (se houver)',
                'Comunicação com fornecedor'
            ],
            'recomendados': [
                'Nota fiscal',
                'Fotos do produto/serviço',
                'Histórico de comunicação'
            ],
            'validacao_automatica': True
        },
        'acao_companhia_aerea': {
            'obrigatorios': [
                'Comprovante de compra',
                'Comprovante de pagamento',
                'E-mails da companhia',
                'Prints de cancelamento',
                'Protocolos'
            ],
            'recomendados': [
                'Comprovante de bagagem extraviada',
                'Fotos de danos',
                'Comunicação com atendimento'
            ],
            'validacao_automatica': True
        },
        'cobranca_indevida': {
            'obrigatorios': [
                'Faturas',
                'Comprovantes de pagamento',
                'Contrato (se houver)',
                'Histórico de comunicação'
            ],
            'recomendados': [
                'Extrato bancário',
                'Comprovantes de cancelamento',
                'Comunicação prévia'
            ],
            'validacao_automatica': True
        },
        'negativacao_indevida': {
            'obrigatorios': [
                'Consulta SPC/Serasa',
                'Comprovantes de pagamento',
                'Comunicação prévia'
            ],
            'recomendados': [
                'Extrato bancário',
                'Comprovante de quitação',
                'Histórico de relacionamento'
            ],
            'validacao_automatica': True
        },
        'pensao_alimenticia': {
            'obrigatorios': [
                'Certidão de nascimento',
                'Comprovantes de renda',
                'Despesas do menor'
            ],
            'recomendados': [
                'Extrato bancário',
                'Comprovante de despesas escolares',
                'Comprovante de despesas médicas'
            ],
            'validacao_automatica': True
        },
        'divorcio_consensual': {
            'obrigatorios': [
                'Certidão de casamento',
                'CPF de ambos',
                'RG de ambos',
                'Comprovante de residência'
            ],
            'recomendados': [
                'Acordo de divórcio',
                'Comprovante de renda'
            ],
            'validacao_automatica': True
        },
        'divorcio_litigioso': {
            'obrigatorios': [
                'Certidão de casamento',
                'CPF de ambos',
                'RG de ambos',
                'Comprovante de residência',
                'Comprovantes de renda',
                'Documentos de bens',
                'Documentos de dívidas'
            ],
            'recomendados': [
                'Extrato bancário',
                'Comprovante de imóveis',
                'Comprovante de veículos'
            ],
            'validacao_automatica': True
        },
        'guarda': {
            'obrigatorios': [
                'Certidão de nascimento',
                'Provas de vínculo',
                'Histórico escolar'
            ],
            'recomendados': [
                'Relatórios médicos',
                'Fotos',
                'Comprovante de residência'
            ],
            'validacao_automatica': True
        },
        'rescisao_indireta': {
            'obrigatorios': [
                'Contrato de trabalho',
                'Holerites',
                'Extrato FGTS',
                'Provas da falta grave'
            ],
            'recomendados': [
                'Comunicação com empresa',
                'Testemunhas',
                'Comprovantes de irregularidades'
            ],
            'validacao_automatica': True
        },
        'horas_extras': {
            'obrigatorios': [
                'Cartões de ponto',
                'Contracheques',
                'Escalas'
            ],
            'recomendados': [
                'Contrato de trabalho',
                'Comunicação sobre horas extras',
                'Comprovantes de pagamento'
            ],
            'validacao_automatica': True
        },
        'descumprimento_contratual': {
            'obrigatorios': [
                'Contrato',
                'Aditivos',
                'Provas de descumprimento',
                'Comunicações'
            ],
            'recomendados': [
                'Notas fiscais',
                'Comprovantes de pagamento',
                'Correspondências'
            ],
            'validacao_automatica': True
        },
        'cobranca_empresarial': {
            'obrigatorios': [
                'Notas fiscais',
                'Boletos',
                'Comprovantes'
            ],
            'recomendados': [
                'Contrato',
                'Histórico de relacionamento',
                'Comunicações'
            ],
            'validacao_automatica': True
        }
    }
    
    def __init__(self):
        """Inicializa o gerador de checklists"""
        logger.info("ChecklistGenerator inicializado")
    
    def generate_checklist(self, tipo_acao: str, variacoes: Optional[Dict] = None) -> Dict:
        """
        Gera checklist baseado no tipo de ação
        
        Args:
            tipo_acao: Tipo de ação jurídica
            variacoes: Variações específicas (ex: divórcio consensual vs litigioso)
            
        Returns:
            Dict com checklist completo
        """
        tipo_normalizado = self._normalize_action_type(tipo_acao)
        
        logger.info(f"Gerando checklist para: {tipo_acao} (normalizado: {tipo_normalizado})")
        
        # Busca template
        template = self.CHECKLIST_TEMPLATES.get(tipo_normalizado)
        
        if not template:
            # Gera checklist genérico se não encontrar template específico
            logger.warning(f"Template não encontrado para {tipo_normalizado}, usando genérico")
            template = self._generate_generic_checklist(tipo_acao)
        
        # Aplica variações se fornecidas
        if variacoes:
            template = self._apply_variations(template, variacoes)
        
        checklist = {
            'tipo_acao': tipo_acao,
            'tipo_normalizado': tipo_normalizado,
            'documentos_obrigatorios': template['obrigatorios'],
            'documentos_recomendados': template.get('recomendados', []),
            'validacao_automatica': template.get('validacao_automatica', True),
            'total_obrigatorios': len(template['obrigatorios']),
            'total_recomendados': len(template.get('recomendados', []))
        }
        
        return checklist
    
    def _normalize_action_type(self, tipo_acao: str) -> str:
        """Normaliza tipo de ação para buscar template"""
        tipo_lower = tipo_acao.lower()
        
        # Mapeamento de tipos para templates
        mappings = {
            'gratuidade': 'gratuidade_justica',
            'gratuidade de justiça': 'gratuidade_justica',
            'consumidor': 'relacao_consumo',
            'relação de consumo': 'relacao_consumo',
            'companhia aérea': 'acao_companhia_aerea',
            'aérea': 'acao_companhia_aerea',
            'cobrança indevida': 'cobranca_indevida',
            'cobranca indevida': 'cobranca_indevida',
            'negativação': 'negativacao_indevida',
            'negativacao': 'negativacao_indevida',
            'pensão': 'pensao_alimenticia',
            'pensao': 'pensao_alimenticia',
            'alimentícia': 'pensao_alimenticia',
            'alimenticia': 'pensao_alimenticia',
            'divórcio': 'divorcio_litigioso',  # Default para litigioso
            'divorcio': 'divorcio_litigioso',
            'guarda': 'guarda',
            'rescisão': 'rescisao_indireta',
            'rescisao': 'rescisao_indireta',
            'horas extras': 'horas_extras',
            'horas extra': 'horas_extras',
            'descumprimento': 'descumprimento_contratual',
            'contratual': 'descumprimento_contratual',
            'cobrança empresarial': 'cobranca_empresarial',
            'cobranca empresarial': 'cobranca_empresarial'
        }
        
        for key, value in mappings.items():
            if key in tipo_lower:
                return value
        
        return tipo_lower.replace(' ', '_').replace('ç', 'c').replace('ã', 'a')
    
    def _generate_generic_checklist(self, tipo_acao: str) -> Dict:
        """Gera checklist genérico quando não há template específico"""
        return {
            'obrigatorios': [
                'CPF/CNPJ',
                'RG',
                'Comprovante de residência',
                'Documentos relacionados ao caso'
            ],
            'recomendados': [
                'Comprovantes de pagamento',
                'Comunicações',
                'Contratos relacionados'
            ],
            'validacao_automatica': True
        }
    
    def _apply_variations(self, template: Dict, variacoes: Dict) -> Dict:
        """Aplica variações ao template"""
        result = template.copy()
        
        # Se for divórcio consensual, usa template específico
        if variacoes.get('consensual'):
            if 'divorcio' in template.get('tipo', '').lower():
                consensual_template = self.CHECKLIST_TEMPLATES.get('divorcio_consensual')
                if consensual_template:
                    result = consensual_template.copy()
        
        # Adiciona documentos extras se especificado
        if variacoes.get('documentos_extras'):
            result['recomendados'].extend(variacoes['documentos_extras'])
        
        return result
    
    def validate_checklist_completeness(self, checklist: Dict, documentos_recebidos: List[Dict]) -> Dict:
        """
        Valida se o checklist está completo
        
        Args:
            checklist: Checklist gerado
            documentos_recebidos: Lista de documentos já recebidos
            
        Returns:
            Dict com status de validação
        """
        documentos_obrigatorios = checklist.get('documentos_obrigatorios', [])
        documentos_recomendados = checklist.get('documentos_recomendados', [])
        
        # Mapeia documentos recebidos por tipo
        tipos_recebidos = [doc.get('tipo_documento', '').lower() for doc in documentos_recebidos]
        
        # Verifica obrigatórios
        obrigatorios_faltantes = []
        obrigatorios_presentes = []
        
        for doc_obrigatorio in documentos_obrigatorios:
            doc_lower = doc_obrigatorio.lower()
            encontrado = any(doc_lower in tipo_recebido or tipo_recebido in doc_lower 
                           for tipo_recebido in tipos_recebidos)
            
            if encontrado:
                obrigatorios_presentes.append(doc_obrigatorio)
            else:
                obrigatorios_faltantes.append(doc_obrigatorio)
        
        # Verifica recomendados
        recomendados_presentes = []
        for doc_recomendado in documentos_recomendados:
            doc_lower = doc_recomendado.lower()
            encontrado = any(doc_lower in tipo_recebido or tipo_recebido in doc_lower 
                           for tipo_recebido in tipos_recebidos)
            if encontrado:
                recomendados_presentes.append(doc_recomendado)
        
        # Calcula percentual de completude
        total_obrigatorios = len(documentos_obrigatorios)
        presentes_obrigatorios = len(obrigatorios_presentes)
        percentual = (presentes_obrigatorios / total_obrigatorios * 100) if total_obrigatorios > 0 else 0
        
        # Determina status
        if percentual == 100:
            status = 'completo'
        elif percentual >= 70:
            status = 'quase_completo'
        elif percentual >= 50:
            status = 'incompleto'
        else:
            status = 'muito_incompleto'
        
        return {
            'status': status,
            'percentual_completude': round(percentual, 2),
            'obrigatorios_presentes': obrigatorios_presentes,
            'obrigatorios_faltantes': obrigatorios_faltantes,
            'recomendados_presentes': recomendados_presentes,
            'total_obrigatorios': total_obrigatorios,
            'total_presentes': presentes_obrigatorios,
            'total_faltantes': len(obrigatorios_faltantes),
            'is_completo': status == 'completo'
        }
    
    def suggest_additional_documents(self, checklist: Dict, documentos_recebidos: List[Dict], 
                                    tipo_acao: str) -> List[str]:
        """Sugere documentos adicionais baseado no caso"""
        sugestoes = []
        
        # Lógica de sugestão baseada no tipo de ação
        tipos_recebidos = [doc.get('tipo_documento', '').lower() for doc in documentos_recebidos]
        
        if 'trabalhista' in tipo_acao.lower():
            if 'contrato' not in ' '.join(tipos_recebidos):
                sugestoes.append('Contrato de trabalho')
            if 'holerite' not in ' '.join(tipos_recebidos):
                sugestoes.append('Holerites dos últimos 12 meses')
        
        if 'consumidor' in tipo_acao.lower():
            if 'nota' not in ' '.join(tipos_recebidos):
                sugestoes.append('Nota fiscal')
            if 'email' not in ' '.join(tipos_recebidos):
                sugestoes.append('E-mails de comunicação')
        
        return sugestoes


if __name__ == "__main__":
    # Exemplo de uso
    generator = ChecklistGenerator()
    
    checklist = generator.generate_checklist('Gratuidade de Justiça')
    print(json.dumps(checklist, indent=2, ensure_ascii=False))
    
    # Validação
    documentos_exemplo = [
        {'tipo_documento': 'irpf'},
        {'tipo_documento': 'contracheque'}
    ]
    
    validacao = generator.validate_checklist_completeness(checklist, documentos_exemplo)
    print(f"\nValidação: {validacao['status']} - {validacao['percentual_completude']}%")

