# World Cup Analytics — O Paradoxo do Hexa

> **Brasil tem o 6º maior perfil estatístico de campeão mundial. E não ganha uma Copa há 24 anos.**
> Esse projeto analisa 92 anos de Copa do Mundo (1930–2022) para entender o porquê.

<img width="1289" height="720" alt="Capa Inicial" src="https://github.com/user-attachments/assets/97b97fde-25da-423b-98dc-30e05d452d58" />

---

## 📌 O projeto

Esse projeto começou com uma pergunta que todo brasileiro já fez em algum momento:

**Por que o Brasil não ganha mais uma Copa do Mundo?**

Os números históricos não justificam 24 anos sem título. O Brasil é a maior seleção da história em quase todas as métricas absolutas — mais participações, mais vitórias, mais gols, mais títulos. Mas desde 2002 não levanta o troféu.

Então fui atrás da resposta da única forma defensável: com dados.

Analisei 964 partidas de Copa do Mundo entre 1930 e 2022 para:

1. Identificar o **padrão estatístico dos campeões** mundiais (DNA do campeão)
2. Mapear a **trajetória histórica do Brasil** em 22 Copas
3. Confrontar o Brasil 2022 com esse padrão
4. Construir uma **síntese reflexiva** sobre o paradoxo do hexa

A resposta encontrada não é simples. Mas é **defensável**, **reproduzível** e **conta uma história** que não cabe num achismo da imprensa esportiva.

---

## 🎯 Objetivo

Construir uma análise end-to-end que responda a 7 perguntas de negócio sobre o desempenho histórico das seleções em Copas do Mundo, usando uma stack completa de engenharia de dados, SQL avançado, machine learning e visualização — entregando um dashboard navegável que conecta dado bruto a narrativa executiva.

---

## 🛠️ Stack — cada ferramenta com um propósito

```
PostgreSQL (DBeaver)  →  SQL Avançado  →  Python (Jupyter)  →  Power BI  →  GitHub
        ↓                     ↓                  ↓                ↓             ↓
   Banco de dados      7 perguntas        Feature Eng       5 páginas      Portfólio
                       de negócio         + ML pipeline     navegáveis     público
```

## 📁 Estrutura do repositório

```
world-cup-analytics/
├── README.md                          # Este arquivo
├── requirements.txt                   # Dependências Python
├── data/
│   ├── raw/                           # Dados brutos (matches, world_cup)
│   ├── processed/                     # matches_clean.csv
│   └── analytics/                     # Tabelas de fato (CSVs exportados)
├── notebooks/
│   ├── 01_data_cleaning.ipynb         # Tratamento inicial
│   └── feature_engineering_final.ipynb # Pipeline ML + export
├── sql/
│   ├── setup/                         # Scripts de criação e carga
│   └── queries/                       # 7 queries das perguntas de negócio
├── powerbi/
│   └── world_cup_analytics.pbix       # Dashboard
└── docs/
    └── screenshots/                   # Imagens do dashboard
```

---

### Detalhamento por etapa

**Etapa 1 — Python · pandas** *(tratamento de dados brutos)*
Padronização das fases, criação da coluna `Result` com lógica de pênaltis, conversão de datas, consolidação histórica de nomes (West Germany → Germany, Soviet Union → Russia). Saída: `matches_clean.csv`.

**Etapa 2 — PostgreSQL** *(banco principal)*
Os dados tratados foram carregados em PostgreSQL local — não direto no Power BI via CSV. Essa escolha é a diferença entre um projeto que escala e um que não escala.

**Etapa 3 — DBeaver · SQL avançado** *(respondendo as 7 perguntas)*
CTEs, window functions, subqueries e CASE WHEN para responder cada uma das 7 perguntas com SQL puro antes de partir pro Python.

**Etapa 4 — Python · Jupyter · scikit-learn · scipy** *(feature engineering e modelagem)*
Pipeline de dados em 4 camadas (Kimball-style), seguido de PCA, clustering hierárquico e cálculo de Champion Probability via distância de Mahalanobis.

**Etapa 5 — Power BI** *(dashboard final)*
5 páginas conectadas aos CSVs processados. Cada página responde uma camada da narrativa: DNA → Histórico → Deep Dive 2022 → Paradoxo 2026.

**Etapa 6 — GitHub** *(repositório público)*
Código documentado, queries SQL comentadas, notebook reproduzível e este README em linguagem de negócio.

---

## 📊 As 7 perguntas de negócio

### Bloco 1 — DNA do Campeão
- **Q1** — Qual o perfil de gols dos campeões históricos (marcados, sofridos, saldo)?
- **Q2** — Em quais fases o campeão se diferencia mais dos demais?
- **Q7** — Times campeões são mais disciplinados (cartões)?

### Bloco 2 — Brasil Histórico
- **Q3** — Como evoluiu o aproveitamento do Brasil Copa a Copa?
- **Q4** — Em quais fases e contra quais adversários o Brasil mais perde?

