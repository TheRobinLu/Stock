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
# # calculate indicator
MyInd = ind.Indicator()
MyInd.ema()
MyInd.kdj()
MyInd.rsi(tickers=[])
MyInd.demark9Point()

MyInd.KDJDaysInRange()
MyInd.RSIDaysInRange()
MyInd.Obv()

#Scan with tickers fall in any strategy
MyScan = Scan.Scan()
today = dt.now().date()

# today = datetime.date(2022, 12, 16)

MyScan.KDJInRange(today)
MyScan.RSIInRange(today)
MyScan.deMark(today)
MyScan.KDJDeviate(today)
MyScan.RSIDeviate(today)

MyScan.KDJRangeExpect(today)
MyScan.RSIRangeExpect(today)
MyScan.DeMarkExpect(today)
MyScan.KDJRangeExpect(today)
MyScan.RSIDeviateExpect(today)

#Evaluate Scan result