
import mysql.connector as conn
from mysql.connector import Error

def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print(f'Hi, {name}')  # Press Ctrl+F8 to toggle the breakpoint.

# See PyCharm help at https://www.jetbrains.com/help/pycharm/


class DB:
    db = conn.connect()

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

    def ntest(self):
        s = {3, 2, 6, 7, 2, 5, 3, 1, -1, 4}
        n = [val for val in s if val % 2 != 0]
        print(len(n))
        print(n)

# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')

myDB = DB()

print(myDB.get_tickers_id())

myDB.ntest()