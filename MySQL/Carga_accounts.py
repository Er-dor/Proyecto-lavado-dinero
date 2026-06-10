#creación y carga de tabla de Accountss
import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('mysql+pymysql://root:31518@127.0.0.1/proyectoalm')

df = pd.read_csv("C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/HI-Medium_accounts.csv")
df.to_sql('accounts', con=engine, if_exists='replace', index=False)
