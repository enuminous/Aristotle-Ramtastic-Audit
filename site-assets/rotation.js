/* Numerical illustration of the exact J_a(x,y)=(-ay,x/a) model. No proof claims. */
(function (root) {
  'use strict';
  function point(degrees, a) {
    if (!Number.isFinite(degrees) || !Number.isFinite(a) || a <= 0) throw new RangeError('A finite angle and positive scale are required.');
    const theta = degrees * Math.PI / 180;
    const x = Math.cos(theta), y = Math.sin(theta) / a;
    return {x, y, euclideanSquared: x*x + y*y, adaptedSquared: x*x + a*a*y*y};
  }
  function apply(x, y, degrees, a) {
    const t = degrees * Math.PI / 180, c = Math.cos(t), s = Math.sin(t);
    return {x: c*x - a*s*y, y: s*x/a + c*y};
  }
  const api = Object.freeze({point, apply});
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.RotationModel = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
