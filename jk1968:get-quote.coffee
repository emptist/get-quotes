@GetData = {} #this simple line is to make coffeescript variables global

if Meteor.isClient
  # use callback to return data to calling function
  GetData.quotes = (param, callback) ->

    callMethod = (url, func) ->
      Meteor.call 'rawData', {url: url} , (err, res)->
        unless err?
          callback func res.content

    switch param.source
      when '126.net'
        url = "http://api.money.126.net/data/feed/#{param.ids}"
        _ntes_quote_callback = (args) -> args

        callMethod url, (res)->
          eval res
        ###
        Meteor.call 'rawData', {url: url} , (err, res)->
          unless err?
            callback eval res.content
        ###

      when '163.com'
        host = 'http://quotes.money.163.com/service/chddata.html?code='
        fields1 = 'TCLOSE'
        fields2 =';HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;'
        fields3 = 'TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP'
        fields = fields1 + fields2 + field3
        url = host + "#{ids[0]}&start=#{start}&end=#{end}&fields=#{fields}"
        callMethod url, (res)->
          res

        ###
        Meteor.call 'rawData', {url: url} , (err, res)->
          unless err?
            callback res.content
        ###

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
      #console.log HTTP.get(url, options)

      try
        return HTTP.get(url, options)
      catch error
        console.log error
      finally
        -> # Only do cleanUp and should not return anything here
