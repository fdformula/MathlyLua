--
-- animate solving y'' = -2y + 5sqrt(x) + 2x - 5, y(0) = 1, y(5) = 2, x on [0, 5] by shooting method
--
-- dwang@liberty.edu, 11/19/2014
--
mathly = require('mathly')

a, b, Ya, Yb = 0.0, 5.0, 1.0, 2.0

jcode = [[
const a = %f, b = %f, Ya = %f, Yb = %f;
const n = 300;
const h = (b - a) / n, tol = 1e-15;

function fw(x, y, w) { return -2*y + 5*Math.sqrt(x) + 2*x - 5; } // dw/dx = -2y + 5sqrt(x) + 2x - 5; w(a) = ?
function fy(x, y, w) { return w; }       // dy/dx = w;      y(a) = Ya

const x = []; // shared data x
{var v = a; for (let i = 1; i <= n + 1; i++) { x.push(v); v += h; }}

var w, y, E1, E2;
var W1 = -5, W2 = 0; // the first 2 guesses of w(a)

function iterate() {
  for(let j = 0; j < I; j++) { // I? control
    var W;
    if (j == 0) {
      W = W1;
    } else if (j == 1) {
      W = W2;
    } else {
      W = W1 - (W2 - W1) / (E2 - E1) * E1; // guess W as a linear function of error E
    }

    w = [W]; y = [Ya];
    for(i = 0; i < n; i++) {
      const fyv = fy(x[i], y[i], w[i]), fwv = fw(x[i], y[i], w[i]);
      const I = i + 1;
      y[I] = y[i] + fyv * h; // Euler's method
      w[I] = w[i] + fwv * h;
      // y[I] = y[i] + 0.5 * (fyv + fy(x[I], y[I], w[I])) * h; // modified Euler's method
      // w[I] = w[i] + 0.5 * (fwv + fw(x[I], y[I], w[I])) * h;
    }
    const E = y[n] - Yb;
    mthlyTraces.push({ x: x, y: y, mode: 'lines', line: { simplify: false, width: (Math.abs(E) < tol || j == I - 1)? 4 : 1 }, fill: 'none' });
    mthlyTraces.push({ x: [%f], y: [y[n] ], mode: 'markers', marker: { color: 'grey', size: 6 } });

    if (j == 0) {
      E1 = E;
    } else if (j == 1) {
      E2 = E;
    } else {
      E1 = E2; E2 = E;
      W1 = W2; W2 = W;
    }
    if (Math.abs(E) < tol) { return [W, y[n], j + 1]; }
  }
  // plot enough extra objects outside the graph so that no old traces will stay - ugly, but works!
  for (i = 0; i < 2*(mthlyIMax - mthlyIMin + 1) / mthlyIStep; i++) {
    mthlyTraces.push({ x: [a], y: [mthlyyMax + 5], mode: 'markers'});
  }
  return [w[0], y[n] ]
}

function displaytext() {
  let v = iterate();
  if (v.length == 3) {
    return 'Done after ' + v[2] + ' attempts with w<sub>0</sub> = ' + v[0] + ' & y(5) = ' + v[1] + '.'
  } else {
    return 'w<sub>0</sub> = ' + v[0] + ', y(5) = ' + v[1] + ' (Yb = ' + Yb + ')';
  }
}
]]

fstr = nil -- no simple analytical solution to be plotted
opts = {
  I = {1, 20, 1, label = 'Guess No.'}, xrange = {-0.1, 5.1}, yrange = {-10, 18}, controls = 'I',
  javascript = string.format(jcode, a, b, Ya, Yb, b),
  layout = {
    width = 600, height = 500, square = false,
    title = 'Shooting method for y\\" = -2y + 5sqrt(x) + 2x - 5, y(0) = 1, y(5) = 2 on [0, 5]<br>&rArr; Solved as w\' = -2y + 5sqrt(x) + 2x - 5, w(0) = w<sub>0</sub> and y\' = w, y(0) = 1'
  },
  enhancements = {
    {x = b, y = Yb, point = true, color = 'red', size = 10},
    {x = 3.6, y = -3, text = 'Note: The red point is the target, and a', size = 12},
    {x = 3.8, y = -4.5, text = 'new guess is a linear function of', size = 12},
    {x = 3.85, y = -6, text = 'the errors at x = 5 corresponding', size = 12},
    {x = 3.6, y = -7.5, text = 'to the previous 2 guesses.', size = 12}
  }
}
manipulate(fstr, opts)
