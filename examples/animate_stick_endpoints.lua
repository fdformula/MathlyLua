-- Animating a stick of length L that can smoothly slide through a point (b, 0),
-- given that one end of the stick moves along a circle with its center at the
-- origin and a radius of R.
--
-- See: <a href="https://github.com/fdformula/CalculusLabs/blob/main/text/ParametricCurves.pdf">ParametricCurves.pdf</a></p>

mathly = require('mathly')

jscode = [[
  // The line passes thru (b,0) and (X,Y) is y = (Y/(X-b))(x-b). So, x = b + ((X-b)/Y)y. Solve
  // (x-X)^2 + (y-Y)^2 = L^2 for y and then obtain x.
  var Xb = X - b;
  var z = Xb / Y;
  var xx, yy = Y + Xb*z;
  var s = Math.sqrt(L*L - b*b - (Xb - b)*X + 2*Y*Xb*z + (L*L - Y*Y)*z*z);
  if (Y > 0) {
    yy = yy - s;
  } else {
    yy = yy + s;
  }
  yy = yy / (1 + z*z);
  xx = b + z * yy;
  // function displaytext() { return 'Hello! L = ' + L; }
]]

fstr = {'@(t) R * cos(t) + 0*b + 0*L', '@(t) R * sin(t)'} -- 0*b + 0*L, b and L are controls, too; X, Y, and T are about a point on this curve
opts = {t = {0, 2 * pi, 0.01},
        b = {0.1, 5, 0.1, default = 2.7}, R = {0.1, 5, 0.1, default = 2}, L = { 0.1, 5, 0.1, default = 5},
        x = {-3, 5}, y = {-5, 5},
        layout = { width = 640, height = 480, title = '',
                   xaxis = { showgrid = false, zeroline = false, showticklabels = false },
                   yaxis = { showgrid = false, zeroline = false, showticklabels = false }},
        javascript = jscode,
        enhancements = {{x = fstr[1], y = fstr[2], t = {0, 2*pi}, color = 'blue'},                           -- order of graphics objects matters, the latter
                        {x = '@(t) b + (L / sqrt(R**2 + b**2 - 2 * b * R * cos(t)) - 1) * (b - R * cos(t))', -- ones are plotted over the former ones
                         y = '@(t) R * (1 - L / sqrt(R**2 + b**2 - 2 * b * R * cos(t))) * sin(t)',
                         t = {0, 2 * pi}, color = 'cyan'},
                        {x = {'X', 'xx'}, y = {'Y', 'yy'}, line = true, color = 'orange'}, -- xx and yy are calculated in the JavaScript code
                        {x = 'X', y = 'Y', color = 'blue', size = 10, point = true},
                        {x = 'b', y = 0, color = 'grey', size = 10, point = true},
                        {x = 'xx', y = 'yy', color = 'red', size = 10, point = true}
                       }}
animate(fstr, opts) -- 'animate' can be replaced with 'manipulate'
