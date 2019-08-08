export default () => {
  const routes = [
    {
      path: '/',
      exact: true,
      component: require('../../containers/home'),
    },
    {
      from: '/redirect',
      to: '/',
      statusCode: 302,
    },
    {
      path: '/onenter',
      onEnter() {
        if (Math.random() > .5) return { statusCode: 302, to: '/redirectedfromonenter' };
      },
      render() {
        return 'AwesomeRoute!';
      },
    },
    {
      component: require('../../containers/error_404'),
      statusCode: 404,
    },
  ];

  return { routes };
};
