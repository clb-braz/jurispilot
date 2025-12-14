"""
JurisPilot - API Server
Servidor Flask para expor scripts Python como endpoints HTTP
"""

import os
import sys
from pathlib import Path
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from werkzeug.utils import secure_filename
from loguru import logger
import traceback

# Adiciona o diretório src ao path
sys.path.insert(0, str(Path(__file__).parent))

from config import settings
from document_processor import DocumentProcessor
from proof_classifier import ProofClassifier
from legal_summary import LegalSummaryGenerator
from deadline_extractor import DeadlineExtractor
from checklist_generator import ChecklistGenerator
from timeline_generator import TimelineGenerator

# Configuração do Flask
app = Flask(__name__)
CORS(app)

# Configuração de logging
logger.add(
    settings.log_file,
    rotation="10 MB",
    retention="10 days",
    level=settings.log_level
)

# Inicializa processadores
document_processor = DocumentProcessor(
    tesseract_path=os.getenv("TESSERACT_PATH")
)
proof_classifier = ProofClassifier()
legal_summary = LegalSummaryGenerator()
deadline_extractor = DeadlineExtractor()
checklist_generator = ChecklistGenerator()
timeline_generator = TimelineGenerator()


@app.route("/health", methods=["GET"])
def health_check():
    """Endpoint de health check"""
    return jsonify({
        "status": "healthy",
        "service": "JurisPilot API",
        "version": "1.0.0"
    }), 200


@app.route("/api/process-document", methods=["POST"])
def process_document():
    """
    Processa um documento e extrai texto, metadados e tipo
    POST /api/process-document
    Body: multipart/form-data com arquivo 'file'
    """
    try:
        if "file" not in request.files:
            return jsonify({"error": "Nenhum arquivo enviado"}), 400
        
        file = request.files["file"]
        if file.filename == "":
            return jsonify({"error": "Nome de arquivo vazio"}), 400
        
        # Valida extensão
        filename = secure_filename(file.filename)
        extension = filename.rsplit(".", 1)[1].lower() if "." in filename else ""
        
        if extension not in settings.storage.allowed_extensions:
            return jsonify({
                "error": f"Extensão não permitida. Permitidas: {', '.join(settings.storage.allowed_extensions)}"
            }), 400
        
        # Salva arquivo temporariamente
        upload_path = Path(settings.storage.uploads_path)
        upload_path.mkdir(parents=True, exist_ok=True)
        
        temp_file_path = upload_path / filename
        file.save(str(temp_file_path))
        
        try:
            # Processa documento
            result = document_processor.process_file(str(temp_file_path))
            
            return jsonify({
                "success": True,
                "data": result
            }), 200
        finally:
            # Remove arquivo temporário
            if temp_file_path.exists():
                temp_file_path.unlink()
                
    except Exception as e:
        logger.error(f"Erro ao processar documento: {str(e)}\n{traceback.format_exc()}")
        return jsonify({
            "error": "Erro ao processar documento",
            "message": str(e)
        }), 500


@app.route("/api/classify-proof", methods=["POST"])
def classify_proof():
    """
    Classifica uma prova jurídica
    POST /api/classify-proof
    Body: JSON com { "text": "...", "file_path": "..." }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "Body JSON necessário"}), 400
        
        text = data.get("text", "")
        file_path = data.get("file_path", "")
        
        if not text and not file_path:
            return jsonify({"error": "text ou file_path necessário"}), 400
        
        if file_path:
            # Processa arquivo primeiro
            doc_result = document_processor.process_file(file_path)
            text = doc_result.get("text", "")
        
        # Classifica prova
        classification = proof_classifier.classify_proof(text)
        
        return jsonify({
            "success": True,
            "data": classification
        }), 200
        
    except Exception as e:
        logger.error(f"Erro ao classificar prova: {str(e)}\n{traceback.format_exc()}")
        return jsonify({
            "error": "Erro ao classificar prova",
            "message": str(e)
        }), 500


@app.route("/api/generate-summary", methods=["POST"])
def generate_summary():
    """
    Gera resumo jurídico de um caso
    POST /api/generate-summary
    Body: JSON com { "caso_id": "...", "documentos": [...] }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "Body JSON necessário"}), 400
        
        caso_id = data.get("caso_id")
        documentos = data.get("documentos", [])
        
        if not caso_id:
            return jsonify({"error": "caso_id necessário"}), 400
        
        # Gera resumo
        summary = legal_summary.generate_summary(caso_id, documentos)
        
        return jsonify({
            "success": True,
            "data": summary
        }), 200
        
    except Exception as e:
        logger.error(f"Erro ao gerar resumo: {str(e)}\n{traceback.format_exc()}")
        return jsonify({
            "error": "Erro ao gerar resumo jurídico",
            "message": str(e)
        }), 500


