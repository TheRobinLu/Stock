import mysql.connector as conn
from mysql.connector import Error


class mysql_stock:
    ##db = conn.connect()
    def __init__(self):
        self.db = conn.connect(
            host='localhost',
            user='root',
            password='TToomm7&',
            database='stock'
        )

    def dbconn(self):
        return conn.connect(
            host='localhost',
            user='root',
            password='TToomm7&',
            database='stock'
        )

    def get_tickers_id(self):
        cursor = self.db.cursor()
        select = "SELECT Code FROM equity"
        cursor.execute(select)
        data = cursor.fetchall()
        tickers = []
        for a in data:
            tickers.append(''.join(a))
        return tickers

