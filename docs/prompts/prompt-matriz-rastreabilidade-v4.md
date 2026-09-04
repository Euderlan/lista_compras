# Prompt — Gerador de Matriz de Rastreabilidade (RTM) para Documentação a partir do Código

> Versão 4.0

## Objetivo

Este prompt deve gerar uma **Matriz de Rastreabilidade (Requirements Traceability Matrix - RTM)** a partir da documentação existente e do **código-fonte do software**, identificando automaticamente a relação entre requisitos, objetivos, implementação, testes e evidências.

---

# Entradas obrigatórias

- Nome do projeto
- Versão/recorte
- Origem A — documento contendo problemas, contexto, escopo ou requisitos
- Origem B — documento contendo objetivos (opcional)
- Origem C — repositório/código-fonte do sistema (obrigatório quando existir)
- Evidências existentes (testes, documentos, mapas EV, pipelines, relatórios)

Se Origem B não existir, inferir objetivos a partir da Origem A e marcar como `[INFERIDO]`.

---

# Regras Gerais

1. Cada linha representa apenas uma claim/requisito.
2. Nunca duplicar claims.
3. Nunca inventar arquivos, testes, APIs ou métricas.
4. Quando uma evidência não existir utilizar `PENDING: User Input`.
5. Objetivos inferidos devem conter `[INFERIDO]`.
6. Sempre analisar o código antes de montar a matriz.

---

# Análise obrigatória do código

Quando houver código-fonte disponível, identificar:

- Estrutura do projeto
- Controllers
- Services
- Repositories
- Models
- Entidades
- Rotas
- APIs
- Banco de dados
- Migrations
- DTOs
- Schemas
- Funções
- Classes
- Métodos
- Testes
- Documentação

Relacionar cada item aos requisitos sempre que possível.

---

# Rastreabilidade

A matriz deve ligar:

Documento
→ Problema
→ Objetivo
→ Implementação
→ Teste
→ Evidência

Também gerar rastreabilidade reversa:

Código
→ Objetivo
→ Requisito
→ Documento

---

# Template

| ID | Problema | Objetivo | Implementação | Evidência | Teste | Resultado |
|----|----------|----------|---------------|-----------|-------|------------|
| REQ-001 | ... | OBJ-001 | IMP-001 | docs/... | TEST-001 | PASS |

Implementação pode conter:

- arquivo
- classe
- método
- endpoint
- migration
- schema
- service

Exemplo:

backend/auth/service.py::AuthService.login()

---

# Cobertura

Gerar obrigatoriamente:

| Item | Total |
|------|------:|
| Requisitos | |
| Implementados | |
| Sem implementação | |
| Com testes | |
| Sem testes | |
| Código órfão | |

---

# Código órfão

Listar implementações sem requisito correspondente.

---

# Requisitos órfãos

Listar requisitos sem implementação.

---

# Testes órfãos

Listar testes sem requisito associado.

---

# Impacto

Para cada arquivo relevante informar quais requisitos são impactados.

| Arquivo | Impacta |
|---------|---------|
| auth.py | REQ-001, REQ-008 |

---

# Seção Implementação

| Componente | Classe | Método | Arquivo | Teste | Status |

---

# Checklist QA

- IDs únicos
- Sem duplicação
- Objetivos inferidos marcados
- Evidências reais ou PENDING
- Implementação identificada
- Código analisado
- Cobertura calculada
- Código órfão listado
- Testes órfãos listados
- Impacto preenchido

---

# Instrução final para a IA

Antes de gerar a matriz:

1. Ler toda a documentação.
2. Analisar o repositório.
3. Mapear requisitos.
4. Localizar implementação.
5. Localizar testes.
6. Localizar documentação relacionada.
7. Gerar a matriz completa.
8. Gerar cobertura.
9. Gerar rastreabilidade reversa.
10. Nunca inventar implementações; quando não houver evidência usar `PENDING: User Input`.
11. Saída em C:\Users\EudFr\OneDrive\Documentos\VSCODEPROJETOS\lista_compras\flutter_application_1\lista_compras\docs\prompts\matriz-rastreabilidade