@app.route("/api/extract-deadlines", methods=["POST"])
def extract_deadlines():
    """
    Extrai prazos de documentos
    POST /api/extract-deadlines
    Body: JSON com { "text": "...", "file_path": "..." }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "Body JSON necessário"}), 400
        
        text = data.get("text", "")
        file_path = data.get("file_path", "")
        
        if not text and not file_path:
            return jsonify({"error": "text ou file_path necessário"}), 400
        
        if file_path:
            doc_result = document_processor.process_file(file_path)
            text = doc_result.get("text", "")
        
        # Extrai prazos
        deadlines = deadline_extractor.extract_deadlines(text)
        
        return jsonify({
            "success": True,
            "data": deadlines
        }), 200
        
    except Exception as e:
        logger.error(f"Erro ao extrair prazos: {str(e)}\n{traceback.format_exc()}")
        return jsonify({
            "error": "Erro ao extrair prazos",
            "message": str(e)
        }), 500


@app.route("/api/generate-checklist", methods=["POST"])
def generate_checklist():
    """
    Gera checklist dinâmico para um caso
    POST /api/generate-checklist
    Body: JSON com { "tipo_acao": "...", "caso_id": "..." }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "Body JSON necessário"}), 400
        
        tipo_acao = data.get("tipo_acao")
        caso_id = data.get("caso_id")
        
        if not tipo_acao:
            return jsonify({"error": "tipo_acao necessário"}), 400
        
        # Gera checklist
        checklist = checklist_generator.generate_checklist(tipo_acao, caso_id)
        
        return jsonify({
            "success": True,
            "data": checklist
        }), 200
        
    except Exception as e:
        logger.error(f"Erro ao gerar checklist: {str(e)}\n{traceback.format_exc()}")
        return jsonify({
            "error": "Erro ao gerar checklist",
            "message": str(e)
        }), 500


@app.route("/api/generate-timeline", methods=["POST"])
def generate_timeline():
    """
    Gera linha do tempo de um caso
    POST /api/generate-timeline
    Body: JSON com { "caso_id": "...", "documentos": [...] }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "Body JSON necessário"}), 400
        
        caso_id = data.get("caso_id")
        documentos = data.get("documentos", [])
        
        if not caso_id:
            return jsonify({"error": "caso_id necessário"}), 400
        
        # Gera timeline
        timeline = timeline_generator.generate_timeline(caso_id, documentos)
        
        return jsonify({
            "success": True,
            "data": timeline
        }), 200
        
    except Exception as e:
        logger.error(f"Erro ao gerar timeline: {str(e)}\n{traceback.format_exc()}")
        return jsonify({
            "error": "Erro ao gerar linha do tempo",
            "message": str(e)
        }), 500


@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint não encontrado"}), 404


@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Erro interno: {str(error)}")
    return jsonify({"error": "Erro interno do servidor"}), 500


if __name__ == "__main__":
    logger.info("Iniciando JurisPilot API Server...")
    logger.info(f"Host: {settings.api.host}")
    logger.info(f"Port: {settings.api.port}")
    logger.info(f"Debug: {settings.api.debug}")
    
    app.run(
        host=settings.api.host,
        port=settings.api.port,
        debug=settings.api.debug,
        reload=settings.api.reload
    )
