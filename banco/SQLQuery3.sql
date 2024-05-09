-- script somente venda
--procedures

-- Procedures somente de venda
drop procedure abrirVenda
drop procedure vendaDeProduto

go

-- Procedure para iniciar venda e codigo para executar procedure
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

declare @codVenda int;
exec abrirVenda @codCliente = 1, @codVenda = @codVenda output; 
-- PROCEDURE Venda de Produto )

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

    -- Atualizando o estoque 
    declare @quantidadeRestante int;
    set @quantidadeRestante = @estoqueAtual - @quantidade;

    update produto set estoque = @quantidadeRestante where id = @codProduto;

    -- Verificando o estoque
    if @quantidadeRestante <= 0
    begin
        -- Atualizando o status do produto para 0 (false = inativo)
        update produto set produtoStatus = 0 where id = @codProduto;
    end;

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

Go

--drop trigger tr_atualizarEstoqueProduto 
--trigger para atualizar o status do estoque
create trigger tr_atualizarEstoqueProduto on produto after insert, update as 
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
EXEC vendaDeProduto @codProduto = 1, @quantidade = 1, @codVenda = 2;

SELECT * FROM venda;
SELECT * FROM vendaProduto;
select * from produto

DELETE FROM venda;
DELETE FROM vendaProduto;





-- script OS 

create procedure abrirOs
    @codCliente int,
	 @codOs int output 
as
begin
    -- Inserindo uma nova venda
    insert into os (codCliente, dataReparacao)
    values (@codCliente, getdate());

    -- Obtendo o código da venda recém-criada
    set @codOs = scope_identity();

end;

SELECT * FROM os;

--abrindo os 
declare @codOs int;
exec abrirOs @codCliente = 1, @codOs = @codOs output; 


-- procedure Os
--drop procedure produtoOs
create procedure produtoOs
    @codProduto int,
    @quantidade int,
    @codOs int
as
begin
    -- Verificando se a venda existe
    if not exists (select 1 from os where id = @codOs)
    begin
        raiserror('Os não encontrada.', 15, 1);
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

    -- Atualizando ou inserindo o produto vendido na tabela osProduto
    if exists (select 1 from osProduto where codOs = @codOs and codProduto = @codProduto)
    begin
        -- Atualizando a quantidade e o valor total
        update osProduto
        set quantidade = quantidade + @quantidade,
            valorTotal = (quantidade + @quantidade) * (select valorUnitario from produto where id = @codProduto)
        where codOs = @codOs and codProduto = @codProduto;
    end

    else
    begin
        -- Inserindo o produto vendido na tabela vendaProduto
        declare @valorTotal int;
        set @valorTotal = @quantidade * (select valorUnitario from produto where id = @codProduto);

        insert into osProduto (codOs, codProduto, quantidade, valorTotal)
        values (@codOs, @codProduto, @quantidade, @valorTotal);
    end;

    -- Atualizando o estoque 
    declare @quantidadeRestante int;
    set @quantidadeRestante = @estoqueAtual - @quantidade;

    update produto set estoque = @quantidadeRestante where id = @codProduto;

    -- Verificando o estoque
    if @quantidadeRestante <= 0
    begin
        -- Atualizando o status do produto para 0 (false = inativo)
        update produto set produtoStatus = 0 where id = @codProduto;
    end;

    -- Calculando e atualizando o valor total da venda
    update os
	set valorTotal = (
        select sum(vp.quantidade * p.valorUnitario)
        from osProduto vp
        inner join produto p ON vp.codProduto = p.id
		where vp.codOs = @codOs
    )
    where id = @codOs;

    return 0;
end;

EXEC produtoOs @codProduto = 2, @quantidade = 1, @codOs = 1;

select * from os
select * from osProduto
select * from produto