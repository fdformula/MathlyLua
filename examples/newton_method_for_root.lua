-- Animating Newton's method for solving f(x) = x^3 - 2x + 2 = 0
-- by David Wang, dwang@liberty.edu, October 2025

mathly = require('mathly')

jscode = [[
  function f(x) { return x**3 - 2*x + 2; }
  function fprime(x) { return 3*x**2 - 2; }  // f'(x))
  function nextx(x) { return x - f(x) / fprime(x); }
  var xs = [];
  xs.push(i); // initial guess
  for (let i = 0; i < 16; i += 1) { xs.push( nextx(xs[i]) ); }

  function displaytext() { return 'Initial guess: x<sub>0</sub> = ' + i + '; Iteration ' + I + ': x<sub>' + I + '</sub> = ' + xs[I-1]; }
]]

fstr = {'@(t) t', '@(t) f(xs[I-1]) + fprime(xs[I-1]) * (t - xs[I-1])'}
opts = {
  I = {1, 16, 1, label = 'Iterations'}, x = {-4, 4}, y = {-45, 15},
  layout = {
    width = 640, height = 640, square = false,
    title = "<h3>Newton\\'s method for x<sup>3</sup> - 2x + 2 = 0 starting at x = 1.2</h3>"
  },
  javascript = jscode, controls = 'iI', i = {0, 2.5, 0.5, default = 2.5, label = 'Initial Guess'},
  enhancements = {
    {x = {'xs[I-1]', 'xs[I-1]'}, y = {'f(xs[I-1])', 0}, line = true, width = 1, color = 'grey'},
    {x = '@(t) t', y = '@(t) t^3 - 2*t + 2', t = {-4, 4}, color = 'orange'},
    {x = 'xs[I]', y = 0, color = 'blue', size = 8, point = true},
    {x = 'xs[I-1]', y = 0, color = 'red', size = 8, point = true},
    {x = 'xs[I-1]', y = 'f(xs[I-1])', color = 'red', size = 8, point = true, style="'symbol': 'circle-open'"},
    {x = 'xs[I-1]', y = -0.7, color = 'black', size = 12, text = "x<sub>' + (I-1) + '</sub>"},
    {x = 'xs[I]', y = -0.7, color = 'black', size = 12, text = "x<sub>' + I + '</sub>"}}}
manipulate(fstr, opts)
