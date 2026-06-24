# Visão do Produto

- Documento: Visão do Produto
- Versão: v1.0
- Owners: Equipe de Produto / Engenharia
- Last_update_date: 2026-06-24
- Status: Draft

---

## 1. Resumo

O `lista_compras` é um aplicativo mobile desenvolvido em Flutter para ajudar usuários a planejar, executar e acompanhar compras do dia a dia. O produto centraliza listas de compras, itens, categorias, preços, totais, histórico de compras, apoio à nota fiscal, controle básico de estoque, notificações e compartilhamento.

A proposta é reduzir esquecimento de itens, melhorar previsibilidade de gastos, facilitar reaproveitamento de compras anteriores e criar uma base organizada para evolução futura com sincronização, autenticação, importação por nota fiscal e alertas inteligentes.

---

## 2. Problema

Usuários que fazem compras recorrentes geralmente enfrentam dificuldades como:

- esquecer itens importantes durante a compra;
- não saber o total aproximado antes de finalizar a compra;
- perder histórico de compras anteriores;
- não conseguir comparar itens comprados, pendentes e valores;
- manter controle manual de produtos em estoque;
- compartilhar listas por mensagens sem padronização;
- depender de anotações soltas, prints ou aplicativos genéricos.

O aplicativo busca resolver esses problemas oferecendo uma experiência simples, organizada e rastreável para listas de compras.

---

## 3. Objetivo do Produto

Permitir que o usuário crie, organize, acompanhe e finalize listas de compras, com suporte a itens, categorias, preços, totais, histórico, compartilhamento e integração futura com recursos fiscais e estoque.

---

## 4. Público-alvo

### 4.1 Usuários principais

- Pessoas que fazem compras domésticas recorrentes.
- Famílias que compartilham listas de mercado.
- Usuários que desejam controlar gastos por compra.
- Usuários que desejam consultar histórico de compras anteriores.

### 4.2 Usuários secundários

- Pessoas que desejam controlar itens em estoque doméstico.
- Usuários que desejam importar ou consultar dados de nota fiscal.
- Usuários que desejam receber lembretes e alertas relacionados a compras ou validade de produtos.

---

## 5. Atores

| Ator | Descrição |
|---|---|
| Usuário | Pessoa que utiliza o aplicativo para criar, editar, compartilhar e finalizar listas de compras. |
| Sistema | Conjunto de funcionalidades internas responsáveis por cálculos, persistência, sincronização, notificações e validações. |
| Serviço de Autenticação | Serviço responsável por login, cadastro, recuperação de senha e sessão do usuário. |
| Serviço de Backend | Serviço responsável por armazenar e sincronizar dados do usuário. |
| Serviço de Notificações | Serviço responsável por enviar notificações push ou locais. |
| Aplicativo Externo | Aplicativos como WhatsApp, navegador ou leitor de WebView acionados pelo aplicativo. |

---

## 6. Escopo do Produto

### 6.1 Dentro do escopo

- Cadastro, login, recuperação de senha e logout.
- Criação, edição, exclusão e fechamento de listas de compras.
- Criação, edição, remoção e marcação de itens como comprados.
- Organização de itens por categorias.
- Registro de quantidade e preço dos itens.
- Cálculo de totais da lista.
- Histórico de compras finalizadas.
- Resumo de compra.
- Compartilhamento de lista ou resumo pelo WhatsApp.
- Leitura inicial de QR Code de nota fiscal.
- Visualização de nota fiscal por WebView quando houver URL válida.
- Controle básico de estoque.
- Alertas e notificações.
- Sincronização dos dados do usuário com backend.
- Restrições de acesso por usuário autenticado.

### 6.2 Fora do escopo inicial

- Emissão de nota fiscal.
- Pagamento dentro do aplicativo.
- Integração direta com supermercados.
- Comparação automática de preços entre lojas.
- Marketplace ou compra online.
- Gestão empresarial de estoque.
- Multiusuário avançado com papéis administrativos complexos.

---

## 7. Funcionalidades principais

