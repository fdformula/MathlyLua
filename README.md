# MathlyLua makes Lua mathly and like MATLAB.

Mathly for Lua is a Lua module which depends on a Lua module,
plotly.lua (see https://github.com/kenloen/plotly.lua). The latter is modified
to suit the needs of mathly.lua, and it depends on another Lua module, dkjson.lua
(see http://dkolf.de/dkjson-lua). A very sall part of code is borrowed from a Lua
module, matrix.lua (see https://github.com/davidm/lua-matrix/blob/master/lua/matrix.lua).

Mathly uses plotly JavaScript graphing tools to plot graphs of functions (see https://plotly.com/javascript/).
Therefore, graphs are shown in an internet browser.

The whole mathly tool is less than 5 MB, while it provides enough features for college instructors and
students to introduce and/or implement numerical algorithms in most cases. Because it is lightweight and fast,
it is can be employed to slow devices like Micrsoft Surface Pro 7. Imagine that the smallest size of GNU Octave
is about 300 MB, MATLAB, needs a few GB space, and Julia with graphing modules occupies is also huge.

It is especially good for linear algebra and numerical analysis instructors for teaching. It takes no time to
start Lua and load mathly. They can simply focus on course materials and never need to worry if their computers
work too slowly.

Mathly makes Lua mathly and like MATLAB. It provides implementation of
a group of commonly used MATLAB functions, for example, ones, zeros, rand,
matrix operations, and even plot. They make coding and testing a thought/algorithm
much easier then working in some other programming languages like C/C++ and Java.
If there is anything I like MATLAB, these tools are.

With provided functions, it is much easier and faster to do math,
especially linear algebra, and plot graphs of functions.

## Three important things are:

### 1. A mathly matrix/metatable is a LUA table, but a LUA table is not
     a mathly matrix/metatable unless it is set so.

#### a. examples

        mathly = require('mathly')
        a = mathly{{1, 2, 3}, {2, 3, 4}}   -- a, b, c, d are mathly matrices
        b = {{1}, {2}, {3}}; b = mathly(b)
        c = mathly(1, 10, 5)
        d = mathly(1, 10, 0) --  same as d = mathly(zeros(1, 10))
        A = mathly(10, 10)
        B = mathly(1, 10)

        -- Style of MATLAB mMatrix operations are enabled. E.g.,
        3*a - 10
        2*c + 5 * d - 3
        -- inv(A) * B         -- not allowed as in math
        inv(A) * B^T
        inv(A) * randi(1, 10) -- mathly knows how to handle a Lua table
        randi(1, 10) * inv(A) -- randi(1, 10) here in its context

        A = randi(10, 5)
        B = randi(5, 3)
        C = rand(3, 1)
        A - 2
        A * B
        A * B * C
        B * C

#### b. Functions, eye, ones, zeros, rand, randi, reshape, generate
        each a mathly matrix.

#### c. mathly matrix operations each return a mathly metatable(s),
        e.g., 3 * A - 4 * B, rref, inv, if the result is a matrix.

### 2. A mathly row/column vector is a matrix. It's ith element must be
     accessed/indexed by either x[i][1] (a column vector) or x[1][i]
     (a row vector).

### 3. ones, rand, randi, and zeros are commonly used. If vector/matrix
     operations are needed, use them to create a column vector, e.g.,
     zeros(1, 10).

     a. They create each an ordinary Lua table if called like
     zeros(10, 1).

     b. If a row vector/matrix with vector/maxtrix operations needed,
     always use, e.g., mathly(1, 10), or mathly(ones(1, 10)) to
     generate or convert a Lua list to a row vector/matrix. See 1a.

## plot and its spec

### Some specs
#### 1) mode='lines+markers', 'lines', or 'markers'

#### 2) of a line:
      width=5
      style='-' (solid), ':' (dot), or '--' (dash)

#### 3) of a marker:
      size=10
      symbol='circle'

      Some possible symbols are: circle, circle-open, circle-open-dot, cross, diamond, square, x,
      triangle-left, triangle-right, triangle-up, triangle-down, hexagram, star, hourglass, bowtie

#### 4) of a plot: layout={width=500, height=400}

### Some examples
require 'mathly';

x = linspace(0, pi, 100)
y1 = sin(x)
y2 = map(math.cos, x)
y3 = map(function(x) return x^2*math.sin(x) end, x)

spec1 = {layout={width=700, height=900, grid={rows=4, columns=1}, title='Example'}}
spec2 = {color='blue', name='f2', layout={width=500, height=500, grid={rows=4, columns=1}, title='Demo'}}
spec3 = {width=5, name='f3', style=':', color='cyan', symbol='circle-open', size78}

plot(x, y1)
plot(x, y1, x, y2, spec1)
plot(x, y1, '--xr', x, y2, {1.55}, {-0.6}, {symbol='circle-open', size=10, color='blue'})
plot(x, y1, '--xr', x, y2, ':g')
plot(x, y1, {xlabel="x-axis", ylabel="y-axis", color='red'})
plot(x, y1, spec1, x, y2, x, y3, 'o')
plot(x, y1, spec3, x, y2, spec1, x, y3, spec2, x, sin(x))
plot(rand(125, 4)) -- plots functions defined in each column of a matrix with the range of x from 0 to # of rows

spec = {layout={width=900, height=400, grid={rows=2, columns=2}, title='Demo'}, names={'f1', 'f2', 'f3', 'g'}}
plot(rand(125, 4), spec)

plot(rand(125, 4), {layout={width=900, height=400, grid={rows=2, columns=2}, title='Example'}})
plot(rand(100,3), {layout={width=900, height=400, grid={rows=3, columns=2}, title='Example'}}, rand(100,2))
plot(rand(100, 2), linspace(1,100,1000), sin(linspace(1,100,1000)), '-og', rand(100, 3))
