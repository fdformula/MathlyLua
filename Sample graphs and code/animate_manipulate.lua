mathly = require('mathly')

-- manipulate1.jpg
manipulate('@(x) a * (x - h)^2 + k',
           {a = {-3, 3, 0.02, default = 3}, h = {-10, 10, 0.5, default = 0}, k = {-90, 90, default = 0},
            x = {-10, 10}, y = {-100, 100},
            layout = { width = 600, height = 400, square = false }})

-- manipulate2.jpg
fstr = {'@(t) a*sin(m * t)', '@(t) b*sin(n * t)'}
opts = {t = {0, 2*pi, 0.01},
        a = {0.1, 5, 0.1, default = 1}, m = {1, 20, 1, default = 2},
        b = {0.1, 5, 0.1, default = 2}, n = {1, 20, 1, default = 1},
        x = {-5, 5}, resolution = 1500,
        layout = { width = 640, height = 540 }}
manipulate(fstr, opts)

-- animate1~3.jpg
fstr = {'@(t) r * t - d*sin(t)', '@(t) r - d*cos(t)'}
opts = {t = {0, 8 * pi, 0.01}, r = {0.1, 5, 0.1, default = 1.5}, d = {0.1, 5, 0.1, default = 1.5},
        x = {-2, 40}, y = {-5, 10.5},
        layout = {width = 800, height = 400},
        enhancements = {{x = 'X', y = 'Y', color = 'red', size = 10, point = true},
                        {x = '@(t) r * T + r * cos(t)', y = '@(t) r + r * sin(t)', t = {0, 2 * pi}, color = 'orange'},
                        {x = {'X', 'r * T'}, y = {'Y', 'r'}, line = true, color = 'orange'}
                       }}
animate(fstr, opts)

-- animate4.jpg
jscode = [[
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
]]
fstr = {'@(t) R * cos(t) + 0*b + 0*L', '@(t) R * sin(t)'} -- 0*b + 0*L, b and L are controls, too; X, Y, and T are about a point on this curve
opts = {t = {0, 2 * pi, 0.01},
        b = {0.1, 5, 0.1, default = 2.7}, R = {0.1, 5, 0.1, default = 2}, L = { 0.1, 5, 0.1, default = 5},
        x = {-3, 5}, y = {-4, 4}, layout = { width = 640, height = 480, title = '' },
        javascript = jscode,
        enhancements = {{x = fstr[1], y = fstr[2], t = {0, 2*pi}, color = 'blue'},                           -- order of graphics objects matters, the latter
                        {x = '@(t) b + (L / sqrt(R**2 + b**2 - 2 * b * R * cos(t)) - 1) * (b - R * cos(t))', -- ones are plotted over the former ones
                         y = '@(t) R * (1 - L / sqrt(R**2 + b**2 - 2 * b * R * cos(t))) * sin(t)',
                         t = {0, 2 * pi}, color = 'cyan'
                        },
                        {x = {'X', 'xx'}, y = {'Y', 'yy'}, line = true, color = 'orange'}, -- xx and yy are calculated in the JavaScript code
                        {x = 'X', y = 'Y', color = 'red', size = 10, point = true},
                        {x = 'b', y = 0, color = 'grey', size = 10, point = true},
                        {x = 'xx', y = 'yy', color = 'red', size = 10, point = true}
                       }}
animate(fstr, opts)
