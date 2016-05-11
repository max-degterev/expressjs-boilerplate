React = require('react')

{ PureComponent } = require('../../components/base')
{ Link } = require('../../components/link')


module.exports = class Error extends PureComponent
  render: ->
    <section>
      <h1>Error 404</h1>
      <p>This is not the page you're looking for. <Link to="/">Go Home</Link>.</p>
    </section>
