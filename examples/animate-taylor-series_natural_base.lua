--
-- 'animate' value of Taylor series of e^x = ∑x^n/n!, n = 0, 1, 2, ..., at x = 1
--
-- dwang@liberty.edu, 12/1/2025
--
mathly = require('mathly')

jcode = [[
function displaytext() {
  var x = [], y = [];
  let sum = 0, factorial = 1;
  for(let i = 1; i <= I; i++) {
    sum += 1 / factorial;
    x.push(i);
    y.push(sum);
    factorial *= i;
  }
  mthlyTraces.push({x: x, y: y, mode: "markers"});
  return 'Sum of the first ' + I + ' term' + ((I == 1)? '' : 's') + ': ' + sum + ' (error: ' + Math.abs(Math.E - sum) + ')';
}
]]

maxI = 25 -- max number of first terms to be used in a Taylor series expansion

fstr = nil
opts = {
  I = {1, maxI, 1, label = 'Number of first terms'}, x = {-0.1, maxI}, y = {-0.1, 3}, controls = 'I',
  javascript = jcode,
  layout = {
    width = 600, height = 400, square = false,
    title = 'Taylor Series: Approximating Value of the Natural Base, <em>e</em>'
  },
  enhancements = {
    {x = {0, maxI}, y = {e, e}, line = true, width = 1, color = 'red', style = "dash: 'dot'"},
    {x = 20, y = e + 0.18, text = '<i>y</i> = 2.718281828459045235360...', color = 'red'}
  }
}
manipulate(fstr, opts)
-- round-off errors are noticeable when using 18 or more terms
