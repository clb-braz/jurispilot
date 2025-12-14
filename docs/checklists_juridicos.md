# JurisPilot - Checklists Jurídicos

## Visão Geral

Os checklists jurídicos são gerados dinamicamente pelo sistema baseado no tipo de ação identificada. Cada tipo de ação tem um template pré-configurado com documentos obrigatórios e recomendados.

## Templates por Tipo de Ação

### Cível/Consumidor

#### Gratuidade de Justiça

**Documentos Obrigatórios**:
- IRPF
- Contracheque
- Extrato bancário (últimos 3 meses)
- Carteira de trabalho

**Documentos Recomendados**:
- Comprovante de residência
- Comprovante de despesas
- Atestado médico (se aplicável)

#### Relação de Consumo

**Documentos Obrigatórios**:
- Comprovante de compra
- Comprovante de pagamento
- Contrato (se houver)
- Comunicação com fornecedor

**Documentos Recomendados**:
- Nota fiscal
- Fotos do produto/serviço
- Histórico de comunicação

#### Ação contra Companhia Aérea

**Documentos Obrigatórios**:
- Comprovante de compra
- Comprovante de pagamento
- E-mails da companhia
- Prints de cancelamento
- Protocolos

**Documentos Recomendados**:
- Comprovante de bagagem extraviada
- Fotos de danos
- Comunicação com atendimento

#### Cobrança Indevida

**Documentos Obrigatórios**:
- Faturas
- Comprovantes de pagamento
- Contrato (se houver)
- Histórico de comunicação

**Documentos Recomendados**:
- Extrato bancário
- Comprovantes de cancelamento
- Comunicação prévia

#### Negativação Indevida

**Documentos Obrigatórios**:
- Consulta SPC/Serasa
- Comprovantes de pagamento
- Comunicação prévia

**Documentos Recomendados**:
- Extrato bancário
- Comprovante de quitação
- Histórico de relacionamento

### Família

#### Pensão Alimentícia

**Documentos Obrigatórios**:
- Certidão de nascimento
- Comprovantes de renda
- Despesas do menor

**Documentos Recomendados**:
- Extrato bancário
- Comprovante de despesas escolares
- Comprovante de despesas médicas

#### Divórcio Consensual

**Documentos Obrigatórios**:
- Certidão de casamento
- CPF de ambos
- RG de ambos
- Comprovante de residência

**Documentos Recomendados**:
- Acordo de divórcio
- Comprovante de renda

#### Divórcio Litigioso

**Documentos Obrigatórios**:
- Certidão de casamento
- CPF de ambos
- RG de ambos
- Comprovante de residência
- Comprovantes de renda
- Documentos de bens
- Documentos de dívidas

**Documentos Recomendados**:
- Extrato bancário
- Comprovante de imóveis
- Comprovante de veículos

#### Guarda

**Documentos Obrigatórios**:
- Certidão de nascimento
- Provas de vínculo
- Histórico escolar

**Documentos Recomendados**:
- Relatórios médicos
- Fotos
- Comprovante de residência

### Trabalhista

#### Rescisão Indireta

**Documentos Obrigatórios**:
- Contrato de trabalho
- Holerites
- Extrato FGTS
- Provas da falta grave

**Documentos Recomendados**:
- Comunicação com empresa
- Testemunhas
- Comprovantes de irregularidades

#### Horas Extras

**Documentos Obrigatórios**:
- Cartões de ponto
- Contracheques
- Escalas

**Documentos Recomendados**:
- Contrato de trabalho
- Comunicação sobre horas extras
- Comprovantes de pagamento

### Empresarial/Contratual

#### Descumprimento Contratual

**Documentos Obrigatórios**:
- Contrato
- Aditivos
- Provas de descumprimento
- Comunicações

**Documentos Recomendados**:
- Notas fiscais
- Comprovantes de pagamento
- Correspondências

#### Cobrança Empresarial

**Documentos Obrigatórios**:
- Notas fiscais
- Boletos
- Comprovantes

**Documentos Recomendados**:
- Contrato
- Histórico de relacionamento
- Comunicações

## Validação Automática

O sistema valida automaticamente:

1. **Presença de documentos obrigatórios**: Calcula percentual de completude
2. **Classificação de provas**: Identifica tipo de prova (oficial, conversa, comprovante, técnica)
3. **Relevância**: Atribui relevância de 1-10 para cada documento
4. **Alertas**: Gera alertas quando documentos essenciais estão faltando

## Como Adicionar Novos Checklists

1. Acesse o banco de dados PostgreSQL
2. Insira registros na tabela `checklists_juridicos`:
   ```sql
   INSERT INTO checklists_juridicos (tipo_acao, documento_obrigatorio, documento_recomendado, validacao_automatica, ordem)
   VALUES ('novo_tipo', 'Documento Obrigatório', false, true, 1);
   ```
3. O sistema automaticamente usará o novo checklist na próxima triagem

## Seeds do Banco de Dados

Os seeds pré-configurados estão em `database/seeds/checklists_seed.sql` e contêm todos os templates acima.

