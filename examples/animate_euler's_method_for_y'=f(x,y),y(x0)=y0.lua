--
-- animating Euler's method for y' = f(x,y); y(x0) = y0 on [a, b], i.e., [x0, b]
-- by David Wang, dwang@liberty.edu, on 11/06/2025 Thursday
--
mathly = require('mathly')

jscode = [[
  function f(x, y) { return %s; }
  const a = %f, b = %f;
  var h;
  function plotsolu() {
    var xs = [%f], ys = [%f];
    h = (b - a) / n;
    let style = {'color': 'red', 'width': 1}
    var xi = xs[0], yi = ys[0];
    for (let i = 1; i < I; i++) {
      yi = yi + f(xi, yi)*h; ys.push(yi);
      xi = xi + h; xs.push(xi);
      mthlyTraces.push({x: [xs[i-1], xs[i] ], y: [ys[i-1], ys[i] ], mode: 'lines+markers', line: style});
    }

    // plot enough extra objects outside the graph so that no old traces will stay - ugly, but works!
    for (let i = 1; i <= mthlyIMax; i ++) {
      mthlyTraces.push({x: [mthlyxMax + 10], y: [mthlyyMax + 10], mode: 'markers'})
    }
  }

  function displaytext() { plotsolu(); return 'Increment in <i>x</i>: ' + h; };
  function displaytitle() { return "<h3>Animating Euler's method for <i>y' = 1/15 e<sup>x</sup>, y(0) = 1</i></h3>"};
]]

---------- define the initial-value problem ----------
fexpr = '1/15*exp(x)' -- expression of f(x,y)
soluStr = '@(x) 1/15*exp(x) + 14/15' -- exact solution
x0, y0 = 0, 1
a, b = x0, 5
------------------------------------------------------
opts = {
  x = {a, b}, y = {0, 10}, -- make adjustments here for your initial-value problem
  I = {1, 50, 1, default = 15, label = 'Iterations'}, n = {1, 50, 1, default =17, label = 'Subintervals'}, controls = 'In',
  width = 2, color = 'green',
  layout = {width = 500, height = 500},
  javascript = string.format(jscode, _to_jscript_expr(fexpr), a, b, x0, y0),
  enhancements = {{x = x0, y = y0, point = true, color = 'red'}}
}

manipulate(soluStr, opts)
