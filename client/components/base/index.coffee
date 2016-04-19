React = require('react')
shallowCompare = require('react-addons-shallow-compare')


class PureComponent extends React.Component
  shouldComponentUpdate: (nextProps, nextState) -> shallowCompare(@, nextProps, nextState)

module.exports = { PureComponent }