| Área | Funcionalidade | Descrição |
|---|---|---|
| Autenticação | Cadastro e login | Permitir acesso seguro ao aplicativo. |
| Compras | Listas de compras | Criar, editar, excluir e finalizar listas. |
| Compras | Itens da lista | Adicionar, editar, remover e marcar itens como comprados. |
| Compras | Categorias | Organizar itens por grupos. |
| Compras | Totais | Calcular total estimado ou realizado da lista. |
| Nota Fiscal | QR Code | Capturar informação fiscal a partir de QR Code. |
| Nota Fiscal | WebView | Abrir URL fiscal dentro do aplicativo. |
| Estoque | Controle de itens | Registrar produtos, quantidades e validade. |
| Histórico | Compras finalizadas | Consultar listas fechadas e seus resumos. |
| Notificações | Push/local | Enviar lembretes e alertas. |
| Compartilhamento | WhatsApp | Compartilhar lista ou resumo formatado. |

---

## 8. Jornada principal do usuário

1. O usuário acessa o aplicativo e autentica-se.
2. O usuário cria uma nova lista de compras.
3. O usuário adiciona itens, quantidades, categorias e preços quando disponíveis.
4. O sistema calcula o total da lista.
5. Durante a compra, o usuário marca itens como comprados.
6. O usuário compartilha a lista ou resumo, se necessário.
7. Ao terminar, o usuário fecha a compra.
8. O sistema grava a compra no histórico.
9. O usuário consulta compras anteriores ou usa dados para novas listas.

---

## 9. Regras de negócio iniciais

| ID | Regra | Descrição |
|---|---|---|
| RN-001 | Lista pertence a usuário | Toda lista deve estar associada ao usuário autenticado. |
| RN-002 | Item pertence a lista | Todo item deve estar associado a uma lista de compras. |
| RN-003 | Total da lista | O total deve considerar preço e quantidade dos itens com valor informado. |
| RN-004 | Fechamento de compra | Uma lista fechada deve ser preservada no histórico. |
| RN-005 | Acesso protegido | Usuários não devem acessar dados de outros usuários. |
| RN-006 | Compartilhamento | A mensagem compartilhada deve representar o estado atual da lista ou resumo. |
| RN-007 | Nota fiscal | A leitura de nota fiscal depende de QR Code ou URL fiscal válida. |

---

## 10. Premissas

- O aplicativo será desenvolvido em Flutter.
- O backend poderá usar Supabase, Firebase ou combinação definida em ADR específico.
- O usuário principal será uma pessoa autenticada.
- As funcionalidades serão evoluídas por módulos.
- A documentação seguirá a estrutura definida em `docs/`.
- Os requisitos funcionais serão rastreados em `docs/01-visao-geral/requisitos-funcionais.md`.

---

## 11. Dependências externas

| Dependência | Uso esperado |
|---|---|
| Flutter | Desenvolvimento mobile multiplataforma. |
| Supabase/Firebase | Autenticação, banco, storage, funções ou notificações conforme decisão arquitetural. |
| Google Sign-In | Autenticação com conta Google. |
| FCM | Notificações push. |
| WhatsApp/url_launcher | Compartilhamento externo. |
| WebView | Visualização de página de nota fiscal. |
| Leitor de QR Code | Captura de URL ou chave fiscal. |

---

## 12. Métricas de sucesso

| Métrica | Objetivo |
|---|---|
| Criação de lista | Usuário consegue criar uma lista em poucos passos. |
| Conclusão de compra | Usuário consegue finalizar uma lista e consultar no histórico. |
| Controle de total | Usuário consegue visualizar total estimado ou realizado. |
| Uso recorrente | Usuário reutiliza o aplicativo em compras futuras. |
| Compartilhamento | Usuário consegue enviar lista ou resumo por WhatsApp. |

---

## 13. Riscos iniciais

| Risco | Impacto | Mitigação |
|---|---|---|
| Extração de nota fiscal variar por estado/serviço | Alto | Começar com leitura de QR Code e WebView antes de parser completo. |
| Offline aumentar complexidade de sincronização | Médio | Definir claramente quais operações funcionam offline. |
| Mistura Supabase/Firebase gerar duplicidade | Médio | Registrar decisões em ADRs. |
| Escopo crescer rápido | Médio | Priorizar MVP e backlog por versão. |

---

## 14. Referências relacionadas

- `docs/01-visao-geral/requisitos-funcionais.md`
- `docs/01-visao-geral/glossario.md`
- `docs/03-modulos/compras.md`
- `docs/02-arquitetura/fluxo-de-dados.md`
- `docs/04-banco-de-dados/esquema-er.md`

---

FIM
