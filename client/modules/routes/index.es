export default () => {
  const routes = [
    {
      path: '/',
      exact: true,
      component: require('../../containers/home'),
    },
    {
      component: require('../../containers/error_404'),
    },
  ];

  return { routes };
};
