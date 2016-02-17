React = require('react')
{ Link } = require('react-router')


module.exports = class Home extends React.Component
  render: ->
    <section>
      <h1>Home</h1>
      <Link to="/404">Error 404</Link>
    </section>
