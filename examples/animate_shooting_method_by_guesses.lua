--
-- animate solving y'' = -2y + 5sqrt(x) + 2x - 5, y(0) = 1, y(5) = 2, x on [0, 5] by shooting method
--
-- for demonstration only
--
-- dwang@liberty.edu, 11/19/2014
--
mathly = require('mathly')

a, b, Ya, Yb = 0.0, 5.0, 1.0, 2.0

jcode = [[
const a = %f, b = %f, Ya = %f, Yb = %f;
const n = 200;
const h = (b - a) / n, tol = 1e-14;

function fw(x, y, w) { return -2*y + 5*Math.sqrt(x) + 2*x - 5; } // dw/dx = -2y + 5sqrt(x) + 2x - 5; w(a) = ?
function fy(x, y, w) { return w; }       // dy/dx = w;      y(a) = Ya

const guesses = [];
for (let i = -20; i <= 2; i += 2) { guesses.push(i); }

const x = []; // shared data x
{var v = a; for (let i = 1; i <= n + 1; i++) { x.push(v); v += h; }}

function iterate() {
  var w, y;
  for(let j = 0; j < I; j++) { // I? control
    w = [guesses[j] ]; y = [Ya];
    for(i = 0; i < n; i++) {
      const fyv = fy(x[i], y[i], w[i]), fwv = fw(x[i], y[i], w[i]);
      const I = i + 1;
      y[I] = y[i] + fyv * h; // Euler's method
      w[I] = w[i] + fwv * h;
      // y[I] = y[i] + 0.5 * (fyv + fy(x[I], y[I], w[I])) * h; // modified Euler's method
      // w[I] = w[i] + 0.5 * (fwv + fw(x[I], y[I], w[I])) * h;
    }
    mthlyTraces.push({ x: x, y: y, mode: 'lines', line: { simplify: false, width: (j == I - 1)? 4 : 1 }, fill: 'none' });
    mthlyTraces.push({ x: [%f], y: [y[n] ], mode: 'markers', marker: { color: 'grey', size: 5 } });
  }
  // plot enough extra objects outside the graph so that no old traces will stay - ugly, but works!
  for (i = 0; i < 2*(mthlyIMax - mthlyIMin + 1) / mthlyIStep; i++) {
    mthlyTraces.push({ x: [a], y: [mthlyyMax + 5], mode: 'markers'});
  }
  return [w[0], y[n] ]
}

function displaytext() {
  let v = iterate();
  return 'w<sub>0</sub> = ' + v[0] + ', y(b) = ' + v[1] + ' (Yb = ' + Yb + ')';
}
]]

fstr = nil -- no simple analytical solution to be plotted
opts = {
  I = {1, 12, 1, label = 'Guess No.'}, x = {-0.1, 5.1}, y = {-17, 25}, controls = 'I',
  javascript = string.format(jcode, a, b, Ya, Yb, b),
  layout = {
    width = 600, height = 600, square = false,
    title = 'Shooting method for y\\" = -2y + 5sqrt(x) + 2x - 5, y(0) = 1, y(5) = 2 on [0, 5]<br>&rArr; Solved as w\' = -2y + 5sqrt(x) + 2x - 5, w(0) = w<sub>0</sub> and y\' = w, y(0) = 1'
  },
  enhancements = {
    {x = b, y = Yb, point = true, color = 'red', size = 8},
    {x = 3.7, y = -14, text = 'Note: The red point is the target.', size = 12}
  }
}
manipulate(fstr, opts)
