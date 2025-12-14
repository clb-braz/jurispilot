"""
JurisPilot - Classificador de Provas
Classifica documentos como provas jurídicas e atribui relevância
"""

from typing import Dict, List, Optional
from enum import Enum
from loguru import logger


class TipoProva(Enum):
    """Tipos de provas jurídicas"""
    DOCUMENTO_OFICIAL = "documento_oficial"
    CONVERSA = "conversa"
    COMPROVANTE_FINANCEIRO = "comprovante_financeiro"
    PROVA_TECNICA = "prova_tecnica"
    OUTRO = "outro"


class ProofClassifier:
    """Classifica documentos como provas jurídicas"""
    
    # Documentos oficiais
    DOCUMENTOS_OFICIAIS = [
        'cpf', 'cnpj', 'rg', 'certidao', 'contrato', 'irpf',
        'carteira_trabalho', 'atestado', 'laudo', 'decisao',
        'sentenca', 'peticao', 'intimacao'
    ]
    
    # Comprovantes financeiros
    COMPROVANTES_FINANCEIROS = [
        'holerite', 'extrato_bancario', 'nota_fiscal', 'boleto',
        'comprovante', 'recibo', 'fatura', 'conta'
    ]
    
    # Conversas/comunicações
    CONVERSAS = [
        'email', 'whatsapp', 'mensagem', 'chat', 'correspondencia',
        'carta', 'oficio', 'comunicacao'
    ]
    
    # Provas técnicas
    PROVAS_TECNICAS = [
        'laudo', 'pericia', 'exame', 'analise', 'relatorio_tecnico',
        'vistoria', 'inspecao'
    ]
    
    def __init__(self):
        """Inicializa o classificador de provas"""
        logger.info("ProofClassifier inicializado")
    
    def classify(self, documento_info: Dict) -> Dict:
        """
        Classifica um documento como tipo de prova
        
        Args:
            documento_info: Dict com informações do documento (tipo_documento, texto_extraido, etc)
            
        Returns:
            Dict com classificação e relevância
        """
        tipo_documento = documento_info.get('tipo_documento', '').lower()
        texto = documento_info.get('texto_extraido', '').lower()
        
        # Determina tipo de prova
        tipo_prova = self._determine_proof_type(tipo_documento, texto)
        
        # Calcula relevância (1-10)
        relevancia = self._calculate_relevance(tipo_documento, tipo_prova, texto, documento_info)
        
        # Determina se é prova essencial
        is_essencial = self._is_essential_proof(tipo_documento, tipo_prova)
        
        result = {
            'classificacao_prova': tipo_prova.value,
            'relevancia': relevancia,
            'is_essencial': is_essencial,
            'justificativa': self._generate_justification(tipo_prova, relevancia, is_essencial)
        }
        
        logger.info(f"Documento classificado: {tipo_prova.value} - Relevância: {relevancia}/10")
        
        return result
    
    def _determine_proof_type(self, tipo_documento: str, texto: str) -> TipoProva:
        """Determina o tipo de prova baseado no documento"""
        tipo_lower = tipo_documento.lower()
        
        # Verifica documentos oficiais
        if any(doc in tipo_lower for doc in self.DOCUMENTOS_OFICIAIS):
            return TipoProva.DOCUMENTO_OFICIAL
        
        # Verifica comprovantes financeiros
        if any(comp in tipo_lower for comp in self.COMPROVANTES_FINANCEIROS):
            return TipoProva.COMPROVANTE_FINANCEIRO
        
        # Verifica conversas
        if any(conv in tipo_lower for conv in self.CONVERSAS):
            return TipoProva.CONVERSA
        
        # Verifica provas técnicas
        if any(tec in tipo_lower or tec in texto for tec in self.PROVAS_TECNICAS):
            return TipoProva.PROVA_TECNICA
        
        return TipoProva.OUTRO
    
    def _calculate_relevance(self, tipo_documento: str, tipo_prova: TipoProva, 
                            texto: str, documento_info: Dict) -> int:
        """
        Calcula relevância da prova (1-10)
        
        Critérios:
        - Documentos oficiais: alta relevância (7-10)
        - Comprovantes financeiros: média-alta (6-9)
        - Conversas: média (4-7)
        - Provas técnicas: alta (8-10)
        - Outros: baixa-média (3-6)
        """
        relevancia = 5  # Base
        
        # Ajusta baseado no tipo de prova
        if tipo_prova == TipoProva.DOCUMENTO_OFICIAL:
            relevancia = 8
            # Documentos de identidade são críticos
            if any(doc in tipo_documento for doc in ['cpf', 'cnpj', 'rg', 'certidao']):
                relevancia = 10
        elif tipo_prova == TipoProva.COMPROVANTE_FINANCEIRO:
            relevancia = 7
            # Extratos e holerites são mais relevantes
            if any(doc in tipo_documento for doc in ['extrato', 'holerite', 'irpf']):
                relevancia = 9
        elif tipo_prova == TipoProva.PROVA_TECNICA:
            relevancia = 9
        elif tipo_prova == TipoProva.CONVERSA:
            relevancia = 5
            # Emails oficiais são mais relevantes
            if 'oficio' in texto or 'oficial' in texto:
                relevancia = 7
        else:
            relevancia = 4
        
        # Ajusta baseado em metadados
        if documento_info.get('validado'):
            relevancia = min(10, relevancia + 1)
        
        # Verifica se contém informações importantes
        if documento_info.get('metadados', {}).get('tem_cpf') or \
           documento_info.get('metadados', {}).get('tem_cnpj'):
            relevancia = min(10, relevancia + 1)
        
        return max(1, min(10, relevancia))  # Garante entre 1 e 10
    
    def _is_essential_proof(self, tipo_documento: str, tipo_prova: TipoProva) -> bool:
        """Determina se a prova é essencial para o caso"""
        provas_essenciais = [
            'cpf', 'cnpj', 'rg', 'certidao', 'contrato', 'holerite',
            'extrato_bancario', 'irpf', 'carteira_trabalho'
        ]
        
        if any(prova in tipo_documento.lower() for prova in provas_essenciais):
            return True
        
        if tipo_prova == TipoProva.DOCUMENTO_OFICIAL:
            return True
        
        return False
    
    def _generate_justification(self, tipo_prova: TipoProva, relevancia: int, 
                               is_essencial: bool) -> str:
        """Gera justificativa para a classificação"""
        justificativas = {
            TipoProva.DOCUMENTO_OFICIAL: "Documento oficial com alto valor probatório",
            TipoProva.COMPROVANTE_FINANCEIRO: "Comprovante financeiro relevante para o caso",
            TipoProva.CONVERSA: "Comunicação que pode servir como prova",
            TipoProva.PROVA_TECNICA: "Prova técnica com alto valor probatório",
            TipoProva.OUTRO: "Documento genérico"
        }
        
        base = justificativas.get(tipo_prova, "Documento classificado")
        
        if is_essencial:
            base += " - Prova essencial para o caso"
        
        if relevancia >= 8:
            base += " - Alta relevância"
        elif relevancia >= 6:
            base += " - Média-alta relevância"
        else:
            base += " - Relevância moderada"
        
        return base
    
    def classify_batch(self, documentos: List[Dict]) -> List[Dict]:
        """Classifica múltiplos documentos"""
        results = []
        for doc in documentos:
            classification = self.classify(doc)
            doc.update(classification)
            results.append(doc)
        return results


if __name__ == "__main__":
    # Exemplo de uso
    classifier = ProofClassifier()
    
    exemplo_doc = {
        'tipo_documento': 'cpf',
        'texto_extraido': 'CPF: 123.456.789-00',
        'validado': True,
        'metadados': {'tem_cpf': True}
    }
    
    resultado = classifier.classify(exemplo_doc)
    print(f"Classificação: {resultado}")