### Bloco 3 — Brasil e o futuro
- **Q5** — Quais seleções mais evoluíram nas últimas Copas?
- **Q6** — Qual seleção tem o perfil mais próximo do campeão histórico?

---

## 🏗️ Arquitetura de dados

Pipeline em 4 camadas, com granularidade declarada em cada nível:

```
matches_clean (964 partidas, 1930–2022)
    ↓
team_matches                    → 1 linha = 1 seleção × 1 partida
    ↓
fact_team_historical_stats      → 1 linha = 1 seleção (all-time)
fact_team_year_stage_stats      → 1 linha = 1 seleção × edição × fase
fact_modern_team_stats          → 1 linha = 1 seleção (2002+)
fact_team_ml_features           → 1 linha = 1 seleção (com cluster + scores)
```

### Decisões metodológicas-chave

**1. Lógica de empate com pênaltis.** Jogos decididos em pênaltis foram tratados como W/L pelo critério "quem avançou" — não como empate FIFA. Decisão documentada e auditável.

**2. Classificação por Era.** Classic Era (1930–1970) · Modern Era (1970–2002) · Contemporary Era (2002+). O formato da Copa mudou demais para comparar 1930 com 2022 sem contexto.

**3. Consolidação histórica de nomes.** West Germany → Germany, Soviet Union → Russia, Yugoslavia → Serbia, Czechoslovakia → Czech Republic. Aplicada uma única vez na fonte.

**4. Knockout como constante.** `KNOCKOUT_STAGES = ['Oitavas de Final', 'Quartas de Final', 'Semi-finais', 'Final', 'Terceiro Lugar']` — definido uma vez, reutilizado em toda a pipeline.

---

## 🤖 Modelagem de ML

### Features selecionadas (4)

Após análise de correlação com `is_champion`:
- `win_rate`
- `avg_goals_scored`
- `avg_goals_conceded`
- `knockout_win_rate`

`titles` foi explicitamente **excluída** — usar a variável-alvo como feature é leakage. `gd_per_match` também foi excluída por ser combinação linear de gols marcados e sofridos (prevenção de multicolinearidade).

### PCA + Clustering Hierárquico

- **PCA** concentrou **90,5% da variância em 2 componentes** (PCA1 = 72,8%, PCA2 = 17,7%)
- **Clustering Hierárquico (Ward)** com k validado via Silhouette Score (k=2 a k=6)
- **k=4 escolhido por interpretabilidade**, gerando 4 perfis com significado real:

```
🏆 World Cup Champions     →  8 seleções
⚡ Elite Contenders         →  ~10 seleções
💪 Strong Nations           →  ~25 seleções
🌱 Emerging Teams           →  ~38 seleções
```

### Champion Probability

Score de proximidade ao centroide dos campeões, calculado via **distância de Mahalanobis** com matriz de covariância robusta (pseudo-inversa de Moore-Penrose). Normalizado para escala 0–1.

```python
champ_centroid = X_scaled[champ_mask].mean(axis=0)
cov_inv = np.linalg.pinv(np.cov(X_scaled.T))
distances = [mahalanobis(row, champ_centroid, cov_inv) for row in X_scaled]
champion_probability = (1 - (distances - d_min) / (d_max - d_min)).round(3)
```

> **Nota técnica:** o nome "champion_probability" é uma simplificação narrativa. Tecnicamente, é um **score de similaridade normalizado**, não uma probabilidade Bayesiana. A renomeação para `champion_dna_score` está prevista como melhoria futura (ver seção *Limitações*).

---

## 📺 Dashboard — 5 páginas

| # | Página | Pergunta que responde |
|---|---|---|
| 1 | **Capa** | Identidade visual e hook narrativo |
| 2 | **DNA dos Campeões** | O que define um campeão estatisticamente? (Q1, Q2, Q7) |
| 3 | **Histórico do Brasil em Copas** | Como o Brasil chegou até aqui? (Q3, Q4) |
| 4 | **Brasil 2022** | Anatomia da última eliminação — radar tático + comparação direta com Argentina |
| 5 | **O Paradoxo do Hexa** | Brasil tem DNA de campeão, jejum de 24 anos — síntese reflexiva (Q5, Q6) |

Cada página tem **um tempo verbal e um propósito distinto** — não há redundância entre elas. A jornada de leitura é:

> *Conceito → Trajetória → Caso concreto → Síntese*

---

## 💡 Principais achados

### 1. Champion Probability do Brasil: 0,95 (6º no mundo)

Brasil está no cluster *World Cup Champions* do modelo, a apenas 0,05 do líder (Argentina). O perfil estatístico de campeão **está lá** — win rate de 69%, knockout win rate de 69%, 2,08 gols marcados por jogo, 0,95 sofridos.

### 2. Brasil tem o 3º maior jejum entre os campeões mundiais

