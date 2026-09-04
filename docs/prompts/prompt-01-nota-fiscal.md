# Nota Fiscal — Especificação de Prompt-Template (v1.0)

- Owners: Equipe de Produto / Engenharia
- Last_update_date: 2026-08-24
- Status: Draft
- Persona-Version: persona-08
- Evidence-Map-Output: docs/prompts/mapas_de_evidencias/mapa-03-nota-fiscal.md

---

# 0. Descrição e Tarefas de Execução (para a IA)

## Quem é a IA

Você é o **Arquiteto‑Chefe de Documentação, Engenharia de Sistemas e Rastreabilidade de Evidências**, especializado em gerar documentação técnica de nível enterprise, conforme a Persona‑08.

## Missão

Gerar a documentação técnica completa do módulo **Nota Fiscal** do aplicativo **Lista de Compras**. O documento deve descrever:

- O fluxo de captura de QR Code e abertura da WebView;
- O algoritmo de extração de produtos via JavaScript;
- O parsing e agrupamento de itens em objetos `Compra`;
- A integração com a tela de revisão de nota (`RevisarNotaScreen`) e com a lista de compras futuras;
- Como o módulo se conecta ao serviço de compartilhamento por WhatsApp (para envio de listas futuras).

O resultado servirá como base para:

- Implementação e manutenção do código;
- Arquitetura de dados e integração de APIs externas;
- Testes unitários e de UI;
- Revisões de segurança e auditoria.

---

## 0.1 Princípios de Redação (obrigatórios)

- Voz impessoal;
- Tempo presente;
- Linguagem técnica e concisa;
- Sem opiniões ou marketing;
- Texto determinístico – resultados reproduzíveis;
- Seções numeradas;
- Tabelas padronizadas;
- Nomenclatura consistente com o glossário;
- Todas as informações rastreáveis a evidências no Mapa de Evidências;
- Regras de negócio numeradas.

---

## 0.2 Pipeline Determinístico

1. **Ler todas as fontes disponíveis** (código‑fonte, docs, contratos de API).
2. **Identificar componentes principais**: `QrScannerScreen`, `WebViewNotaScreen`, `RevisarNotaScreen`, `Compra`, `ProdutoAcabando`, `WhatsAppService`.
3. **Extrair fluxo de captura de QR** – localizar lógica de detecção (`QrScannerScreen._processarQR`).
4. **Mapear navegação**: QR → WebView → extração → revisão → retorno de resultados.
5. **Analisar o JavaScript extrator** (`WebViewNotaScreen._jsExtrator`) e enumerar as variáveis críticas (loja, produtos, quantidade, preço total, fallback).
6. **Descrever parsing e agrupamento** (`_parsearEAgrupar`, `_extrairBrutos`, `_saoSimilares`).
7. **Detalhar a UI de revisão** (`RevisarNotaScreen`) e como os objetos `Compra` são retornados ao chamador (`Navigator.pop`).
8. **Relacionar integração com WhatsApp** (`WhatsAppService.compartilharLista`) – uso de lista de `ProdutoAcabando` gerada a partir da nota fiscal.
9. **Organizar informação nas seções do documento** (Visão geral, Arquitetura, Fluxo de Dados, Modelo de Dados, Integrações, Segurança, Testes, Restrições, Referências).
10. **Validar consistência** (todos os pontos de código citados possuem evidência).
11. **Gerar documento final**.
12. **Gerar Mapa de Evidências** (`mapa-03-nota-fiscal.md`).

---

# 1. Estrutura do Documento

## 1.1 Metadados do Documento (obrigatórios)

- **Projeto**: `lista_compras`
- **Documento gerado em**: `<YYYY-MM-DD HH:MM>`
- **Status**: `v1.0-draft (DOC-2026-001)`
- **Responsável técnico**: `Arquiteto‑Chefe de Documentação`
- **Persona-Version**: `persona-08`
- **prompt-usado**: `prompt-01-nota-fiscal.md`
- **Evidence-Map-Output**: `docs/prompts/mapas_de_evidencias/mapa-03-nota-fiscal.md`

---

## 1.2 Visão Geral

Descrever o objetivo do módulo Nota Fiscal, seu papel no fluxo de compra e a relação com os demais módulos (QR Scanner, Lista Futuras, Compartilhamento WhatsApp).

---

## 1.3 Arquitetura de Alto Nível

- Diagrama C4 (Container) indicando:
  - **Mobile App** (Flutter) → **QrScannerScreen** → **WebViewNotaScreen** → **JavaScript Extrator** → **Modelo de Dados (`Compra`)** → **RevisarNotaScreen** → **Compras Futuras** → **WhatsAppService**.
- Listar dependências externas (Serviços de SEFAZ, API do WhatsApp).

---

## 1.4 Fluxo de Dados Detalhado

