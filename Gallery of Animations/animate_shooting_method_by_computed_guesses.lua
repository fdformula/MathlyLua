--
-- animate solving y'' = y + x(x-y), y(0) = 5, y(4) = -2, x on [0, 4] by shooting method
--
-- for demonstration only
--
-- dwang@liberty.edu, 11/19/2014
--
a, b, Ya, Yb = 0.0, 4.0, 5.0, -2.0

jcode = [[
const a = %f, b = %f, Ya = %f, Yb = %f;
const n = 100;
const h = (b - a) / n, tol = 1e-14;

function fw(x, y, w) { return y + x * (x - y); } // dw/dx = y + x(x-y); w(a) = ?
function fy(x, y, w) { return w; }       // dy/dx = w;      y(a) = Ya

const x = []; // shared data x
{var v = a; for (let i = 1; i <= n + 1; i++) { x.push(v); v += h; }}

var w, y, E1, E2;
var W1 = -5, W2 = 14; // the first 2 guesses of w(a)

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
    if (Math.abs(E) < tol) { return [W, j + 1, 0]; }
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
    return 'Found the numerical solution after ' + v[1] + ' attempts with w<sub>0</sub> = ' + v[0] + '.'
  } else {
    return 'w<sub>0</sub> = ' + v[0] + ', y(b) = ' + v[1] + ' (Yb = ' + Yb + ')';
  }
}
]]

fstr = nil -- no simple analytical solution to be plotted
opts = {
  I = {1, 40, 1, label = 'Guess No.'}, x = {-0.1, 4.1}, y = {-20, 40}, controls = 'I',
  javascript = string.format(jcode, a, b, Ya, Yb, b),
  layout = {
    width = 600, height = 500, square = false,
    title = 'Shooting method for y\\" = y + x(x - y), y(0) = 5, y(4) = -2 on [0, 4]<br>&rArr; Solved as w\' = y + x(x - y), w(0) = w<sub>0</sub> and y\' = w, y(0) = 5'
  },
  enhancements = {
    {x = b, y = Yb, point = true, color = 'red', size = 8},
    {x = 1.7, y = -11, text = 'Note: The red point is the target, and a new guess is a', size = 12},
    {x = 1.95, y = -14, text = 'linear function of the errors at x = 4 corresponding', size = 12},
    {x = 1.24, y = -17, text = 'to the previous 2 guesses.', size = 12}
  }
}
manipulate(fstr, opts)
