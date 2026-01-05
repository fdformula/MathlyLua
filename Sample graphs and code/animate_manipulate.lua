mathly = require('mathly')

-- manipulate1.jpg
manipulate('@(x) a * (x - h)^2 + k',
           {a = {-3, 3, 0.02, default = 3}, h = {-10, 10, 0.5, default = 0}, k = {-90, 90, default = 0},
            x = {-10, 10}, y = {-100, 100},
            layout = { width = 600, height = 400, square = false }})

-- manipulate2.jpg
fstr = {'@(t) a*sin(m * t)', '@(t) b*sin(n * t)'}
opts = {t = {0, 2*pi, 0.01},
        a = {0.1, 5, 0.1, default = 1}, m = {1, 20, 1, default = 2},
        b = {0.1, 5, 0.1, default = 2}, n = {1, 20, 1, default = 1},
        x = {-5, 5}, resolution = 1500,
        layout = { width = 640, height = 540 }}
manipulate(fstr, opts)

-- animate1~3.jpg
fstr = {'@(t) r * t - d*sin(t)', '@(t) r - d*cos(t)'}
opts = {t = {0, 8 * pi, 0.01}, r = {0.1, 5, 0.1, default = 1.5}, d = {0.1, 5, 0.1, default = 1.5},
        x = {-2, 40}, y = {-5, 10.5},
        layout = {width = 800, height = 400},
        enhancements = {{x = 'X', y = 'Y', color = 'red', size = 10, point = true},
                        {x = '@(t) r * T + r * cos(t)', y = '@(t) r + r * sin(t)', t = {0, 2 * pi}, color = 'orange'},
                        {x = {'X', 'r * T'}, y = {'Y', 'r'}, line = true, color = 'orange'}
                       }}
animate(fstr, opts)

-- animate4.jpg
jscode = [[
  var Xb = X - b;
  var z = Xb / Y;
  var xx, yy = Y + Xb*z;
  var s = Math.sqrt(L*L - b*b - (Xb - b)*X + 2*Y*Xb*z + (L*L - Y*Y)*z*z);
  if (Y > 0) {
    yy = yy - s;
  } else {
    yy = yy + s;
  }
  yy = yy / (1 + z*z);
  xx = b + z * yy;
]]
fstr = {'@(t) R * cos(t) + 0*b + 0*L', '@(t) R * sin(t)'} -- 0*b + 0*L, b and L are controls, too; X, Y, and T are about a point on this curve
opts = {t = {0, 2 * pi, 0.01},
        b = {0.1, 5, 0.1, default = 2.7}, R = {0.1, 5, 0.1, default = 2}, L = { 0.1, 5, 0.1, default = 5},
        x = {-3, 5}, y = {-4, 4},
        layout = { width = 640, height = 480, title = '',
                   xaxis = { showgrid = false, zeroline = false, showticklabels = false },
                   yaxis = { showgrid = false, zeroline = false, showticklabels = false }},
        javascript = jscode,
        enhancements = {{x = fstr[1], y = fstr[2], t = {0, 2*pi}, color = 'blue'},                           -- order of graphics objects matters, the latter
                        {x = '@(t) b + (L / sqrt(R**2 + b**2 - 2 * b * R * cos(t)) - 1) * (b - R * cos(t))', -- ones are plotted over the former ones
                         y = '@(t) R * (1 - L / sqrt(R**2 + b**2 - 2 * b * R * cos(t))) * sin(t)',
                         t = {0, 2 * pi}, color = 'cyan'},
                        {x = {'X', 'xx'}, y = {'Y', 'yy'}, line = true, color = 'orange'}, -- xx and yy are calculated in the JavaScript code
                        {x = 'X', y = 'Y', color = 'red', size = 10, point = true},
                        {x = 'b', y = 0, color = 'grey', size = 10, point = true},
                        {x = 'xx', y = 'yy', color = 'red', size = 10, point = true}
                       }}
animate(fstr, opts)

