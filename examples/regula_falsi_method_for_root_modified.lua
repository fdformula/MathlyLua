-- Animating modified regula falsi method for solving f(x) = x^3 - 2x + 2 = 0, forcing to approach a root from both sides.
-- by David Wang, dwang@liberty.edu, October 2025

mathly = require('mathly')

jscode = [[
  let a = -3, b = 2;
  let A = a, B = b;
  function f(x) { return x**3 - 2*x + 2; }
  let fa = f(a), fb = f(b);
  var ab = [], midpts = [];
  var fas = [fa], fbs = [fb];
  var counta = 0, countb = 0;
  ab.push([a, b]);
  for (let i = 1; i <= 67; i += 1) {
    let midpt = a - (b - a)/(fb - fa) * fa, fmidpt = f(midpt);
    if (fa * fmidpt > 0) {
      a = midpt; fa = fmidpt;
      if (m == 2) {
        counta = counta + 1; countb = 0;
        if (counta == 3) { fb = fb/2; counta = r; } // reset counta to r (0/1/2)
      }
    } else {
      b = midpt; fb = fmidpt;
      if (m == 2) {
        counta = 0; countb = countb + 1;
        if (countb == 3) { fa = fa/2; countb = r; } // reset countb to r (0/1/2)
      }
    }
    midpts.push(midpt);
    ab.push([a, b]);
    fas.push(fa); fbs.push(fb);
  }
  a = A; b = B;

  function displaytext() { return ((m == 1)? 'Original ' : 'Modified') +' method: [' + ab[I-1][0] + ', ' + ab[I-1][1] + '], x-intercept = ' + midpts[I-1]; }
]]

fstr = {'@(t) t', '@(t) f(ab[I-1][0]) + (f(ab[I-1][1]) - f(ab[I-1][0])) / (ab[I-1][1] - ab[I-1][0]) * (t - ab[I-1][0])'}
opts = {
  I = {1, 67, 1, label = 'Iterations'}, x = {-3.1, 2.1}, y = {-22, 8},
  m = {1, 2, 1, label = 'Method'}, r = {0, 2, 1, label = 'Reset count to'},
  layout = {
    width = 640, height = 640, square = false,
    title = "<h3>Regula falsi method for x<sup>3</sup> - 2x + 2 = 0 starting on [-3, 2]</h3>"
  },
  javascript = jscode, controls = 'mrI',
  enhancements = {
    {x = {'ab[I-1][0]', 'ab[I-1][1]'}, y = {'fas[I-1]', 'fbs[I-1]'}, line = true, width = 1, color = 'grey'},
    {x = '@(t) t', y = '@(t) t^3 - 2*t + 2', t = {-3.1, 2.1}, color = 'orange'},
    {x = {'ab[I-1][0]', 'ab[I-1][0]'}, y = {'f(ab[I-1][0])', 0}, line = true, width = 1, color = 'grey'},
    {x = 'ab[I-1][0]', y = 0, point = true, size = 8, color = 'green'},
    {x = 'ab[I-1][0]', y = 'fas[I-1]', point = true, size = 12, color = 'green', style="'symbol': 'circle-open'"},
    {x = {'ab[I-1][1]', 'ab[I-1][1]'}, y = {'f(ab[I-1][1])', 0}, line = true, width = 1, color = 'grey'},
    {x = 'ab[I-1][1]', y = 0, point = true, size = 8, color = 'blue'},
    {x = 'ab[I-1][1]', y = 'fbs[I-1]', point = true, size = 12, color = 'blue', style="'symbol': 'circle-open'"},
    {x = 'midpts[I-1]', y = 0, color = 'red', size = 8, point = true},
    {x = 'ab[I-1][0]', y = 1, color = 'black', size = 12, text = 'a'},
    {x = 'ab[I-1][1]', y = -0.5, color = 'black', size = 12, text = 'b'}}}
manipulate(fstr, opts)
