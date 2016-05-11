React = require('react')

{ PureComponent } = require('../../components/base')


module.exports = class Home extends PureComponent
  render: ->
    <section>
      <h1>Home</h1>
      <p>It works!</p>
    </section>
