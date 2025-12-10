--
-- animate sin(x) using its Taylor series ∑x^k / k!, k = 0, 1, 2, ...
--
-- dwang@liberty.edu, 12/1/2025
--
jcode = [[
const maxI = %d;
function taylorCoeffs() { // coefficients of the first maxI terms of the Taylor series
  // mthlyGlobal = []; // unnecessary
  var factorial = 1;
  for(let i = 0; i < maxI; i++) {
    if (i > 0) { factorial *= i; }
    mthlyGlobal.push(1 / factorial);  // global variable mthlyGlobal is used to save the coefficients of Taylor series
  }
}

if (mthlyGlobal.length == 0) { taylorCoeffs(); }

function taylor(x) { // evaluate the first I terms of the Taylor series at x
  var sum = 0, X = 1;
  for(let i = 0; i < I; i++) {
    sum += mthlyGlobal[i] * X;
    X *= x;
  }
  return sum;
}

function displaytext() {
  const n = I - 1;
  var s = 'P<sub>' + n + '</sub>(x) = 1 + x/1! '
  if (I > 2) {
    s = s + '+ x<sup>2</sup>/2! ';
    if (I > 3) {
      if (I == 4) {
        s = s + '+ x<sup>3</sup>/3! ';
      } else if (I > 4) {
        s = s + '+ ... + x<sup>' + n + '</sup>/' + n + '!';
      }
    }
  }
  return s;
}
]]

maxI = 41

fstr = '@(x) exp(x)'
opts = {
  I = {2, maxI, 1, label = 'Number of first terms'}, x = {-15, 5}, y = {-5, 15}, width = 3, controls = 'I',
  javascript = string.format(jcode, maxI),
  layout = {
    width = 500, height = 500, square = false,
    title = 'Approximating <em>e<sup>x</sup></em>'
  },
  enhancements = {
    {x = '@(t) t', y = '@(t) taylor(t)', color = 'red'}
  }
}
manipulate(fstr, opts)
