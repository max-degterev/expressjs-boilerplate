BaseController = require('./base')


class DefaultController extends BaseController
  default: (req, res) -> res.render('index')
  attachRoutes: -> @get('*', @default)

module.exports = new DefaultController()
