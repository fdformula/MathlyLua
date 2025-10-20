-- Animating the derivative of y = f(x) at x = x0

mathly = require('mathly')

jscode = [[
  function f(x) { return x*x; }
  const x0 = 0.5;
  const fx0 = f(x0);
  if (Math.abs(h) < 0.0000000001) { if (h > 0) {h == 0.000000001;} else {h = -0.000000001}}
  const x1 = x0 + h, fx1 = f(x1), k = (f(x1) - fx0) / h; // k: slope
  function displaytext() { return 'Slope of the secant line: ' + k + ' (Exact value: 1)'; }
]]

fstr = {'@(t) t', '@(t) fx0 + k * (t - x0)'} -- @(x) fx0 + k * (x - x0)'
opts = {h = {-1.95, 0.87, 0.01, default = -0.79, label = 'Increment in x'}, controls = 'h',
        x = {-1.5, 1.43}, y = {-0.1, 2.12}, width = 1, color = 'grey',
        layout = { width = 540, height = 640, square = true, title = "Animating a derivative" },
        javascript = jscode,
        enhancements = {
          {x = '@(t) t', y = '@(t) t^2', color = 'orange', width = 2}, -- y = f(x)
          {x = '@(t) t', y = '@(t) fx0 + 1*(t - x0)', style = 'dash: "dot"', width = 2, color = "green"}, -- tangent line at x = x0
          {x = 'x0', y = 'fx0', point = true, color = 'green', width = 8},
          {x = 'x0', y = 0, point = true, color = 'green', width = 8},
          {x = {'x0', 'x0'}, y = {0, 'fx0'}, line = true, color = 'green', width = 1},
          {x = 'x1', y = 'fx1', point = true, color = 'red', width = 8},
          {x = 'x1', y = 0, point = true, color = 'red', width = 8},
          {x = {'x1', 'x1'}, y = {0, 'fx1'}, line = true, color = 'grey', width = 1}
        }}
manipulate(fstr, opts)
