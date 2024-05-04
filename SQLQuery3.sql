drop procedure abrirVenda
drop procedure vendaDeProduto

--procedure para iniciar venda e codigo para executar procedure

CREATE PROCEDURE abrirVenda
    @codCliente int,
    @codVenda int output 
AS
BEGIN
    -- Inserir uma nova venda
    INSERT INTO venda (codCliente, dataVenda)
    VALUES (@codCliente, GETDATE());

    -- Obter o código da venda recém-criada
    SELECT @codVenda = SCOPE_IDENTITY(); 

    -- Retornar o código da venda
    SELECT @codVenda as codVenda; 
END;

go

declare @codVenda int;
EXEC abrirVenda @codCliente = 1, @codVenda = @codVenda OUTPUT; 

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
CREATE PROCEDURE vendaDeProduto
    @codProduto int,
    @quantidade int,
    @codVenda int
AS
BEGIN
    -- Verificar se o produto existe
    IF NOT EXISTS (SELECT 1 FROM produto WHERE id = @codProduto)
    BEGIN
        RAISERROR('Produto não encontrado.', 16, 1);
        RETURN;
    END;

    -- Verificar se a venda existe
    IF NOT EXISTS (SELECT 1 FROM venda WHERE id = @codVenda)
    BEGIN
        RAISERROR('Venda não encontrada.', 15, 1);
        RETURN;
    END;

    -- Verificar se há estoque suficiente para o produto
    DECLARE @estoqueAtual int;
    SELECT @estoqueAtual = estoque FROM produto WHERE id = @codProduto;

    IF @estoqueAtual < @quantidade
    BEGIN
        RAISERROR('Estoque insuficiente para o produto selecionado.', 17, 1);
        RETURN; 
    END;

    -- Atualizar ou inserir o produto vendido na tabela vendaProduto
    IF EXISTS (SELECT 1 FROM vendaProduto WHERE codVenda = @codVenda AND codProduto = @codProduto)
    BEGIN
        -- Atualizar a quantidade e o valor total
        UPDATE vendaProduto
        SET quantidade = quantidade + @quantidade,
            valorTotal = (quantidade + @quantidade) * (SELECT valorUnitario FROM produto WHERE id = @codProduto)
        WHERE codVenda = @codVenda AND codProduto = @codProduto;
    END
    ELSE
    BEGIN
        -- Inserir o produto vendido na tabela vendaProduto
        DECLARE @valorTotal int;
        SELECT @valorTotal = @quantidade * (SELECT valorUnitario FROM produto WHERE id = @codProduto);

        INSERT INTO vendaProduto (codVenda, codProduto, quantidade, valorTotal)
        VALUES (@codVenda, @codProduto, @quantidade, @valorTotal);
    END;

    -- Atualizar o estoque 
    DECLARE @quantidadeRestante int;
    SET @quantidadeRestante = @estoqueAtual - @quantidade;

    UPDATE produto SET estoque = @quantidadeRestante WHERE id = @codProduto;

    -- Verificar estoque
    IF @quantidadeRestante <= 0
    BEGIN
        -- Atualizar o status do produto para 0 (false = inativo)
        UPDATE produto SET produtoStatus = 0 WHERE id = @codProduto;
    END;

    -- Calcular e atualizar o valor total da venda
    UPDATE venda
    SET valorTotal = (
        SELECT SUM(vp.quantidade * p.valorUnitario)
        FROM vendaProduto vp
        INNER JOIN produto p ON vp.codProduto = p.id
        WHERE vp.codVenda = @codVenda
    )
    WHERE id = @codVenda;

    -- Finalmente, retornar o sucesso da operação
    RETURN 0;
END;

-- iniciando venda
go
EXEC vendaDeProduto @codProduto = 1, @quantidade = 1, @codVenda = 4;


SELECT * FROM venda;
SELECT * FROM vendaProduto;
select * from produto

DELETE FROM venda;
DELETE FROM vendaProduto;

