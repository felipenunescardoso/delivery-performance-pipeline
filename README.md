DELIVERY PERFORMANCE

Projeto de engenharia de dados e Business Intelligence desenvolvido com Python, SQL Server e Power BI.

A solução implementa uma pipeline local de ETL, utilizando arquitetura em camadas Bronze (STG), Silver (ODS) e Gold (DW), com modelagem dimensional em Star Schema para consumo analítico no Power BI.


REQUISITOS

- Python 3
- SQL Server Express ou superior
- SQL Server Management Studio (SSMS)
- ODBC Driver 18 for SQL Server
- Microsoft Power BI Desktop
- Pandas
- PyODBC
- PyArrow


ARQUIVOS DO PROJETO

client_name.xlsx
Base de clientes utilizada pela pipeline.

client_sla.xlsx
Base contendo as regras de SLA por cliente.

config.json
Arquivo de configuração da conexão com o SQL Server e dos caminhos utilizados pela pipeline.

Delivery_Performance.pbix
Dashboard desenvolvido no Microsoft Power BI.

Delivery_Performance_DW.sql
Script responsável pela criação do banco Delivery_Performance_DW, schemas, tabelas, procedures, login e permissões.

Documentacao_Arquitetura_PowerBI.pdf
Documentação técnica da modelagem dimensional e arquitetura utilizada no Power BI.

msodbcsql18.msi
Instalador do Microsoft ODBC Driver 18 for SQL Server.

orders.parquet
Base de pedidos utilizada no processamento da pipeline.

Pipeline.py
Pipeline Python responsável pela leitura, validação, tratamento e carga dos dados no SQL Server.

region.xlsx
Base contendo os dados de regiões.


INSTALAÇÃO

1. COPIE A PASTA DO PROJETO

Copie os arquivos do projeto para:

C:\Delivery Performance


2. INSTALE O ODBC DRIVER 18

Caso o Microsoft ODBC Driver 18 for SQL Server não esteja instalado, execute:

msodbcsql18.msi


3. INSTALE AS DEPENDÊNCIAS PYTHON

Abra um terminal e execute:

pip install pandas pyodbc pyarrow openpyxl


4. CRIE O BANCO DE DADOS

Abra o SQL Server Management Studio (SSMS).

Execute o script:

Delivery_Performance_DW.sql

O script irá criar:

- Banco Delivery_Performance_DW
- Login adm_pwbi
- Schemas STG, ODS, DW e ETL
- Tabelas utilizadas pela pipeline
- Stored Procedures de carga e tratamento
- Permissões necessárias para execução da solução


5. CONFIGURE A INSTÂNCIA DO SQL SERVER

Abra o arquivo:

C:\Delivery Performance\config.json

Altere o campo "server" caso sua instância do SQL Server possua outro nome.

Exemplo:

"server": ".\\SQLEXPRESS"


6. EXECUTE A PIPELINE

Abra um terminal na pasta:

C:\Delivery Performance

Execute:

python Pipeline.py

A pipeline realiza a leitura dos arquivos Excel e Parquet, tratamento e validação dos dados e carga das camadas Bronze, Silver e Gold.

A atualização dos dados ocorre automaticamente a cada 5 minutos.

Mantenha o terminal aberto durante a execução da pipeline.


7. ABRA O DASHBOARD

Abra:

Delivery_Performance.pbix

No Power BI Desktop, clique em "Atualizar" na página inicial.

O dashboard irá consumir os dados processados e armazenados na camada Gold do Data Warehouse.


ARQUITETURA

Origem dos Dados
        |
        v
Python / Pandas
        |
        v
STG - Bronze
        |
        v
ODS - Silver
        |
        v
DW - Gold
        |
        v
Power BI


ESTRATÉGIA DE ATUALIZAÇÃO

A solução utiliza Full Load.

A cada execução da pipeline:

- A camada Bronze é limpa.
- Os arquivos de origem são carregados novamente.
- A camada Silver é reconstruída.
- A camada Gold é atualizada.
- Os dados ficam disponíveis para consumo no Power BI.

Essa estratégia garante consistência entre as camadas da solução.
