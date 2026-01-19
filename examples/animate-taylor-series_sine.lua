--
-- animate sin(x) using its Taylor series ∑(-1)^k x^(2k+1) / (2k+1)!, k = 0, 1, 2, ...
--
-- dwang@liberty.edu, 12/1/2025
--
mathly = require('mathly')

jcode = [[
const maxI = %d;
function taylorCoeffs() { // coefficients of the first maxI terms of the Taylor series
  // mthlyGlobal = []; // unnecessary
  var sign = 1;
  let factorial = 1;
  for(let i = 0; i < maxI; i++) {
    const I = 2 * i;
    if (I > 0) { factorial *= I * (I + 1); }
    mthlyGlobal.push(sign / factorial);  // global variable mthlyGlobal is used to save the coefficients of Taylor series
    sign *= -1;
  }
}

if (mthlyGlobal.length == 0) { taylorCoeffs(); }

function taylor(x) { // evaluate the first I terms of the Taylor series at x
  var sum = 0, X = x, xx = x * x;
  for(let i = 0; i < I; i++) {
    sum += mthlyGlobal[i] * X;
    X *= xx;
  }
  return sum;
}

function displaytext() {
  const n = 2*I - 1;
  var s = 'P<sub>' + n + '</sub>(x) = x ';
  if (I > 1) {
    s = s + '- x<sup>3</sup>/3! ';
    if (I > 2) {
      if (I == 3) {
        s = s + '+ x<sup>5</sup>/5! ';
      } else {
        if (I == 4) {
          s = s + '+ ... - x<sup>7</sup>/7!';
        } else {
          s = s + '+ ... ' + ((I %% 2 == 0)? '-' : '+') + ' x<sup>' + n + '</sup>/' + n + '!';
        }
      }
    }
  }
  return s;
}
]]

maxI = 50

fstr = '@(x) sin(x)'
opts = {
  I = {1, maxI, 1, label = 'Number of first terms'}, controls = 'I',
  xrange = {-11*pi, 11*pi}, yrange = {-3, 3},
  javascript = string.format(jcode, maxI),
  layout = {
    width = 600, height = 300, square = false,
    title = 'Approximating <em>sin</em>(<em>x</em>)'
  },
  enhancements = {
    {x = '@(t) t', y = '@(t) taylor(t)'}
  }
}
manipulate(fstr, opts)
