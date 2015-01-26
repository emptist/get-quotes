###*
csvjson.js - A script to convert between CSV and JSON formats
Author: Aaron Snoswell (@aaronsnoswell, elucidatedbianry.com)
###

# Namespace
csvjson = GetData

# Hide from global scope
(->
  isdef = (ob) ->
    return false  if typeof (ob) is "undefined"
    true
  
  ###*
  splitCSV function (c) 2009 Brian Huisman, see http://www.greywyvern.com/?post=258
  Works by spliting on seperators first, then patching together quoted values
  ###
  splitCSV = (str, sep) ->
    foo = str.split(sep = sep or ",")
    x = foo.length - 1
    tl = undefined

    while x >= 0
      if foo[x].replace(/"\s+$/, "\"").charAt(foo[x].length - 1) is "\""
        if (tl = foo[x].replace(/^\s+"/, "\"")).length > 1 and tl.charAt(0) is "\""
          foo[x] = foo[x].replace(/^\s*"|"\s*$/g, "").replace(/""/g, "\"")
        else if x
          foo.splice x - 1, 2, [
            foo[x - 1]
            foo[x]
          ].join(sep)
        else
          foo = foo.shift().split(sep).concat(foo)
      else
        foo[x].replace /""/g, "\""
      x--
    foo
  
  ###*
  Converts from CSV formatted data (as a string) to JSON returning
  an object.
  @required csvdata {string} The CSV data, formatted as a string.
  @param args.delim {string} The delimiter used to seperate CSV
  items. Defauts to ','.
  @param args.textdelim {string} The delimiter used to wrap text in
  the CSV data. Defaults to nothing (an empty string).
  ###
  csvjson.csv2json = (csvdata, args) ->
    args = args or {}
    delim = (if isdef(args.delim) then args.delim else ",")
    header = (if isdef(args.header) then args.header else true)
    
    # Unused
    #var textdelim = isdef(args.textdelim) ? args.textdelim : "";
    
    # normalize line breaks before continue
    csvdata.replace(/\x0A\x0D/g, "\n").replace /\x0D/g, "\n"
    csvlines = csvdata.split("\n")
    csvheaders = splitCSV(csvlines[0], delim)
    console.log "headers: ", csvheaders.length
    csvrows = csvlines.slice(1, csvlines.length)
    console.log "lenght: ", csvrows.length
    unless header
      i = 0

      while i < csvheaders.length
        csvheaders[i] = i
        i++
    ret = {}
    csvheaders = args.headers # I added this to overcome Chinese fonts
    ret.headers = csvheaders
    ret.rows = []
    for r of csvrows
      if csvrows.hasOwnProperty(r)
        row = csvrows[r]
        rowitems = splitCSV(row, delim)
        
        # Break if we're at the end of the file
        break  if row.length is 0
        rowob = {}
        for i of rowitems
          if rowitems.hasOwnProperty(i)
            item = rowitems[i]
            
            # Try to (intelligently) cast the item to a number, if applicable
            item = item * 1  unless isNaN(item * 1)
            rowob[csvheaders[i]] = item
        ret.rows.push rowob
    ret

  # end csv2json
  
  ###*
  Taken an object of the form
  {
  headers: ["Heading 1", "Header 2", ...]
  rows: [
  {"Heading 1": SomeValue, "Heading 2": SomeOtherValue},
  {"Heading 1": SomeValue, "Heading 2": SomeOtherValue},
  ...
  ]
  }
  and returns a CSV representation as a string.
  @requires jsondata {object} The JSON object to parse.
  @param args.delim {string} The delimiter used to seperate CSV
  items. Defauts to ','.
  @param args.textdelim {string} The delimiter used to wrap text in
  the CSV data. Defaults to nothing (an empty string).
  ###
  csvjson.json2csv = (jsondata, args) ->
    args = args or {}
    delim = (if isdef(args.delim) then args.delim else ",")
    textdelim = (if isdef(args.textdelim) then args.textdelim else "")
    
    # JSON text parsing is not implemented (yet)
    return null  if typeof (jsondata) is "string"
    ret = ""
    
    # Add the headers
    for h of jsondata.headers
      if jsondata.headers.hasOwnProperty(h)
        heading = jsondata.headers[h]
        ret += textdelim + heading + textdelim + delim
    
    # Remove trailing delimiter
    ret = ret.slice(0, ret.length - 1)
    ret += "\n"
    
    # Add the items
    for r of jsondata.rows
      if jsondata.rows.hasOwnProperty(r)
        row = jsondata.rows[r]
        
        # Only add elements that are mentioned in the headers (in order, obviously)
        for h of jsondata.headers
          if jsondata.headers.hasOwnProperty(h)
            heading = jsondata.headers[h]
            data = row[heading]
            if typeof (data) is "string"
              ret += textdelim + row[heading] + textdelim + delim
            else
              ret += row[heading] + delim
        
        # Remove trailing delimiter
        ret = ret.slice(0, ret.length - 1)
        ret += "\n"
    
    # Remove trailing newling
    ret = ret.slice(0, ret.length - 1)
    ret

  return
)() # Execute hidden-scope code
