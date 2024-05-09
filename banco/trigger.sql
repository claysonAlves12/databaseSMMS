drop trigger tr_atualizarEstoqueProduto 

--trigger para atualizar estoque

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