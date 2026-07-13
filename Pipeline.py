import os
import json
import time
from datetime import datetime
import pandas as pd
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus

##Caminho do Arquivo
CONFIG_PATH = r"C:\Delivery_Performance\config.json"

#Ler a cada 5 minutos
INTERVALO_SEGUNDOS = 60 * 5

##Def inicial para ler o arquivo, precisa estar na pasta
def load_config():
    with open(CONFIG_PATH, "r", encoding="utf-8") as file:
        return json.load(file)


config = load_config()

BASE_PATH = config["paths"]["base_path"]

db = config["database"]

##Connection String de configuração, precisa estar odbc driver 18
connection_string = quote_plus(
    f"DRIVER={{{db['driver']}}};"
    f"SERVER={db['server']};"
    f"DATABASE={db['database']};"
    f"UID={db['user']};"
    f"PWD={db['password']};"
    f"TrustServerCertificate={'yes' if db['trust_server_certificate'] else 'no'};"
)

engine = create_engine(f"mssql+pyodbc:///?odbc_connect={connection_string}")


def get_file_path(file_key):
    return os.path.join(BASE_PATH, config["paths"][file_key])


def load_temp(df, temp_table):
    df.to_sql(
        temp_table,
        engine,
        schema="stg",
        if_exists="replace",
        index=False
    )


def execute_sql(sql):
    with engine.begin() as conn:
        conn.execute(text(sql))


def load_orders():
    df = pd.read_parquet(get_file_path("orders"))

    load_temp(df, "tmp_orders_raw")

    execute_sql("""
        MERGE stg.orders_raw AS target
        USING stg.tmp_orders_raw AS source
            ON target.idOrder = source.idOrder

        WHEN MATCHED THEN
            UPDATE SET
                target.idClient = source.idClient,
                target.consignorProvince = source.consignorProvince,
                target.consigneeProvince = source.consigneeProvince,
                target.consigneeZipCode = source.consigneeZipCode,
                target.receiveDate = source.receiveDate,
                target.deliveredTime = source.deliveredTime

        WHEN NOT MATCHED THEN
            INSERT
            (
                idOrder,
                idClient,
                consignorProvince,
                consigneeProvince,
                consigneeZipCode,
                receiveDate,
                deliveredTime
            )
            VALUES
            (
                source.idOrder,
                source.idClient,
                source.consignorProvince,
                source.consigneeProvince,
                source.consigneeZipCode,
                source.receiveDate,
                source.deliveredTime
            );
    """)

#Performance igual, demonstrando possibilidades na Pipeline
def load_client():
    df = pd.read_excel(get_file_path("client"))

    load_temp(df, "tmp_client_raw")

    execute_sql("""
        MERGE stg.client_raw AS target
        USING stg.tmp_client_raw AS source
            ON target.clientCode = source.clientCode

        WHEN MATCHED THEN
            UPDATE SET
                target.name = source.name,
                target.businessType = source.businessType,
                target.workDaysCalculation = source.workDaysCalculation,
                target.calculationRule = source.calculationRule

        WHEN NOT MATCHED THEN
            INSERT
            (
                clientCode,
                name,
                businessType,
                workDaysCalculation,
                calculationRule
            )
            VALUES
            (
                source.clientCode,
                source.name,
                source.businessType,
                source.workDaysCalculation,
                source.calculationRule
            );
    """)

#Pandas teve mais performance
def load_client_sla():
    df = pd.read_excel(get_file_path("client_sla"))

    df = df.drop_duplicates(
        subset=["idClient", "zipIni", "zipEnd", "consigneeProvince"],
        keep="first"
    )

    df.to_sql(
        "client_sla_raw",
        engine,
        schema="stg",
        if_exists="append",
        index=False
    )

#Usando Pandas para evitar duplicidade
def load_region():
    df = pd.read_excel(get_file_path("region"))

    df["consigneeCity_key"] = df["consigneeCity"].astype(str).str.strip().str.upper()
    df["consigneeProvince_key"] = df["consigneeProvince"].astype(str).str.strip().str.upper()

    df = df.drop_duplicates(
        subset=["consigneeCity_key", "consigneeProvince_key"],
        keep="first"
    )

    df = df.drop(columns=["consigneeCity_key", "consigneeProvince_key"])

    df.to_sql(
        "region_raw",
        engine,
        schema="stg",
        if_exists="append",
        index=False
    )


#Execução da Pipeline
def run_pipeline():
    execute_sql("EXEC etl.sp_TruncateStage;")
    load_client()
    load_client_sla()
    load_region()
    load_orders()

    execute_sql("EXEC etl.sp_LoadODS;")
    execute_sql("EXEC etl.sp_FullLoadGold;")

#Execução Final
if __name__ == "__main__":

    while True:
        print(f"[{datetime.now():%d/%m/%Y %H:%M:%S}] Executando pipeline...")

        try:
            run_pipeline()
            print(f"[{datetime.now():%d/%m/%Y %H:%M:%S}] Pipeline executada com sucesso.")
        except Exception as e:
            print(f"[{datetime.now():%d/%m/%Y %H:%M:%S}] Erro na pipeline: {e}")

        print(f"Próximo Ciclo em 5 minutos...")
        time.sleep(INTERVALO_SEGUNDOS)