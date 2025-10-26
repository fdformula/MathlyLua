-- Animating matrix operators on the graph of y = f(x)

mathly = require('mathly')

jcode = [[
  function f(x) { return x - x*Math.sin(x) + 2; }
  // apply standard matrix A on B, "matrix multiplication", where
  // A = [ [a, b], [c, d] ], B = { x: [x1, x2, ..., xn], y: [y1, y2, ..., yn]}
  function transform(A, B) {
    const siz = B.x.length;
    var x = Array(siz), y = Array(siz);
    for (let j = 0; j < siz; j++) {
      x[j] = A[0][0]*B.x[j] + A[0][1]*B.y[j];
      y[j] = A[1][0]*B.x[j] + A[1][1]*B.y[j];
    }
    return { 'x' : x, 'y': y};
  }

  function rotate() {
    return [ [Math.cos(a), -Math.sin(a)], [Math.sin(a), Math.cos(a)] ];
  }
  function shear() {
    return [ [1, b], [0, 1] ];
  }
  function reflect() { // about y = x
    return (r == 0)? [ [1, 0], [0, 1] ] : [ [0, 1], [1, 0] ];
  }
  function dilate() {
    return [ [m, 0], [0, n] ];
  }
  function rotshr(k) {
    if (q == 0) {
      return (k == 1)? rotate(a) : shear(b);
    } else {
      return (k == 1)? shear(b) : rotate(a);
    }
  }
  const curve  = {'x': x, 'y': x.map(x => f(x))};
  var newcurve = transform(dilate(),
                           transform(reflect(),
                                     transform(rotshr(2), transform(rotshr(1), curve))));
  newcurve.x = newcurve.x.map(x => x + c)
  newcurve.y = newcurve.y.map(y => y + d)
  newcurve.mode  = 'lines'; newcurve.line  = {'simplify': false};
  mthlyTraces.push(newcurve);
  function displaytext() { return 'A shear is applied ' + (q == 0? 'after' : 'before') + ' a rotation.'; }
]]

fstr = '@(x) x - x * sin(x) + 2'
opts = {
  a = {-3.14, 3.14, 0.01, default = 0, label = 'Rotation'},
  b = {-3, 3, 0.01, default = 0, label = 'Shear'},
  q = {0, 1, 1, default = 0, label = 'Shear before Rotation'},
  c = {-3, 3, 0.01, default = 0, label = 'X Shift'},
  d = {-3, 3, 0.01, default = 0, label = 'Y Shift'},
  m = {-3, 3, 0.1, default = 1, label = 'Dilate in x'},
  n = {-3, 3, 0.1, default = 1, label = 'Dilate in y'},
  r = {0, 1, 1, default = 0, label = 'Reflect about y = x'},
  x = {-6, 6}, y = {-6, 6}, controls = 'abqcdmnr',
  javascript = jcode,
  layout = { width = 640, height = 640, square = true, title = '' } -- no title
}
manipulate(fstr, opts)
