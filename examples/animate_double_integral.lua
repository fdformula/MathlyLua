-- Animating the double integral of f(x, y) over [a, b] x [c, d]

mathly = require('mathly')

jcode = [[
  function f(x, y) { return 16 - x*x - 2*y*y; }
  let a = 0, b = 2, c = 0, d = 2;

  let rule = (O == 1)? 'Mid' : ((O == 2)? 'Left down end' : ((O == 3)? 'Right up end' : ((O == 4)? 'Left up end' : ((O == 5)? 'Right down end' : 'Random '))));
  function plotgrids(hx, hy) {
    let x = a, y = c;
    for (i = 0; i <= m; i++) {
      mthlyTraces.push({ 'x': [x, x], 'y': [c, d], 'mode': 'lines', 'line': { 'color': 'green', 'width': 1  } });
      x += hx;
    }
    for (i = 0; i <= n; i++) {
      mthlyTraces.push({ 'x': [a, b], 'y': [y, y], 'mode': 'lines', 'line': { 'color': 'green', 'width': 1  } });
      y += hy;
    }
  }
  function sum() {
    let hx = (b - a) / m, hy = (d - c) / n;
    let randq = false;
    plotgrids(hx, hy);
    var x, ystart, s = 0;
    if (O == 1) {
      x = a + hx / 2; ystart = c + hy / 2; rule = 'Mid';
    } else if (O == 2) {
      x = a; ystart = c; rule = 'Left down end';
    } else if (O == 3) {
      x = a; ystart = c + hy; rule = 'Left up end';
    } else if (O == 4) {
      x = a + hx; ystart = c; rule = 'Right down end';
    } else if (O == 5) {
      x = a + hx; ystart = c + hy; rule = 'Right up end';
    } else {
      randq = true; rule = 'Random ';
    }

    if (randq) {
      x = a;
      for (i = 0; i < m; i++) {
        y = c;
        for (j = 0; j < n; j++ ) {
          let X = x + hx * Math.random(), Y = y + hy * Math.random();
          mthlyTraces.push({ 'x': [X], 'y': [Y], 'mode': 'markers', 'marker': { 'color': 'red', 'size': 6  } });
          s += f(X, Y);
          y += hy;
        }
        x += hx;
      }
    } else {
      for (i = 1; i <= m; i++) {
        let y = ystart;
        for (j = 1; j <= n; j++) {
          mthlyTraces.push({ 'x': [x], 'y': [y], 'mode': 'markers', 'marker': { 'color': 'red', 'size': 6  } });
          s += f(x, y);
          y += hy;
        }
        x += hx;
      }
    }

    // plot enough extra objects outside the graph so that no old traces will stay - ugly, but works!
    x = mthlyxMax + 1;
    for (i = 0; i < mthlymMax; i++) {
      y = mthlyyMax + 1
      for (j = 0; j < mthlynMax; j++) {
        mthlyTraces.push({ 'x': [x], 'y': [y], 'mode': 'markers'});
        y += hy;
      }
      x += hx;
    }
    return s * hx * hy;
  }

  function displaytext() { const s = sum(); return rule + 'point method: V = ' + s + ' (Exact value: 48)'; }
]]

fstr = '@(x) mthlyyMax + 5'
opts = {m = {1, 32, 1, default = 8, label = 'X Subintervals'}, n = {1, 32, 1, default = 8, label = 'Y Subintervals'}, O = {1, 6, 1, default = 1, label = 'Method'},
        x = {0, 2.1}, y = {-0.05, 2.1},
        controls = 'Omn', javascript = jcode,
        layout = { width = 640, height = 640, square = true, title = 'Double integral of 16 - x^2 - 2y^2 over [0, 2] x [0, 2]' }}
manipulate(fstr, opts)
