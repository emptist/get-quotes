@GetData = {} #this simple line is to make coffeescript variables global

if Meteor.isClient
  # use callback to return data to calling function
  GetData.quotes = (param, callback) ->
    rawData = (url, func) ->
      Meteor.call 'rawData', {url: url} , (err, res)->
        unless err?
          callback func res.content#.toString 'utf8'

    switch param.source
      when '126.net'
        url = "http://api.money.126.net/data/feed/#{param.ids}"
        _ntes_quote_callback = (args) -> args
        rawData url, (cnt)-> eval cnt

      when '163.com' # encoding in GBK
        host = 'http://quotes.money.163.com/service/chddata.html?code='
        # 日期，代碼，名稱，收盤，最高，最低，開盤，前收，漲跌，幅度，換手率，成交量，成交金額，總市值，流通市值
        fields = 'TOPEN;HIGH;LOW;TCLOSE;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP'
        headers = 'DATE;CODE;NAME;' + fields
        id = (param.ids.split ',')[0]
        url = host + "#{id}&start=#{param.start}&end=#{param.end}&fields=#{fields}"

        rawData url, (cnt) ->
          csvlines = cnt.split "\n"
          csvrows = (csvlines.slice 1, csvlines.length).reverse()
          GetData.rows = rows =  []
          for r in csvrows
            unless r.length is 0
              row = r.split ','
              date = [(new Date row[0]).getTime()]
              res = row.map(Number)
              unless (res[3] is 0) or (res[4] is 0) or (res[5] is 0) or res[6] is 0
                rows.push date.concat res[3..6], res[11..11]

          GetData.csv2json (cnt), {delim: ',', textdelim:'\r', headers: headers.split(';')}

      else
        return

if Meteor.isServer
  # 服務器端應該只管獲取數據，其他的事情應該由客戶端提供參數和callback
  Meteor.methods
    # stockIds 可以接受一組代碼，例如 '1000001, 0600000'，其中深1滬0
    rawData: (param) ->
      this.unblock()
      url = param.url
      options = {timeout: 3000000}

      try
        return HTTP.get(url, options)
      catch error
        console.log error
      finally
        -> # Only do cleanUp and should not return anything here
