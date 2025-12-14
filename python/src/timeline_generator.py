"""
JurisPilot - Gerador de Linha do Tempo
Gera linha do tempo cronológica de eventos do caso baseado nos documentos
"""

from typing import Dict, List, Optional
from datetime import datetime
from loguru import logger
import json


class TimelineGenerator:
    """Gera linha do tempo cronológica de casos jurídicos"""
    
    def __init__(self):
        """Inicializa o gerador de linha do tempo"""
        logger.info("TimelineGenerator inicializado")
    
    def generate_timeline(self, caso_info: Dict, documentos: List[Dict], 
                         prazos: Optional[List[Dict]] = None) -> List[Dict]:
        """
        Gera linha do tempo completa do caso
        
        Args:
            caso_info: Informações do caso
            documentos: Lista de documentos do caso
            prazos: Lista de prazos (opcional)
            
        Returns:
            Lista de eventos ordenados cronologicamente
        """
        logger.info(f"Gerando linha do tempo para caso: {caso_info.get('id')}")
        
        eventos = []
        
        # Adiciona criação do caso
        eventos.append({
            'evento': 'Caso criado',
            'data_evento': caso_info.get('created_at', datetime.now().isoformat()),
            'tipo_evento': 'sistema',
            'descricao': f"Caso {caso_info.get('tipo_acao', 'N/A')} criado",
            'documento_relacionado_id': None
        })
        
        # Adiciona eventos dos documentos
        for doc in documentos:
            data_doc = doc.get('data_documento') or doc.get('data_upload')
            if data_doc:
                eventos.append({
                    'evento': f"Documento recebido: {doc.get('tipo_documento', 'N/A')}",
                    'data_evento': data_doc,
                    'tipo_evento': 'upload_documento',
                    'descricao': f"Documento {doc.get('nome_arquivo', 'N/A')} recebido",
                    'documento_relacionado_id': doc.get('id'),
                    'classificacao': doc.get('classificacao_prova'),
                    'relevancia': doc.get('relevancia')
                })
        
        # Adiciona eventos de prazos
        if prazos:
            for prazo in prazos:
                data_venc = prazo.get('data_vencimento')
                if data_venc:
                    eventos.append({
                        'evento': f"Prazo: {prazo.get('descricao', 'N/A')}",
                        'data_evento': data_venc,
                        'tipo_evento': 'prazo',
                        'descricao': prazo.get('descricao', ''),
                        'documento_relacionado_id': prazo.get('documento_relacionado_id'),
                        'tipo_prazo': prazo.get('tipo_prazo'),
                        'status': prazo.get('status', 'pendente')
                    })
        
        # Ordena eventos por data
        eventos_ordenados = self._sort_events_by_date(eventos)
        
        # Adiciona contexto e relacionamentos
        eventos_enriquecidos = self._enrich_events(eventos_ordenados, documentos)
        
        logger.info(f"Linha do tempo gerada com {len(eventos_enriquecidos)} evento(s)")
        
        return eventos_enriquecidos
    
    def _sort_events_by_date(self, eventos: List[Dict]) -> List[Dict]:
        """Ordena eventos por data"""
        def get_date(evento):
            data_str = evento.get('data_evento')
            if isinstance(data_str, str):
                try:
                    # Tenta vários formatos
                    for fmt in ['%Y-%m-%d', '%Y-%m-%dT%H:%M:%S', '%Y-%m-%d %H:%M:%S', '%d/%m/%Y']:
                        try:
                            return datetime.strptime(data_str[:10], fmt)
                        except:
                            continue
                    # Se não conseguir, usa data atual
                    return datetime.now()
                except:
                    return datetime.now()
            elif isinstance(data_str, datetime):
                return data_str
            else:
                return datetime.now()
        
        eventos_ordenados = sorted(eventos, key=get_date)
        return eventos_ordenados
    
    def _enrich_events(self, eventos: List[Dict], documentos: List[Dict]) -> List[Dict]:
        """Enriquece eventos com informações adicionais"""
        # Cria mapa de documentos por ID
        docs_map = {doc.get('id'): doc for doc in documentos if doc.get('id')}
        
        eventos_enriquecidos = []
        
        for i, evento in enumerate(eventos):
            evento_enriquecido = evento.copy()
            
            # Adiciona informações do documento relacionado
            doc_id = evento.get('documento_relacionado_id')
            if doc_id and doc_id in docs_map:
                doc = docs_map[doc_id]
                evento_enriquecido['documento_info'] = {
                    'nome': doc.get('nome_arquivo'),
                    'tipo': doc.get('tipo_documento'),
                    'classificacao': doc.get('classificacao_prova')
                }
            
            # Adiciona contexto temporal
            if i > 0:
                evento_anterior = eventos[i-1]
                evento_enriquecido['evento_anterior'] = evento_anterior.get('evento')
                evento_enriquecido['dias_apos_anterior'] = self._calculate_days_between(
                    evento_anterior.get('data_evento'),
                    evento.get('data_evento')
                )
            
            # Adiciona contexto futuro
            if i < len(eventos) - 1:
                evento_proximo = eventos[i+1]
                evento_enriquecido['evento_proximo'] = evento_proximo.get('evento')
                evento_enriquecido['dias_ate_proximo'] = self._calculate_days_between(
                    evento.get('data_evento'),
                    evento_proximo.get('data_evento')
                )
            
            eventos_enriquecidos.append(evento_enriquecido)
        
        return eventos_enriquecidos
    
    def _calculate_days_between(self, data1: Optional[str], data2: Optional[str]) -> Optional[int]:
        """Calcula dias entre duas datas"""
        if not data1 or not data2:
            return None
        
        try:
            def parse_date(date_str):
                if isinstance(date_str, datetime):
                    return date_str
                if isinstance(date_str, str):
                    for fmt in ['%Y-%m-%d', '%Y-%m-%dT%H:%M:%S', '%Y-%m-%d %H:%M:%S', '%d/%m/%Y']:
                        try:
                            return datetime.strptime(date_str[:10], fmt)
                        except:
                            continue
                return datetime.now()
            
            d1 = parse_date(data1)
            d2 = parse_date(data2)
            
            delta = d2 - d1
            return delta.days
        except Exception as e:
            logger.debug(f"Erro ao calcular dias entre datas: {e}")
            return None
    
    def generate_timeline_summary(self, timeline: List[Dict]) -> Dict:
        """Gera resumo da linha do tempo"""
        if not timeline:
            return {
                'total_eventos': 0,
                'periodo': None,
                'eventos_por_tipo': {},
                'documentos_por_periodo': {}
            }
        
        # Calcula período
        datas = [e.get('data_evento') for e in timeline if e.get('data_evento')]
        if datas:
            try:
                datas_parseadas = []
                for data_str in datas:
                    if isinstance(data_str, datetime):
                        datas_parseadas.append(data_str)
                    elif isinstance(data_str, str):
                        for fmt in ['%Y-%m-%d', '%Y-%m-%dT%H:%M:%S']:
                            try:
                                datas_parseadas.append(datetime.strptime(data_str[:10], fmt))
                                break
                            except:
                                continue
                
                if datas_parseadas:
                    periodo_inicio = min(datas_parseadas)
                    periodo_fim = max(datas_parseadas)
                    periodo = {
                        'inicio': periodo_inicio.strftime('%Y-%m-%d'),
                        'fim': periodo_fim.strftime('%Y-%m-%d'),
                        'dias_total': (periodo_fim - periodo_inicio).days
                    }
                else:
                    periodo = None
            except:
                periodo = None
        else:
            periodo = None
        
        # Conta eventos por tipo
        eventos_por_tipo = {}
        for evento in timeline:
            tipo = evento.get('tipo_evento', 'outro')
            eventos_por_tipo[tipo] = eventos_por_tipo.get(tipo, 0) + 1
        
        # Agrupa documentos por período (mensal)
        documentos_por_periodo = {}
        for evento in timeline:
            if evento.get('tipo_evento') == 'upload_documento':
                data_str = evento.get('data_evento')
                if data_str:
                    try:
                        if isinstance(data_str, datetime):
                            periodo_key = data_str.strftime('%Y-%m')
                        elif isinstance(data_str, str):
                            periodo_key = data_str[:7]  # YYYY-MM
                        else:
                            continue
                        
                        documentos_por_periodo[periodo_key] = documentos_por_periodo.get(periodo_key, 0) + 1
                    except:
                        pass
        
        return {
            'total_eventos': len(timeline),
            'periodo': periodo,
            'eventos_por_tipo': eventos_por_tipo,
            'documentos_por_periodo': documentos_por_periodo,
            'eventos_criticos': [e for e in timeline if e.get('tipo_evento') == 'prazo' and e.get('status') == 'vencido']
        }
    
    def export_timeline_json(self, timeline: List[Dict], file_path: str):
        """Exporta linha do tempo para JSON"""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(timeline, f, indent=2, ensure_ascii=False, default=str)
            logger.info(f"Linha do tempo exportada para: {file_path}")
        except Exception as e:
            logger.error(f"Erro ao exportar linha do tempo: {e}")
            raise


if __name__ == "__main__":
    # Exemplo de uso
    generator = TimelineGenerator()
    
    caso_exemplo = {
        'id': '123',
        'tipo_acao': 'Gratuidade de Justiça',
        'created_at': '2024-12-01'
    }
    
    documentos_exemplo = [
        {
            'id': 'doc1',
            'tipo_documento': 'cpf',
            'nome_arquivo': 'cpf.pdf',
            'data_documento': '2024-12-02',
            'data_upload': '2024-12-02T10:00:00'
        },
        {
            'id': 'doc2',
            'tipo_documento': 'irpf',
            'nome_arquivo': 'irpf.pdf',
            'data_documento': '2024-12-05',
            'data_upload': '2024-12-05T14:30:00'
        }
    ]
    
    timeline = generator.generate_timeline(caso_exemplo, documentos_exemplo)
    
    for evento in timeline:
        print(f"{evento['data_evento']}: {evento['evento']}")
    
    resumo = generator.generate_timeline_summary(timeline)
    print(f"\nResumo: {resumo}")

