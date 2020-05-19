export const isNumber = (val) => typeof val === 'number';
export const isFunction = (val) => typeof val === 'function';

export const getMatchableRoute = (route) => {
  const { exact = true, sensitive = false, strict = true, ...params } = route;
  return { ...params, exact, sensitive, strict };
};
