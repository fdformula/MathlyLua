-- Animating the secant method for solving <code>f(x) = x^3 - 2x + 2 = 0

mathly = require('mathly')

jscode = [[
  let x1 = -3, x2 = 2;
  let X1 = x1, X2 = x2;
  function f(x) { return x**3 - 2*x + 2; }
  let fx1 = f(x1), fx2 = f(x2);
  var ab = [], midpts = [];
  for (let i = 1; i <= 26; i += 1) {
    let midpt = x1 - (x2 - x1)/(fx2 - fx1) * fx1, fmidpt = f(midpt);
    midpts.push(midpt);
    ab.push([x1, x2]);
    x1 = x2; fx1 = fx2;
    x2 = midpt; fx2 = fmidpt;
  }
  x1 = X1; x2 = X2;

  function displaytext() { return 'x<sub>1</sub> = ' + ab[I-1][0] + ', x<sub>2</sub> = ' + ab[I-1][1] + ', x<sub>3</sub> = ' + midpts[I-1]; }
]]

fstr = {{'@(t) t', '@(t) f(ab[I-1][0]) + (f(ab[I-1][1]) - f(ab[I-1][0])) / (ab[I-1][1] - ab[I-1][0]) * (t - ab[I-1][0])'},
        {x = {'ab[I-1][0]', 'ab[I-1][0]'}, y = {'f(ab[I-1][0])', 0}, line = true, width = 1, color = 'grey'},
        {x = {'ab[I-1][1]', 'ab[I-1][1]'}, y = {'f(ab[I-1][1])', 0}, line = true, width = 1, color = 'grey'},
        {x = 'ab[I-1][0]', y = 0, color = 'grey', size = 8, point = true},
        {x = 'ab[I-1][1]', y = 0, color = 'blue', size = 8, point = true}}
opts = {t = {-4.1, 4.1, 0.01}, I = {1, 26, 1, label = 'Iterations'}, x = {-4.1, 4.1}, y = {-46, 40},
        layout = { width = 640, height = 640, square = false, title = "Secant method for x^3 - 2x + 2 = 0 starting with x1 = -3 and x2 = 2" },
        javascript = jscode, controls = 'I', cumulative = false,
        enhancements = {{x = '@(t) t', y = '@(t) f(ab[I-1][0]) + (f(ab[I-1][1]) - f(ab[I-1][0]))/(ab[I-1][1] - ab[I-1][0]) * (t - ab[I-1][0])', t = {-4.1, 4.1}, width = 1, color = 'grey'},
                        {x = '@(t) t', y = '@(t) t^3 - 2*t + 2', t = {-4.1, 4.1}, color = 'orange'},
                        {x = 'midpts[I-1]', y = 0, color = 'red', size = 8, point = true}
                       }}
manipulate(fstr, opts)
