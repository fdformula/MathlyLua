mathly = require('mathly')

clear()
axissquare()
plot(slopefield('@(x, y) x + y', {-3, 3, 0.2}),
     {layout={width=700, height=700}}) -- sfield1.png

x = linspace(-3, 2.7, 100)
y1 = x^2 - 2*x + 2 - exp(-x)
y2 = x^2 - 2*x + 2 - 2*exp(-x -1)
y3 = x^2 - 2*x + 2 - 8*exp(-x -2)
xa = linspace(-2.77, 2.7, 90)
ya = xa^2 - 2*xa + 2 - 1.2607*exp(-xa)
axissquare()
plot(slopefield('@(x, y) x^2 - y', {-3, 2.8, 0.5}, {-5, 4.5, 0.5}, 2), -- sfield2.png
     x, y1, '-r', point(0, 1, {symbol='x', size=7, color='red'}),
     x, y2, '-b', point(-1, 3, {symbol='circle', size=7, color='blue'}),
     x, y3, '-g', point(-2, 2, {symbol='square', size=7, color='green'}),
     xa, ya, '-n', point(-1.5, 1.6, {symbol='circle', size=7, color='purple'}),
     {layout={width=400, height=600,
              title="y' = x<sup>2</sup> - y",
              margin={l=50, r=30, t=30, b=50, pad=10}}})
