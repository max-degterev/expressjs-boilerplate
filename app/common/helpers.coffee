_ = require('underscore')

utils = {}

utils.numberOrdinalSuffix = (i) ->
  j = i % 10
  return i + 'st' if j is 1 and i isnt 11
  return i + 'nd' if j is 2 and i isnt 12
  return i + 'rd' if j is 3 and i isnt 13
  i + 'th'

# utils.valid =
  # int: (value)-> /^\d+$/.test(value)
  # alphameric: (value)-> /^\w{2,30}$/g.test(value)
  # float: (value)-> !isNaN(parseFloat(value))
  # date: (value)-> !!+helpers.dateFromYMD(value)
  # uuid: (value)-> /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i.test(value)
  # email: (value)-> /^[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/.test(value)

# Format numbers by adding commas on each 3 digits of integer part.
# number - The number to be formatted as {number}.
# Returns the formatted number as `string`.
utils.numberFormat = (number) ->
  parts = number.toString().split('.')
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  parts.join('.')

# `dd/mm/YYYY hh:mm`
utils.appendLeadingZero = (num)->
  ('0' + num).slice(-2)

utils.dateFormat = (date, skipTime) ->
  return null unless date
  date = new Date(date) unless date instanceof Date
  fn = utils.appendLeadingZero

  dateString = "#{fn(date.getDate())}/#{fn(date.getMonth() + 1)}/#{date.getFullYear()}"
  return dateString if skipTime

  timeString = "#{fn(date.getHours())}:#{fn(date.getMinutes())}"
  "#{dateString} #{timeString}"

utils.dateToYMD = (date, separator = '-')->
  return null unless date
  date = new Date(date) unless date instanceof Date
  fn = utils.appendLeadingZero

  date.getFullYear() + separator + fn(date.getMonth() + 1) + separator + fn(date.getDate())

utils.choosePlural = (number, endings) ->
  # Better to display "Following movies" than "Following undefined movies"
  return endings[1] unless number?
  number + ' ' + if number is 1 then endings[0] else endings[1]

utils.shorten = (str, len, pos) ->
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

utils.capFirst = (string) -> string.charAt(0).toUpperCase() + string.slice(1)

utils.keyToName = (string) ->
  utils.capFirst(string).replace(/_+/g, ' ')

utils.slugify = (string) -> string.toLowerCase().replace(/[^\w ]+/g,'').replace(/ +/g,'-')

utils.stripTags = (str) ->
  if _.isString(str) then str.replace(/(<([^>]+)>)/g, '') else ''

# Use when outputting string from untrusted source directly to the DOM, especially as JSON
utils.sanitize = (string) ->
  return unless string
  string = JSON.stringify(string) if _.isObject(string)

  string
    .replace(/\r\n/g, '\n')
    .replace(/<\/script>/g, '<\\/script>')
    .replace(/\u2028/g, '\\u2028')
    .replace(/\u2029/g, '\\u2029')

module.exports = utils
