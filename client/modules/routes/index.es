export default () => {
  const routes = [
    {
      path: '*', // Needed for the fetch to work, OK to leave empty for routes that don't load data
      component: require('../../containers/wrapper'),
      routes: [
        {
          path: '/',
          exact: true,
          component: require('../../containers/home'),
        },
        {
          path: '/prompt',
          component: require('../../containers/prompt'),
        },
        {
          from: '/redirect',
          to: '/',
          statusCode: 307,
        },
        {
          path: '/onenter',
          onEnter() {
            return { statusCode: 307, to: '/redirectedfromonenter' };
          },
          render() {
            return 'AwesomeRoute!';
          },
        },
        {
          component: require('../../containers/error_404'),
          statusCode: 404,
        },
      ],
    },
  ];

  return { routes };
};
