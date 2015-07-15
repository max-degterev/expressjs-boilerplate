# Notice:
# Please keep this module simple. 3rd party module requires here will result in breakage of
# Cakefile and some others.

utils = {}

STYLES =
  bold: ['\x1B[1m', '\x1B[22m']
  italic: ['\x1B[3m', '\x1B[23m']

  red: ['\x1B[31m', '\x1B[39m']
  green: ['\x1B[32m', '\x1B[39m']
  blue: ['\x1B[34m', '\x1B[39m']

  cyan: ['\x1B[36m', '\x1B[39m']
  magenta: ['\x1B[35m', '\x1B[39m']
  yellow: ['\x1B[33m', '\x1B[39m']

stylize = (string, style)-> "#{STYLES[style][0]}#{string}#{STYLES[style][1]}"

# Public: Apply styles to message and log it by `console.log`.
#
# message - The message to be logged as {string}.
# styles  - The space separated list of styles as {string}.
module.exports = (message, styles)->
  if styles and not process.browser and (not process.env.NODE_ENV or process.env.NODE_ENV is 'development')
    styles = styles.split(' ')
    message = stylize(message, style) for style in styles

  console.log("[#{(new Date).toUTCString()}] #{@logPrefix or '[app]:'} #{message}")