-- manipulate3.jpg
-- Animating the definite integral of f(x) on [a, b]
-- by David Wang, dwang@liberty.edu, October 2025

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
        mthlyTraces.push({x: [x1, x1], y: [0, f1], mode: 'lines', line: style});
        mthlyTraces.push({x: [x1, x2], y: [f1, f2], mode: 'lines', line: style});
        mthlyTraces.push({x: [x2, x2], y: [f2, 0], mode: 'lines', line: style});
        if (i < N - 1) { s += f2; }
        f1 = f2;
      } else {
        mthlyTraces.push({x: [x1, x1], y: [0, fx], mode: 'lines', line: style});
        mthlyTraces.push({x: [x1, x2], y: [fx, fx], mode: 'lines', line: style});
        mthlyTraces.push({x: [x2, x2], y: [fx, 0], mode: 'lines', line: style});
        if (O == 3 || O == 4) {
          mthlyTraces.push({x: [x, x], y: [0, fx], mode: 'lines', line: { color: 'grey', width: 0.3}}); // dash: 'dot'
          mthlyTraces.push({x: [x], y: [0], mode: 'markers', marker: { color: 'red', size: 6}});
        }
        s += fx;
      }
      x1 = x2;
      if (randq) { x = x1 + h * Math.random(); } else { x = x + h; }
    }

    // plot enough extra objects outside the graph so that no old traces will stay - ugly, but works!
    x = mthlyxMax + 5;
    for (i = 0; i < mthlyNMax * 5; i++) {
      mthlyTraces.push({ x: [x], y: [mthlyyMax + 5], mode: 'markers'});
      x += h;
    }

    if (trapzq) { s += (f(a) + f2) / 2; }
    return s * h;
  }
  function displaytext() { const s = sum(); return rule + ' method: A = ' + s + ' (Exact value: 2/3 or 0.6666666666666667)'; }
]]

MaxN = 50 -- max number of subintervals
fstr = '@(x) 1 - x^2'
opts = {
  N = {1, MaxN, 1, default = MaxN, label = 'Subintervals'}, x = {-0.1, 1.1}, y = {-0.1, 1.12},
  O = {1, 5, 1, default = 3, label = 'Method'},
  controls = 'ON', javascript = jscode,
  layout = {
    width = 640, height = 640, square = true,
    title = "<h3>Animating the integral of f(x) = 1 - x<sup>2</sup> on [0, 1]</h3>",
    xaxis = { showgrid = false }, yaxis = { showgrid = false }}
}
manipulate(fstr, opts)

-- manipulate4.jpg
--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ cobweb for x = g(x) ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓--
g = '1 - sqrt(x)'  -- g(x) = 1 - sqrt(x); divergent? g = '1-x^2'
MaxIterations = 30
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ cobweb for x = g(x) ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑--
jscode = [[
  function g(x) { return %s; }
  var xs = [a]; // xs[i] == g(xs[i-1]); jscript index starts at 0 & xs[0] is extra
  for (let I = 0; I <= %d; I += 1) { xs.push( g(xs[I]) ); } // one extra element, xs[0]!

  function plotweb() {
    let style = { 'color': 'grey', 'width': 1 }
    for (let i = 2; i <= I; i++) {
      mthlyTraces.push({x: [ xs[i-2], xs[i-1] ], y: [ xs[i-1], xs[i-1] ], mode: 'lines', line: style}); // horizontal line
      mthlyTraces.push({x: [ xs[i-1], xs[i-1] ], y: [ xs[i-1], xs[i]   ], mode: 'lines', line: style}); // vertical line
    }

    // plot enough extra objects outside the graph so that no old traces will stay - ugly, but works!
    for (let i = 1; i <= mthlyIMax * 4; i ++) {
      mthlyTraces.push({ x: [mthlyxMax + i], y: [mthlyyMax + i], mode: 'markers' })
    }
  }

  function displaytext() { plotweb(); return 'x<sub>' + (I-1) + '</sub> = ' + xs[I-1]; }
]]

fstr = '@(x) ' .. g
opts = {
  I = {1, MaxIterations, 1, default = MaxIterations, label = 'Iterations'}, x = {-0.1, 1.1}, y = {-0.1, 1.1},
  a = {0, 1, 0.1, default = 0.9, label = 'Initial Value'},
  layout = {
    width = 540, height = 540, square = true,
    title = "<h3>Cobweb of g(x) = " .. g .. '</h3>'
  },
  javascript = string.format(jscode, _to_jscript_expr(g), MaxIterations), controls = 'aI',
  enhancements = {
    {x = '@(t) t', y = '@(t) t', t = {0, 1}, width = 2, color = 'green'}, -- line: y = x
    {x = {'xs[0]', 'xs[0]'}, y = {0, 'xs[1]'}, line = true, width = 1, color = 'grey'},
    {x = 'xs[I-1]', y = 'g(xs[I-1])', color = 'red', size = 8, point = true},
    {x = 'xs[I-1]', y = 0, color = 'red', size = 8, point = true},
    {x = 'xs[I-1]', y = -0.02, color = 'black', size = 12, text = "x<sub>' + (I-1) + '</sub>"}
  }
}
manipulate(fstr, opts)
