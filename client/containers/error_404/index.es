import React from 'react';
import Link from 'react-router/lib/Link';


export default function () {
  return (
    <section>
      <h1>Error 404</h1>
      <p>This is not the page you&apos;re looking for. <Link to="/">Go Home</Link>.</p>
    </section>
  );
}
