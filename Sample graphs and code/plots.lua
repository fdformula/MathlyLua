mathly = require('mathly')
clear()

 -- plot1.png
axisnotsquare()
x = linspace(-2.337, 0.779, 100)
X = linspace(-5, 5, 200)
plot(x, cos(x), x, sin(x), '-rff', X, cos(X), X, sin(X))


-- plot2.png
axissquare()
do -- https://en.wikipedia.org/wiki/Butterfly_curve_(transcendental)
  local function f(t) return (exp(cos(t)) - 2*cos(4*t) - sin(t/12)^5) end
  local function x(t) return sin(t) * f(t) end
  local function y(t) return cos(t) * f(t) end
  plot(parametriccurve2d({x, y}, {0, 12*pi}), {layout={title = "Butterfly Curve"}})
end


-- plot3.png
axissquare()
plot(
  parametriccurve2d({'@(t) 3*cos(t)', '@(t) 3*sin(t)'}, {0, 2*pi}, {orientationq = true}), -- counter clockwise
  parametriccurve2d({'@(t) 2*sin(t)', '@(t) cos(t)'}, {0, 2*pi}, {orientationq = true}),   -- clockwise
  parametriccurve2d({'@(t) 2.5*sin(t)', '@(t) 2.5*cos(t)'}, {0, 2*pi}, {color = 'green'}),
  sin, '-r'
)


-- plot4.png
plot(parametriccurve2d(
      {'@(t) cos(3*t)/(1 + sin(3*t)^2)',
       '@(t) sin(5*t)*cos(5*t)/(1 + sin(5*t)^2)'},
       {0, 2*pi}, '-g', 150),
     {layout = {margin = {l = 40, r = 40, t = 40, b = 40, pad = 15}, autosize = false}}
)


-- plot5.png
plotparametriccurve3d({'@(t) t*math.cos(t)', '@(t) t*math.sin(t)', '@(t) t'}, {0, 8*pi})


-- plot6.png
plotparametricsurface3d({
  '@(u, v) u*cos(v)’,
  '@(u, v) u*sin(v)’,
  '@(u, v) v’
  }, {0, 2*pi}, {0, 20}
)


-- plot7.png
-- https://plotly.com/python/3d-surface-plots/
a, b, d = 1.32, 1, 0.8
c = a^2 - b^2
plotparametricsurface3d({
  '@(u, v) (d * (c - a * cos(u) * cos(v)) + b^2 * cos(u)) / (a - c * cos(u) * cos(v))',
  '@(u, v) b * sin(u) * (a - d*cos(v)) / (a - c * cos(u) * cos(v))',
  '@(u, v) b * sin(v) * (c*cos(u) - d) / (a - c * cos(u) * cos(v))'}, {0, 2*pi}, {0, 2*pi})


-- plot8.png
function linear_regression(x, y)
  local n, Sx, Sy, Sxy, Sxx = length(x), sum(x), sum(y), sum(x * y), sum(x * x)
  return (n * Sxy - Sx * Sy) / (n * Sxx - Sx ^ 2),  -- a1
         (Sxx * Sy - Sxy * Sx) / (n * Sxx - Sx ^ 2) -- a0
end

xExp = mathly(range(2, 30, 2))
yExp = mathly({9.7, 8.1, 6.6, 5.1, 4.4, 3.7, 2.8, 2.4, 2.0, 1.6, 1.4, 1.1, 0.85, 0.69, 0.6})
a1, a0 = linear_regression(xExp, log(yExp))
b, m = exp(a0), a1

x = mathly(linspace(0, 30, 100))
y = b * exp(m * x)

axissquare()
plot(x, y, xExp, yExp, "or")
