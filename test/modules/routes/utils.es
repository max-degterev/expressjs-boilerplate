import { assert } from 'chai';
import { getRoutesParams } from '../../../client/modules/routes/utils';


describe('modules/routes/utils', () => {
  it('getRoutesParams', () => {
    const routeOptions = [
      'component',
      'path',
      'childRoutes',
      'getChildRoutes',
      'indexRoute',
      'getIndexRoute',
      'onEnter',
      'onLeave',
    ];

    const routes = [
      { a: 5 },
      { ki: '123', asd: 12313 },
    ];

    routes.forEach((route) => {
      routeOptions.forEach((option) => {
        route[option] = 12312;
      });
    });

    const expected = { a: 5, ki: '123', asd: 12313 };

    assert.deepEqual(getRoutesParams(routes), expected, 'merge routes params and remove extra options');

    routes.forEach((route) => {
      routeOptions.forEach((option) => {
        assert.isNotNull(route[option], 'do not mutate source objects');
      });
    });
  });
});
