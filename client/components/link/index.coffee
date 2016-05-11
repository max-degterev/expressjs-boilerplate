React = require('react')
Link = require('react-router/lib/Link')
IndexLink = require('react-router/lib/Link')
{ connect } = require('react-redux')

mapProps = (state) -> { __previousLocation__: state.routing.locationBeforeTransitions }
Link = connect(mapProps)(Link)
IndexLink = connect(mapProps)(IndexLink)

module.exports = { Link, IndexLink }
