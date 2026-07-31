import pandas as pd
import numpy as np
import time

# Funções auxiliares

# Conversão de tipos
def convert(df, colunas, type=1):

    if type == 1:
        for col in colunas:
            df[col] = pd.to_numeric(
                df[col],
                errors="coerce"
        )
    elif type == 2:
        for col in colunas:
            df[col] = df[col].astype("category")
    elif type == 3:
        for col in colunas:
            df[col] = pd.to_datetime(
                df[col],
                errors="coerce"
            )

    return df

# Declacração de variáveis fixas e auxiliares

CAM_PAD = r"C:\Users\leona\OneDrive\Documentos\MBA Eng Dados\Projeto Final de curso\base de dados"

CAM = CAM_PAD + r"\camada_silver_v2.csv"

CAM_GOLD = CAM_PAD + r"\camada_gold.csv"

CAM_TREINO = CAM_PAD + r"\camada_treino.csv"

CAM_TESTE = CAM_PAD + r"\camada_teste.csv"

regioes = {
    "AC": "Norte",
    "AP": "Norte",
    "AM": "Norte",
    "PA": "Norte",
    "RO": "Norte",
    "RR": "Norte",
    "TO": "Norte",

    "AL": "Nordeste",
    "BA": "Nordeste",
    "CE": "Nordeste",
    "MA": "Nordeste",
    "PB": "Nordeste",
    "PE": "Nordeste",
    "PI": "Nordeste",
    "RN": "Nordeste",
    "SE": "Nordeste",

    "DF": "Centro-Oeste",
    "GO": "Centro-Oeste",
    "MT": "Centro-Oeste",
    "MS": "Centro-Oeste",

    "ES": "Sudeste",
    "MG": "Sudeste",
    "RJ": "Sudeste",
    "SP": "Sudeste",

    "PR": "Sul",
    "RS": "Sul",
    "SC": "Sul",

    # Exterior
    "EX": "Exterior"
}

cod_regioes = {
    "Norte": 1,
    "Nordeste": 2,
    "Centro-Oeste": 3,
    "Sudeste": 4,
    "Sul": 5,
    "Exterior": 6
}

# 1. Marca o tempo de início
inicio = time.perf_counter()

# Importando dataframe
print("Importando base de dados...\n")

df = pd.read_csv(CAM, sep=";", encoding="latin-1")

# Marca o tempo de fim
fim = time.perf_counter()

# Calcula a diferença em segundos
tempo_total_segundos = fim - inicio

# Converte segundos para o formato hh:mm:ss
horas, resto = divmod(tempo_total_segundos, 3600)
minutos, segundos = divmod(resto, 60)

print(f"Tempo de importação da base: {int(horas):02d}:{int(minutos):02d}:{segundos:02.0f}\n")

# Removendo colunas irrelevantes
column_drop = [
    'cnpj_ordem', 'cnpj_dv', 'identificador_mf', 
    'nome_fantasia', 'motivo_situacao_cad', 
    'pais', 'cnae_fiscal_secundaria', 'municipio', 'data_situacao_especial', 
    'razao_social', 'qualif_responsavel', 'ente_federativo_resp', 
    'identificador_socio', 'qualif_socio', 'pais_socio', 
    'qualif_representante', 'opcao_simples', 'data_opcao_mei', 'data_exclusao_mei',
    'data_inicio_atividade', 'data_situacao_cadastral', 'data_situacao_especial',
    'data_entrada_sociedade', 'data_opcao_simples', 'data_exclusao_simples', 'data_opcao_mei',
    'data_exclusao_mei', 'faixa_etaria'
    ]

print("Removendo colunas irrelevantes...\n")

df_d = df.drop(columns=column_drop).copy()

# Reforçando filtros para garantir integridade dos dados

df_d = df_d[df_d["opcao_mei"] == "N"].copy()

df_d = df_d[df_d["porte_empresa"] != 5].copy()

# Adicionando colunas novas para análise
print("Adicionando colunas novas para análise...\n")

df_d["regiao"] = df_d["uf"].map(regioes)

df_d["cod_reg"] = df_d["regiao"].map(cod_regioes)

# Ajustando tipagem de dados
print("Ajustando tipagem de dados:")

print("1- Garantindo colunas com o tipo numérico")

column_data = [
    'cnae_fiscal_principal', 'porte_empresa', 'capital_social', 'natureza_juridica',
    'empresa_mais_5_anos', 'tempo_vida', 'tempo_exclusao_mei', 'tempo_op_simples', 
    'situacao_especial', 'tempo_excl_op_simples', 'cod_reg'
]

df_d = convert(df_d, column_data, type=1)

print("2- Garantindo colunas com o tipo categórico\n")

column_cat = ['uf', 'opcao_mei']

df_d = convert(df_d, column_cat, type=2)

# Ajustando tempos negativos
print("Ajustando tempos negativos...\n")

colunas_tempo = ['tempo_vida', 'tempo_exclusao_mei', 'tempo_op_simples', 'tempo_excl_op_simples']

for col in colunas_tempo:
    df_d[col] = df_d[col].apply(lambda x: 0 if x < 0 else x)

# Romvendo colunas auxiliares que não possuem utilidaede
print("Removendo colunas auxiliares que não possuem utilidaede...\n")

df_d = df_d.drop(columns=['regiao', 'uf', 'opcao_mei']).copy()

print("Tratamento de dados concluído com sucesso!\n")

print("Salvando base de dados tratada...\n")

df_d.to_csv(CAM_GOLD, index=False, sep=";", encoding="latin-1")

print("Separando dados para treinamento e teste:")

print("1- Treinamento...\n")

treino = df_d.head(int(len(df_d) * 0.8)).copy()

print("2- Teste...\n")

teste = df_d.tail(int(len(df_d) * 0.2)).copy()

print("Salvando bases de dados de treinamento e teste...\n")

treino.to_csv(CAM_TREINO, index=False, sep=";", encoding="latin-1")
teste.to_csv(CAM_TESTE, index=False, sep=";", encoding="latin-1")

# Marca o tempo de fim do código
fim_codigo = time.perf_counter()

tempo_total_segundos = fim_codigo - inicio

horas, resto = divmod(tempo_total_segundos, 3600)
minutos, segundos = divmod(resto, 60)

print(f"Fim do processo!\nTempo total de execução do código: {int(horas):02d}:{int(minutos):02d}:{segundos:02.0f}\n")
