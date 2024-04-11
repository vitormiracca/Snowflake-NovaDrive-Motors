# Snowflake-NovaDrive-Motors

## O PROJETO

Projeto prático de Pipeline de Dados, desenvolvido em um bootcamp ministrado por Fernando Amaral.
Para este bootcamp, Fernando disponibilizou um ambiente que simula muito bem um site de vendas de carros. Temos o site, onde os vendedores podem registrar as vendas de carros realizadas, e temos um banco de dados transacional (real) registrando todas as informações.

A ídeia é termos um ambiente muito próximo da realidade de alguns projetos reais de engenharia de dados, onde iremos construir o fluxo para a construção e manutenção de um ambiente de dados analíticos para este empresa de vendas de carros de luxo: a NovaDrive Motors.
*******

## A ARQUITETURA

***Anexar desenho da solução***

Para a arquitetura deste ambiente, iremos contar com tecnologias modernas como:
- PostgreSQL: Banco de Dados Transacional do site de vendas;
- Snowflake: Poderoso Data Warehouse, para o ambiente analítico da empresa;
- Airflow: para orquestração dos Data Pipelines;
- AWS: provedor de cloud 
    - EC2: para configurar e rodar o Airflow e o código fonte, como para hospedar o Snowflake;
    - Docker: conteiner com o Airflow
- DBT: manipulação e transformação de Dados no Snowflake;

## O FLUXO:

### - Configurações Iniciais:

- Configuração das conexões ao banco de dados transacional da NovaDrive Motors (PostgreSQL), no meu caso usando o DBeaver.
    - Análise Exploratório dos dados para conhecer o schema e suas entidades. (/exploracao_sql/exp_pg_novadrive.sql)

- Subimos uma instância EC2 na AWS, com Airflow rodando em um container Docker, e configuramos as devidas chaves SSH, roles de segurança (porta 8080 para o Airflow), e demais configurações. 
    - Instalção do Airflow com Docker no EC2 em: */infra/instalacao_airflow_docker.sh*
    - as máquinas elegíveis ao Free Tier da AWS podem não ter os recursos suficientes para esta arquitetura, portanto escolhemos uma máquina Ubuntu 22.04 LTS, com t2.large de 8GB de RAM com 2vCPU. (custo pouco significativo, para este proejto)

- Configuramos nosso ambiente de Data Warehouse no Snowflake, criando um database (novadrive), o primeiro schema para o pouso inicial dos dados na camada analítica (stage) e os objetos necessários dentro deste schema, como também o Warehouse do Snowflake para os recursos computacionais e de processamento. */infra/config_snowflake.sql*

### - Extração:

- Desenvolvemos uma grande Dag dinâmica para carrgeamento dos dados de forma incremental no Snowflake.
    - "Dinâmica" pois a estrutura do Banco de Dados Relacional permite isso, pois todas as tabelas possuem um padrão de chave primária (sendo sempre "id_[nome_da_tabela]"), portanto podemos colocar todas as tabelas numa lista, e percorrer esta lista para gerar tasks dinâmica.
    - Para as tasks, definimos duas tasks para cada tabela: uma onde buscamos o registro com o último id da tabela (chave pramária) lá no Snowflake, e uma outra task que insere os registros com id (chave primária) que ainda não existem no Snowflake, ou seja, incrementa os novos registros na camada analítica.
    - Resultado: extraimos e carregamos os dados numa landing zone no ambiente análitico.

### - Transformação

- Criação de camadas de transformação (models) no DBT, para realizar as devidas transformações nos dados:
    - stage;
    - dimensions;
    - facts;
    - analysis;

- Desenvolvimentos das querys SQL no DBT, para transformação dos dados e inserção nas camadas de dados estruturados no Snowflake (a partir do DBT).

### - Resultado e Manutenção

Ao final de todo o desenvolvimento, temos um processo produtivo com Airflow, para extrair os dados diariamente do banco de dados transacional e carregá-los na primeira camada do ambiente analítico no Snowflake (stage).em seguida um processo de transformação nesses dados, rodando com o DBT, que ao final garante dados estruturados nas respectivas camadas do ambiente analítico, asssim como também já gera os datasets agregados e filtrados (conforme necessidade do negócio).

---
#### Referências:

Este projeto foi realizado durante o **Bootcamp Engenharia de Dados: Construa um Projeto Real -2024** do **Fernando Amaral**.
Link do curso: https://www.udemy.com/course/bootcamp-engenharia-de-dados/?couponCode=ST8MT40924