"""
JurisPilot - Extrator de Prazos
Extrai e identifica prazos processuais e administrativos de documentos
"""

from typing import Dict, List, Optional
from datetime import datetime, timedelta
import re
import dateparser
from loguru import logger


class DeadlineExtractor:
    """Extrai prazos de documentos jurídicos"""
    
    # Padrões de prazos processuais comuns (em dias)
    PRAZOS_PROCESSUAIS = {
        'contestação': 15,
        'recurso': 15,
        'agravo': 15,
        'embargos': 15,
        'apelação': 15,
        'resposta': 15,
        'manifestação': 5,
        'impugnação': 5,
        'intimação': 3,
        'citação': 15,
        'sentença': 30,
        'recurso especial': 15,
        'recurso extraordinário': 15
    }
    
    # Palavras-chave que indicam prazos
    PRAZO_KEYWORDS = [
        'prazo', 'vencimento', 'vencer', 'expirar', 'expiração',
        'limite', 'até', 'dentro de', 'no prazo de', 'no período de',
        'deadline', 'due date', 'data limite'
    ]
    
    def __init__(self):
        """Inicializa o extrator de prazos"""
        logger.info("DeadlineExtractor inicializado")
    
    def extract_deadlines(self, documento_info: Dict, tipo_acao: Optional[str] = None) -> List[Dict]:
        """
        Extrai prazos de um documento
        
        Args:
            documento_info: Informações do documento (texto_extraido, data_documento, etc)
            tipo_acao: Tipo de ação jurídica (opcional)
            
        Returns:
            Lista de prazos encontrados
        """
        texto = documento_info.get('texto_extraido', '')
        data_documento = documento_info.get('data_documento')
        
        if not texto:
            return []
        
        logger.info(f"Extraindo prazos do documento: {documento_info.get('nome_arquivo', 'N/A')}")
        
        prazos = []
        
        # Extrai prazos explícitos (datas de vencimento)
        prazos.extend(self._extract_explicit_deadlines(texto, data_documento))
        
        # Extrai prazos processuais (texto como "15 dias")
        prazos.extend(self._extract_procedural_deadlines(texto, data_documento, tipo_acao))
        
        # Extrai prazos por palavras-chave
        prazos.extend(self._extract_keyword_deadlines(texto, data_documento))
        
        # Remove duplicatas e valida
        prazos = self._deduplicate_and_validate(prazos)
        
        logger.info(f"Encontrados {len(prazos)} prazo(s)")
        
        return prazos
    
    def _extract_explicit_deadlines(self, texto: str, data_base: Optional[str]) -> List[Dict]:
        """Extrai prazos explícitos (datas de vencimento)"""
        prazos = []
        
        # Padrões de data
        date_patterns = [
            r'vencimento[:\s]+(\d{2}/\d{2}/\d{4})',
            r'vencer[áa]\s+em[:\s]+(\d{2}/\d{2}/\d{4})',
            r'prazo[:\s]+até[:\s]+(\d{2}/\d{2}/\d{4})',
            r'data\s+limite[:\s]+(\d{2}/\d{2}/\d{4})',
            r'até\s+o\s+dia[:\s]+(\d{2}/\d{2}/\d{4})',
            r'(\d{2}/\d{2}/\d{4})\s+é\s+o\s+prazo',
        ]
        
        for pattern in date_patterns:
            matches = re.finditer(pattern, texto, re.IGNORECASE)
            for match in matches:
                data_str = match.group(1)
                try:
                    parsed_date = dateparser.parse(data_str, languages=['pt'], date_formats=['%d/%m/%Y'])
                    if parsed_date:
                        prazos.append({
                            'tipo_prazo': 'processual',
                            'data_vencimento': parsed_date.strftime('%Y-%m-%d'),
                            'descricao': f"Prazo identificado: {data_str}",
                            'origem': 'data_explicita',
                            'confianca': 'alta'
                        })
                except Exception as e:
                    logger.debug(f"Erro ao parsear data: {e}")
        
        return prazos
    
    def _extract_procedural_deadlines(self, texto: str, data_base: Optional[str], 
                                     tipo_acao: Optional[str]) -> List[Dict]:
        """Extrai prazos processuais (ex: "15 dias para contestação")"""
        prazos = []
        
        # Padrão: número + dias + tipo de prazo
        pattern = r'(\d+)\s+dias?\s+(?:para|de|para o|para a)?\s*([a-záàâãéêíóôõúç\s]+)'
        matches = re.finditer(pattern, texto, re.IGNORECASE)
        
        for match in matches:
            dias = int(match.group(1))
            tipo_texto = match.group(2).strip().lower()
            
            # Identifica tipo de prazo
            tipo_prazo = self._identify_deadline_type(tipo_texto)
            
            # Calcula data de vencimento
            if data_base:
                try:
                    base_date = datetime.strptime(data_base, '%Y-%m-%d')
                    vencimento = base_date + timedelta(days=dias)
                    
                    prazos.append({
                        'tipo_prazo': tipo_prazo,
                        'data_vencimento': vencimento.strftime('%Y-%m-%d'),
                        'descricao': f"{dias} dias para {tipo_texto}",
                        'origem': 'prazo_processual',
                        'dias': dias,
                        'confianca': 'media'
                    })
                except Exception as e:
                    logger.debug(f"Erro ao calcular vencimento: {e}")
            else:
                # Se não tem data base, usa data atual
                vencimento = datetime.now() + timedelta(days=dias)
                prazos.append({
                    'tipo_prazo': tipo_prazo,
                    'data_vencimento': vencimento.strftime('%Y-%m-%d'),
                    'descricao': f"{dias} dias para {tipo_texto} (a partir de hoje)",
                    'origem': 'prazo_processual',
                    'dias': dias,
                    'confianca': 'baixa'
                })
        
        # Verifica prazos conhecidos no texto
        for prazo_nome, dias_padrao in self.PRAZOS_PROCESSUAIS.items():
            if prazo_nome in texto.lower():
                if data_base:
                    try:
                        base_date = datetime.strptime(data_base, '%Y-%m-%d')
                        vencimento = base_date + timedelta(days=dias_padrao)
                        
                        prazos.append({
                            'tipo_prazo': 'processual',
                            'data_vencimento': vencimento.strftime('%Y-%m-%d'),
                            'descricao': f"Prazo padrão para {prazo_nome}: {dias_padrao} dias",
                            'origem': 'prazo_padrao',
                            'dias': dias_padrao,
                            'confianca': 'alta'
                        })
                    except Exception as e:
                        logger.debug(f"Erro ao calcular prazo padrão: {e}")
        
        return prazos
    
    def _extract_keyword_deadlines(self, texto: str, data_base: Optional[str]) -> List[Dict]:
        """Extrai prazos usando palavras-chave"""
        prazos = []
        
        for keyword in self.PRAZO_KEYWORDS:
            # Procura por padrões próximos à palavra-chave
            pattern = rf'{keyword}[:\s]+([^\.\n]+)'
            matches = re.finditer(pattern, texto, re.IGNORECASE)
            
            for match in matches:
                contexto = match.group(1).strip()
                
                # Tenta extrair data do contexto
                data_match = re.search(r'(\d{2}/\d{2}/\d{4})', contexto)
                if data_match:
                    try:
                        parsed_date = dateparser.parse(data_match.group(1), languages=['pt'])
                        if parsed_date:
                            prazos.append({
                                'tipo_prazo': 'processual',
                                'data_vencimento': parsed_date.strftime('%Y-%m-%d'),
                                'descricao': f"Prazo encontrado: {contexto[:100]}",
                                'origem': 'palavra_chave',
                                'confianca': 'media'
                            })
                    except Exception as e:
                        logger.debug(f"Erro ao parsear data do contexto: {e}")
        
        return prazos
    
    def _identify_deadline_type(self, texto: str) -> str:
        """Identifica o tipo de prazo baseado no texto"""
        texto_lower = texto.lower()
        
        if any(palavra in texto_lower for palavra in ['contestação', 'contestar', 'resposta']):
            return 'processual'
        elif any(palavra in texto_lower for palavra in ['recurso', 'apelação', 'agravo']):
            return 'processual'
        elif any(palavra in texto_lower for palavra in ['intimação', 'citação', 'notificação']):
            return 'processual'
        elif any(palavra in texto_lower for palavra in ['pagamento', 'vencimento', 'fatura']):
            return 'contratual'
        else:
            return 'administrativo'
    
    def _deduplicate_and_validate(self, prazos: List[Dict]) -> List[Dict]:
        """Remove duplicatas e valida prazos"""
        if not prazos:
            return []
        
        # Remove duplicatas por data de vencimento
        seen_dates = set()
        unique_prazos = []
        
        for prazo in prazos:
            data_venc = prazo.get('data_vencimento')
            if data_venc and data_venc not in seen_dates:
                seen_dates.add(data_venc)
                unique_prazos.append(prazo)
            elif not data_venc:
                # Mantém prazos sem data se não houver duplicata
                unique_prazos.append(prazo)
        
        # Ordena por data de vencimento
        unique_prazos.sort(key=lambda x: x.get('data_vencimento', '9999-12-31'))
        
        # Valida prazos (remove datas no passado muito distante ou futuro irreal)
        valid_prazos = []
        hoje = datetime.now()
        
        for prazo in unique_prazos:
            data_venc = prazo.get('data_vencimento')
            if data_venc:
                try:
                    venc_date = datetime.strptime(data_venc, '%Y-%m-%d')
                    # Aceita prazos até 10 anos no futuro
                    if (venc_date - hoje).days <= 3650:
                        valid_prazos.append(prazo)
                except:
                    pass
            else:
                valid_prazos.append(prazo)
        
        return valid_prazos
    
    def calculate_reminder_date(self, data_vencimento: str, dias_antes: int = 3) -> str:
        """Calcula data de lembrete (X dias antes do vencimento)"""
        try:
            venc_date = datetime.strptime(data_vencimento, '%Y-%m-%d')
            lembrete = venc_date - timedelta(days=dias_antes)
            return lembrete.strftime('%Y-%m-%d')
        except Exception as e:
            logger.error(f"Erro ao calcular data de lembrete: {e}")
            return data_vencimento
    
    def is_critical_deadline(self, prazo: Dict) -> bool:
        """Determina se um prazo é crítico (próximo do vencimento)"""
        data_venc = prazo.get('data_vencimento')
        if not data_venc:
            return False
        
        try:
            venc_date = datetime.strptime(data_venc, '%Y-%m-%d')
            dias_restantes = (venc_date - datetime.now()).days
            return 0 <= dias_restantes <= 3  # Crítico se vence em até 3 dias
        except:
            return False


if __name__ == "__main__":
    # Exemplo de uso
    extractor = DeadlineExtractor()
    
    doc_exemplo = {
        'nome_arquivo': 'intimacao.pdf',
        'texto_extraido': 'Você tem 15 dias para apresentar contestação. Prazo até 25/12/2024.',
        'data_documento': '2024-12-10'
    }
    
    prazos = extractor.extract_deadlines(doc_exemplo, 'Cível')
    for prazo in prazos:
        print(f"Prazo: {prazo}")

