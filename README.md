# Mathly Turns Lua into a Tiny, Portable, Free but Powerful MATLAB and More

Mathly for [Lua](https://www.lua.org) is a Lua module which turns Lua into a tiny, portable, free but powerful MATLAB and more. It provides a group of commonly
used MATLAB functions and features, including `linspace`, `zeros`, `rand`, `save`, `plot`, `plot3d`, and convenient matrix operations
as well. If there are things many love the most about MATLAB, these tools are. They make coding and testing a thought much easier and faster
than working in most other programming languages. Besides, `animate` and `manipulate` allow easy and cool animation of the graph of a
single-variable function or a parametric 2D curve.

Mathly uses Plotly JavaScript graphing tools (see https://plotly.com/javascript/) to plot graphs. Therefore, graphs are
shown in an internet browser.

The entire mathly tool together with Lua interpreter is less than 5 MB, while providing enough features for instructors and college students
to implement numerical algorithms. <b>Because it is super lightweight and fast as well, it can run fast even on old and slow devices</b> like 
Microsoft Surface Pro 4 (Intel Core i5-6300U with 8 GB RAM). In contrast to it, MATLAB needs a few GB of storage space. In addition, 
it takes about 22 seconds to start MATLAB R2024b on a new high-end Intel Core i9-14900HX laptop with 56 GB RAM. Thus, it can hardly 
be installed on slow or pretty old computers and run smoothly.

Mathly is especially a good choice for instructors of linear algebra and numerical computing for teaching. It takes no time to
start Lua with mathly loaded. While developing code and doing computation in a lecture, they can simply focus on delivery
of course contents and never need to worry if their computers work too slowly. Moreover, Lua is so
simple and so natural a language that students without programming skills can understand most of Lua code.

## Which version of Lua is needed?

Mathly is developed in Lua 5.4.6. It might work with previous versions.

You may download Lua source code in https://lua.org/ and compile it yourself or simply download prebuilt binary commands
for Microsoft Windows in, say, https://joedf.github.io/LuaBuilds/ and https://www.nuget.org/packages/lua/. Another way to get prebuilt Lua is to download
ZeroBrane Studio (https://studio.zerobrane.com/), a lightweight Lua IDE for various platforms. It comes with multiple versions of Lua.

&rArr; Microsoft Windows users may download on this very page the file, `cudatext-for-mathly-win-*.7z`. It includes a text editor, CudaText, with Lua 5.4.8 and
mathly integrated. Run [7zip](https://7-zip.org/) to extract it to C:\ (the root directory of the C drive). <em>Do not change the name of the folder,
C:\cygwin</em>.

[CudaText](https://cudatext.github.io/) is a very good "IDE" for Lua and running mathly as well.
Quite a few CudaText plugins are included. Some are customized and even have new features added. While in CudaText, press
```
  F1               to open help document on current Lua/mathly function

  F2               to start Lua interpreter with mathly loaded
  Ctrl-,           to run the command on current line or selected code in the editor
  Ctrl-.           to run all code in the editor (HTML file? open it in a browser)

  Ctrl-Alt-Space   to trigger auto (Lua/mathly) lexical completion
  Shift-Alt-Space  to trigger auto text completion (Ctrl-P D, load an English dictionary as part of the text)

  Ctrl-P L         to turn on/off Lua lexer switch (when editing Lua script, say, in a HTML file)
  Ctrl-P P         to insert a plot template
```
`F2`, `Ctrl-,`, and `Ctrl-.` work with Bash, Julia, Octave, Python, R, Ruby, and some other languages with interactive REPL terminal.
CudaText detects and selects the very language according to the extension of the present filename (defaults to Lua). See: The first few
lines of the file, `C:\cygwin\cudatext\py\cuda_ex_terminal\__init__.py`.

Other hotkeys? Refer to `C:\cygwin\cudatext\cudatext-hotkeys-for-plugins.txt`.

Linux users? For most Linux distributions, download the file, cudatext-for-mathly-linux.tar.gz. For other distributions like Fedora, download the file, cudatext-for-mathly-linux-RARE.tar.gz. Expand the downloaded file and refer to the included file, note.txt, for other steps.

MacOS users? Download the file, cudatext-for-mathly-macosx.tar.gz. Expand the downloaded file and refer to the included file, note.txt, for other steps.

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

`..` (or `horzcat`), `all`, `any`, `apply`, `cc`, `clc`, `clear`, `copy`, `cross`, `demathly`, `det`, `diag`, `disp`, `display`, `div`, `dot`, `eval`, `expand`,
`eye`, `findroot`, `flatten`,  `fliplr`, `flipud`, `format`, `fstr2f`, `fzero`, `gcd`, `hasindex`, `input`, `inv`, `isinteger`, `iseven`, `isodd`, `ismatrix`, `ismember`,
`isvector`, `lagrangepoly`, `length`, `linsolve`, `linspace`, `lu`, `map`, `match`, `mathly`, `max`, `mean`, `merge`, `min`, `mod`, `namedargs`, `newtonpoly`, `norm`,
`ones`, `polynomial`, `polyval`, `powermod`, `printf`, `prod`, `qq`, `qr`, `rand`, `randi`, `randn`, `range`, `remake`, `repmat`, `reshape`, `reverse`, `round`, `rr`,
`rref`, `save`, `seq`, `size`, `sort`, `sprintf`, `std`, `strcat`, `submatrix`, `subtable`, `sum`, `tables`, `tblcat`, `tic`, `toc`, `transpose`, `tt`, `unique`, `var`,
`vectorangle`, `vertcat`, `who`, `zeros`; `bin2dec`, `oct2hex`, ...

`cat`, `cd`, `dir`, `isdir`, `isfile`, `iswindows`, `ls`, `mv`, `pwd`, `rm`

`animate`, `manipulate`, `plot`; `plot3d`, `plotparametriccurve3d`, `plotparametricsurface3d`, `plotsphericalsurface3d`

`arc`, `circle`, `contourplot`, `dotplot`, `line`, `parametriccurve2d`, `point`, `polarcurve2d`, `polygon`, `scatter`, `text`, `wedge`; `boxplot`, `freqpolygon`, `hist`, `hist1`,
`histfreqpolygon`, `pareto`, `pie`; `directionfield` (or `slopefield`), `vectorfield2d` &lArr; All are graphics objects passed to `plot`.

See mathly.html.

## Mathly objects and Lua tables

1. A mathly table is a simple Lua table registered as a mathly object. E.g., `x = tt{1, 2, 3}` is such a table. It has the same structure as an ordinary Lua table `y = {1, 2, 3}`. The difference is that we can apply "vectorization" operations and matrix operations on `x` instead of `y`. For instance, `2 * x - 1` gives a new mathly table, {1, 3, 5}. Here, `x[i]` gives the i-th element in the table.

2. A mathly row vector is actually a `1xn` matrix. E.g., `x = rr{1, 2, 3}` is a mathly row vector. It is stored as {{1, 2, 3}}. To access 2, we must use `x[1][2]`. Similarly, a column vector `y = cc{1, 2, 3}` is a `3x1` matrix stored in the format {{1}, {2}, {3}}. We use `y[2][1]` to access 2. Indeed, `x[1][2]` or `y[2][1]` is quite strange and inconvenient, which is why the results of most operations on these row/column vectors and matrices and many mathly functions are mathly tables.

3. Mathly tables and matrices may simply be called mathly objects. Mathly objects and Lua tables can appear in same math expressions. Mathly automatically converts Lua tables and mathly tables into mathly matrices of proper dimensions to complete the evaluation of the expressions. We may use mathly functions such as `mathly`, `cc`, `rr`, `tt`, and `^T` to replace the automatic conversion by mathly.

4. In a vector/matrix operation involving Lua tables which are not mathly objects, there must be at least one mathly object to activate the operation. For example, `tt{1, 2} + {3, 4}`, `{1, 2} + tt{3, 4}`, `({1, 2} * tt{3, 4} + {5, 6})*7 - {8, 9}`, and `tt{1, 2} * {3, 4} + ({5, 6} - tt{8, 9}) * 7`.

```Lua
mathly = require('mathly')
a = mathly{{1, 2, 3}, {2, 3, 4}}
b = mathly{{1}, {2}, {3}} -- or simply b = cc{1, 2, 3}
A = mathly(10, 10)        -- or rand(10, 10)
B = mathly(1, 10)         -- or rand(1, 10), a mathly table

inv(A) * B                -- B is interpreted as a 10x1 matrix
inv(A) * B^T              -- B^T can be cc(B). We control the conversion
a * {5, 6, 7}             -- Lua table {5, 6, 7} can be cc{5, 6, 7}
{5, 6} * a                -- Lua table {5, 6} can be rr{5, 6}

x = tt{2, 3, 4} + {5, 6, 7}
x ^ 3 - 5 * x ^ 2 + 4 *x - 1

A = randi({50, 100}, 3)
B = randi({0, 10}, 3)
C = 3 * A - 4 * B + 5
D = A .. B .. C           -- concatenate matrices A, B, and C horizontally
disp(D)
E = A .. cc{1, 2, 3}
disp(E)

-- matrix/table "division" is elementwise, provided for convenience only
x = {1, 2, 3, 4, 5}
2 * tt(x) + x - 1
x / (2 * cos(x) + 3)

A = mathly{{1, 2}, {3, 4}}
1 / (2 * A - 1)
{{2, 3}, {4, 5}} / A

-- elementary row operations
A = randi({-100, 100}, 5, 7)
A[3] = A[3] * 2         -- rowi := rowi * scaler; rr or cc
A[2] = A[2] - A[1] * 2  -- rowj := rowj - rowi * scaler; rr or cc
A[1], A[3] = A[3], A[1] -- interchange 2 rows
```
### More examples
```Lua
mathly = require('mathly')

x = linspace(0, pi, 100)
y1 = sin(x)
y2 = cos(x)
y3 = x^2 * sin(x)

axisnotsquare()
plot(x, y1)
plot(x, y1, '-r', x, y2, '-g', x, y3, '--o')
plot(sin, '-r', {layout={xaxis={title="x-axis"}, yaxis={title="y-axis"}, title='y = sin(x)'}})
plot('@(x) x', '--r', sin, '@(x) x^3', '-g', {range = {0, 1.5}})

plot(rand(125, 4), {layout={width=900, height=400, grid={rows=2, columns=2}, title='Demo'}, names={'f1', 'f2', 'f3', 'g'}})

axissquare()
plot(polarcurve2d('@(t) t*cos(sqrt(t))', {0, 35*pi}))
plot(parametriccurve2d({'@(t) cos(3*t)/(1 + sin(3*t)^2)', '@(t) sin(5*t)*cos(5*t)/(1 + sin(5*t)^2)'}, {0, 2*pi}, '-g', 150, true))

plot3d('@(x, y) x^2 - y^2')
do -- https://plotly.com/python/3d-surface-plots/
  local a, b, d = 1.32, 1, 0.8
  local c = a^2 - b^2
  local u, v = linspace(0, 2*pi, 100), linspace(0, 2*pi, 100)
  local function x(u, v) return (d * (c - a * cos(u) * cos(v)) + b^2 * cos(u)) / (a - c * cos(u) * cos(v)) end
  local function y(u, v) return b * sin(u) * (a - d*cos(v)) / (a - c * cos(u) * cos(v)) end
  local function z(u, v) return b * sin(v) * (c*cos(u) - d) / (a - c * cos(u) * cos(v)) end
  plotparametricsurface3d({x, y, z}, {0, 2*pi}, {0, 2*pi})
end

x = linspace(-3, 2.7, 100)
y1 = x^2 - 2*x + 2 - exp(-x)
y2 = x^2 - 2*x + 2 - 2*exp(-x -1)
y3 = x^2 - 2*x + 2 - 8*exp(-x -2)
axissquare()
plot(slopefield('@(x, y) x^2 - y', {-3, 2.8, 0.5}, {-5, 4.5, 0.5}, 2),
     x, y1, '-r', point(0, 1, {symbol='x', size=7, color='red'}),
     x, y2, '-b', point(-1, 3, {symbol='circle', size=7, color='blue'}),
     x, y3, '-g', point(-2, 2, {symbol='square', size=7, color='green'}),
     {layout={autosize=false, width=380, height=600, title="y' = x<sup>2</sup> - y",
              margin={l=40, r=20, t=45, b=40, pad=10}}})

manipulate('@(x) a * (x - h)^2 + k',
           {a = {-3, 3, 0.02, default = 3}, h = {-10, 10, 0.5, default = 0}, k = {-90, 90, default = 0},
            x = {-10, 10}, y = {-100, 100},
            layout = { width = 600, height = 400, square = false }})

-- animating trochoids, including cycloids
fstr = {'@(t) r * t - d*sin(t)', '@(t) r - d*cos(t)'}
opts = {t = {0, 8 * pi, 0.01}, r = {0.1, 5, 0.1, default = 1.5}, d = {0.1, 5, 0.1, default = 1.5},
        x = {-2, 40}, y = {-5, 10.5},
        layout = {width = 800, height = 400},
        enhancements = {{x = 'X', y = 'Y', color = 'red', size = 10, point = true},
                        {x = '@(t) r * T + r * cos(t)', y = '@(t) r + r * sin(t)', t = {0, 2 * pi}, color = 'orange'},
                        {x = {'X', 'r * T'}, y = {'Y', 'r'}, line = true, color = 'orange'}
                       }}
animate(fstr, opts)
```

### Note
1. Part of modules dkjson.lua, http://dkolf.de/dkjson-lua, and plotly.lua, https://github.com/kenloen/plotly.lua,
is merged into this project to reduce dependencies and make it easier for users to download and use mathly. Though
some changes have been made, full credit belongs to the original authors for whom the author of mathly
is very grateful.

1. This project was started first right in the downloaded code of the Lua module, matrix.lua, found
in https://github.com/davidm/lua-matrix/blob/master/lua/matrix.lua, to see if Lua is good for
numerical computing. However, it failed to solve numerically a boundary value problem. The solution
was obviously wrong because the boundary condition at one endpoint is not satisfied, but I could not find
anything wrong in both the algorithm and the code. I had to wonder if there were bugs in the module. In many
cases, it is easier to start a small project from scratch than debugging and using others' code. In
addition, matrix.lua addresses a column vector like a[i][1] and a row vector a[1][i], rather than a[i]
in both cases, which is quite ugly and unnatural. Furthermore, no basic graphics capabilities are provided in
matrix.lua. Therefore, this mathly module was developed. But anyway, the work in matrix.lua is highly appreciated.

&nbsp; &nbsp; &nbsp; &nbsp;December 25, 2024
