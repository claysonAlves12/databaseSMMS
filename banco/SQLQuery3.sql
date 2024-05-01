drop procedure vendaDeProduto

CREATE PROCEDURE vendaDeProduto
    @codProduto int,
    @quantidade int
AS
BEGIN
    DECLARE @codVenda int;

    -- Verificar se há vendas na tabela venda
    IF NOT EXISTS (SELECT 1 FROM venda)
    BEGIN
        -- Se não houver vendas, inserir uma nova venda com o código do cliente definido como 1
        INSERT INTO venda (codCliente)
        VALUES (1);

        -- Obter o ID da última venda inserida
        SET @codVenda = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        -- Se houver vendas, obter o ID da última venda inserida
        SELECT @codVenda = MAX(id) FROM venda;
    END

    -- Inserir o produto vendido na tabela vendaProduto
    DECLARE @valorTotal int;
    SELECT @valorTotal = @quantidade * valorUnitario
    FROM produto
    WHERE id = @codProduto;

    INSERT INTO vendaProduto (codVenda, codProduto, quantidade, valorTotal)
    VALUES (@codVenda, @codProduto, @quantidade, @valorTotal);
END;


-- Executar a procedure venda com o produto de id 2 e uma quantidade de 3
EXEC vendaDeProduto @codProduto = 2, @quantidade = 3;

SELECT * FROM venda;
SELECT * FROM vendaProduto;


DELETE FROM venda;
DELETE FROM vendaProduto;

