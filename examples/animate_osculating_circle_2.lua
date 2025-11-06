-- Animating osculating circle of y = x^2
-- by David Wang, dwang@liberty.edu, October 2025

mathly = require('mathly')

jscode = [[
  function f(x) { return x*x; }  // f(x) = x^2
  function fp(x) { return 2*x; } // f'(x) = 2x
  function fpp(x) { return 2; }  // f''(x) = 2
  function m(x) { return Math.sqrt(1 + fp(x)**2); }
  function mp(x) { return 4*x / Math.sqrt(1 + 4*x*x); } // setup: m'(x) = 4x / sqrt(1 + 4x^2)
  function k(x) { const z = 1 + fp(x)**2; return Math.abs(fpp(x)) / (z * Math.sqrt(z)); }
  function q(x) { return fpp(x)*m(x) - fp(x) * mp(x); }  // do NOT use p which is reserved for 'play'
  const cx = X - mp(X) / (k(X) * Math.sqrt(mp(X)**2 + q(X)**2));   // (cx, cy), center of osculation circle at (X, Y)
  const cy = f(X) + q(X) / (k(X) * Math.sqrt(mp(X)**2 + q(X)**2));
]]

fstr = {'@(t) t', '@(t) t*t'}
opts = {
  x = {-5, 5},
  layout = { title = '<h3><em>y = x<sup>2</sup></em></h3>' },
  p = { default = 0.43 }, -- control p starts at p = 0.43
  javascript = jscode,
  enhancements = {
    {x = fstr[1], y = fstr[2], t = {-2*pi, 2*pi}, color = 'blue'},
    {x = '@(t) cx + cos(t) / k(X)', y = '@(t) cy + sin(t) / k(X)', t = {0, 2*pi}, color = 'orange'},
    {x = 'X', y = 'Y', color = 'red', size = 10, point = true}
  }
}
animate(fstr, opts)
