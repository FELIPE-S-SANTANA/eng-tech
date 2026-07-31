# 📊 EngTech: Inteligência de Dados para Sobrevivência Empresarial

**Projeto de TCC em Engenharia de Dados** *Abordagem prática (Hands-On) focada na construção de uma solução de dados end-to-end para análise de risco empresarial no Brasil.*

### 👥 Integrantes

* **Davi Araujo** – 10731795
* **Rafael Cruz** – 10732175
* **Everton Ribeiro** – 10732297
* **Felipe Santana** – 10732452
* **Erickson Silva** – 10732435
* **Leonardo Gomes** – 10731860

---

## 🚀 1. Visão Geral e Contexto de Negócio

A taxa de mortalidade de empresas no Brasil é um fator crítico para o desenvolvimento econômico. Este projeto apresenta uma solução de dados completa para responder a um problema real de mercado: **qual a probabilidade de uma empresa encerrar as suas atividades nos primeiros 5 anos de vida?**

A análise utiliza variáveis estruturais, financeiras e regionais para identificar padrões que expliquem este fenômeno, permitindo uma tomada de decisão baseada em dados para empreendedores, analistas de crédito e investidores.

---

## 🔗 2. Detalhamento das Fontes de Dados (Data Sources)

Para solucionar a fragmentação e detalhar a origem técnica, as fontes de dados foram mapeadas diretamente dos repositórios oficiais:

* **Repositório de Arquivos (RFB):** [Arquivos Receita Federal](https://arquivos.receitafederal.gov.br/index.php/s/YggdBLfdninEJX9?dir=/2025-10)
*Servidor público que hospeda os arquivos brutos compactados (`.zip`). É a fonte primária de onde o pipeline extrai os dados de forma massiva.*
* **Portal de Dados Abertos (Gov.br):** [Dados.gov.br - CNPJ](https://dados.gov.br/dados/conjuntos-dados/cadastro-nacional-da-pessoa-juridica---cnpj)
*Catálogo oficial que fornece os metadados, layouts técnicos e a descrição detalhada de cada campo das tabelas.*

### 🗺️ Mapeamento de Tabelas vs. Arquivos Originais

| Nome da Tabela | Arquivo de Origem (RFB) | Conteúdo e Aplicação no Projeto |
| --- | --- | --- |
| **EMPRESAS** | `K3241.K0312.V1.EMPRE.D...zip` | Dados estruturais: Capital Social, Natureza Jurídica e Porte da Empresa. |
| **ESTABELECIMENTOS** | `K3241.K0312.V1.ESTABELE.D...zip` | Dados de operação: CNAE (Setor), Situação Cadastral e Localização Geográfica. |
| **SIMPLES** | `K3241.K0312.V1.SIMPLES.D...zip` | Dados tributários: Identificação de opção pelo MEI e pelo regime Simples Nacional. |

---

## 🏗️ 3. Arquitetura da Solução e Pipeline ETL

A arquitetura da solução foi projetada para ser altamente eficiente e robusta, utilizando orquestração via script batch (`EXECUTAR.BAT`) e as poderosas capacidades nativas do **PostgreSQL** para todo o processamento de dados (**Medallion Architecture**). A abordagem prioriza o processamento *in-database* (ELT) para garantir máxima performance com grandes volumes de dados.

<img width="2986" height="1408" alt="Diagrama Atualziado" src="https://github.com/user-attachments/assets/41ad67ef-be71-4acd-b0a0-2db6ddbc406c" />

* **Ingestão e Landing Zone (Raw):** O fluxo de dados brutos inicia-se a partir de repositórios locais (`C:/rfb/`), onde se encontram os arquivos compactados (`.zip`) e descompactados (`.csv`). A Landing Zone é constituída por este diretório local, garantindo a linhagem dos dados (*data lineage*) e permitindo o reprocessamento rápido sem a necessidade de novos downloads.
* **Camada Bronze (Staging Area):** A ingestão é orquestrada por um arquivo `.bat` que aciona um script Python executado via terminal. Através de comandos SQL nativos `\copy`, a tarefa automatizada realiza o carregamento direto dos dados dos arquivos `.csv` para as tabelas de estágio no PostgreSQL. Nesta camada, os dados mantêm sua estrutura original de texto (`LATIN1`) para fins de auditoria.
* **Processamento e Camada Silver (Trusted):** A fase de processamento e transformação ocorre integralmente dentro do PostgreSQL por meio de scripts SQL. O pipeline consome as tabelas da Camada Bronze e executa:
1. **Tipagem de Datas:** Conversão via `TO_DATE` (padrão `YYYYMMDD` para `DATE`), com tratamento de inconsistências para `NULL`.
2. **Tipagem Numérica:** Tratamento do campo de capital social (substituição de `,` por `.` e conversão para `numeric`).
3. **Conversão de Encoding:** Transição assistida de `LATIN1` para `UTF-8`.
4. **Normalização:** Limpeza de strings e remoção de registros vazios.


Os dados higienizados são persistidos na Camada Silver em suas respectivas tabelas normalizadas (`empresas`, `estabelecimentos`, `cnaes`, `municipios`, `simples`), sem joins pré-processados, consolidando um repositório confiável e limpo.
* **Data Warehouse (Gold Ready):** Os dados estruturados da Camada Silver estão prontos para o enriquecimento e a modelagem de visões analíticas na futura Camada Gold. Esta fase final será responsável por estruturar as tabelas analíticas necessárias para o treinamento dos modelos de Machine Learning e para o consumo de alta performance por dashboards.

---

## 🧠 4. Dicionário de Dados e Engenharia de Features

Com base no critério de seleção técnica, o modelo preditivo focará nas variáveis de maior impacto para o negócio:

* **Variável Alvo (Target):** `SITUAÇÃO CADASTRAL` (Ativa / Baixada) combinada com a `DATA DA SITUAÇÃO CADASTRAL` para determinar matematicamente a ocorrência de falência/encerramento em até 5 anos de atividade.
* **Features Selecionadas:**
* **CAPITAL SOCIAL:** Indicador de robustez e resistência financeira inicial da empresa.
* **CNAE FISCAL:** Setor econômico de atuação (indústria, comércio, serviços, etc.).
* **NATUREZA JURÍDICA:** Estrutura legal da constituição empresarial (LTDA, S/A, EIRELI).
* **UF / MUNICÍPIO:** Indicadores do contexto econômico, infraestrutura e mercado regional.
* **PORTE DA EMPRESA:** Classificação do porte do negócio (Micro, Pequena ou Média/Grande).



---

## 🧰 5. Tecnologias Utilizadas

* **Linguagens:** SQL (PostgreSQL Dialect) para ingestão e transformações em banco; Python (Pandas, Scikit-Learn) focado na etapa de Ciência de Dados e Machine Learning.
* **Armazenamento e Processamento:** PostgreSQL (atuando como repositório central das camadas Bronze e Silver).
* **Visualização e Aplicação:** Power BI (análises executivas e dashboards BI) e Streamlit (aplicação web interativa).
* **Versionamento:** Git & GitHub.

---

## 📊 6. Resultados Esperados

* **Modelo Preditivo de Risco:** Algoritmo de classificação capaz de gerar o score de probabilidade de encerramento de novas empresas com base nas características de registro.
* **Dashboard Executivo:** Painel interativo com mapas e gráficos setoriais detalhando a demografia e a mortalidade empresarial no Brasil.
* **Simulador de Viabilidade:** Interface interativa em Streamlit onde o usuário insere os dados de abertura de uma empresa hipotética (Localização, CNAE, Capital Social) e recebe o diagnóstico de risco em tempo real.

---
