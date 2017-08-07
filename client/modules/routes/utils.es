{ stringify, parse } = require('querystring')

validations = require('../validations')
{ isExternalUrl } = require('../utils/misc')
{ isStringMatched } = require('../utils/strings')
{ pathnameInRoutes } = require('../permissions')

{ INVALID_ROUTE } = require('../constants/misc')
{ TAGS_INTERESTS_KEY, TAGS_SKILLS_KEY } = require('../constants/tags')
REGEX_TOKEN = /^[a-zA-Z0-9\-_]{20}$/
REGEX_ACCESS_CODE = /^[a-zA-Z0-9]{5}\-[a-zA-Z0-9]{5}$/
REGEX_SLUG = /^[a-zA-Z0-9\-_]+$/
REGEX_TAG_KEY = new RegExp("^(#{TAGS_INTERESTS_KEY}|#{TAGS_SKILLS_KEY})$")

ROUTE_OPTIONS = [
  'component'
  'path'
  'childRoutes'
  'getChildRoutes'
  'indexRoute'
  'getIndexRoute'
  'onEnter'
  'onLeave'
]


validationMap =
  id: validations.isInt
  hoodId: validations.isInt
  token: (value) -> validations.isRegex(value, REGEX_TOKEN)
  accessCode: (value) -> validations.isRegex(value, REGEX_ACCESS_CODE)
  slug: (value) -> validations.isRegex(value, REGEX_SLUG)
  hood: (value) -> validations.isRegex(value, REGEX_SLUG)
  zipCode: validations.isZipCode
  tagKey: (value) -> validations.isRegex(value, REGEX_TAG_KEY)

validateParams = (props...) ->
  (state, replace) ->
    for prop in props
      if state.params[prop] and not validationMap[prop](state.params[prop])
        return replace(INVALID_ROUTE)

getLocationPath = (location) ->
  return null unless location
  { pathname, search, hash } = location
  [ pathname, search, hash ].join('')

isSafeReferrer = (path, allowedRoutes) ->
  return false if not path
  return false if isExternalUrl(path)
  isStringMatched(path, allowedRoutes)

getReferrer = (search) -> parse(search.substr(1)).referrer or null
setReferrer = (pathname, referrer) ->
  if pathname.indexOf('?') >= 0
    pathname += '&'
  else
    pathname += '?'

  "#{pathname}#{stringify({ referrer })}"

getRoutesParams = (routes) ->
  result = {}

  for route in routes
    option = Object.assign({}, route)

    for name in ROUTE_OPTIONS
      delete option[name]

    Object.assign(result, option)

  result


module.exports = {
  validationMap, validateParams,
  getLocationPath,
  isSafeReferrer, getReferrer, setReferrer, getRoutesParams
}
