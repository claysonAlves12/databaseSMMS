drop trigger tr_atualizarEstoqueProduto 

--trigger para atualizar estoque

CREATE TRIGGER tr_atualizarEstoqueProduto ON produto AFTER INSERT, UPDATE AS 
BEGIN 
    -- Atualiza o produtoStatus com base no estoque inserido ou atualizado
    UPDATE produto 
    SET produtoStatus = CASE 
                            WHEN estoque > 0 THEN 1 
                            ELSE 0 
                        END
    WHERE id IN (SELECT id FROM inserted);

    -- Atualiza o produtoStatus para 0 quando o estoque chegar a 0
    UPDATE produto 
    SET produtoStatus = 0 
    WHERE id IN (SELECT id FROM inserted) AND estoque = 0;
END;

