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
      component: require('../../containers/error_404'),
      statusCode: 404,
    },
  ];

  return { routes };
};
