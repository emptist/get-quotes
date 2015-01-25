@GetData = {}

if Meteor.isClient
  # use callback to return data to calling function
  GetData.quotes = (param, callback) ->
    switch param.source
      when '126.net'
        url = "http://api.money.126.net/data/feed/#{param.ids}"
        _ntes_quote_callback = (args) -> args

        Meteor.call 'getQuotes', {url: url} , (err, res)->
          unless err?
            callback eval res.content
      else
        return

if Meteor.isServer
  # 服務器端應該只管獲取數據，其他的事情應該由客戶端提供參數和callback
  Meteor.methods
    # stockIds 可以接受一組代碼，例如 '1000001, 0600000'，其中深1滬0
    # 獲取實時行情
    getHistory: (param) ->
      url = param.url
      stockIds = param.stockIds
      start = param.start
      end = param.end


    getQuotes: (param) ->
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