Em 2026, são **24 anos sem título** desde 2002. Atrás apenas de Inglaterra (60 anos, último em 1966) e Uruguai (76 anos, último em 1950). Argentina venceu há 4 anos, França há 8, Alemanha há 12.

### 3. Brasil 2022 dominou tanto quanto Argentina — mas não converteu

Os dois times terminaram a Copa do Qatar com saldo idêntico de **+1,00 gol por jogo**. A diferença foi em como cada um construiu esse saldo:
- Argentina venceu jogos de alta voltagem (3-3 com França na final, pênaltis com Holanda nas quartas)
- Brasil controlou jogos de baixa intensidade na fase de grupos e não encontrou repertório quando precisou sofrer (eliminado nos pênaltis pela Croácia)

### 4. A defesa não foi o problema do Brasil 2022

Contrariando a percepção comum, a defesa do Brasil 2022 ficou **acima** do padrão dos campeões modernos (0,64 vs 0,61 padronizado). E foi mais **disciplinado** que a média (0,72 vs 0,54). O gap real estava em produção ofensiva: 1,60 gols/jogo do Brasil vs 2,14 da Argentina.

### 5. A "maldição das quartas" é mensurável

Brasil foi eliminado nas Quartas de Final em **4 das últimas 5 Copas** (2006, 2010, 2018, 2022). A única exceção foi 2014 — quando passou das quartas e perdeu por 7-1 na semifinal.

---

## 🔄 Como reproduzir

### Pré-requisitos
- Python 3.10+
- PostgreSQL 14+
- Power BI Desktop
- Bibliotecas Python: `pandas`, `numpy`, `scikit-learn`, `scipy`, `seaborn`, `matplotlib`

### Passo a passo

```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/world-cup-analytics.git
cd world-cup-analytics

# 2. Instalar dependências
pip install -r requirements.txt

# 3. Rodar o tratamento inicial
jupyter notebook notebooks/01_data_cleaning.ipynb

# 4. Carregar no PostgreSQL (scripts em /sql/setup)
psql -U usuario -d worldcup -f sql/setup/create_tables.sql
psql -U usuario -d worldcup -f sql/setup/load_data.sql

# 5. Rodar o feature engineering e ML
jupyter notebook notebooks/feature_engineering_final.ipynb

# 6. Abrir o dashboard
# Power BI Desktop → Abrir → /powerbi/world_cup_analytics.pbix
```

---

## ⚠️ Limitações reconhecidas

Toda análise tem trade-offs. Esses são os principais:

**1. `champion_probability` não é probabilidade Bayesiana.**
É um score de similaridade normalizado via distância de Mahalanobis. Não vem de função de likelihood, não soma 1 sobre nada, não passa por sigmoide/softmax. A renomeação para `champion_dna_score` é a forma correta de comunicar.

**2. Tautologia centroide ↔ campeões.**
O centroide é definido pela média dos próprios campeões. Por construção, campeões têm score alto. O sinal útil está na **posição relativa dos não-campeões** (Bélgica, Holanda, Croácia, Portugal).

**3. Filtragem de times sem jogos de knockout.**
Times com `knockout_matches == 0` foram preenchidos com `knockout_win_rate = 0`. Tecnicamente, deveriam ser tratados como missing — mas filtrar reduz a amostra demais. Trade-off documentado.

**4. Disciplina ausente das ML_FEATURES.**
A Q7 (cartões) aparece como contraste descritivo no dashboard, mas não entrou no modelo de clusterização. Disciplina depende muito de árbitro e era — adicionaria ruído sem aumentar separabilidade. Decisão defensável, mas reconhecida.

**5. Era contemporânea com poucas Copas.**
A análise "campeões modernos" usa só 6 edições (2002–2022). N pequeno para conclusões absolutas, suficiente para narrativa comparativa.

---

## 🚀 Próximos passos

- Renomear `champion_probability` → `champion_dna_score` no notebook e no Power BI
- Adicionar `yellow_cards` e `red_cards` na agregação de `fact_team_year_stage_stats`
- Testar inclusão de `discipline_per_match` em ML_FEATURES e validar via silhouette
- Validar Champion DNA Score com **leave-one-out** nos campeões (remove a tautologia)
- Atualizar dados após Copa de 2026 e revisitar a tese do paradoxo do hexa

---


## 👤 Sobre

Projeto desenvolvido como case de portfólio em análise de dados, com foco em demonstrar:
- Domínio de stack completa (banco → SQL → Python → BI → versionamento)
- Capacidade de traduzir pergunta de negócio em pipeline técnico
- Maturidade analítica (reconhecimento de limitações, decisões metodológicas explícitas)
- Comunicação de dado em linguagem executiva (dashboard navegável + narrativa de negócio)

**Contato:** [LinkedIn](#) · [Email](#)

---

*Última atualização: maio de 2026*
