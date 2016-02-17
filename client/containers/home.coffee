React = require('react')
{ Link } = require('react-router')

module.exports = class Home extends React.Component
  render: ->
    <section>
      <h1>Home</h1>
      <ul>
        <li><Link to="/404">Error 404</Link></li>
        <li><Link to="/502">Error 502</Link></li>
      </ul>
    </section>
