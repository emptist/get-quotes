## This simple package is not finished and not for use.
By the way how to use packages in a private way without publish them?

## Usage:

GetData.quotes {source: source, ids: ids, interval: interval}, (data) ->
  #dealing with the data here

GetData.history {source: source, ids: ids, start: start, end: end}, (data) ->
  #dealing with the data here

source now includes 126.net

## Todo:
1. add support to update interval for realtime quote


## References
### How to build packages

http://derrybirkett.com/2014/12/how-to-build-the-simplest-meteor-package/

### 從網易下載歷史行情數據
https://gist.github.com/yanping/4617519/fork
https://gist.github.com/yanping/4617519

url = http://quotes.money.163.com/service/chddata.html
field = "&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP"
