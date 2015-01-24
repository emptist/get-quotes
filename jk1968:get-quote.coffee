if Meteor.isServer
  #
  Meteor.methods
    # stockIds 可以接受一組代碼，例如 '1000001, 0600000'，其中深1滬0
    # 獲取實時行情
    getQuotes: (stockIds) ->
      this.unblock()

      url = "http://api.money.126.net/data/feed/#{stockIds}"

      options =
        timeout: 3000000

      try
        res = HTTP.get url, options
        _ntes_quote_callback = (args) -> args
        obj = eval res.content
        # here we can manipulate the obj
        # q = (quotes for id, quotes of obj)
        # console.log obj[stockIds.split(',')[0]]
        return obj
      catch error
        console.log error
      finally
        -> # Only do cleanUp and should not return anything here
