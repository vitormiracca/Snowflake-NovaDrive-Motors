# Snowflake-NovaDrive-Motors
***em desenvolvimento***

### O PROJETO

Projeto prático de Pipeline de Dados, desenvolvido em um bootcamp ministrado por Fernando Amaral.
Para este bootcamp, Fernando disponibilizou um ambiente que simula muito bem um site de vendas de carros. Temos o site, onde os vendedores podem registrar as vendas de carros realizadas, e temos um banco de dados transacional (real) registrando todas as informações.

A ídeia é termos um ambiente muito próximo da realidade de alguns projetos reais de engenharia de dados, onde iremos construir o fluxo para a construção e manutenção de um ambiente de dados analíticos para este empresa de vendas de carros de luxo: a NovaDrive Motors.
*******

### A ARQUITETURA

*** Anexar desenho da solução ***

Para a arquitetura deste ambiente, iremos contar com tecnologias modernas como:
- PostgreSQL: Banco de Dados Transacional do site de vendas;
- Snowflake: Poderoso Data Warehouse, para o ambiente analítico da empresa;
- AWS: provedor de cloud 
    - EC2: para configurar e rodar o Airflow e o código fonte, como para hospedar o Snowflake;
- Airflow com Docker: para orquestração dos Data Pipelines;
- DBT: manipulação e transformação de Dados no Snowflake;

### Em que pé estamos:

Configuramos as conexões ao banco de dados transacional da NovaDriver (PostgreSQL), no meu caso usando o DBeaver, para em seguida fizeros uma breve análise exploratória, para conhecer o schema e seus objetos. (/exploracao_sql/exp_pg_novadrive.sql).

Em seguida, configuramos e subimos uma instância do EC2 na AWS. Como iremos usar o Airflow, sendo instalado com os containers do Docker, as máquinas elegíveis ao Free Tier da AWS podem não ter os recursos suficientes para esta arquitetura, portanto escolhemos uma máquina Ubuntu 22.04 LTS, com t2.large de 8GB de RAM com 2vCPU (ainda assim, está configuração apenas para desenvovimento do projeto, terá um custo pouco significativo, se bem gerida).
Após configurar um par de chaves para conexão SSH nesta instância e definição de usuários, rodamos uma série de comandos para preparar o ambiente e configurar o Airflow, começando com a criação de um role de segurança para a porta 8080 (porta que hospeda o Airflow), como várias outras configurações e instalações via linha de comando da inmstância (/infra/instalacao_airflow_docker.sh).

E em seguida, configuramos nosso ambiente de Data Warehouse no Snowflake, criando um database (novadrive), o primeiro schema para o pouso inicial dos dados na camada analítica (stage) e os objetos necessários dentro deste schema, como também o Warehouse para os recursos computacionais e de processamento. Como este primeiro schema se trata da extração dos dados do banco de dados relacional (PostgreSQL), criamos os mesmos objetos lá presentes (/infra/config_snowflake.sql)

Desenvolvemos uma grande dag Dinamica para carrgeamento dos dados de forma incremental no Snowflake.
"Dinâmica" pois a estrutura do Banco de Dados Relacional permite isso, pois todas as tabelas possuem um padrão de chave primária (sendo sempre "id_[nome_da_tabela]"), e como foi decidido seguir com carga incremental, podemos colocar todas as tabelas numa lista, e percorrer esta lista para gerar tasks dinâmica.
Para as tasks, definimos duas tasks para cada tabela: uma onde buscamos o registro com o último id da tabela (chave pramária) lá no Snowflake, e uma outra task que insere os registros com id (chave primária) que ainda não existem no Snowflake, ou seja, incrementa os novos registros na camada analítica.

Este passo é o passo inicial do ELT, onde extraimos e carregamos os dados numa landing zone no ambiente análitico.
Para as próximas etapas, concentramos os esforços no T de Transform, visando gerar tabelas análiticas, de acordo com as necessidades do time de negócios.
