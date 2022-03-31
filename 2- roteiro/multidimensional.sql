
CREATE TABLE public.dim_funcionario (
                sk_funcionario INTEGER NOT NULL,
                nk_funcionario VARCHAR NOT NULL,
                nm_func VARCHAR(20) NOT NULL,
                genero CHAR(1) NOT NULL,
                cod_func INTEGER NOT NULL,
                CONSTRAINT sk_funcionario PRIMARY KEY (sk_funcionario)
);


CREATE TABLE public.dim_data (
sk_data integer not null,
nk_data date not null,
desc_data_completa varchar(60) not null,
nr_ano integer not null,
nm_trimestre varchar(20) not null,
nr_ano_trimestre varchar(20) not null,
nr_mes integer not null,
nm_mes varchar(20) not null,
ano_mes varchar(20) not null,
nr_semana integer not null,
ano_semana varchar(20) not null,
nr_dia integer not null,
nr_dia_ano integer not null,
nm_dia_semana varchar(20) not null,
flag_final_semana char(3) not null,
flag_feriado char(3) not null,
nm_feriado varchar(60) not null,
etl_dt_inicio timestamp not null,
etl_dt_fim timestamp not null,
versao integer not null,
constraint sk_data_pk primary key (sk_data)
);

insert into dim_data
select to_number(to_char(datum,'yyyymmdd'), '99999999') as sk_tempo,
datum as nk_data,
to_char(datum,'dd/mm/yyyy') as data_completa_formatada,
extract (year from datum) as nr_ano,
'T' || to_char(datum, 'q') as nm_trimestre,
to_char(datum, '"T"q/yyyy') as nr_ano_trimenstre,
extract(month from datum) as nr_mes,
to_char(datum, 'tmMonth') as nm_mes,
to_char(datum, 'yyyy/mm') as nr_ano_nr_mes,
extract(week from datum) as nr_semana,
to_char(datum, 'iyyy/iw') as nr_ano_nr_semana,
extract(day from datum) as nr_dia,
extract(doy from datum) as nr_dia_ano,
to_char(datum, 'tmDay') as nm_dia_semana,
case when extract(isodow from datum) in (6, 7) then 'Sim' else 'Não'
end as flag_final_semana,
case when to_char(datum, 'mmdd') in ('0101','0421','0501','0907','1012','1102','1115','1120','1225') then 'Sim' else 'Não'
end as flag_feriado,
case 
---incluir aqui os feriados
when to_char(datum, 'mmdd') = '0101' then 'Ano Novo' 
when to_char(datum, 'mmdd') = '0421' then 'Tiradentes'
when to_char(datum, 'mmdd') = '0501' then 'Dia do Trabalhador'
when to_char(datum, 'mmdd') = '0907' then 'Dia da Pátria' 
when to_char(datum, 'mmdd') = '1012' then 'Nossa Senhora Aparecida' 
when to_char(datum, 'mmdd') = '1102' then 'Finados' 
when to_char(datum, 'mmdd') = '1115' then 'Proclamação da República'
when to_char(datum, 'mmdd') = '1120' then 'Dia da Consciência Negra'
when to_char(datum, 'mmdd') = '1225' then 'Natal' 
else 'Não é Feriado'
end as nm_feriado,
current_timestamp as data_carga,
'2199-12-31',
'1'
from (
---incluir aqui a data de início do script, criaremos 15 anos de datas
select '2020-01-01'::date + sequence.day as datum
from generate_series(0,5479) as sequence(day)
group by sequence.day
) dq
order by 1;


CREATE TABLE public.dim_cliente (
                sk_cliente INTEGER NOT NULL,
                cod_cliente INTEGER NOT NULL,
                nk_cliente INTEGER NOT NULL,
                nm_cliente VARCHAR(50) NOT NULL,
                genero CHAR(1) NOT NULL,
                bairro VARCHAR(50) NOT NULL,
                dt_nascimento DATE NOT NULL,
                cidade VARCHAR(50) NOT NULL,
                CONSTRAINT sk_cliente PRIMARY KEY (sk_cliente)
);


CREATE TABLE public.dim_produto (
                sk_produto VARCHAR NOT NULL,
                nk_produto INTEGER NOT NULL,
                nm_produto VARCHAR(30) NOT NULL,
                copo VARCHAR(20) NOT NULL,
                pote VARCHAR(20) NOT NULL,
                sabor VARCHAR(20) NOT NULL,
                preco REAL NOT NULL,
                CONSTRAINT sk_produto PRIMARY KEY (sk_produto)
);


CREATE TABLE public.ft_venda (
                sk_cliente INTEGER NOT NULL,
                sk_produto VARCHAR NOT NULL,
                sk_data INTEGER NOT NULL,
                sk_funcionario INTEGER NOT NULL
);


ALTER TABLE public.ft_venda ADD CONSTRAINT dim_funcionario_ft_venda_fk
FOREIGN KEY (sk_funcionario)
REFERENCES public.dim_funcionario (sk_funcionario)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.ft_venda ADD CONSTRAINT dim_data_ft_venda_fk
FOREIGN KEY (sk_data)
REFERENCES public.dim_data (sk_data)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.ft_venda ADD CONSTRAINT dim_cliente_ft_venda_fk
FOREIGN KEY (sk_cliente)
REFERENCES public.dim_cliente (sk_cliente)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.ft_venda ADD CONSTRAINT dim_produto_ft_venda_fk
FOREIGN KEY (sk_produto)
REFERENCES public.dim_produto (sk_produto)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;