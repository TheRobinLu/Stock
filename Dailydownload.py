import TradeData as td
import indicator as ind
from datetime import datetime as dt
from dateutil.relativedelta import *
import datetime
import Scan



# download data from yahoo daily data, 1min, 2min


myTd = td.TradeData()
#
myTd.delete_today()
myTd.get_new('')
# #
myTd.get_2min('', dt.now() + relativedelta(days=-5), dt.now())
myTd.get_min('', dt.now() + relativedelta(days=-4), dt.now())

# # calculate indicator
MyInd = ind.Indicator()
MyInd.ema()
MyInd.kdj()
MyInd.rsi(tickers=[])
MyInd.demark9Point()

MyInd.KDJDaysInRange()
MyInd.RSIDaysInRange()
MyInd.Obv()
MyInd.kdj_deviate()
MyInd.rsi_deviate()


#Scan with tickers fall in any strategy
MyScan = Scan.Scan()
today = dt.now().date()

# today = datetime.date(2023, 2, 3)

MyScan.KDJInRange(today)
MyScan.RSIInRange(today)
MyScan.deMark(today)
MyScan.KDJDeviate(today)
MyScan.RSIDeviate(today)


MyScan.KDJRangeExpect(today)
MyScan.RSIRangeExpect(today)
MyScan.DeMarkExpect(today)

MyScan.KDJDeviateExpect(today)
MyScan.RSIDeviateExpect(today)
#Evaluate Scan result