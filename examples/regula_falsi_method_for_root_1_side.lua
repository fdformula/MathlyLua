-- Animating regula falsi method for solving f(x) = x^3 - 2x + 2 = 0, approaching the root from one single side.

mathly = require('mathly')

jscode = [[
  let a = -3, b = 2;
  let A = a, B = b;
  function f(x) { return x**3 - 2*x + 2; }
  let fa = f(a), fb = f(b);
  var ab = [], midpts = [];
  ab.push([a, b]);
  for (let i = 1; i <= 67; i += 1) {
    let midpt = a - (b - a)/(fb - fa) * fa, fmidpt = f(midpt);
    if (fa * fmidpt > 0) {
      a = midpt; fa = fmidpt;
    } else {
      b = midpt; fb = fmidpt;
    }
    midpts.push(midpt);
    ab.push([a, b]);
  }
  a = A; b = B;

  function displaytext() { return '[' + ab[I-1][0] + ', ' + ab[I-1][1] + '], x-intercept = ' + midpts[I-1]; }
]]

fstr = {'@(t) t', '@(t) f(ab[I-1][0]) + (f(ab[I-1][1]) - f(ab[I-1][0])) / (ab[I-1][1] - ab[I-1][0]) * (t - ab[I-1][0])'}
opts = {I = {1, 67, 1, label = 'Iterations'}, x = {-3.1, 2.1}, y = {-22, 8},
        layout = { width = 640, height = 640, square = false, title = "Regula falsi method for x^3 - 2*x + 2 = 0 starting on [-3, 2]" },
        javascript = jscode, controls = 'I',
        enhancements = {
          {x = {'ab[I-1][0]', 'ab[I-1][1]'}, y = {'f(ab[I-1][0])', 'f(ab[I-1][1])'}, line = true, width = 1, color = 'grey'},
          {x = '@(t) t', y = '@(t) t^3 - 2*t + 2', t = {-3.1, 2.1}, color = 'orange'},
          {x = {'ab[I-1][0]', 'ab[I-1][0]'}, y = {'f(ab[I-1][0])', 0}, line = true, width = 1, color = 'grey'},
          {x = 'ab[I-1][0]', y = 0, point = true, size = 8, color = 'green'},
          {x = {'ab[I-1][1]', 'ab[I-1][1]'}, y = {'f(ab[I-1][1])', 0}, line = true, width = 1, color = 'grey'},
          {x = 'ab[I-1][1]', y = 0, point = true, size = 8, color = 'blue'},
          {x = 'midpts[I-1]', y = 0, color = 'red', size = 8, point = true}
        }}
manipulate(fstr, opts)
