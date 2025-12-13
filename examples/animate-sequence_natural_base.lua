--
-- 'animate' value of Taylor series of e^x = ∑x^n/n!, n = 0, 1, 2, ..., at x = 1
--
-- dwang@liberty.edu, 12/1/2025
--
jcode = [[
function displaytext() {
  var x = [], y = [];
  const v = (1 + 1/I)**I;
  for(let i = 0; i < I; i++) {
    x.push(i);
    y.push((1 + 1/i)**i);
  }
  x.push(I); y.push(v);
  mthlyTraces.push({x: x, y: y, mode: "markers", marker: {size: 4, color: 'green'}});
  return '(1 + 1/' + I + ')<sup>' + I + '</sup> = ' + v + ' (error: ' + Math.abs(Math.E - v) + ')';
}
]]

maxI = 200 -- max n in (1 + 1/n) ^ n

fstr = nil
opts = {
  I = {0, maxI, 1, label = 'n as in { (1 + 1/n)^n }'}, x = {-1, maxI}, y = {-0.1, 3}, controls = 'I',
  javascript = jcode,
  layout = {
    width = 800, height = 400, square = false,
    title = 'Sequence: Approximating Value of the Natural Base, <em>e</em>'
  },
  enhancements = {
    {x = {0, maxI}, y = {e, e}, line = true, width = 1, color = 'red', style = "dash: 'dot'"},
    {x = 30, y = e + 0.18, text = '<i>y</i> = 2.718281828459045235360...', color = 'red'}
  }
}
manipulate(fstr, opts)

