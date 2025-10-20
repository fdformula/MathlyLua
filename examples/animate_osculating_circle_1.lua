-- Animating osculating circle of y = sin(x)

mathly = require('mathly')

jscode = [[
  // see https://www.desmos.com/calculator/lbjisuikaf
  function f(x) { return Math.sin(x); }     // setup: f(x) = sin(x)
  function fp(x) { return Math.cos(x); }    // setup: f'(x) = cos(x)
  function fpp(x) { return 0-Math.sin(x); } // setup: f''(x) = - sin(x)
  function m(x) { return Math.sqrt(1 + fp(x)**2); }
  function mp(x) { return -0.5 * Math.sin(2*x) / Math.sqrt(1 + Math.cos(x)**2); } // setup: m'(x) = - sin(2x)/sqrt(1 + cos(x)^2)
  function k(x) { const z = 1 + fp(x)**2; return Math.abs(fpp(x)) / (z * Math.sqrt(z)); }
  function q(x) { return fpp(x)*m(x) - fp(x) * mp(x); }  // do NOT use p which is reserved for 'play'
  const cx = X - mp(X) / (k(X) * Math.sqrt(mp(X)**2 + q(X)**2));   // (cx, cy), center of osculation circle at (X, Y)
  const cy = f(X) + q(X) / (k(X) * Math.sqrt(mp(X)**2 + q(X)**2));
]]

fstr = {'@(t) t', '@(t) sin(t)'}
opts = {t = {-2*pi, 2*pi, 0.01}, x = {-2*pi, 2*pi},
        layout = { title = 'y = sin(x)' },
        javascript = jscode,
        enhancements = {
          {x = fstr[1], y = fstr[2], t = {-2*pi, 2*pi}, color = 'blue'},
          {x = '@(t) cx + cos(t) / k(X)', y = '@(t) cy + sin(t) / k(X)', t = {0, 2*pi}, color = 'orange'},
          {x = 'X', y = 'Y', color = 'red', size = 10, point = true}
        }}
animate(fstr, opts)
