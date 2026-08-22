-- Animating osculating circle of y = sin(x)
-- by David Wang, dwang@liberty.edu, October 2025

mathly = require('mathly')

jscode = [[
  // see https://www.desmos.com/calculator/lbjisuikaf
  function f(x) { return Math.sin(x); }     // f(x) = sin(x)
  function fp(x) { return Math.cos(x); }    // f'(x) = cos(x)
  function fpp(x) { return 0-Math.sin(x); } // f''(x) = - sin(x)
  function m(x) { return Math.sqrt(1 + fp(x)**2); }
  function mp(x) { return -0.5 * Math.sin(2*x) / Math.sqrt(1 + Math.cos(x)**2); } // setup: m'(x) = - sin(2x)/sqrt(1 + cos(x)^2)
  function k(x) { const z = 1 + fp(x)**2; return Math.abs(fpp(x)) / (z * Math.sqrt(z)); }
  function q(x) { return fpp(x)*m(x) - fp(x) * mp(x); }  // do NOT use p which is reserved for 'play'
  const cx = X - mp(X) / (k(X) * Math.sqrt(mp(X)**2 + q(X)**2));   // (cx, cy), center of osculation circle at (X, Y)
  const cy = f(X) + q(X) / (k(X) * Math.sqrt(mp(X)**2 + q(X)**2));
  function displaytext() { const K = k(X); const R = 1/K; return "At (" + X.toFixed(2) + ", " + Y.toFixed(2) + "): <em>&kappa;</em> = " + K.toFixed(4) + ", <em>r</em> = " + R.toFixed(4) + ", center (" + cx.toFixed(4) +", " + cy.toFixed(4) + ")"; }
]]

fstr = {'@(t) t', '@(t) sin(t)'}
opts = {
  xrange = {-2*pi, 2*pi},
  layout = { title = '<font size=5>Osculating circle: <em>y</em> = sin <em>x</em></h3>' },
  javascript = jscode,
  enhancements = {
    {x = fstr[1], y = fstr[2], t = {-2*pi, 2*pi}, color = 'blue'},
    {x = '@(t) cx + cos(t) / k(X)', y = '@(t) cy + sin(t) / k(X)', t = {0, 2*pi}, color = 'orange'},
    {x = {'cx', 'X'}, y = {'cy', 'Y'}, line = true, width = '2', color = 'orange'},
    {x = 'cx', y = 'cy', color = 'orange', size = 7, point = true},
    {x = 'X', y = 'Y', color = 'red', size = 10, point = true}
  }
}
animate(fstr, opts)
