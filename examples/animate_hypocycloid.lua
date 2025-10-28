-- Animating hypocycloid, a plane curve traced out by a fixed point P on a circle C of radius b
-- as C rolls without slipping on the inside of a circle with center O and radius a, where b < a.
--
-- See: <a href="https://github.com/fdformula/CalculusLabs/blob/main/text/ParametricCurves.pdf">ParametricCurves.pdf</a></p>

mathly = require('mathly')

fstr = {'@(t) (a - b) * cos(t) + b * cos((a - b) / b * t)', '@(t) (a - b) * sin(t) - b * sin((a - b) / b * t)'}
opts = {
  t = {0, 20 * pi, 0.01}, a  = {0.2, 9, 0.1, default = 7.8}, b = {0.2, 9, 0.1, default = 1.6}, x = {-10, 10},
  resolution = 1500,
  layout = { width = 500, height = 500, title = '<h3>Hypocycloid</h3>' },
  enhancements = {
    {x = 'X', y = 'Y', color = 'red', size = 10, point = true},
    {x = '@(t) a * cos(t)', y = '@(t) a * sin(t)', t = {0, 2 * pi}, color = 'orange'},
    {x = '@(t) (a - b) * cos(T) + b * cos(t)', y = '@(t) (a - b) * sin(T) + b * sin(t)', t = {0, 2 * pi}, color = 'green'},
    {x = {'X', '(a - b) * cos(T)'}, y = {'Y', '(a - b) * sin(T)'}, line = true, color = 'green'}
  }
}
animate(fstr, opts)
