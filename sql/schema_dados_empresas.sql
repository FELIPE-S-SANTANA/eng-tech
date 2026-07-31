CREATE SCHEMA IF NOT EXISTS dados_empresas;

SET search_path TO dados_empresas;

-- =============================================================
-- TABELAS DE DOMÍNIO
-- =============================================================

CREATE TABLE paises (
    codigo      CHAR(3)         NOT NULL,
    descricao   VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_paises PRIMARY KEY (codigo)
);

CREATE TABLE municipios (
    codigo      CHAR(7)         NOT NULL,
    descricao   VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_municipios PRIMARY KEY (codigo)
);

CREATE TABLE qualificacoes_socios (
    codigo      CHAR(2)         NOT NULL,
    descricao   VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_qualificacoes_socios PRIMARY KEY (codigo)
);

CREATE TABLE motivos (
    codigo      CHAR(2)      NOT NULL,
    descricao   VARCHAR(100) NOT NULL,
    CONSTRAINT pk_motivos PRIMARY KEY (codigo)
);

CREATE TABLE naturezas_juridicas (
    codigo      CHAR(4)         NOT NULL,
    descricao   VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_naturezas_juridicas PRIMARY KEY (codigo)
);

CREATE TABLE cnaes (
    codigo      CHAR(7)         NOT NULL,
    descricao   VARCHAR(200)    NOT NULL,
    CONSTRAINT pk_cnaes PRIMARY KEY (codigo)
);


-- =============================================================
-- EMPRESAS
-- =============================================================

CREATE TABLE empresas (
    cnpj_basico             CHAR(8)         NOT NULL,
    razao_social            VARCHAR(200)    NOT NULL,
    natureza_juridica       CHAR(4),
    qualif_responsavel      CHAR(2),
    capital_social          NUMERIC(18, 2),
    porte_empresa           CHAR(2),
    ente_federativo_resp    VARCHAR(50),

    CONSTRAINT pk_empresas PRIMARY KEY (cnpj_basico),

    CONSTRAINT fk_empresa_natureza FOREIGN KEY (natureza_juridica)
        REFERENCES naturezas_juridicas (codigo)
);

-- =============================================================
-- ESTABELECIMENTOS
-- =============================================================

CREATE TABLE estabelecimentos (
    cnpj_basico             CHAR(8)         NOT NULL,
    cnpj_ordem              CHAR(4)         NOT NULL,
    cnpj_dv                 CHAR(2)         NOT NULL,
    identificador_mf        CHAR(1)         NOT NULL,
    nome_fantasia           VARCHAR(200),
    situacao_cadastral      CHAR(2),
    data_situacao_cadastral DATE,
    motivo_situacao_cad     CHAR(2),
    cidade_exterior         VARCHAR(100),
    pais                    CHAR(3),
    data_inicio_atividade   DATE,
    cnae_fiscal_principal   CHAR(7),
    cnae_fiscal_secundaria  TEXT,
    tipo_logradouro         VARCHAR(20),
    logradouro              VARCHAR(200),
    numero                  VARCHAR(10),
    complemento             VARCHAR(255),
    bairro                  VARCHAR(100),
    cep                     CHAR(8),
    uf                      CHAR(2),
    municipio               CHAR(7),
    ddd1                    CHAR(4),
    telefone1               VARCHAR(9),
    ddd2                    CHAR(4),
    telefone2               VARCHAR(9),
    ddd_fax                 CHAR(4),
    fax                     VARCHAR(9),
    correio_eletronico      VARCHAR(115),
    situacao_especial       VARCHAR(100),
    data_situacao_especial  DATE,

    CONSTRAINT pk_estabelecimentos PRIMARY KEY (cnpj_basico, cnpj_ordem, cnpj_dv),

    CONSTRAINT fk_estab_empresa FOREIGN KEY (cnpj_basico)
        REFERENCES empresas (cnpj_basico),

    CONSTRAINT fk_estab_cnae FOREIGN KEY (cnae_fiscal_principal)
        REFERENCES cnaes (codigo),

    CONSTRAINT fk_estab_municipio FOREIGN KEY (municipio)
        REFERENCES municipios (codigo),

    CONSTRAINT ck_identificador_mf CHECK (
        identificador_mf IN ('1', '2')
    ),

    CONSTRAINT ck_situacao_cadastral CHECK (
        situacao_cadastral IN ('01', '02', '03', '04', '08')
    )
);


