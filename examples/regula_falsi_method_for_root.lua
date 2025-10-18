-- Animating regula falsi method for solving f(x) = 3cos(x) - 0.3x^2 + 2 = 0, approaching the root from both sides.

mathly = require('mathly')

jscode = [[
  let a = -1.6, b = 5.5;
  let A = a, B = b;
  function f(x) { return 3*Math.cos(x) - 0.3*x**2 + 2; }
  let fa = f(a), fb = f(b);
  var ab = [], midpts = [];
  ab.push([a, b]);
  for (let i = 1; i <= 12; i += 1) {
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

fstr = {{'@(t) t', '@(t) f(ab[I-1][0]) + (f(ab[I-1][1]) - f(ab[I-1][0])) / (ab[I-1][1] - ab[I-1][0]) * (t - ab[I-1][0])'},
        {x = {'ab[I-1][0]', 'ab[I-1][0]'}, y = {'f(ab[I-1][0])', 0}, line = true, width = 1, color = 'grey'},
        {x = {'ab[I-1][1]', 'ab[I-1][1]'}, y = {'f(ab[I-1][1])', 0}, line = true, width = 1, color = 'grey'}}
opts = {t = {-2.5, 6.1, 0.01}, I = {1, 12, 1, label = 'Iterations'}, x = {-2.5, 6.1}, y = {-6, 6},
        layout = { width = 640, height = 640, square = false, title = "Regula falsi method for 3cos(x) - 0.3x^2 + 2 = 0 starting on [-1.6, 5.5]" },
        javascript = jscode, controls = 'I', cumulative = false,
        enhancements = {{x = {'ab[I-1][0]', 'ab[I-1][1]'}, y = {'f(ab[I-1][0])', 'f(ab[I-1][1])'}, line = true, width = 1, color = 'grey'},
                        {x = '@(t) t', y = '@(t) 3*cos(t) - 0.3*t^2 + 2', t = {-2.5, 6.1}, color = 'orange'},
                        {x = 'midpts[I-1]', y = 0, color = 'red', size = 8, point = true}
                       }}
manipulate(fstr, opts)
