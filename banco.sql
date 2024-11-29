CREATE TABLE clientes (
    id_cliente INT IDENTITY(1,1) NOT NULL,
    nome NVARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL,
    endereco NVARCHAR(255),
    telefone VARCHAR(15),
    email NVARCHAR(100),
    data_cadastro DATETIME DEFAULT GETDATE(),
	CONSTRAINT pk_clientes PRIMARY KEY CLUSTERED (id_cliente)
);

CREATE TABLE contas (
    id_conta INT IDENTITY(1,1),
    id_cliente INT,
    tipo_conta NVARCHAR(50),
    saldo DECIMAL(18,2) DEFAULT 0.00,
    data_abertura DATETIME DEFAULT GETDATE(),
    status_conta NVARCHAR(20) DEFAULT 'Ativa',
	CONSTRAINT pk_contas PRIMARY KEY CLUSTERED (id_conta)
);
ALTER TABLE contas 
   ADD CONSTRAINT fk_cliente FOREIGN KEY (id_cliente)
   REFERENCES clientes (id_cliente)

CREATE TABLE transacoes (
    id_transacao INT IDENTITY(1,1),
    id_conta INT,
    tipo_transacao NVARCHAR(50),
    valor DECIMAL(18,2),
    data_transacao DATETIME DEFAULT GETDATE(),
    descricao NVARCHAR(255),
	CONSTRAINT pk_transacoes PRIMARY KEY CLUSTERED (id_transacao),
);
ALTER TABLE transacoes 
   ADD CONSTRAINT fk_conta FOREIGN KEY (id_conta)
   REFERENCES contas (id_conta)

CREATE TABLE emprestimos (
    id_emprestimo INT IDENTITY(1,1),
    id_cliente INT,
    valor DECIMAL(18,2),
    taxa_juros DECIMAL(5,2),
    prazo_meses INT,
    data_emprestimo DATETIME DEFAULT GETDATE(),
    status_emprestimo NVARCHAR(20) DEFAULT 'Ativo',
	CONSTRAINT pk_emprestimos PRIMARY KEY CLUSTERED (id_emprestimo)
);
ALTER TABLE emprestimos 
   ADD CONSTRAINT fk_cliente FOREIGN KEY (id_cliente)
   REFERENCES clientes (id_cliente)

CREATE TABLE cartoes_credito (
    id_cartao INT IDENTITY(1,1),
    id_cliente INT,
    numero_cartao CHAR(16),
    limite_credito DECIMAL(18,2),
    data_vencimento DATETIME,
    status_cartao NVARCHAR(20) DEFAULT 'Ativo',
	CONSTRAINT pk_cartoes_credito PRIMARY KEY CLUSTERED (id_cartao)
);
ALTER TABLE cartoes_credito 
   ADD CONSTRAINT fk_cliente FOREIGN KEY (id_cliente)
   REFERENCES clientes (id_cliente)

CREATE TABLE taxas_cambio (
    id_taxa INT IDENTITY(1,1),
    moeda_origem NVARCHAR(3),
    moeda_destino NVARCHAR(3),
    taxa DECIMAL(18,6),
    data_taxa DATETIME DEFAULT GETDATE()
	CONSTRAINT pk_taxas_cambio PRIMARY KEY CLUSTERED (id_taxa)
);


DECLARE @i INT = 0;
WHILE @i < 10000
BEGIN
    INSERT INTO clientes (nome, cpf, endereco, telefone, email)
    VALUES 
        ('Cliente ' + CAST(@i AS NVARCHAR(10)), 
        REPLACE(CONVERT(VARCHAR(11), NEWID()), '-', ''), 
        'Endereco ' + CAST(@i AS NVARCHAR(10)), 
        '555-' + RIGHT('00000000' + CAST(RAND() * 10000000 AS INT), 8), 
        'cliente' + CAST(@i AS NVARCHAR(10)) + '@email.com');

	INSERT INTO contas (id_cliente, tipo_conta, saldo, data_abertura, status_conta)
    VALUES 
        (FLOOR(RAND() * 10000) + 1,  -- ClienteID aleatório
        CASE WHEN RAND() < 0.5 THEN 'Corrente' ELSE 'Poupança' END, 
        ROUND(RAND() * 10000, 2), 
        DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE()),  -- Data aleatória dentro do último ano
        CASE WHEN RAND() < 0.9 THEN 'Ativa' ELSE 'Inativa' END);

	INSERT INTO transacoes (id_conta, tipo_transacao, valor, data_transacao, descricao)
    VALUES 
        (FLOOR(RAND() * 10000) + 1,  -- ContaID aleatória
        CASE WHEN RAND() < 0.33 THEN 'Depósito' 
             WHEN RAND() < 0.66 THEN 'Saque' 
             ELSE 'Transferência' END,
        ROUND(RAND() * 1000, 2), 
        DATEADD(MINUTE, -FLOOR(RAND() * 10000), GETDATE()),  -- Data aleatória nos últimos dias
        'Transação ' + CAST(@i AS NVARCHAR(10)));

	INSERT INTO emprestimos (id_cliente, valor, taxa_juros, prazo_meses, data_emprestimo, status_emprestimo)
    VALUES 
        (FLOOR(RAND() * 10000) + 1,  -- ClienteID aleatório
        ROUND(RAND() * 50000, 2),  -- Valor do empréstimo
        ROUND(RAND() * 15, 2),     -- Taxa de juros (0-15%)
        FLOOR(RAND() * 60) + 12,   -- Prazo em meses (12 a 72 meses)
        DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE()),  -- Data aleatória
        CASE WHEN RAND() < 0.9 THEN 'Ativo' ELSE 'Inadimplente' END);
    
	INSERT INTO cartoes_Credito (id_cliente, numero_cartao, limite_credito, data_vencimento, status_cartao)
    VALUES 
        (FLOOR(RAND() * 10000) + 1,  -- ClienteID aleatório
        CAST(FLOOR(RAND() * 10000000000000000) AS CHAR(16)),  -- Número aleatório de 16 dígitos
        ROUND(RAND() * 5000, 2), 
        DATEADD(DAY, FLOOR(RAND() * 30), GETDATE()),  -- Data de vencimento aleatória no próximo mês
        CASE WHEN RAND() < 0.95 THEN 'Ativo' ELSE 'Bloqueado' END);

	INSERT INTO taxas_cambio (moeda_origem, moeda_destino, taxa, data_taxa)
    VALUES 
        (CASE WHEN RAND() < 0.5 THEN 'USD' ELSE 'EUR' END,  -- Moeda de origem (USD ou EUR)
        CASE WHEN RAND() < 0.5 THEN 'BRL' ELSE 'GBP' END,   -- Moeda de destino (BRL ou GBP)
        ROUND(RAND() * 5 + 1, 4),  -- Taxa de câmbio entre 1.0000 e 6.0000
        DATEADD(DAY, -FLOOR(RAND() * 30), GETDATE()));  -- Data aleatória nos últimos 30 dias
    

    SET @i = @i + 1;
END

