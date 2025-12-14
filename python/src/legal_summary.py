"""
JurisPilot - Gerador de Resumo Jurídico
Gera resumos estruturados de casos jurídicos baseado nos documentos
"""

from typing import Dict, List, Optional
from datetime import datetime
from loguru import logger
import json


class LegalSummaryGenerator:
    """Gera resumos jurídicos estruturados de casos"""
    
    def __init__(self):
        """Inicializa o gerador de resumos"""
        logger.info("LegalSummaryGenerator inicializado")
    
    def generate_summary(self, caso_info: Dict, documentos: List[Dict]) -> Dict:
        """
        Gera resumo jurídico completo do caso
        
        Args:
            caso_info: Informações do caso (tipo_acao, descricao, etc)
            documentos: Lista de documentos processados do caso
            
        Returns:
            Dict com resumo estruturado
        """
        logger.info(f"Gerando resumo jurídico para caso: {caso_info.get('id')}")
        
        # Análise dos documentos
        analise_documentos = self._analyze_documents(documentos)
        
        # Identificação de pontos-chave
        pontos_chave = self._extract_key_points(caso_info, documentos, analise_documentos)
        
        # Identificação de pontos fortes e fracos
        pontos_fortes = self._identify_strengths(documentos, analise_documentos)
        pontos_fracos = self._identify_weaknesses(caso_info, documentos, analise_documentos)
        
        # Alertas sobre provas faltantes
        alertas = self._generate_alerts(caso_info, documentos, analise_documentos)
        
        # Gera resumo textual
        resumo_texto = self._generate_text_summary(
            caso_info, pontos_chave, pontos_fortes, pontos_fracos, alertas
        )
        
        result = {
            'resumo_texto': resumo_texto,
            'pontos_chave': pontos_chave,
            'pontos_fortes': pontos_fortes,
            'pontos_fracos': pontos_fracos,
            'alertas': alertas,
            'estatisticas': {
                'total_documentos': len(documentos),
                'documentos_validados': sum(1 for d in documentos if d.get('validado')),
                'provas_essenciais': sum(1 for d in documentos if d.get('is_essencial')),
                'relevancia_media': self._calculate_avg_relevance(documentos)
            },
            'gerado_em': datetime.now().isoformat()
        }
        
        logger.info("Resumo jurídico gerado com sucesso")
        
        return result
    
    def _analyze_documents(self, documentos: List[Dict]) -> Dict:
        """Analisa conjunto de documentos"""
        analise = {
            'tipos_documentos': {},
            'classificacoes': {},
            'datas_encontradas': [],
            'valores_totais': [],
            'partes_identificadas': []
        }
        
        for doc in documentos:
            # Conta tipos de documentos
            tipo = doc.get('tipo_documento', 'desconhecido')
            analise['tipos_documentos'][tipo] = analise['tipos_documentos'].get(tipo, 0) + 1
            
            # Conta classificações
            classificacao = doc.get('classificacao_prova', 'nao_classificado')
            analise['classificacoes'][classificacao] = analise['classificacoes'].get(classificacao, 0) + 1
            
            # Coleta datas
            if doc.get('data_documento'):
                analise['datas_encontradas'].append(doc['data_documento'])
            
            # Coleta valores
            valores = doc.get('valores_encontrados', [])
            analise['valores_totais'].extend(valores)
        
        return analise
    
    def _extract_key_points(self, caso_info: Dict, documentos: List[Dict], 
                           analise: Dict) -> List[str]:
        """Extrai pontos-chave do caso"""
        pontos = []
        
        tipo_acao = caso_info.get('tipo_acao', '').lower()
        
        # Pontos baseados no tipo de ação
        if 'gratuidade' in tipo_acao:
            pontos.append("Caso de gratuidade de justiça - requer comprovação de hipossuficiência")
            if analise['tipos_documentos'].get('irpf') or analise['tipos_documentos'].get('extrato_bancario'):
                pontos.append("Documentos de renda presentes")
            else:
                pontos.append("ATENÇÃO: Documentos de renda podem estar faltando")
        
        elif 'pensao' in tipo_acao or 'alimenticia' in tipo_acao:
            pontos.append("Caso de pensão alimentícia - requer comprovação de renda e despesas")
            if analise['valores_totais']:
                pontos.append(f"Valores identificados nos documentos: R$ {sum(analise['valores_totais']):,.2f}")
        
        elif 'trabalhista' in tipo_acao or 'rescisao' in tipo_acao:
            pontos.append("Caso trabalhista - requer documentação de vínculo empregatício")
            if analise['tipos_documentos'].get('holerite') or analise['tipos_documentos'].get('contrato'):
                pontos.append("Documentação trabalhista presente")
        
        elif 'consumidor' in tipo_acao or 'consumo' in tipo_acao:
            pontos.append("Caso de direito do consumidor - requer comprovação de relação de consumo")
        
        # Pontos baseados em documentos
        if analise['classificacoes'].get('documento_oficial', 0) > 0:
            pontos.append(f"{analise['classificacoes']['documento_oficial']} documento(s) oficial(is) presente(s)")
        
        if analise['classificacoes'].get('comprovante_financeiro', 0) > 0:
            pontos.append(f"{analise['classificacoes']['comprovante_financeiro']} comprovante(s) financeiro(s) presente(s)")
        
        # Linha do tempo
        if len(analise['datas_encontradas']) > 1:
            datas_ordenadas = sorted(analise['datas_encontradas'])
            pontos.append(f"Período documentado: {datas_ordenadas[0]} a {datas_ordenadas[-1]}")
        
        return pontos
    
    def _identify_strengths(self, documentos: List[Dict], analise: Dict) -> List[str]:
        """Identifica pontos fortes do caso"""
        pontos_fortes = []
        
        # Documentos oficiais
        num_oficiais = analise['classificacoes'].get('documento_oficial', 0)
        if num_oficiais > 0:
            pontos_fortes.append(f"Presença de {num_oficiais} documento(s) oficial(is) com alto valor probatório")
        
        # Provas essenciais presentes
        provas_essenciais = sum(1 for d in documentos if d.get('is_essencial'))
        if provas_essenciais > 0:
            pontos_fortes.append(f"{provas_essenciais} prova(s) essencial(is) presente(s)")
        
        # Documentos validados
        validados = sum(1 for d in documentos if d.get('validado'))
        if validados == len(documentos) and len(documentos) > 0:
            pontos_fortes.append("Todos os documentos foram validados")
        
        # Alta relevância média
        relevancia_media = self._calculate_avg_relevance(documentos)
        if relevancia_media >= 7:
            pontos_fortes.append(f"Alta qualidade probatória (relevância média: {relevancia_media:.1f}/10)")
        
        # Documentação financeira completa
        if analise['tipos_documentos'].get('extrato_bancario') and \
           analise['tipos_documentos'].get('holerite'):
            pontos_fortes.append("Documentação financeira completa presente")
        
        return pontos_fortes if pontos_fortes else ["Análise de pontos fortes em andamento"]
    
    def _identify_weaknesses(self, caso_info: Dict, documentos: List[Dict], 
                            analise: Dict) -> List[str]:
        """Identifica pontos fracos do caso"""
        pontos_fracos = []
        
        # Poucos documentos
        if len(documentos) < 3:
            pontos_fracos.append(f"Poucos documentos presentes ({len(documentos)}) - pode ser necessário solicitar mais provas")
        
        # Falta de documentos oficiais
        if analise['classificacoes'].get('documento_oficial', 0) == 0:
            pontos_fracos.append("Ausência de documentos oficiais - reduz força probatória")
        
        # Documentos não validados
        nao_validados = sum(1 for d in documentos if not d.get('validado'))
        if nao_validados > 0:
            pontos_fracos.append(f"{nao_validados} documento(s) ainda não validado(s)")
        
        # Baixa relevância média
        relevancia_media = self._calculate_avg_relevance(documentos)
        if relevancia_media < 5:
            pontos_fracos.append(f"Baixa qualidade probatória geral (relevância média: {relevancia_media:.1f}/10)")
        
        # Falta de provas essenciais específicas por tipo de ação
        tipo_acao = caso_info.get('tipo_acao', '').lower()
        if 'gratuidade' in tipo_acao:
            if not analise['tipos_documentos'].get('irpf') and \
               not analise['tipos_documentos'].get('extrato_bancario'):
                pontos_fracos.append("Falta documentação de renda para gratuidade de justiça")
        
        if 'trabalhista' in tipo_acao:
            if not analise['tipos_documentos'].get('contrato') and \
               not analise['tipos_documentos'].get('holerite'):
                pontos_fracos.append("Falta documentação trabalhista essencial (contrato ou holerites)")
        
        return pontos_fracos if pontos_fracos else ["Nenhum ponto fraco crítico identificado"]
    
    def _generate_alerts(self, caso_info: Dict, documentos: List[Dict], 
                        analise: Dict) -> List[str]:
        """Gera alertas sobre provas faltantes ou problemas"""
        alertas = []
        
        tipo_acao = caso_info.get('tipo_acao', '').lower()
        
        # Alertas específicos por tipo de ação
        if 'gratuidade' in tipo_acao:
            if not analise['tipos_documentos'].get('irpf'):
                alertas.append("ALERTA: IRPF não encontrado - necessário para gratuidade de justiça")
            if not analise['tipos_documentos'].get('extrato_bancario'):
                alertas.append("ALERTA: Extrato bancário não encontrado - recomendado para gratuidade")
        
        if 'pensao' in tipo_acao or 'alimenticia' in tipo_acao:
            if not analise['tipos_documentos'].get('certidao'):
                alertas.append("ALERTA: Certidão de nascimento não encontrada")
            if not analise['tipos_documentos'].get('holerite'):
                alertas.append("ALERTA: Comprovantes de renda podem estar faltando")
        
        if 'trabalhista' in tipo_acao:
            if not analise['tipos_documentos'].get('contrato'):
                alertas.append("ALERTA: Contrato de trabalho não encontrado - documento essencial")
            if not analise['tipos_documentos'].get('holerite'):
                alertas.append("ALERTA: Holerites não encontrados - necessários para cálculo trabalhista")
        
        # Alertas gerais
        if len(documentos) == 0:
            alertas.append("ALERTA CRÍTICO: Nenhum documento presente no caso")
        
        provas_essenciais = sum(1 for d in documentos if d.get('is_essencial'))
        if provas_essenciais == 0 and len(documentos) > 0:
            alertas.append("ALERTA: Nenhuma prova essencial identificada")
        
        return alertas
    
    def _generate_text_summary(self, caso_info: Dict, pontos_chave: List[str],
                              pontos_fortes: List[str], pontos_fracos: List[str],
                              alertas: List[str]) -> str:
        """Gera resumo textual completo"""
        resumo = f"RESUMO JURÍDICO - CASO {caso_info.get('id', 'N/A')}\n\n"
        resumo += f"Tipo de Ação: {caso_info.get('tipo_acao', 'Não especificado')}\n"
        resumo += f"Status: {caso_info.get('status', 'Não especificado')}\n"
        resumo += f"Descrição: {caso_info.get('descricao', 'Não fornecida')}\n\n"
        
        resumo += "PONTOS-CHAVE:\n"
        for i, ponto in enumerate(pontos_chave, 1):
            resumo += f"{i}. {ponto}\n"
        
        resumo += "\nPONTOS FORTES:\n"
        for i, ponto in enumerate(pontos_fortes, 1):
            resumo += f"{i}. {ponto}\n"
        
        resumo += "\nPONTOS FRACOS:\n"
        for i, ponto in enumerate(pontos_fracos, 1):
            resumo += f"{i}. {ponto}\n"
        
        if alertas:
            resumo += "\nALERTAS:\n"
            for i, alerta in enumerate(alertas, 1):
                resumo += f"⚠️ {i}. {alerta}\n"
        
        return resumo
    
    def _calculate_avg_relevance(self, documentos: List[Dict]) -> float:
        """Calcula relevância média dos documentos"""
        if not documentos:
            return 0.0
        
        relevancias = [d.get('relevancia', 5) for d in documentos if d.get('relevancia')]
        if not relevancias:
            return 5.0
        
        return sum(relevancias) / len(relevancias)


if __name__ == "__main__":
    # Exemplo de uso
    generator = LegalSummaryGenerator()
    
    caso_exemplo = {
        'id': '123',
        'tipo_acao': 'Gratuidade de Justiça',
        'status': 'em_triagem',
        'descricao': 'Solicitação de gratuidade de justiça'
    }
    
    documentos_exemplo = [
        {
            'tipo_documento': 'cpf',
            'classificacao_prova': 'documento_oficial',
            'relevancia': 10,
            'is_essencial': True,
            'validado': True
        },
        {
            'tipo_documento': 'irpf',
            'classificacao_prova': 'documento_oficial',
            'relevancia': 9,
            'is_essencial': True,
            'validado': True
        }
    ]
    
    resumo = generator.generate_summary(caso_exemplo, documentos_exemplo)
    print(resumo['resumo_texto'])

