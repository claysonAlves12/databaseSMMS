-------------------------------------------------------------------------------- script somente venda
----------------------------------------------------------------------------------------procedures
drop procedure abrirVenda
drop procedure vendaDeProduto

go

------------------------------------------------------------------------------- Procedure para iniciar venda e codigo para executar procedure
create procedure abrirVenda
    @codCliente int,
    @codVenda int output 
as
begin
    -- Inserindo uma nova venda
    insert into venda (codCliente, dataVenda)
    values (@codCliente, getdate());

    -- Obtendo o código da venda recém-criada
    set @codVenda = scope_identity(); 
end;

go

-- execute para iniciar a venda 
declare @codVenda int;
exec abrirVenda @codCliente = 1, @codVenda = @codVenda output;
-------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------- procedure Venda de Produto 
-- drop procedure vendaDeProduto
create procedure vendaDeProduto
    @codProduto int,
    @quantidade int,
    @codVenda int
as
begin
    -- Verificando se a venda existe
    if not exists (select 1 from venda where id = @codVenda)
    begin
        raiserror('Venda não encontrada.', 15, 1);
        return;
    end;

	    -- Verificando se o produto existe
    if not exists (select 1 from produto where id = @codProduto)
   begin
        raiserror('Produto não encontrado.', 16, 1);
        return;
    end;

    -- Verificando se há estoque suficiente para o produto
    declare @estoqueAtual int;
    select @estoqueAtual = estoque from produto where id = @codProduto;

    if @estoqueAtual < @quantidade
    begin
        raiserror('Estoque insuficiente para o produto selecionado.', 17, 1);
        return;
    end;

    -- Atualizando ou inserindo o produto vendido na tabela vendaProduto
    if exists (select 1 from vendaProduto where codVenda = @codVenda and codProduto = @codProduto)
    begin
        -- Atualizando a quantidade e o valor total
        update vendaProduto
        set quantidade = quantidade + @quantidade,
            valorTotal = (quantidade + @quantidade) * (select valorUnitario from produto where id = @codProduto)
        where codVenda = @codVenda and codProduto = @codProduto;
    end

    else
    begin
        -- Inserindo o produto vendido na tabela vendaProduto
        declare @valorTotal int;
        set @valorTotal = @quantidade * (select valorUnitario from produto where id = @codProduto);

        insert into vendaProduto (codVenda, codProduto, quantidade, valorTotal)
        values (@codVenda, @codProduto, @quantidade, @valorTotal);
    end;

    -- Atualizando o estoque produto
    declare @quantidadeRestante int;
    set @quantidadeRestante = @estoqueAtual - @quantidade;

    update produto set estoque = @quantidadeRestante where id = @codProduto;

    -- Calculando e atualizando o valor total da venda
    update venda
	set valorTotal = (
        select sum(vp.quantidade * p.valorUnitario)
        from vendaProduto vp
        inner join produto p ON vp.codProduto = p.id
		where vp.codVenda = @codVenda
    )
    where id = @codVenda;

    return 0;
end;


------------ scrip para vender o produto Obs.: o execute
exec vendaDeProduto @codProduto = 2, @quantidade = 1, @codVenda = 4;
---------------------------------------------------------------------------------------

------------------------------------------------ testes ----------------------------------------
select * from venda;
select * from vendaProduto;
select * from produto

delete from venda;
delete from vendaProduto;
------------------------------------------------------------------------------------------------


------------------------------------------------------------------------trigger para atualizar o status do estoque
--drop trigger tr_atualizarEstoqueProduto 
create trigger tr_atualizarEstoqueProduto 
on produto 
after insert, update 
as 
begin
  
    update produto 
    set produtoStatus = case 
                            when estoque > 0 then 1 
                            else 0 
                        end
    WHERE id IN (select id from inserted);

    
    update produto 
    set produtoStatus = 0 
    where id in (select id from inserted) and estoque = 0;
end;


-- iniciando venda
go
---------------------------------------------------------------------------------



------------------------------------------------------------------- script OS procedures
--drop procedure abrirOs
create procedure abrirOs
    @codCliente int,
	 @codOs int output 
