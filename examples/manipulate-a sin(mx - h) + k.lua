--
-- manipulate a*sin(mx - h) + k
--
-- dwang@liberty.edu, 8/19/2026
--
mathly = require('mathly')

jscode = [[
function displaytitle() {
  return "<h3><em>y = a</em> sin<em>(mx - h) + k</em></h3>"
}
function displaytext() {
  var s = '<em>y = </em>'
  if (a == 0 || (m == 0 && h == 0)) {
    return s + k
  }

  if (a == -1) {
    s = s + '- '
  } else if (a != 1) {
    s = s + a + ' '
  }
  s = s + 'sin('
  if (m != 0) {
    if (m == -1) {
      s = s + '-'
    } else if (m != 1) {
      if (m < 0) {
        s = s + '-' + (-m)
      } else {
        s = s + m
      }
    }
    s = s + '<em>x</em>'
    if (h < 0) {
      s = s + ' + ' + (-h)
    } else if (h > 0) {
      s = s + ' - ' + h
    }
  } else {
    s = s + h
  }
  s = s + ')'

  if (k != 0) {
    if (k > 0) {
      s = s + ' + ' + k
    } else {
      s = s + ' - ' + (-k)
    }
  }
  return s
}
]]

fstr = '@(x) a*sin(m*x - h) + k'
opts = {
    javascript = jscode,
    xrange = {-2*pi, 2*pi},
    a = {-5, 5, default = 1},
    m = {-10, 10, default = 1},
    h = {-5, 5, default = 0},
    k = {-5, 5, default = 0},
  }
manipulate(fstr, opts)
