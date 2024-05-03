CREATE TRIGGER tr_inserirEstoqueProduto
ON produto
AFTER INSERT
AS
BEGIN
    DECLARE @produto_id int;
    DECLARE @estoque_padrao int;

    -- Obt�m o ID do produto inserido
    SELECT @produto_id = id FROM inserted;

    -- Define o estoque padr�o para novos produtos (por exemplo, 0)
    SET @estoque_padrao = 0;

    -- Insere o estoque padr�o para o produto rec�m-inserido
    UPDATE produto
    SET estoque = @estoque_padrao
    WHERE id = @produto_id;
END;
