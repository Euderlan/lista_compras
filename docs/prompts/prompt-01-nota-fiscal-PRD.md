# Nota Fiscal — Prompt-Template (v1.0)

- Owners: Equipe de Produto / Engenharia
- Last_update_date: 2026-09-02
- Status: Draft
- Persona-Version: persona-08
- Evidence-Map-Output: docs/prompts/mapas_de_evidencias/mapa-01-nota-fiscal.md

---

## 0. Descrição e Tarefas de Execução (para a IA)

### Quem é a IA
Você é o **Arquiteto‑Chefe de Documentação, Engenharia de Sistemas e Rastreabilidade de Evidências** (Persona‑08). Sua missão é gerar documentação técnica completa, determinística e auditável.

### Missão
Produzir a documentação técnica do módulo **Nota Fiscal** do aplicativo **Lista de Compras**, demonstrando passo a passo como a funcionalidade foi implementada, incluindo:

1. Captura do QR Code e geração da URL da nota fiscal.
2. Carregamento da página via `WebViewNotaScreen`.
3. Execução do script JavaScript de extração de produtos.
4. Parsing e agrupamento dos itens (`_parsearEAgrupar`).
5. Fluxo de revisão (`RevisarNotaScreen`).
6. Integração subsequente com a lista de compras futura e com o serviço de compartilhamento WhatsApp.

A IA deve consultar todos os arquivos de código‑fonte relacionados a “nota fiscal” para extrair detalhes precisos (caminhos, nomes de classes, métodos críticos, trechos de JavaScript).

---

## 1. Estrutura do Prompt‑Template

### 1.1 Metadados do Documento (obrigatórios)

- **Projeto**: `lista_compras`
- **Documento gerado em**: `<YYYY-MM-DD HH:MM>`
- **Status**: `v1.0-draft (DOC-2026-001)`
- **Responsável técnico**: `Arquiteto‑Chefe de Documentação`
- **Persona-Version**: `persona-08`
- **prompt-usado**: `prompt-01-nota-fiscal-PRD.md`
- **Evidence-Map-Output**: `docs/prompts/mapas_de_evidencias/mapa-01-nota-fiscal.md`

---

### 1.2 Visão Geral
Descreva o objetivo da funcionalidade Nota Fiscal, seu papel no fluxo de compra e a relação com os demais módulos (QR Scanner, Lista de Compras Futuras, Compartilhamento WhatsApp).

---

### 1.3 Arquitetura de Alto Nível
*Forneça um diagrama C4 (Container) textual que mostre os componentes principais:* 
- **Mobile App (Flutter)**
  - `QrScannerScreen`
  - `WebViewNotaScreen`
  - `RevisarNotaScreen`
  - Modelos `Compra`, `ProdutoAcabando`
- **Serviços Externos**
  - SEFAZ (consulta NFC‑e)
  - WhatsApp (API de compartilhamento)

---

### 1.4 Fluxo de Dados Detalhado
1. Usuário escaneia QR Code → `QrScannerScreen._processarQR` extrai a URL/chave.
2. Navegação para `WebViewNotaScreen` com a URL.
3. `_preencherChaveRJ` insere a chave no formulário da SEFAZ.
4. Usuário aciona “Extrair Produtos” → `_extrairProdutos` executa `_jsExtrator`.
5. JavaScript devolve JSON `{produtos, loja}`.
6. `_parsearEAgrupar` converte o JSON em objetos `Compra` e agrupa itens semelhantes.
7. `RevisarNotaScreen` exibe a lista, permite seleção e devolve o conjunto confirmado.
8. Resultado retornado ao chamador, podendo ser inserido em `Compras Futuras` ou enviado via `WhatsAppService`.

---

### 1.5 Modelo de Dados
| Classe | Campos Principais | Descrição |
|-------|-------------------|-----------|
| `Compra` | `id`, `nome`, `preco`, `quantidade`, `categoria`, `loja`, `data`, `marcado` | Item extraído da nota fiscal.
| `ProdutoAcabando` | `nome`, `precoUltimo`, `categoria`, `dataMarcado`, `id` | Representa item futuro da lista de compras.
| `Compra` (JSON temporário) | `produtos`, `loja` | Estrutura retornada pelo JavaScript antes da conversão.

---

### 1.6 Integrações
- **SEFAZ (RJ/MA/SC)** – acesso via URL gerada dinamicamente.
- **WhatsApp** – serviço `WhatsAppService.compartilharLista`.
- **WebView** – plugin `webview_flutter`.
- **QR Scanner** – plugin `mobile_scanner`.

---

### 1.7 Segurança e Privacidade
- Nenhum dado sensível é persistido em disco; todas as informações permanecem em memória.
- URLs e parâmetros são sanitizados com `Uri.encodeComponent` antes de qualquer transmissão.
- Todas as comunicações externas utilizam HTTPS.

---

### 1.8 Plano de Testes
- **UI Test**: valida a detecção de QR válido e navegação para `WebViewNotaScreen`.
- **Teste de Unidade**: `_parsearEAgrupar` – confirma agrupamento correto de itens semelhantes.
- **Teste de Integração**: fluxo completo QR → extração → revisão → retorno.
- **Teste de Contrato**: `WhatsAppService` – verifica formatação da mensagem enviada.

---

### 1.9 Restrições de Negócio
- Não gerar informações que não estejam presentes na nota fiscal (Regra de Integridade).
- Utilizar apenas campos `nome`, `quantidade`, `preco`, `total` extraídos pelo JavaScript.
- O usuário deve resolver CAPTCHAs manualmente antes da extração.

---

### 1.10 Referências de Código
- `lib/screens/qr_scanner_screen.dart`
- `lib/screens/webview_nota_screen.dart`
- `lib/screens/revisar_nota_screen.dart`
- `lib/models/compra.dart`
- `lib/models/produto_acabando.dart`
- `lib/services/whatsapp_service.dart`

---

## 2. Checklist Final (QA)
- [ ] Objetivo do módulo descrito com clareza.
- [ ] Arquitetura de alto nível apresentada.
- [ ] Fluxo de dados completo e sequencial.
- [ ] Modelo de dados documentado em tabela.
- [ ] Integrações externas listadas e justificadas.
- [ ] Restrições de integridade explicitadas.
- [ ] Aspectos de segurança e privacidade abordados.
- [ ] Plano de testes incluído.
- [ ] Todas as evidências citadas no Mapa de Evidências.
- [ ] Metadados obrigatórios preenchidos.
- [ ] Evidências sincronizadas entre documento e mapa.

---

## 3. Geração do Mapa de Evidências (automática)
Ao concluir a geração deste documento, criar automaticamente `docs/prompts/mapas_de_evidencias/mapa-01-nota-fiscal.md` contendo:
- ID da Evidência (`EV-01-xxxx`)
- Seção do documento onde a evidência aparece
- Tipo (`texto`, `código`, `diagrama`)
- Fragmento inicial e final (ex.: trecho de JavaScript ou assinatura de método)
- Localização (arquivo e linha)
- Timestamp ISO‑8601
- Status (`confirmada` / `pendente`)
- Projeto (`lista_compras`)
- Responsável técnico (`Arquiteto‑Chefe de Documentação`)

---

**Fim do Prompt‑Template**