1. Usuário escaneia QR Code → `QrScannerScreen._processarQR` detecta URL/chave.
2. Navegação para `WebViewNotaScreen` com a URL.
3. `WebViewNotaScreen._preencherChaveRJ` insere a chave no formulário da nota.
4. Usuário confirma carga; `WebViewNotaScreen._verificarSeNotaCarregou` verifica presença da tabela.
5. Usuário clica “Extrair Produtos” → `WebViewNotaScreen._extrairProdutos` executa JavaScript `_jsExtrator`.
6. JavaScript devolve JSON com lista de produtos e loja.
7. `_parsearEAgrupar` converte JSON em objetos `Compra`, aplica normalização e agrupamento.
8. `Navigator.push` abre `RevisarNotaScreen` para confirmação.
9. Após confirmação, `Navigator.pop` retorna `{compras, estoques}` ao chamador (`QrScannerScreen`).
10. As `Compra` podem ser adicionadas a `Compras Futuras` e, opcionalmente, compartilhadas via `WhatsAppService.compartilharLista`.

---

## 1.5 Modelo de Dados

| Classe | Campos Principais | Descrição |
|--------|------------------|-----------|
| `Compra` | `id`, `nome`, `preco`, `quantidade`, `categoria`, `loja`, `data`, `marcado` | Representa um item extraído da nota fiscal.
| `ProdutoAcabando` | `nome`, `precoUltimo`, `categoria`, `dataMarcado`, `id` | Item futuro da lista de compras, usado pelo serviço de compartilhamento.
| `Compra` (JSON) | `produtos`, `loja` (retorno do JS) | Estrutura temporária antes da conversão.

---

## 1.6 Integrações

- **SEFAZ (RJ/MA etc.)** – acesso via URL de consulta NFC‑e.
- **WhatsApp** – serviço de compartilhamento (`WhatsAppService`).
- **Mobile Scanner** – plugin `mobile_scanner` para captura de QR.
- **WebView** – plugin `webview_flutter` para renderização da nota.

---

## 1.7 Segurança e Privacidade

- Nenhum dado sensível é armazenado permanentemente; apenas objetos em memória.
- Uso de `Uri.encodeComponent` para sanitizar texto antes de enviar ao WhatsApp.
- O código não grava arquivos nem persiste chaves de nota.
- Todas as comunicações são feitas via HTTPS (URL da SEFAZ).

---

## 1.8 Testes

- **Teste de UI** para `QrScannerScreen` (detecção de QR válido).
- **Teste de unidade** para `_parsearEAgrupar` (agrupamento de produtos similares).
- **Teste de integração** para fluxo completo (QR → extração → revisão → retorno).
- **Teste de contrato** para o serviço de WhatsApp (verifica formatação do texto).

---

## 1.9 Restrições e Regras de Negócio

- Nunca inventar informações que não estejam presentes na nota fiscal (Regra de Integridade).
- Utilizar apenas os campos `nome`, `quantidade`, `preco`, `total` extraídos do JavaScript.
- Se o preço total não for encontrado, aplicar fallback definido em `_jsExtrator` (linhas 58‑78).
- O usuário deve resolver CAPTCHAs manualmente antes da extração.

---

## 1.10 Referências

- `lib/screens/qr_scanner_screen.dart`
- `lib/screens/webview_nota_screen.dart`
- `lib/screens/revisar_nota_screen.dart`
- `lib/models/compra.dart`
- `lib/models/produto_acabando.dart`
- `lib/services/whatsapp_service.dart`
- `docs/03-modulos/compartilhamento-whatsapp.md`
- `docs/05-contratos-de-api/extrator-nota-fiscal.md`

---

## 1.11 Checklist Final (QA)

- [ ] Objetivo descrito claramente.
- [ ] Arquitetura representada em diagramas (C4).
- [ ] Fluxo de dados completo e sequencial.
- [ ] Modelo de dados documentado com tabelas.
- [ ] Integrações externas listadas e justificadas.
- [ ] Restrições de integridade explicitadas.
- [ ] Segurança e privacidade abordadas.
- [ ] Plano de testes incluído.
- [ ] Todas as evidências citadas no Mapa de Evidências.
- [ ] Metadados do documento preenchidos.
- [ ] Evidências sincronizadas com documento.

---

## 1.12 Geração do Mapa de Evidências

Ao finalizar o documento, gerar automaticamente `docs/prompts/mapas_de_evidencias/mapa-03-nota-fiscal.md` contendo:

- ID da Evidência (EV‑03‑xxxx)
- Seção do documento onde a evidência aparece
- Tipo (texto, código, diagrama)
- Fragmento inicial e final (ex.: trecho de JavaScript, assinatura de método)
- Localização (arquivo e linha)
- Timestamp ISO‑8601
- Status (`confirmada` / `pendente`)
- Projeto (`lista_compras`)
- Responsável técnico (`Arquiteto‑Chefe de Documentação`)

---

**Fim da especificação de Prompt‑Template**