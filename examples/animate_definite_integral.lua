-- Animating the definite integral of f(x) on [a, b]

mathly = require('mathly')

jscode = [[
  function f(x) { return 1 - x*x; }
  const a = 0, b = 1;

  const style = { 'color': 'grey', 'width': 1};
  var rule;
  function sum() {
    var x1 = a, x, randq = false, s = 0, h = (b - a) / N, trapzq = false, f1, f2;
    if (O == 1) {
      x = a;
      rule = 'Left endpoint';
    } else if (O == 2) {
      x = a + h;
      rule = 'Right endpoint';
    } else if (O == 3) {
      x = a + h/2;
      rule = 'Midpoint';
    } else if (O == 4) {
      randq = true;
      x = a + h * Math.random();
      rule = 'Random point';
    } else {
      rule = 'Trapezoidal';
      x = a; f1 = f(x1);
      trapzq = true;
    }
    for (let i = 0; i < N; i++) {
      const x2 = x1 + h, fx = f(x);
      if (trapzq) {
        f2 = f(x2);
        mthlyTraces.push({'x': [x1, x1], 'y': [0, f1], 'mode': 'lines', 'line': style});
        mthlyTraces.push({'x': [x1, x2], 'y': [f1, f2], 'mode': 'lines', 'line': style});
        mthlyTraces.push({'x': [x2, x2], 'y': [f2, 0], 'mode': 'lines', 'line': style});
        if (i < N - 1) { s += f2; }
        f1 = f2;
      } else {
        mthlyTraces.push({'x': [x1, x1], 'y': [0, fx], 'mode': 'lines', 'line': style});
        mthlyTraces.push({'x': [x1, x2], 'y': [fx, fx], 'mode': 'lines', 'line': style});
        mthlyTraces.push({'x': [x2, x2], 'y': [fx, 0], 'mode': 'lines', 'line': style});
        if (O == 3 || O == 4) {
          mthlyTraces.push({'x': [x, x], 'y': [0, fx], 'mode': 'lines', 'line': { 'color': 'grey', 'width': 0.3}}); // 'dash': 'dot'
          mthlyTraces.push({'x': [x], 'y': [0], 'mode': 'markers', 'marker': { 'color': 'red', 'size': 6}});
        }
        s += fx;
      }
      x1 = x2;
      if (randq) { x = x1 + h * Math.random(); } else { x = x + h; }
    }

    // plot enough extra objects outside the graph so that no old traces will stay - ugly, but works!
    x = mthlyxMax + 5;
    for (i = 0; i < mthlyNMax * 5; i++) {
      mthlyTraces.push({ 'x': [x], 'y': [mthlyyMax + 5], 'mode': 'markers'});
      x += h;
    }

    if (trapzq) { s += (f(a) + f2) / 2; }
    return s * h;
  }
  function displaytext() { const s = sum(); return rule + ' method: A = ' + s + ' (Exact value: 2/3 or 0.6666666666666667)'; }
]]

MaxN = 50 -- max number of subintervals
fstr = '@(x) 1 - x^2'
opts = {N = {1, MaxN, 1, default = MaxN, label = 'Subintervals'}, x = {-0.1, 1.1}, y = {-0.1, 1.12},
        O = {1, 5, 1, default = 3, label = 'Method'},
        controls = 'ON', javascript = jscode,
        layout = { width = 640, height = 640, square = true, title = "Animating the integral of f(x) = 1 - x^2 on [0, 1]",
                   xaxis = { showgrid = false }, yaxis = { showgrid = false }},
        }
manipulate(fstr, opts)
