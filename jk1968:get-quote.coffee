if Meteor.isServer
  Meteor.methods
    getQuote: (stock) ->
      this.unblock()

      url = "http://api.money.126.net/data/feed/#{stock}"

      options =
        timeout: 30000000


      try
        res = HTTP.get url, options
        _ntes_quote_callback = (args) -> args
        obj = eval res.content
        q = (quotes for id, quotes of obj)
        console.log obj[stock.split(',')[0]]
        return q[0]

      catch error
        console.log error

      finally
        -> # Only do cleanUp and should not return anything here
