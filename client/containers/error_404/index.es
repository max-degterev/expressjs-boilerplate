import React, { PureComponent } from 'react'
import Link from 'react-router/lib/Link'

export default class Error extends React.PureComponent {
  render() {
    return (
      <section>
        <h1>Error 404</h1>
        <p>This is not the page you're looking for. <Link to="/">Go Home</Link>.</p>
      </section>
    );
  }
}
