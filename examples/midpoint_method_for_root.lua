-- Animating the midpoint method for solving f(x) = x^3 - 2x + 2 = 0
-- by David Wang, dwang@liberty.edu, October 2025

mathly = require('mathly')

jscode = [[
  let a = -3, b = 2;
  let A = a, B = b;
  function f(x)   { return x**3 - 2*x + 2; }
  let fa = f(a), fb = f(b);
  var ab = [], midpts = [];
  ab.push([a, b]);
  for (let i = 1; i <= 56; i += 1) {
    let midpt = (a + b) / 2, fmidpt = f(midpt);
    if (fa * fmidpt > 0) {
      a = midpt; fa = fmidpt;
    } else {
      b = midpt; fb = fmidpt;
    }
    midpts.push(midpt);
    ab.push([a, b]);
  }
  a = A; b = B;

  function displaytext() { return '[' + ab[I-1][0] + ', ' + ab[I-1][1] + '], midpoint = ' + midpts[I-1]; }
]]

fstr = {'@(t) t', '@(t) f(ab[I-1][0]) + (f(ab[I-1][1]) - f(ab[I-1][0])) / (ab[I-1][1] - ab[I-1][0]) * (t - ab[I-1][0])'}
opts = {
  I = {1, 56, 1, label = 'Iterations'}, x = {-3.1, 2.1}, y = {-22, 8},
  layout = {
    width = 640, height = 640, square = false,
    title = "<font size=4 color=black>Midpoint method for <em>x<sup>3</sup> - 2x + 2 = 0</em> starting on [-3, 2]</font>"
  },
  javascript = jscode, controls = 'I',
  enhancements = {
    {x = '@(t) t', y = '@(t) t^3 - 2*t + 2', t = {-3.1, 2.1}, color = 'orange'},
    {x = {'ab[I-1][0]', 'ab[I-1][0]'}, y = {'f(ab[I-1][0])', 0}, line = true, width = 1, color = 'grey'},
    {x = 'ab[I-1][0]', y = 0, color = 'green', size = 8, point = true},
    {x = 'ab[I-1][0]', y = 'f(ab[I-1][0])', color = 'green', size = 8, point = true, style="'symbol': 'circle-open'"},
    {x = {'midpts[I-1]', 'midpts[I-1]'}, y = {'f(midpts[I-1])', 0}, line = true, width = 1, color = 'grey'},
    {x = {'ab[I-1][1]', 'ab[I-1][1]'}, y = {'f(ab[I-1][1])', 0}, line = true, width = 1, color = 'grey'},
    {x = 'ab[I-1][1]', y = 0, color = 'blue', size = 8, point = true},
    {x = 'ab[I-1][1]', y = 'f(ab[I-1][1])', color = 'blue', size = 8, point = true, style="'symbol': 'circle-open'"},
    {x = 'midpts[I-1]', y = 0, color = 'red', size = 8, point = true},
    {x = 'midpts[I-1]', y = 'f(midpts[I-1])', color = 'red', size = 8, point = true, style="'symbol': 'circle-open'"},
    {x = 'ab[I-1][0]', y = 1, color = 'black', size = 12, text = 'a'},
    {x = 'ab[I-1][1]', y = -0.5, color = 'black', size = 12, text = 'b'},
    {x = 'midpts[I-1]', y = -1.1, color = 'black', size = 12, text = 'midpoint'}
  }
}
manipulate(fstr, opts)

