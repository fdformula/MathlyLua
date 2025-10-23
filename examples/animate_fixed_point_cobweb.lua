-- Animating the fixed-point method or the generation of a cobweb for x = g(x)

mathly = require('mathly')
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
      mthlyTraces.push({'x': [ xs[i-2], xs[i-1] ], 'y': [ xs[i-1], xs[i-1] ], 'mode': 'lines', 'line': style}); // horizontal line
      mthlyTraces.push({'x': [ xs[i-1], xs[i-1] ], 'y': [ xs[i-1], xs[i]   ], 'mode': 'lines', 'line': style}); // vertical line
    }

    // plot enough extra objects outside the graph so that no old traces will stay - ugly, but works!
    for (let i = 1; i <= mthlyIMax * 4; i ++) {
      mthlyTraces.push({ 'x': [mthlyxMax + i], 'y': [mthlyyMax + i], 'mode': 'markers' })
    }
  }

  function displaytext() { plotweb(); return 'x<sub>' + (I-1) + '</sub> = ' + xs[I-1]; }
]]

fstr = '@(x) ' .. g
opts = {I = {1, MaxIterations, 1, default = MaxIterations, label = 'Iterations'}, x = {-0.1, 1.1}, y = {-0.1, 1.1},
        a = {0, 1, 0.1, default = 0.9, label = 'Initial Value'},
        layout = { width = 540, height = 540, square = true, title = "Cobweb of g(x) = " .. g },
        javascript = string.format(jscode, _to_jscript_expr(g), MaxIterations), controls = 'aI',
        enhancements = {
          {x = '@(t) t', y = '@(t) t', t = {0, 1}, width = 2, color = 'green'}, -- line: y = x
          {x = {'xs[0]', 'xs[0]'}, y = {0, 'xs[1]'}, line = true, width = 1, color = 'grey'},
          {x = 'xs[I-1]', y = 'g(xs[I-1])', color = 'red', size = 8, point = true},
          {x = 'xs[I-1]', y = 0, color = 'red', size = 8, point = true},
          {x = 'xs[I-1]', y = -0.02, color = 'black', size = 12, text = "x<sub>' + (I-1) + '</sub>"}
        }}
manipulate(fstr, opts)
