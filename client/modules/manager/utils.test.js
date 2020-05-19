const { assert } = require('chai');

const {
  isNumber,
  isFunction,
  getMatchableRoute,
} = require('./utils');


describe('utils', () => {
  it('isNumber', () => {
    assert.isTrue(isNumber(0), 'number');
    assert.isFalse(isNumber('0'), 'string');
    assert.isFalse(isNumber(null), 'null');
    assert.isFalse(isNumber(), 'undefined');
  });

  it('isFunction', () => {
    assert.isTrue(isFunction(() => {}), 'func');
    assert.isFalse(isFunction('0'), 'string');
    assert.isFalse(isFunction(null), 'null');
    assert.isFalse(isFunction(), 'undefined');
  });

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
