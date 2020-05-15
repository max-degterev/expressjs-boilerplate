const { assert } = require('chai');

const {
  getMatchableRoute,
} = require('../lib/utils');


describe('utils', () => {
  it('getMatchableRoute', () => {
    const defaults = { exact: true, strict: true, sensitive: false };
    const inverted = { exact: false, strict: false, sensitive: true };
    assert.deepEqual(getMatchableRoute({}), defaults, 'injects defaults');
    assert.deepEqual(getMatchableRoute({ path: '/test' }), { ...defaults, path: '/test' }, 'keeps unrelated props');
    assert.deepEqual(getMatchableRoute({ exact: false }), { ...defaults, exact: false }, 'can override exact');
    assert.deepEqual(getMatchableRoute({ strict: false }), { ...defaults, strict: false }, 'can override strict');
    assert.deepEqual(getMatchableRoute({ sensitive: true }), { ...defaults, sensitive: true }, 'can override sensitive');
    assert.deepEqual(getMatchableRoute(inverted), inverted, 'can override all values');
    assert.deepEqual(getMatchableRoute({ path: '/test', exact: false }), { ...defaults, path: '/test', exact: false }, 'overrides exact and keeps unrelated props');
  });
});
