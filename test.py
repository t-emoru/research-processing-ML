### ----------------------------------------------------
### USING THE API
### ----------------------------------------------------

"INPRACTICAL APPLICATION CHANGE ALL PRINT STATEMENTS TO RETURN FOR OUTPUT"

print("this is python")

from ibapi.client import *
from ibapi.wrapper import *
import datetime
import time
import threading
from ibapi.ticktype import TickTypeEnum

port = 7497


class TestApp(EClient, EWrapper):
  def __init__(self):
    EClient.__init__(self, self)
  
  def nextValidId(self, orderId):
    # receives the EWrapper return of the next valid orderId
    self.orderId = orderId 

  def nextId(self):
    # increments to next OrderId 
    self.orderId += 1
    return self.orderId
  
  def currentTime(self, time):
    print(time)

  def error(self, reqId, errorCode, errorString, advancedOrderReject=""):
    print(f"reqId: {reqId}, errorCode: {errorCode}, errorString: {errorString}, orderReject: {advancedOrderReject}")



  # CONTRACTS----------------------

  def contractDetails(self, reqId, contractDetails):
    # stores all the contract details (underlying details, supported exchanges & trading hours) in a dictionary structure
    attrs = vars(contractDetails)
    # print("\n".join(f"{name}: {value}" for name,value in attrs.items()))
    print(contractDetails.contract)
    return contractDetails.contract

  def contractDetailsEnd(self, reqId):
    # indicates there is no data remaining for a request that may return several responses to a single request
    print("End of contract details")
    # self.disconnect()



  # MARKET DATA------------------
  """
  Kinds of Data: Delayed, Live and Historcal
  At least 500$ in account to have a Data Subscription - subs made thorugh the client portal

  """
  
  def tickPrice(self, reqId, tickType, price, attrib):
    """
    TickType - this indicates what kinda is coming in, this is an integer value that
    corolates to a specific value such as bid price, last size, closing price or otherwise

    """
    print(f"reqId: {reqId}, tickType: {TickTypeEnum.toStr(tickType)}, price: {price}, attrib: {attrib}")
  

  def tickSize(self, reqId, tickType, size):
    """
    A tick in this context refers to a single piece of market data, 
    such as the last traded price, bid size, or ask size.

    Tick Size -  the quantity or volume associated with specific market data types, 
    such as the bid size, ask size, or last trade size, for a given financial instrument.
    
    """
    print(f"reqId: {reqId}, tickType: {TickTypeEnum.toStr(tickType)}, size: {size}")


  "how far back market history goes for a contract"
  def headTimestamp(self, reqId, headTimeStamp):
      print(headTimeStamp)
      print(datetime.datetime.fromtimestamp(int(headTimeStamp)))
      self.cancelHeadTimeStamp(reqId)
  

  "retriving actual historical data"
  def historicalData(self, reqId, bar):
    print(reqId, bar)
    
  def historicalDataEnd(self, reqId, start, end):
      print(f"Historical Data Ended for {reqId}. Started at {start}, ending at {end}")
      self.cancelHistoricalData(reqId)



  # ORDERS------------------

  "placing orders"






#testing
app = TestApp()
app.connect("127.0.0.1", port, 0) # connecting to TWS paper session 
threading.Thread(target=app.run).start()
time.sleep(1)

for i in range(0,5):
  #print("index:", i)
  time.sleep(1)
  print(app.nextId())
  #app.reqCurrentTime()
  print("    ")
  time.sleep(1)

# Contracts
mycontract = Contract()
mycontract.symbol = "AAPL" #sets mycontract to apple stock
mycontract.secType = "STK" #sets sercurities type: Stocks, Futures & Options
mycontract.currency = "USD"
mycontract.exchange = "SMART"
mycontract.primaryExchange = "NASDAQ"

app.reqContractDetails(app.nextId(), mycontract)


# Market Data
app.reqMarketDataType(3) #values ranging from 1 - 3 returning different kinds of market data ^
app.reqMktData(app.nextId(), mycontract, "232", False, False, []) #can be used to receive snapshots
""" regulatory snapshots can be created using the function above but they cause
1 US Penny per shot, by passing the need for a subscription """
app.reqHeadTimeStamp(app.nextId(), mycontract, "TRADES", 1, 2) #returns historical data range
"""
Values that can be shown: https://ibkrcampus.com/campus/ibkr-api-page/twsapi-doc/#historical-whattoshow
"""
app.reqHistoricalData(app.nextId(), mycontract, "20240523 16:00:00 US/Eastern", "1 D", "1 hour", "TRADES", 1, 1, False, [])



# Orders
myorder = Order()
myorder.orderId = app.nextId()
contract_details = app.reqContractDetails(myorder.orderId, mycontract)
myorder.action = "BUY"
myorder.orderType = "MKT"
myorder.totalQuantity = 10

type(myorder.orderId)
type(contract_details)
app.placeOrder(myorder.orderId, contract_details, myorder)

## LEFT OF:: FOLLOWING TUTORIAL TRYING OT GENERALISE


#disconnect
app.disconnect()














### ----------------------------------------------------
### SYNTAX DETAILS
### ----------------------------------------------------



"more examples"
# Future
# mycontract.symbol = "ES"
# mycontract.secType = "FUT"
# mycontract.currency = "USD"
# mycontract.exchange = "CME"
# mycontract.lastTradeDateOrContractMonth = 202412 #returns only information for dec of 2024

# Option
# mycontract.symbol = "SPX"
# mycontract.secType = "OPT"
# mycontract.currency = "USD"
# mycontract.exchange = "SMART"
# mycontract.lastTradeDateOrContractMonth = 202412
# mycontract.right = "P"
# mycontract.tradingClass = "SPXW"
# mycontract.strike = 5300


"""
these added dates acts as filtering when looking for information about a security
https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-ref/#contract-ref
https://www.interactivebrokers.com/campus/ibkr-api-page/contracts/
"""