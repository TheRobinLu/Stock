import mysql_stock as sql

class Strategy:
    def __init__(self):
        aa = sql.mysql_stock()
        self.db = aa.dbconn()

    def isLowKDJ(self, ticker, trade_date):

        return True