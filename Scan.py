import mysql_stock as sql
from datetime import datetime as dt

class Scan:
    def __init__(self):
        aa = sql.mysql_stock()
        self.db = aa.dbconn()

    def KDJInRange(self, trade_date):

        runquery = self.db.cursor()
        runquery.callproc("p_scan_kdj_range", tuple([trade_date]))
        self.db.commit()
        print(dt.now(), "Completed KDJ range scan for ", trade_date)
        return

    def RSIInRange(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_scan_rsi_range", tuple([trade_date]))
        self.db.commit()
        print(dt.now(), "Completed RSI range scan for ", trade_date)
        return


    def deMark(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_scan_demark", tuple([trade_date, 9]))
        self.db.commit()
        print(dt.now(), "Completed DeMark scan for ", trade_date)
        return


    def KDJDeviate(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_scan_kdj_deviate", tuple([trade_date, 3]))
        self.db.commit()
        print(dt.now(), "Completed KDJ deviate scan for ", trade_date)
        return


    def RSIDeviate(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_scan_rsi_deviate", tuple([trade_date, 3]))
        self.db.commit()
        print(dt.now(), "Completed RSI deviate scan for ", trade_date)
        return



    def KDJRangeExpect(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_expect_kdj_range", tuple([trade_date]))
        self.db.commit()
        print(dt.now(), "Completed KDJ range expect for ", trade_date)
        return

    def RSIRangeExpect(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_expect_rsi_range", tuple([trade_date]))
        self.db.commit()
        print(dt.now(), "Completed RSI range expect for ", trade_date)
        return


    def DeMarkExpect(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_expect_demark", tuple([trade_date]))
        self.db.commit()
        print(dt.now(), "Completed DeMark expect for ", trade_date)
        return


    def KDJDeviateExpect(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_Expect_kdj_deviate", tuple([trade_date]))
        self.db.commit()
        print(dt.now(), "Completed KDJ deviate Expect for ", trade_date)
        return


    def RSIDeviateExpect(self, trade_date):
        runquery = self.db.cursor()
        runquery.callproc("p_Expect_rsi_deviate", tuple([trade_date]))
        self.db.commit()
        print(dt.now(), "Completed RSI deviate Expect for ", trade_date)
        return
