React = require('react')
{ Link } = require('react-router')


module.exports = class Error404 extends React.Component
  render: ->
    <section>
      <h1>Error 404</h1>
      <Link to="/">Back home</Link>
    </section>