as
begin
    -- Inserindo uma nova os
    insert into os (codCliente, dataInicial)
    values (@codCliente, getdate());

    -- Obtendo o código da os recém-criada
    set @codOs = scope_identity();

end;

SELECT * FROM os;

--------------- execute os para criar uma os 
declare @codOs int;
exec abrirOs @codCliente = 1, @codOs = @codOs output; 
------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------- procedure Os
--drop procedure produtoOs
CREATE PROCEDURE produtoOs
    @codProduto int,
    @quantidade int,
    @codOs int
AS
BEGIN
    -- Verificando se a OS existe
    IF NOT EXISTS (SELECT 1 FROM os WHERE id = @codOs)
    BEGIN
        RAISERROR('OS não encontrada.', 18, 1);
        RETURN;
    END;

    -- Verificando se o produto existe
    IF NOT EXISTS (SELECT 1 FROM produto WHERE id = @codProduto)
    BEGIN
        RAISERROR('Produto não encontrado.', 16, 1);
        RETURN;
    END;

    -- Verificando se há estoque suficiente para o produto
    DECLARE @estoqueAtual int;
    SELECT @estoqueAtual = estoque FROM produto WHERE id = @codProduto;

    IF @estoqueAtual < @quantidade
    BEGIN
        RAISERROR('Estoque insuficiente para o produto selecionado.', 17, 1);
        RETURN;
    END;

    -- Atualizando ou inserindo o produto vendido na tabela osProduto
    IF EXISTS (SELECT 1 FROM osProduto WHERE codOs = @codOs AND codProduto = @codProduto)
    BEGIN
        -- Atualizando a quantidade e o valor total
        UPDATE osProduto
        SET quantidade = quantidade + @quantidade,
            valorTotal = (quantidade + @quantidade) * (SELECT valorUnitario FROM produto WHERE id = @codProduto)
        WHERE codOs = @codOs AND codProduto = @codProduto;
    END
    ELSE
    BEGIN
        -- Inserindo o produto vendido na tabela osProduto
        DECLARE @valorTotal int;
        SET @valorTotal = @quantidade * (SELECT valorUnitario FROM produto WHERE id = @codProduto);

        INSERT INTO osProduto (codOs, codProduto, quantidade, valorTotal)
        VALUES (@codOs, @codProduto, @quantidade, @valorTotal);
    END;

END;



------------------------------comando para executar a procedure para os venda de produto
EXEC produtoOs @codProduto = 2, @quantidade = 1, @codOs = 5;
-------------------------------------------------------------------------

-------------------------------------------------test-----------------------------------
select * from os
select * from osProduto
select * from produto

delete from os
delete from osProduto
delete from osServico
------------------------------------------------------------------------------------------
---------------------------------triger para atualizar o valorTotal da Os

--drop trigger tr_atualizarValorTotalOs
CREATE TRIGGER tr_atualizarValorTotalOs
ON osProduto 
AFTER UPDATE, insert
AS
BEGIN
    DECLARE 
        @codOs int,
        @valorTotal INT;

    SELECT @codOs = codOs, @valorTotal = SUM(valorTotal) 
    FROM inserted 
    GROUP BY codOs;

    UPDATE os
    SET valorTotal = (SELECT SUM(valorTotal) FROM osProduto WHERE codOs = @codOs)
    WHERE id = @codOs;
END






---------------------------------------------------triger para atualizar o estoque quando inserir na tabela osProduto
--drop trigger trgAtualizaEstoque
CREATE TRIGGER trgAtualizaEstoque
ON osProduto
AFTER INSERT, UPDATE
AS
BEGIN
    -- Verifica se é uma inserção
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN deleted d ON i.codProduto = d.codProduto WHERE d.codProduto IS NULL)
    BEGIN
        -- Inserção
        UPDATE produto
        SET estoque = estoque - i.quantidade
        FROM produto
        INNER JOIN inserted i ON produto.id = i.codProduto;
    END;
    ELSE
    BEGIN
        -- Atualização
        UPDATE produto
        SET estoque = estoque - (i.quantidade - COALESCE(d.quantidade, 0))
        FROM produto
        INNER JOIN inserted i ON produto.id = i.codProduto
        INNER JOIN deleted d ON i.codProduto = d.codProduto;
    END;
END;

