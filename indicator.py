import mysql_stock as sql
from datetime import datetime as dt
from dateutil.relativedelta import *
import time


class Indicator:

    def __init__(self):
        self.mysql = sql.mysql_stock()
        self.db = self.mysql.dbconn()

    def ema(self, tickers=[], emadays=[3, 5, 7, 10, 12, 14, 15, 20, 25,  30, 40, 50, 70, 90, 120, 150, 180]):
        runquery = self.db.cursor()
        if len(tickers) == 0:
            tickers = self.mysql.get_tickers_id()
        for ticker in tickers:
            for day in emadays:
                runquery.callproc("p_ema", tuple([ticker, day]))
                self.db.commit()
                print("Completed EMA for ", ticker, day)

    def rsi(self, tickers=[], days=[7, 14, 21]):
        runquery = self.db.cursor()
        if not tickers:
            tickers = self.mysql.get_tickers_id()
        for ticker in tickers:
            for day in days:
                runquery.callproc("p_rsi", tuple([ticker, day]))
                self.db.commit()
                print("Completed RSI for ", ticker, day)
        print(dt.now(), "Completed RSI")

    def kdj(self, tickers=[], days=[6,9,18,34,55,89]):
        runquery = self.db.cursor()
        if not tickers:
            tickers = self.mysql.get_tickers_id()

        for ticker in tickers:
            for day in days:
                runquery.callproc("p_kdj", tuple([ticker, day, 3]))
                self.db.commit()
                print("Completed KDJ for ", ticker, day)
        print( dt.now(), "Completed KDJ")

    def bollinger(self):
        return

    def demark9Point(self, tickers=[]):
        runquery = self.db.cursor()
        if not tickers:
            tickers = self.mysql.get_tickers_id()

        for ticker in tickers:
            runquery.callproc("p_demark9", tuple([ticker]))
            self.db.commit()
            print("Completed demark9 for ", ticker)

        print( dt.now(), "Completed demark9")

    def KDJRange(self, tickers=[]):
        runquery = self.db.cursor()
        if not tickers:
            tickers = self.mysql.get_tickers_id()
        for ticker in tickers:
            # if ticker <= 'WELL':
            #     continue
            runquery.callproc("p_kdj_range", tuple([ticker]))
            self.db.commit()

            print(dt.now(), "Completed p_kdj_range. ", ticker)

    def RSIRange(self):
        runquery = self.db.cursor()

        runquery.callproc("p_rsi_range")
        self.db.commit()

        print(dt.now(), "Completed p_rsi_range. ")

    def KDJDaysInRange(self):
        runquery = self.db.cursor()
        runquery.callproc("p_set_all_kdj_daysInRange", tuple([0]))
        self.db.commit()
        print(dt.now() , "Completed p_set_all_kdj_daysInRange. ")


    def RSIDaysInRange(self):
        #get Ticke

        runquery = self.db.cursor()
        runquery.callproc("p_set_all_RSI_daysInRange", tuple([0]))
        self.db.commit()

        print(dt.now() , "Completed p_set_all_RSI_daysInRange. ")

    def Obv(self, tickers=[]):
        runquery = self.db.cursor()
        if not tickers:
            tickers = self.mysql.get_tickers_id()

        for ticker in tickers:
            runquery.callproc("p_obv", tuple([ticker]))
            self.db.commit()
            print("Completed obv for ", ticker)

        print( dt.now(), "Completed obv")

    def rsi_deviate(self, tickers=[]):
        runquery = self.db.cursor()
        if not tickers:
            tickers = self.mysql.get_tickers_id()

        for ticker in tickers:
            # if ticker < 'WELL':
            #     continue
            # get last dayid and max dayid in dayprice
            ind_dayid = 0
            query = "SELECT Max(dayid) FROM dayprice WHERE code = '" + ticker + "'"

            runquery.execute(query)
            data = runquery.fetchall()
            if data[0][0] != None:
                maxDayId = data[0][0]

            while ind_dayid < maxDayId - 6:
                query = "SELECT Max(last_dayid) FROM deviate_last_date WHERE code = '" + ticker + \
                        "' AND indicator = 'RSI Deviate'"
                runquery.execute(query)
                data = runquery.fetchall()
                if data[0][0] != None:
                    ind_dayid = data[0][0]
                else:
                    ind_dayid = 40

                runquery.callproc("p_ind_rsi_deviate", tuple([ticker, 3]))
                self.db.commit()
                # print(dt.now(), "Completed rsi deviate for ", ticker, 3, ind_dayid)

                runquery.callproc("p_ind_rsi_deviate", tuple([ticker, 5]))
                self.db.commit()
                # print(dt.now(), "Completed rsi deviate for ", ticker, 5, ind_dayid)
            print(dt.now(), "Completed rsi deviate for ", ticker)

        print(dt.now(), "Completed rsi deviate ")

    def kdj_deviate(self, tickers=[]):
        runquery = self.db.cursor()
        if not tickers:
            tickers = self.mysql.get_tickers_id()

        for ticker in tickers:
            # get last dayid and max dayid in dayprice
            ind_dayid = 0
            query = "SELECT Max(dayid) FROM dayprice WHERE code = '" + ticker + "'"

            runquery.execute(query)
            data = runquery.fetchall()
            if data[0][0] != None:
                maxDayId = data[0][0]

            while ind_dayid < maxDayId - 5:
                query = "SELECT Max(last_dayid) FROM deviate_last_date WHERE code = '" + ticker + \
                        "' AND indicator = 'KDJ Deviate'"
                runquery.execute(query)
                data = runquery.fetchall()
                if data[0][0] != None:
                    ind_dayid = data[0][0]
                else:
                    ind_dayid = 40

                runquery.callproc("p_ind_kdj_deviate", tuple([ticker, 3]))
                self.db.commit()
                # print(dt.now(), "Completed kdj deviate for ", ticker, 3, ind_dayid)

                runquery.callproc("p_ind_kdj_deviate", tuple([ticker, 5]))
                self.db.commit()
                # print(dt.now(), "Completed kdj deviate for ", ticker, 5, ind_dayid)
            print(dt.now(), "Completed kdj deviate for ", ticker)

        print(dt.now(), "Completed kdj deviate ")

#
# myInd = Indicator()
# myInd.KDJRange(myInd.mysql.get_tickers_id())
# myInd.RSIRange()


