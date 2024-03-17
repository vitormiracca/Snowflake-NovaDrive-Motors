-- Liste todos os veículos com tipo 'SUV Compacta' e valor inferior a 300.000,00.
select *
from veiculos v
where tipo = 'SUV Compacta'
	and valor < 300000;

-- Exiba o nome dos clientes e o nome das concessionárias onde realizaram suas compras.
select c1.cliente, c2.concessionaria 
from clientes c1 
join concessionarias c2
	on c1.id_concessionarias = c2.id_concessionarias
order by cliente ;

-- Conte quantos vendedores existem em cada concessionária.
select count(*) as contagem_vendedores, c.concessionaria 
from vendedores v 
join concessionarias c 
	on v.id_concessionarias = c.id_concessionarias
group by concessionaria ;

-- Encontre os veículos mais caros vendidos em cada tipo de veículo.
select v.tipo, v.valor, v.nome
from veiculos v
inner join (
	select vs.tipo, MAX(vs.valor) as valor_maximo
	from veiculos vs
	group by vs.tipo	
) as sub 
	on v.tipo = sub.tipo
		and v.valor = sub.valor_maximo
order by v.tipo;

-- Identifique as concessionárias que venderam mais de 500 veículos.
SELECT c.concessionaria, COUNT(v.*) AS total_vendas
FROM vendas v
inner join concessionarias c 
	on v.id_concessionarias = c.id_concessionarias 
GROUP BY concessionaria
HAVING COUNT(v.*) > 500;

-- Selecione todos os veículos adicionados nos últimos  2 mêses.
select v.nome, v.tipo, v.valor, v.data_inclusao
from veiculos v
where data_inclusao > current_timestamp - interval '2 month';

-- Encontre clientes que compraram veículos 'SUV Premium Híbrida' ou veículos com valor acima de 600.000,00, e indique o maior valor pago por eles.
select v.id_clientes, c.cliente, max(v.valor_pago) as maior_venda
from vendas v 
join veiculos v2 
	on v.id_veiculos = v2.id_veiculos
join clientes c
	on c.id_clientes = v.id_clientes
where v2.tipo = 'SUV Premium Híbrida'
	or v2.valor > 600000
group by v.id_clientes, c.cliente;