use  master

drop database automoveis

create database automoveis 
go
use automoveis
go

create table cliente (
	id int primary key identity (1,1),
	nome varchar (60),
	endereco varchar(60),
	telefone nchar(9)
)

go

create table venda (
	id int primary key identity (1,1),
	codCliente int,
)

go

create table vendaProduto(
	id int primary key identity(1,1),
	codVenda int,
	codProduto int,
	quantidade int,
	valorTotal int
)

go

create table produto(
	id int primary key identity(1,1),
	nome nchar(20),
	valorUnitario int,
	estoque int
)

go

create table osProduto(
	id int primary key identity(1,1),
	codProduto int,
	codOs int,
	quantidade int,
	valorTotal int
)

go

create table os(
	id int primary key identity(1,1),
	codCliente int ,
	descricao varchar(60),
	valorTotal int,
	dataReparacao date DEFAULT GETDATE()
)

go

create table osServico(
	id int primary key identity(1,1),
	codOs int,
	codServico int,
	quantidade int,
	valorTotal int
)

go

create table servico(
	id int primary key identity(1,1),
	nomeServico varchar(30),
	valor int
)

go

create table osFuncionario(
	id int primary key identity(1,1),
	codOs int,
	codFuncionario int
)

go

Create table funcionario(
	id int primary key identity(1,1),
	nome varchar(60),
	telefone nchar (9),
	endereco varchar(60),
	codCategoria int
)

go

create table categoria(
	id int primary key identity(1,1),
	valor int
)

go

alter table venda add constraint FK_clienteVenda 
foreign key (codCliente) references cliente(id);

go

alter table vendaProduto add constraint FK_vendaProduto_venda 
foreign key (codVenda) references venda(id);

go

alter table vendaProduto add constraint FK_vendaProduto_produto
foreign key (codProduto) references produto(id);

go

alter table osProduto add constraint FK_osProduto_produto 
foreign key (codProduto) references produto(id);

go

alter table osProduto add constraint FK_vendaProduto_os
foreign key (codOs) references os(id);

go

alter table os add constraint FK_clienteOs
foreign key (codCliente) references cliente(id);

go

alter table osServico add constraint FK_clienteServico_os
foreign key (codOs) references os(id);

go

alter table osServico add constraint FK_clienteServico_servico
foreign key (codServico) references servico(id);

go

alter table osFuncionario add constraint FK_osFuncionario_os
foreign key (codOs) references os(id);

go

alter table osFuncionario add constraint FK_osFuncionario_funcionario
foreign key (codFuncionario) references funcionario(id);

go

alter table funcionario add constraint FK_funcionarioCategoria
foreign key (codCategoria) references categoria(id);

-- Select na tabela cliente
SELECT * FROM cliente;
SELECT * FROM venda;
SELECT * FROM vendaProduto;
SELECT * FROM produto;
SELECT * FROM osProduto;
SELECT * FROM os;
SELECT * FROM osServico;
SELECT * FROM servico;
SELECT * FROM osFuncionario;
SELECT * FROM funcionario;
SELECT * FROM categoria;

insert into cliente (nome,endereco,telefone) values
	('clayson','rua 123','991029578'),
	('lucas1','rua 321', '991029567');

insert into produto (nome, valorUnitario, estoque) values
	('capa',10, null ),
	('banco',20,null);

insert into servico(nomeServico, valor) values
	('troca banco', 20),
	('troca capa', 10);

insert into categoria(valor) values
	(50),
	(100);

insert into funcionario(nome, telefone,endereco,codCategoria) values
	('pedro','991029712','rua rua t', 2),
	('thiago','991029514','rua dois',1);