-- =============================================================
-- SIMPLES NACIONAL
-- =============================================================

CREATE TABLE simples (
    cnpj_basico             CHAR(8)         NOT NULL,
    opcao_simples           CHAR(1),
    data_opcao_simples      TEXT,
    data_exclusao_simples   TEXT,
    opcao_mei               CHAR(1),
    data_opcao_mei          TEXT,
    data_exclusao_mei       TEXT,

    CONSTRAINT pk_simples PRIMARY KEY (cnpj_basico),

    CONSTRAINT ck_opcao_simples CHECK (
        opcao_simples IN ('S', 'N') OR opcao_simples IS NULL
    ),

    CONSTRAINT ck_opcao_mei CHECK (
        opcao_mei IN ('S', 'N') OR opcao_mei IS NULL
    )
);


-- =============================================================
-- SÓCIOS
-- =============================================================

CREATE TABLE socios (
    cnpj_basico             CHAR(8)         NOT NULL,
    identificador_socio     CHAR(1)         NOT NULL,
    nome_socio              VARCHAR(200),
    cnpj_cpf_socio          VARCHAR(14),
    qualif_socio            CHAR(2),
    data_entrada_sociedade  DATE,
    pais                    CHAR(3),
    representante_legal     VARCHAR(11),
    nome_representante      VARCHAR(200),
    qualif_representante    CHAR(2),
    faixa_etaria            CHAR(1),

    CONSTRAINT fk_socio_empresa FOREIGN KEY (cnpj_basico)
        REFERENCES empresas (cnpj_basico),

    CONSTRAINT fk_socio_qualif FOREIGN KEY (qualif_socio)
        REFERENCES qualificacoes_socios (codigo),

    CONSTRAINT fk_socio_qualif_rep FOREIGN KEY (qualif_representante)
        REFERENCES qualificacoes_socios (codigo),

    CONSTRAINT ck_identificador_socio CHECK (
        identificador_socio IN ('1', '2', '3')
    ),

    CONSTRAINT ck_faixa_etaria CHECK (
        faixa_etaria IN ('0','1','2','3','4','5','6','7','8','9')
    )
);


-- =========================================================
-- ESTABELECIMENTOS
-- =========================================================

CREATE INDEX idx_estabelecimentos_cnpj_basico
ON estabelecimentos (cnpj_basico);

CREATE INDEX idx_estabelecimentos_cnpj_completo
ON estabelecimentos (
    cnpj_basico,
    cnpj_ordem,
    cnpj_dv
);

CREATE INDEX idx_estabelecimentos_uf
ON estabelecimentos (uf);

CREATE INDEX idx_estabelecimentos_cnae
ON estabelecimentos (cnae_fiscal_principal);

CREATE INDEX idx_estabelecimentos_situacao
ON estabelecimentos (situacao_cadastral);

CREATE INDEX idx_estabelecimentos_data_inicio
ON estabelecimentos (data_inicio_atividade);


-- =========================================================
-- EMPRESAS
-- =========================================================

CREATE INDEX idx_empresas_cnpj_basico
ON empresas (cnpj_basico);

CREATE INDEX idx_empresas_natureza
ON empresas (natureza_juridica);

CREATE INDEX idx_empresas_porte
ON empresas (porte_empresa);


-- =========================================================
-- SIMPLES
-- =========================================================

CREATE INDEX idx_simples_cnpj_basico
ON simples (cnpj_basico);

CREATE INDEX idx_simples_opcao
ON simples (opcao_simples);

CREATE INDEX idx_simples_mei
ON simples (opcao_mei);


-- =========================================================
-- SOCIOS
-- =========================================================

CREATE INDEX idx_socios_cnpj_basico
ON socios (cnpj_basico);

CREATE INDEX idx_socios_qualificacao
ON socios (qualif_socio);

CREATE INDEX idx_socios_data_entrada
ON socios (data_entrada_sociedade);

-- Executar somente após criacao dos index, executar um por vez

VACUUM ANALYZE estabelecimentos;

VACUUM ANALYZE empresas;

VACUUM ANALYZE simples;

VACUUM ANALYZE socios;
