config = require('config')
env = require('env')
_ = require('underscore')


STYLES =
  bold: ['\x1B[1m', '\x1B[22m']
  italic: ['\x1B[3m', '\x1B[23m']

  blue: ['\x1B[34m', '\x1B[39m']
  cyan: ['\x1B[36m', '\x1B[39m']
  green: ['\x1B[32m', '\x1B[39m']
  magenta: ['\x1B[35m', '\x1B[39m']
  red: ['\x1B[31m', '\x1B[39m']
  yellow: ['\x1B[33m', '\x1B[39m']

stylize = (string, style)-> "#{STYLES[style][0]}#{string}#{STYLES[style][1]}"

helpers = {}
helpers.noop = ->
helpers.log = (message, styles)->
  if styles and not process.browser
    styles = styles.split(' ')
    message = stylize(message, style) for style in styles

  console.log("[#{(new Date).toUTCString()}] #{@logPrefix or '[app]:'} #{message}")

helpers.numberOrdinalSuffix = (i)->
  j = i % 10
  return i + 'st' if j is 1 and i isnt 11
  return i + 'nd' if j is 2 and i isnt 12
  return i + 'rd' if j is 3 and i isnt 13
  i + 'th'

helpers.numberFormat = (number)->
  parts = number.toString().split('.')
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  parts.join('.')

helpers.choosePlural = (number, endings)->
  return endings[1] unless number? # Better to display "Following movies" than "Following undefined movies"
  number + ' ' + if number is 1 then endings[0] else endings[1]

helpers.api = (name, params)-> helpers.makeUrl(config.endpoints[name], params)
helpers.makeUrl = (url, params)->
  matches = url.match(/[:|*][^\d]\w+/g)

  if matches and (typeof params is 'string' or typeof params is 'number')
    url = url.replace(matches[0], params)

  else if params and matches
    i = 0
    l = matches.length

    while i < l
      url = url.replace(matches[i], params[matches[i].slice(1)] or '')
      i++

  url

helpers.shorten = (str, len, pos)->
  str = str or ''
  lim = ((len - 3) / 2) | 0
  res = str

  if str.length > len
    switch pos
      when 'left'
        res = '...' + str.slice(3 - len)
      when 'center'
        res = str.slice(0, lim) + '...' + str.slice(-lim)
      else
        res = str.slice(0, len - 3) + '...'

  res

helpers.capFirst = (string)-> string.charAt(0).toUpperCase() + string.slice(1)

helpers.stripTags = (str)-> if typeof str is 'string' then str.replace(/(<([^>]+)>)/g, '') else ''

# Use when outputting string from untrusted source directly to the DOM, especially as JSON
helpers.sanitizeString = (string)->
  string
    .replace(/\r\n/g, '\n')
    .replace(/<\/script>/g, '<\\/script>')
    .replace(/\u2028/g, '\\u2028')
    .replace(/\u2029/g, '\\u2029')

module.exports = helpers
