# Mathly Turns Lua into a Tiny but Powerful MATLAB

Mathly for [Lua](https://www.lua.org) is a Lua module which turns Lua into a tiny but powerful MATLAB. It provides a group of commonly
used MATLAB functions and features, for example,  `linspace`, `zeros`, `rand`, `save`, convenient matrix operations,
and even `plot` and `plot3d`. They make coding and testing a thought/algorithm much easier and faster than working in most other
programming languages. If there is anything many love the most about MATLAB, these tools are.

Mathly uses Plotly JavaScript graphing tools (see https://plotly.com/javascript/) to plot graphs. Therefore, graphs are
shown in an internet browser.

The entire mathly tool together with Lua is less than 5 MB, while providing enough features for instructors and
college students to introduce and/or implement many numerical algorithms. Because it is super lightweight and fast as well,
it can be employed to slow devices like old Microsoft Surface Pro 4. Imagine that the smallest size of GNU Octave
is about 340 MB, MATLAB needs a few GB storage space, and Julia with graphing modules is huge, too. You can hardly
install them on a quite old computer and run smoothly.

Mathly is especially good for instructors of linear algebra and numerical computing for teaching. It takes no time to
start Lua and load mathly. While developing code and doing computation in a lecture, they can simply focus on delivery
of course contents and never need to worry if their computers work too slowly or even collapse. Moreover, Lua is so
simple and so natural a language that even students without programming skills can understand most of its scripts.

## Which version of Lua is needed?

Mathly is developed in Lua 5.4.6. It works with the present newest version 5.4.7. It might work with previous versions.

You may download Lua source code in https://lua.org/ and compile it yourself or simply download prebuilt binary commands
for Microsoft Windows in, say, https://www.nuget.org/packages/lua/. Another way to get prebuilt Lua is to download
ZeroBrane Studio (https://studio.zerobrane.com/), a lightweight Lua IDE for various platforms. It comes with multiple versions of Lua.

Microsoft Windows users may download on this very page the file, `cudatext-for-mathly-win-*.7z`, including Lua 5.4.6.
Run [7zip](https://7-zip.org/) to extract it to C:/ . [CudaText](https://cudatext.github.io/) is a very good "IDE" for Lua and running mathly as well.
Quite a few CudaText plugins are included. Some are customized and even have new features added. While in CudaText, press
```
  F1               to open help document on current Lua/mathly function

  F2               to start Lua with mathly loaded
  Ctrl-,           to run Lua command on current line in the editor
  Ctrl-.           to run all Lua script in the editor (HTML file? open it in a browser)

  Ctrl-Alt-Space   to trigger auto lexical completion
  Shift-Alt-Space  to trigger auto text completion (Ctrl-p d, load an English dictionary as part of the text)
```
`F2`, `Ctrl-,`, and `Ctrl-.` work with Bash, Julia, Octave, Python, R, Ruby, and some other languages with interactive REPL terminal.
CudaText detects and selects the very language according to the extension of the present filename (defaults to Lua). See: The first few
lines of the file, `C:\cygwin\cudatext\py\cuda_ex_terminal\__init__.py`.

Other hotkeys? Refer to `C:\cygwin\cudatext\cudatext-hotkeys-for-plugins.txt`.

## Where to place the downloaded files?

The files may be placed in either

### 1. the folder of your Lua script files to run/test or

### 2. (Windows) the folder, e.g., c:/cygwin/bin/, which contains the command, `lua.exe`:
```
lua.exe
browser-setting.lua
mathly.lua
plotly-2.9.0.min.js
```
###  (Linux) /usr/local/share/lua/5.4/
You may need to edit the file `browser-setting.lua`. See comments in the file.

Note: The *.lua files can be compiled with `luac`. To use compiled modules, we set `package.path` first as follows:

```Lua
package.path = "./?.luac;;"
```

## Functions provided in mathly

`..` (or `horzcat`), `all`, `any`, `apply`, `cc`, `clc`, `clear`, `copy`, `cross`, `det`, `diag`, `disp`, `display`, `div`, `dot`, `eval`, `expand`, `eye`,
`flatten`,  `fliplr`, `flipud`, `format`, `hasindex`, `input`, `inv`, `isinteger`, `iseven`, `isodd`, `ismember`, `lagrangepoly`, `length`, `linsolve`,
`linspace`, `lu`, `map`, `max`, `mean`, `min`, `mod`, `norm`, `ones`, `polynomial`, `polyval`, `printf`, `prod`, `qr`, `rand`, `randi`, `randn`, `range`,
`remake`, `repmat`, `reshape`, `reverse`, `rr`, `rref`, `save`, `select`, `seq`, `size`, `sort`, `sprintf`, `std`, `strcat`, `submatrix`, `subtable`, `sum`,
`tblcat`, `tic`, `toc`, `transpose`, `tt`, `unique`, `var`, `vertcat`, `who`, `zeros`

`arc`, `circle`, `line`, `parametriccurve2d`, `plot`, `plot3d`, `plotparametriccurve3d`, `plotparametricsurface3d`, `plotsphericalsurface3d`, `point`,
`polarcurve2d`, `polygon`, `scatter`, `text`, `wedge`

`boxplot`, `freqpolygon`, `hist`, `hist1`, `histfreqpolygon`, `pareto`, `pie`

See mathly.html.

## Two important things you need to know

### 1. A mathly matrix is a table (of tables), but a table may not be a mathly matrix.

#### a. Mathly 'constructor', `diag`, `expand`, `flipfr`, `flipud`, `horzcat`, `lu`, `ones`, `zeros`, `rand`, `randi`, `randn`, `remake`, `reshape`, `submatrix`, `vertcat`, `cc`, `rr`, and matrix operations can generate mathly matrices.
```Lua
mathly = require('mathly')
a = mathly{{1, 2, 3}, {2, 3, 4}}   -- a, b, c, d, A, B, C, D, and E are all mathly matrices
b = {{1}, {2}, {3}}; b = mathly(b) -- or simply b = cc{1, 2, 3}
c = mathly(1, 10, 5)
d = mathly(1, 10, 0)      --  same as f = mathly(zeros(1, 10)) or rr(zeros(1, 10))
A = mathly(10, 10)
B = mathly(1, 10)
C = randi(100, 10, 1)     -- a column vector of random integer numbers (from 1 to 100)
D = rand(10, 2)           -- a 10x2 matrix of random numbers (from 0 to 1)
E = reshape(C, 3)         -- a 3x4 matrix; 4 is determined by mathly

-- inv(A) * B             -- not allowed as in math
inv(A) * B^T
inv(A) * seq(1, 10)       -- mathly knows how to handle a Lua table seq(1, 10)
seq(1, 10) * inv(A)       -- here in its context
rr(seq(1, 10)) * inv(A)   -- or you can have full control by using rr or cc

A = randi(100, 10, 5)
B = randi(100, 5, 3)
C = rand(3, 1)
A * B * C
C^T * B^T

A = randi({50, 100}, 3)
B = randi({0, 10}, 3)
C = 3 * A - 4 * B + 5
D = A .. B .. C           -- concatenate matrices A, B, and C horizontally, same as horzcat(A, B, C)
disp(D)
E = A .. cc{1, 2, 3}
disp(E)
```
#### b. `ones`, `zeros`, `rand`, `randi`, and `randn` generate each an ordinary table rather than a mathly matrix if used this way, say, `ones(1, 100)`.
This allows us to generate a table of specified length and address it conveniently like `x[i]` instead of `x[1][i]`.

#### c. Mathly matrix operations can only be applied on mathly matrices; if a matrix operation involves two objects, one must be a mathly matrix.

To allow matrix operations on ordinary tables, conversion is needed. For example,

```Lua
mathly = require('mathly')
x = linspace(0, pi, 10)   -- x, y, and z are not mathly matrices/vectors.
y = cos(x)
z = sin(x)
-- 3 * y                  -- not allowed/defined
-- y + z                  -- not allowed/defined
mathly(y) + z             -- y + mathly(z), or mathly(y) + mathly(z) -- at least one must be a mathly matrix
2*rr(y) - 3 * rr(z)       -- both y and z must be converted to mathly matrices
```

### 2. A mathly row/column vector is a matrix.

Its ith element must be addressed by either `x[i][1]` (a column vector) or `x[1][i]`
(a row vector), while the ith element of an ordinary/raw Lua table is addressed by `x[i]`, the way we human beings do math.

**Mathly tries its best to allow us to write math expressions as we do on paper.** If you want full control, you can use
`cc` or `rr` to convert an ordinary Lua table to a column or row vector as in the following example.
```Lua
a = randi({-10, 10}, 3, 1) * {1, 2, 3}  -- (3x1 matrix) * (1x3 matrix) --> 3x3 matrix
disp(a)
b = randi({-10,10}, 3, 1) * cc{1, 2, 3} -- (3x1 matrix) * (3x1 matrix) --> (3x1 matrix) .* (3x1 matrix) = 3x1 matrix in MATLAB
disp(b)
```
By the way, `tt` converts a mathly matrix to a table columnwisely or flattens any other table first and returns a specified slice of the resulted table.

## `plot` and specifications

### Some specifications/options
#### 1) of a line, i.e., the graph of a function:
```Lua
mode='lines+markers', 'lines', or 'markers'
width=5
style='-' [solid, ':' (dot), or '--' (dash)]
```
#### 2) of a marker:
```Lua
size=10
symbol='circle'
```
Some possible symbols are `circle`, `circle-open`, `circle-open-dot`, `cross`, `diamond`, `square`, `x`,
`triangle-left`, `triangle-right`, `triangle-up`, `triangle-down`, `hexagram`, `star`, `hourglass`, `bowtie`.

#### 3) of a plot:
```Lua
layout={width=500, height=400, grid={rows=2, columns=2}, title='Demo'}.
```
### Some examples
```Lua
require 'mathly'
x = linspace(0, pi, 100)
y1 = sin(x)
y2 = map(math.cos, x)
y3 = map(function(x) return x^2*math.sin(x) end, x)

specs1 = {layout={width=700, height=900, grid={rows=4, columns=1}, title='Example'}}
specs2 = {color='blue', name='f2', layout={width=500, height=500, grid={rows=4, columns=1}, title='Demo'}}
specs3 = {width=5, name='f3', style=':', color='cyan', symbol='circle-open', size78}

plot(math.sin, '--r') -- plot a function
shownotlegend()
plot(x, y1) -- plot a function defined by x and y1
plot(x, y1, '--xr', x, y2)
plot(x, y1, '--xr', x, y2, ':g', text(0.79, 0.71 - 0.08, 'A'), point(0.79, 0.71, {symbol='circle', size=10, color='blue'}))
plot(x, y1, {xlabel="x-axis", ylabel="y-axis", color='red'})
showlegend()
plot(x, y1, x, y2, specs1, math.sin, '--r')
plot(x, y1, specs1, x, y2, x, y3, 'o')
plot(x, y1, specs3, x, y2, specs2, math.sin, x, y3, specs1)

plot(rand(125, 4)) -- plots functions defined in each column of a matrix with the range of x from 0 to # of rows
plot(rand(125, 4),{layout={width=900, height=400, grid={rows=2, columns=2}, title='Demo'}, names={'f1', 'f2', 'f3', 'g'}})
plot(rand(125, 4), {layout={width=900, height=400, grid={rows=2, columns=2}, title='Example'}})
plot(rand(100,3), {layout={width=900, height=400, grid={rows=3, columns=2}, title='Example'}}, rand(100,2))
plot(rand(100, 2), linspace(1,100,1000), sin(linspace(1,100,1000)), '-og', rand(100, 3))

plot(polarcurve2d(function(t) return t*math.cos(math.sqrt(t)) end, {0, 35*pi}))

axissquare()
do
  local function x(t) t = 3 * t; return math.cos(t)/(1 + math.sin(t)^2) end
  local function y(t) t = 5 * t; return math.sin(t)*math.cos(t)/(1 + math.sin(t)^2) end
  plot(parametriccurve2d({x, y}, {0, 2*pi}))
end
```

### A more meaningful example - Quadratic splines using Lagrange interpolating polynomials

```Lua
require('mathly')

function fprimes_for_splines_using_lagrange(x, y)
  local n = length(x) -- or: n = #x
  if length(y) ~= n then
    error("vectors x and y must be of the same size.")
  end

  local A = zeros(n - 1, n - 1)
  local B = zeros(1, n - 1)
  for i = 1, n - 2 do
    A[i][i] = 1; A[i][i + 1] = 1
    B[i] = 2 * (y[i + 1]- y[i]) / (x[i + 1] - x[i])
  end
  A[n - 1][n - 1] = 1
  B[n - 1] = (y[n] - y[n - 1]) / (x[n] - x[n - 1])

  local fprimes = zeros(1, n - 1)
  fprimes[n - 1] = B[n - 1] -- solve Ax = B by back substitution
  for i = n - 2, 1, -1 do
    fprimes[i] = B[i] - fprimes[i + 1]
  end
  return fprimes
end

K = 1 -- 'global', to make it faster to choose a spline
function resetK() K = 1 end

function evaluate_spline_function(X, x, y, fprimes, resetK_q)
  if resetK_q then resetK() end
  local n = length(x)
  while K < n - 1 do -- K is 'global'
    if x[K] <= X and X <= x[K + 1] then break end
    K = K + 1
  end
  if K < n - 1 then
    local h = x[K + 1] - x[K]
    return y[K] + 0.5*((X - x[K+1])^2/(-h) + h)*fprimes[K] + 0.5*(X - x[K])^2/h*fprimes[K+1]
  else
    return y[n] + fprimes[K] * (X - x[n]) -- i == n - 1
  end
end

function test()
  local x = {-1, 0,  1, 2, 4,  7, 10, 11, 15, 16, 18, 19, 22, 25, 27}
  local y = { 5, 9, 10, 8, 7, 12, 14, 21,  9, 11, 15, 17, 20, 31, 35}

  local X = linspace(min(x), max(x), 500)
  local Y = zeros(1, length(X))

  local fprimes = fprimes_for_splines_using_lagrange(x, y)
  resetK()

  for i = 1, length(X) do
    Y[i] = evaluate_spline_function(X[i], x, y, fprimes, false)
  end

  plot(X, Y, "-r", x, y, "*k")
end

test()
```

### Note
1. Most functions provided in this mathly module, e.g., `copy`, `disp`, and `display`, can't be applied to tables like
`{1, 2, age=20, 10, year=2024}` with fields, i.e., *age* and *year* in the example. It is designed simply for numerical computing.

1. Part of modules dkjson.lua, http://dkolf.de/dkjson-lua, and plotly.lua, https://github.com/kenloen/plotly.lua,
is merged into this project to reduce dependencies and make it easier for users to download and use mathly. Though
some changes have been made, full credit belongs to the original authors for whom the author of mathly
is very grateful.

1. This project was started first right in the downloaded code of the Lua module, matrix.lua, found
in https://github.com/davidm/lua-matrix/blob/master/lua/matrix.lua, to see if Lua is good for
numerical computing. However, it failed to solve numerically a boundary value problem. The solution
was obviously wrong because the boundary condition at one endpoint is not satisfied, but I could not find
anything wrong in both the algorithm and the code. I had to wonder if there were bugs in the module. In many
cases, it is easier to start a small project from scratch than using and debugging others' code. In
addition, matrix.lua addresses a column vector like a[i][1] and a row vector a[1][i], rather than a[i]
in both cases, which is quite ugly and unnatural. Furthermore, basic plotting utility is not provided in
matrix.lua. Therefore, this mathly module was developed. But anyway, I appreciate the work in matrix.lua.
Actually, you may find some similarities in the code of matrix.lua and mathly.lua, e.g., m1, m2 are used
to name arguments of some functions.

&nbsp; &nbsp; &nbsp; &nbsp;December 25, 2024
