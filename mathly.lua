--[[

LUA MODULE

  Mathly for Lua - It makes Lua more mathly and like MATLAB.

DESCRIPTION

  With provided functions, it is much easier and faster to do math,
  especially linear algebra, and plot graphs of functions.

API and Usage

  List of functions provided in this module:

    apply, c, clear, clc, concath, concatv, copy, cross, det, diag, disp, display,
    dot, expand, eye, flatten, fliplr, flipud, hasindex, inv, isinteger, ismember,
    join, length, linspace, map, max, min, norm, ones, plot, polyval, printf, prod,
    rand, randi, r, range, remake, repmat, reshape, rref, save, seq, size, linsolve,
    sprintf, submatrix, subtable, sum, t, tic, toc, unique, who, zeros

  See code and mathly.html.

DEPENDENCIES

  plotly: dkjson.lua, plotly.lua, plotly-2.9.0.min.js

HOME PAGE

  https://github.com/fdformula/MathlyLua

LICENSE

  Licensed under MIT license and/or the same terms as Lua itself.

  Developers:

    David Wang - original author

--]]

local mathly = {_TYPE='module', _NAME='mathly', _VERSION='12.25.2024.5'}

local mathly_meta = {}

function abs( x )    return map(math.abs, x) end
function random( x ) return map(math.random, x) end
function sqrt( x )   return map(math.sqrt, x) end
function exp( x )    return map(math.exp, x) end
function log( x )    return map(math.log, x) end
function ceil( x )   return map(math.ceil, x) end
function floor( x )  return map(math.floor, x) end
function cos( x )    return map(math.cos, x) end
function sin( x )    return map(math.sin, x) end
function tan( x )    return map(math.tan, x) end
function acos( x )   return map(math.acos, x) end
function asin( x )   return map(math.asin, x) end
function atan( x )   return map(math.atan, x) end
function deg( x )    return map(math.deg, x) end
function rad( x )    return map(math.rad, x) end

pi = math.pi
e = math.exp(1)
eps = 2.220446049250313e-16  -- machine epsilon, ~MATLAB
phi = 1.6180339887499        -- golden radio
T = 'T' -- reserved by mathly, transpose of a matrix, A^T

function  printf(...) io.write(string.format(table.unpack{...})) end
function sprintf(...) return string.format(table.unpack{...}) end

function r(x) return setmetatable({ flatten(x) }, mathly_meta) end -- convert x to a row vector
function c(x) return setmetatable(map(function(x) return {x} end, flatten(x)), mathly_meta) end -- convert x to a column vector

-- t(x, startpos, endpos, step)
-- convert x to a table (columnwisely if its a mathly matrix) or flatten it first
-- and return a slice of it
-- want row wise? see flatten(tbl)
--
-- t or subtable? t converts first, while subtable doesn't.
function t(x, startpos, endpos, step) -- make x an ordinary table
  local y = {}
  if getmetatable(x) == mathly_meta then -- column wise
    if #x == 1 then -- row vector
      y = x[1]
    else
      local k = 1
      for j = 1, #x[1] do
        for i = 1, #x do
          y[k] = x[i][j]
          k = k + 1
        end
      end
    end
  elseif type(x) == 'table' then
    y = flatten(x)
  else
    return { x }
  end

  if startpos == nil or startpos < 1 then startpos = 1 end
  if endpos == nil or endpos > #y then endpos = #y end
  if startpos > endpos then return {} end
  if step == nil or step < 1 then step = 1 end

  local z = {}
  local k = 1
  for i = startpos, endpos, step do
    z[k] = y[i]
    k = k + 1
  end
  return z
end

local function max_min_shared( f, x ) -- column wise if x is a matrix
  if type(x) == 'table' then
    if type(x[1]) == 'table' then -- a matrix
      if #x == 1 then return max_min_shared(f, x[1]) end -- mathly{1, 2} gives {{1,2}}
      local maxs = {}
      for j = 1, #x[1] do
        local col = {}
        for i = 1, #x do
          col[i] = x[i][j]
        end
        maxs[j] = f(table.unpack(col))
      end
      if #maxs == 1 then
        return maxs[1]
      else
        return maxs
      end
    else
      return f(table.unpack(x))
    end
  else
    return x
  end
end

function max( x ) return max_min_shared(math.max, x) end
function min( x ) return max_min_shared(math.min, x) end

--// map( func, x )
-- applys a function to each atomic entry in a table and keeps the structure of the table
--[[
require 'mathly';
x = {1, 2, 3, {3, 4, 5, 6, 7, 8, {1, 2, {-5, {-6, 9}}, 8}}}
y = map(function(x) return x^2 end, x)
z = map(function(x, y) return x + y end, x, y)
w = sin(x)
display(x); display(y); display(z); display(w)

x = {1, 2, 3, {3, 4, 5, 6, 7, 8, {1, 2, {-5, {-6, 9}}, 8}}}
y = map(function(x) return 's' .. tostring(x) end, x)
z = map(function(x,y) return x .. y end, y, y)
display(x); display(y); display(z)

display(map(function(x) return x*2 end, {1, 2, 3})) --> {2, 4, 6}
display(map(function(x,y) return x+3*y end, {1, 2}, {3, 4})) --> {10, 14}
display(map(function(x,y,z) return x^2-3*y+2*z end, {1, {2}, 3}, {2, {3}, 4}, {3, {0}, 5})) --> {1, {-5}, 7}

A = {{1, 2, 3}, {2, 3, 4}}
B = {{3, 4, 5}, {5, 6, 7}}
C = map(function(x, y) return x * y end, A, B) -- MATHLAB: A .* B
disp(C)
--]]
local function _map( func, ... ) -- ~Mathematica
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end

  if type(args[1]) ~= 'table' then
    return func(table.unpack(args))
  else
    local y = {}
    for i = 1,#args[1] do
      local arg = {}
      for j = 1,#args do
        arg[#arg + 1] = args[j][i]
      end

      if type(args[1][i]) ~= 'table' then
        y[#y + 1] = func(table.unpack(arg))
      else
        y[#y + 1] = _map(func, table.unpack(arg))
      end
    end
    return y
  end
end

function map(func, ...)
  local metaq = false
  for _, v in pairs{...} do
    if getmetatable(v) == mathly_meta then
      metaq = true
      break
    end
  end

  local result = _map(func, ...)

  if metaq then
    return setmetatable(result, mathly_meta)
  else
    return result
  end
end

--// apply( func, args )
-- calls a function with arguments
function apply( func, args ) -- ~Mathematica
  return func(table.unpack(args))
end

--// copy ( x )
-- make a copy of x
function copy( x )
  local y = {}
  if type(x) ~= 'table' then
    return x
  else
    for i = 1,#x do
      if type(x[i]) ~= 'table' then
        y[#y + 1] = x[i]
      else
        y[#y + 1] = copy(x[i])
      end
    end
    if getmetatable( x ) == mathly_meta then
      return setmetatable(y, mathly_meta)
    else
      return y
    end
  end
end

--// function unique(tbl)
-- Return the same data as in tbl but with no repetitions.
function unique(tbl)
  if type(tbl) ~= 'table' then return tbl end
  local x = copy(tbl)
  table.sort(x)
  local y
  if #x > 0 then y = {x[1]} else return {} end
  for i = 2, #x do
    if math.abs(x[i] - x[i - 1]) > eps then -- not equal
      y[#y + 1] = x[i]
    end
  end
  return y
end

--// disp( A )
-- print a mathly matrix while display(x) prints a table with its structure
-- disp({{1, 2, 3, 4}, {2, -3, 4, 5}, {3, 4, -5, 6}})
function disp( A ) -- ~MATLAB
  if getmetatable(A) == mathly_meta then
    local rows, columns = size(A)
    for i = 1, rows do
      io.write('\n')
      for j = 1, columns do
        if isinteger(A[i][j]) then
          io.write(string.format("%12d ", A[i][j]))
        else
          io.write(string.format("%12.6f ", A[i][j]))
        end
      end
    end
    io.write('\n\n')
  else
    display(A)
  end
end

--// display( x )
-- print a table with its structure while disp(x) prints a matrix
-- display({1, 2, 3, {3, 4, 5, 6, 7, 8, {1, 2, {-5, {-6, 9}}, 8}}})
function display( x, first_itemq ) -- ~MATLAB
  local calledbyuserq = first_itemq == nil
  if first_itemq == nil then first_itemq = true end
  if not first_itemq then io.write(', ') end
  if type(x) ~= 'table' then
    io.write(x)
  else
    io.write('{'); first_itemq = true
    for i = 1,#x do
      if type(x[i]) ~= 'table' then
        if not first_itemq then io.write(', ') end
        io.write(x[i])
      else
        display(x[i], first_itemq)
      end
      first_itemq = false
    end
    io.write('}')
  end
  first_itemq = false
  if calledbyuserq then io.write('\n') end
end

--// function who()
-- list all user defined variables (some may be defined by some loaded modules)
-- if a list of variables are needed by other code, pass false to it: who(false)
function who(usercalledq) -- ~R
  if usercalledq == nil then usercalledq = true end
  local list = {}
  for k,v in pairs(_G) do
    if type(v) ~= 'function' then
      if not ismember(k, {'e', 'eps', 'pi', 'phi', 'T', 'mathly', 'm', '_G', 'coroutine',
                          'utf8', '_VERSION', 'io', 'package', 'os', 'arg', 'debug',
                          'string', 'table', 'math', 'linux_browser', 'mac_browser',
                          'win_browser', 'plotly_engine', 'temp_plot_html_file'}) then
        list[#list + 1] = k
      end
    end
  end
  if usercalledq then -- print the list
    if #list >= 1 then io.write(list[1]) end
    for i = 2, #list do
      io.write(', ', list[i])
    end
    io.write('\n')
  else
    return list
  end
end

-- vartostring('y') gives the string version of variable y starting with 'y ='
local function vartostring( x, first_itemq, titleq )
  if titleq == nil then titleq = true end
  if first_itemq == nil then first_itemq = true end

  local str = ''
  if not first_itemq then str = ', ' end
  if titleq then
    str = str .. string.format("%s = ", x)
    x = load('return ' .. x)()
  end
  if type(x) == 'string' then
    str = str .. "'" .. x .. "'"
  elseif type(x) == 'number' then
    str = str .. string.format("%.18f", x)
  elseif type(x) == 'table' then
    str = str .. '{'; first_itemq = true
    for i = 1,#x do
      if type(x[i]) ~= 'table' then
        if not first_itemq then str = str .. ', ' end
        if type(x[i]) == 'string' then
          str = str .. "'" .. x[i] .. "'"
        elseif type(x[i]) == 'number' then
          str = str .. string.format("%.18f", x[i])
      --else -- what?
        end
      else
        str = str .. vartostring(x[i], first_itemq, false)
      end
      first_itemq = false
    end
    str = str .. '}'
--else -- what?
  end
  if titleq then str = str .. '\n\n' end
  return str
end

--// function save(fname, ...)
-- save variables and their values to a textfile
-- e.g., save('dw20241219.lua', 'x', 'y', 'y1') -- save variables, x, y, y1
--       save('dw20241219.lua') -- save all user defined variables
--[[
require 'mathly'
x = {1, 2, {3, 5, 6, 7, {9, {10, {10, 11, 12, {13}}}}}}
y = rand(4, 5)
save('dw20241219.lua', 'x', 'y')

-- recover the saved data:
require 'mathly'
dofile('dw20241219.lua')
disp(x); disp(y)
--]]
function save(fname, ...)
  local vars = {}
  for _, v in pairs{...} do
    vars[#vars + 1] = v
  end
  if #vars == 0 then vars = who(false) end

  local file = io.open(fname, "w")
  if file ~= nil then
    for i = 1, #vars do
      file:write(vartostring(vars[i]))
    end
    file:close()
  else
    print(string.format("Failed to create %s. The device might not be writable.", fname))
  end
end

--// function clc()
-- clear LUA console
function clc()
  local x = os.execute("cls") or os.execute('clear')
end

--// function clear()
-- clear all user-defined variables in current running environment
function clear()
  local vars = who(false)
  for i = 1, #vars do
    load(string.format("%s = nil", vars[i]))()
  end
  if _ ~= nil then _ = nil end
end

--// seq( from, to, len )
-- generates an evenly spaced sequence/table of 'len' numbers on the interval [from, to]. same as linspace(...).
function seq( from, to, len ) -- ~R, generate a sequence of numbers
  if len == nil then return range(from, to) end
  if len < 0 then
    print("seq(from, to, len): len can't be negative.")
    return {}
  end
  local lst = {}
  local step = (to - from) / (len - 1)
  local i = 1
  while i <= len do
    lst[i] = from
    from = from + step
    i = i + 1
  end
  return lst
end

--// linspace( from, to, len )
-- generates an evenly spaced sequence/table of 'len' numbers on the interval [from, to]. same as seq(...).
function linspace( from, to, len ) -- ~MATLAB
  return seq(from, to, len)
end

--// prod( x )
-- calculates the product of all elements of a table
-- calculates the product of all elements of each column in a matrix
function prod( x ) -- ~MATLAB
  if type(x) == 'number' then
    return x
  elseif type(x) == 'table' then
    if type(x[1]) == 'table' then -- a table of tables, i.e., a "matrix"
      local prods = {}  -- ~MATLAB, column wise
      for j = 1,#x[1] do
        prods[j] = 1
        for i = 1,#x do
          prods[j] = prods[j] * x[i][j]
        end
      end
      return setmetatable(prods, mathly_meta)
    else
      local s = 1
      for i = 1,#x do s = s * x[i] end
      return s
    end
  else
    return 0
  end
end

--// sum( x )
-- calculates the sum of all elements of a table
-- calculates the sum of all elements of each column in a matrix
function sum( x ) -- ~MATLAB
  if type(x) == 'number' then
    return x
  elseif type(x) == 'table' then
    if type(x[1]) == 'table' then -- a table of tables, i.e., a "matrix"
      if #x == 1 then -- {{1, 2, ...}} b/c mathly{1, 2, 3} gives {{1, 2, 3}}
         return sum(x[1])
      end
      local sums = {}  -- ~MATLAB, column wise
      for j = 1,#x[1] do
        sums[j] = 0
        for i = 1,#x do
          sums[j] = sums[j] + x[i][j]
        end
      end
      if #sums == 1 then
        return sums[1]
      else
        return setmetatable(sums, mathly_meta)
      end
    else
      local s = 0
      for i = 1,#x do s = s + x[i] end
      return s
    end
  else
    return 0
  end
end

--// dot( a, b )
-- calculates the dot/inner product if two vectors
function dot( a, b ) -- ~MATLAB
  local t1 = flatten(a)
  local t2 = flatten(b)
  if #t1 ~= #t2 then
    print('dot(a, b): vectors a and b are not of the same size.')
    return nil
  else
    local val = 0
    for i = 1,#t1 do
      val = val + t1[i] * t2[i]
    end
    return val
  end
end

--// dot( m1, m2 )
-- calculates the dot/inner product if two vectors
function cross( a, b ) -- ~MATLAB, Mathematica
  local t1 = flatten(a)
  local t2 = flatten(b)
  if #t1 ~= 3 or #t2 ~=3 then
    print('cross(a, b): a and b must be 3D vectors.')
    return nil
  else
    return {a[2] * b[3] - a[3] * b[2],
            a[3] * b[1] - a[1] * b[3],
            a[1] * b[2] - a[2] * b[1]}
  end
end

--// range( start, stop, step )
-- generates a evenly spaced sequence/table of numbers starting at 'start' and likely ending at 'stop' by 'step'.
function range( start, stop, step ) -- ~Python but inclusive
  if start == nil then
    print('range(start, stop, step): no input.')
    return {}
  end
  if stop == nil then stop = start; start = 1 end
  if step == nil then step = 1 end
  if start <= stop and step < 0 then
    printf("range(%d, %d, step): step must be positive.\n", start, stop)
    return {}
  elseif start >= stop and step > 0 then
    printf("range(%d, %d, step): step must be negative.\n", start, stop)
    return {}
  end

  local v = {}
  if step > 0 then
    while start <= stop + 100*eps do -- weird 1*eps doesn't work
      v[#v + 1] = start
      start = start + step
    end
  else
    while start >= stop - 100*eps do
      v[#v + 1] = start
      start = start + step
    end
  end
  return v
end

--// polyval( p, x )
-- evaluate a polynomial p at x
-- example: polyval({6,-3,4}, 5) -- evalue 6 x^2 - 3 x + 4 at x = 5
function polyval( P, x ) -- ~MATLAB
  local p = P
  local msg = 'polyval(p, x): invalid p. It must be a table of the coefficients of a polynomial.'

  if p == nil or type(p) ~= 'table' then
    error(msg)
  end

  if type(p[1]) == 'table' then
    if #p == 1 then -- mathly{1, 2} gives {{1, 2}}
      p = P[1]
    elseif #p[1] == 1 then -- column vector
      p = (P^T)[1]
    else
      error(msg)
    end
  end

  if type(x) ~= 'table' then
    x = { x }
  elseif type(x[1]) == 'table' then
    x = flatten(x)
  end
  local vs = {}
  for j = 1, #x do
    local v = 0
    for i = 1, #p do
      v = v + p[i] * x[j] ^ (#p - i)
    end
    vs[#vs + 1] = v
  end

  if #vs == 1 then
    return vs[1]
  else
    return vs
  end
end

--// norm( v )
-- calculate the Euclidean norm of a vector
function norm( v )
  return math.sqrt(dot(v, v))
end

--// create_table( r, c, val )
-- generates a table of r subtables of which each has c elements, with each element equal to val
-- if c == nil, c = r;
-- if r == 1 or c == 1, return a simple table (so that it can be accessed like a[i] as in MATLAB)
-- if val == nil, it is a random number.
local function create_table( row, col, val, metaq )
  if metaq == nil then metaq = false end
  local x = {}
  if col == nil then col = row end
  if val == nil then
    -- math.randomseed(os.time()) -- keep generating same seq? Lua 5.4.6
    for i = 1,row do
      x[i] = {}
      for j = 1,col do
        x[i][j] = math.random()
      end
    end
  else
    for i = 1,row do
      x[i] = {}
      for j = 1,col do
        x[i][j] = val
      end
    end
  end
  if row == 1 and not metaq then
    return x[1]
  else
    return setmetatable(x, mathly_meta)
  end
end

--// mathly:new ( rows [, columns [, value]] )
function mathly:new( rows, columns, value )
	if type(rows) == "table" then -- check for a given matrix
		if columns ~= nil then
  		return reshape(rows, columns, value)
    end
    -- if rows is a flat table (of level 1)
    local flatq = true
    local col
    for _, v in pairs(rows) do
      if type(v) == 'table' then
        flatq = false
        col = #v
        break
      end
    end
    if flatq then
      return setmetatable( {rows}, mathly_meta ) -- a row vector
    else
      for i = 1, #rows do
        assert(type(rows[i]) == 'table' and #rows[i] == col,'mathly: invalid input:')
        for j = 1, #rows[i] do
          if type(rows[i][j]) ~= 'number' then
            print('mathly:new: invalid input', rows[i][j]); return {}
          end
        end
      end
  		return setmetatable(rows, mathly_meta)
    end
	end

  assert(columns ~= nil, 'mathly(rows, columns): rows and columns must be both specified.')
  return create_table(rows, columns, value, true)
end

--// eye( r )
-- generates a special table, i.e., a rxr identity matrix
function eye( row )
  local A = {}
  for i = 1, row do
    A[i] = {}
    for j = 1, row do A[i][j] = 0 end
    A[i][i] = 1
  end
  return setmetatable(A, mathly_meta)
end

--// ones( r, c )
-- generates a table of r subtables of which each has c elements, with each element equal to 1
-- if c == nil, c = r.
function ones( row, col ) return create_table(row, col, 1) end

-- generates a table of r subtables of which each has c elements, with each element equal to 0
-- if c == nil, c = r.
function zeros( row, col ) return create_table(row, col, 0) end

--// rand( r, c )
-- generates a table of r subtables of which each has c elements, with each element equal to a random number
-- if c == nil, c = r.
function rand( row, col ) return create_table(row, col) end

--// function randi( imax, m, n )
-- generate a mxn matrix of which each entry is a random integer in [1, imax]
--
--// function randi( {imin, imax}, m, n )
-- generate a mxn matrix of which each entry is a random integer in [imin, imax]
--
function randi( imax, m, n )
  local imin
  if type(imax) == 'number' then
    imin = 1
  elseif type(imax) == 'table' then
    imin = imax[1]
    imax = imax[2]
  end
  if m == nil then return math.random(imin, imax) end
  if n == nil then n = m end

  assert(imin < imax,
         'randi({iminm, imax}, m, n): imin must be less than imax.')

  local B = {}
  -- math.randomseed(os.time()) -- keep generating same seq? Lua 5.4.6
  for i = 1, m do
    B[i] = {}
    for j = 1, n do
      B[i][j] = math.random(imin, imax)
    end
  end
  if m == 1 then
    return B[1]
  else
    return setmetatable(B, mathly_meta)
  end
end

--// tic()
-- starts a time stamp to measure elapsed time
local elapsed_time = nil
function tic()
  elapsed_time = os.time()
end

--// toc()
-- prints elapsed time from last calling tic() if no values are passed to it;
-- returns elapsed time from last calling tic() if any none-nil value is passed to it.
function toc(print_not)
  if elapsed_time == nil then
    print("Please call tic() first.")
    if print_not ~= nil then
      return 0
    end
  end
  local tmp = os.difftime(os.time(), elapsed_time)
  if print_not == nil then
    print(string.format("%.6f secs.", tmp))
  else
    return tmp
  end
end

--// flatten( tbl )
-- removes the structure of a table and returns the resulted table.
-- if tbl is a mathly matrix, the result is row wise (rather than column wise)
-- want column wise? use t(tbl)
--
-- flatten({{1},{2,3}}) returns {1, 2, 3}
-- flatten({1,{2,3}}) returns {1, 2, 3}
function flatten(x)
  local y = {}
  local j = 1
  local function flat(x)
    if type(x) == 'table' then
      for i = 1, #x do
        if type(x[i]) == 'table' then
          flat(x[i])
        else
          y[j] = x[i]; j = j + 1
        end
      end
    else
      y[j] = x; j = j + 1
    end
  end
  flat(x)
  return y
end

--// hasindex( tbl, idx )
-- if tbl table has recursively an index, idx, return true.
function hasindex( tbl, idx )
  if type(tbl) ~= 'table' then
    return false
  elseif tbl[idx] ~= nil then
      return true
  else
    for _, v in pairs(tbl) do
      if type(v) == 'table' and hasindex(v, idx) then
        return true
      end
    end
    return false
  end
end

function isinteger( x ) return math.floor(x) == x end

--// function ismember( x, v )
-- return true if x is an entry of a vector, e.g., ismember(5, {1,2,3,4,5,6}),
-- ismember('are', {'We', 'are', 'the', 'world'})
function ismember( x, v )
  for _, val in pairs(v) do
    if x == val then return true end
  end
  return false
end

--[[

  ---------------------- plot, options, and some examples ----------------------

  'plot' has similar usage of the same function in MATLAB with more features.

  1) of a line, i.e., the graph of a function:
      width=5
      style='-' (solid), ':' (dot), or '--' (dash)
      mode='lines+markers', 'lines', or 'markers'

  2) of a marker:
      size=10
      symbol='circle'

      Some possible symbols are: circle, circle-open, circle-open-dot, cross, diamond, square, x,
      triangle-left, triangle-right, triangle-up, triangle-down, hexagram, star, hourglass, bowtie

  3) of a plot: layout={width=500, height=400}

  examples
  --------
  require 'mathly'
  x = linspace(0, pi, 100)
  y1 = sin(x)
  y2 = map(math.cos, x)
  y3 = map(function(x) return x^2*math.sin(x) end, x)

  specs1 = {layout={width=700, height=900, grid={rows=4, columns=1}, title='Example'}}
  specs2 = {color='blue', name='f2', layout={width=500, height=500, grid={rows=4, columns=1}, title='Demo'}}
  specs3 = {width=5, name='f3', style=':', color='cyan', symbol='circle-open', size78}

  plot(math.sin, '--r') -- plot a function
  plot(x, y1)           -- plot a function defined by x and y1
  plot(x, y1, x, y2, specs1, math.sin, '--r')
  plot(x, y1, '--xr', x, y2, {1.55}, {-0.6}, {symbol='circle-open', size=10, color='blue'})
  plot(x, y1, '--xr', x, y2, ':g')
  plot(x, y1, {xlabel="x-axis", ylabel="y-axis", color='red'})
  plot(x, y1, specs1, x, y2, x, y3, 'o')
  plot(x, y1, specs3, x, y2, specs2, math.sin, x, y3, specs1)

  plot(rand(125, 4)) -- plots functions defined in each column of a matrix with the range of x from 0 to # of rows
  plot(rand(125, 4),{layout={width=900, height=400, grid={rows=2, columns=2}, title='Demo'}, names={'f1', 'f2', 'f3', 'g'}})
  plot(rand(125, 4), {layout={width=900, height=400, grid={rows=2, columns=2}, title='Example'}})
  plot(rand(100,3), {layout={width=900, height=400, grid={rows=3, columns=2}, title='Example'}}, rand(100,2))
  plot(rand(100, 2), linspace(1,100,1000), sin(linspace(1,100,1000)), '-og', rand(100, 3))
--]]

--// plot(...)
-- plots the graphs of functions in a way like in MATLAB
local plotly = nil
function plot(...) -- ~MATLAB
  if plotly == nil then -- the plotly module is loaded once when needed
    plotly = require("plotly-for-mathly")
  end

  local args = {}
  local traces = {}
  local x_start = nil -- range of x for a plot
  local x_stop
  for _, v in pairs{...} do
    args[#args + 1] = v
  end

  plotly.gridq = false
  plotly.layout = {}
  local i = 1
  while i <= #args do
    if type(args[i]) == 'function' then
      args[i] = {0, args[i]}
      table.insert(args, i + 1, {0, 0}) -- pretend to be x, y, ...; to be modified before plotting
    else
      local trace = {}
      -- input may be {{1, 2, ...}} or {{1}, {2}, ...}
      if type(args[i]) == 'table' and type(args[i][1]) == 'table' then
        if #args[i] == 1 then -- mathly{1, 2, ...} gives {{1, 2, ...}}
          args[i] = args[i][1]
        elseif #args[i][1] == 1 then -- {{1}, {2}, ...}
          args[i] = flatten(args[i])
        end
      end

      if type(args[i]) == 'table' then
        if type(args[i][1]) == 'table' then -- plot functions defined in each column of a matrix
          local traces_tmp = {}
          local x = seq(1, #args[i]) -- the range of x: 1 to # of rows
          if x_start == nil then
            x_start, x_stop = 1, #args[i]
          end
          for j = 1,#args[i][1] do
            local y = {}
            for k = 1,#args[i] do
              y[k] = (args[i][k])[j]
            end
            trace = {x, y, mode='lines', style='-'}
            if j < #args[i][1] then
              traces_tmp[#traces_tmp + 1] = trace
            end
          end
          i = i + 1 -- the item has been processed

          local names = {}
          if i <= #args and type(args[i]) == 'table' then
            if (hasindex(args[i], 'layout') or hasindex(args[i], 'width') or
                hasindex(args[i], 'height') or hasindex(args[i], 'title') or
                hasindex(args[i], 'names')) then
              local optq = false
              if args[i]['layout'] ~= nil then
                trace['layout'] = args[i]['layout']
                optq = true
              end

              local function test_and_set(key)
                if args[i][key] ~= nil then
                  if trace['layout'] == nil then trace['layout'] = {} end
                  trace['layout'][key] = args[i][key]
                end
              end
              test_and_set('title')
              test_and_set('width')
              test_and_set('height')
              if args[i]['names'] ~= nil then names = args[i]['names'] end
              i = i + 1
            end
          end
          traces_tmp[#traces_tmp + 1] = trace

          if #names > 0 then
            i = i + 1
            for j = 1,#traces_tmp do
              traces_tmp[j]['name'] = names[j]
            end
          end
          for j = 1,#traces_tmp do
            traces[#traces + 1] = traces_tmp[j]
            traces_tmp[j] = nil
          end
        else
          trace[1] = flatten(args[i]); i = i + 1
          trace[2] = flatten(args[i])
          if x_start == nil and #trace[1] >= 2 and type(trace[1][2]) ~= 'function' then
            x_start, x_stop = trace[1][1], trace[1][#trace[1]]
          end
          if i <= #args and type(args[i]) == 'table' and #trace[1] == #trace[2] then
            i = i + 1

            trace['mode'] = ''
            if type(args[i]) == 'string' then -- options
              local specs = string.lower(args[i]); i = i + 1
              if string.find(specs, '%-%-') then
                trace['mode'] = 'lines'
                trace['style'] = '--'
              elseif string.find(specs, '%-') then
                trace['mode'] = 'lines'
                trace['style'] = '-'
              elseif string.find(specs, '%:') then
                trace['mode'] = 'lines'
                trace['style'] = ':'
              end

              if string.find(specs, 'r') then
                trace['color'] = 'red'
              elseif string.find(specs, 'b') then
                trace['color'] = 'blue'
              elseif string.find(specs, 'g') then
                trace['color'] = 'green'
              elseif string.find(specs, 'c') then
                trace['color'] = 'cyan'
              elseif string.find(specs, 'm') then
                trace['color'] = 'magenta'
              elseif string.find(specs, 'y') then
                trace['color'] = 'yellow'
              elseif string.find(specs, 'k') then
                trace['color'] = 'black'
              elseif string.find(specs, 'w') then
                trace['color'] = 'white'
              end

              local symbol = ''
              if string.find(specs, 'o') then
                symbol = 'circle'
              elseif string.find(specs, '%*') then
                symbol = 'star'
              elseif string.find(specs, 'x') then
                symbol = 'x'
              elseif string.find(specs, '%^') then
                symbol = 'triangle-up'
              elseif string.find(specs, '%v') then
                symbol = 'triangle-down'
              elseif string.find(specs, '%>') then
                symbol = 'triagle-right'
              elseif string.find(specs, '%<') then
                symbol = 'triagle-left'
              end

              if symbol ~= '' then
                trace['symbol'] = symbol
                if trace['mode'] == '' then
                  trace['mode'] = 'markers'
                else
                  trace['mode'] = 'lines+markers'
                end
              end
            elseif type(args[i]) == 'table' then -- is it options?
              local optq = false
              for k, v in pairs(args[i]) do
                if type(k) == 'string' then k = string.lower(k) end
                optq = k == 'color' or k == 'size' or k == 'width' or k == 'mode'
                optq = optq or k == 'xlabel' or k == 'ylabel' or k == 'title'
                optq = optq or k == 'symbol' or k == 'name' or k == 'layout'
                if optq then break end
              end
              if optq then -- this arg is options
                for k, v in pairs(args[i]) do
                  if type(k) == 'string' then
                    trace[string.lower(k)] = v
                  else
                    trace[k] = v
                  end
                end
                i = i + 1
              end
              if trace['symbol'] ~= nil then
                if trace['style'] == nil then
                  trace['mode'] = 'markers'
                else
                  trace['mode'] = 'lines+markers'
                end
              else
                trace['mode'] = 'lines'
              end
            end

            traces[#traces + 1] = trace
          else
            print('Invalid input: x and y must be of the same size.')
            return
          end
        end
      else -- invalid input, skipped
        i = i + 1
      end
    end
  end

  if x_start == nil then
    x_start, x_stop = -7, 7
  end
  for i = 1, #traces do
    if #traces[i][1] >=2 and type(traces[i][1][2]) == 'function' then
      local func = traces[i][1][2]
      traces[i][1] = linspace(x_start, x_stop, math.ceil(math.abs(x_stop - x_start)) * 10)
      traces[i][2] = map(func, traces[i][1])
    end
  end

  plotly.plots(traces):show()
  plotly.gridq = false
  plotly.layout = {}
end

-- to-do list
-- rref
-- transpose
-- size

--// transpose ( A )
-- transpose a matrix
function transpose( A )
  assert(getmetatable(A) == mathly_meta, 'transpose( A ): A must be a mathly metatable.')
	local B = {}
	for i = 1,#A[1] do
		B[i] = {}
		for j = 1,#A do
			B[i][j] = A[j][i]
		end
	end
	return setmetatable(B, mathly_meta)
end

--// rref( A, B )
-- calculate the reduced row-echlon form of matrix A
-- if B is provided, it works on [ A | B]; useful for finding the inverse of A or
-- solving Ax = b by rref [ A | b ]
-------- note: A, B are modified on purpose for performance for large matrices!!! --------
function rref( A, B ) -- gauss-jordan elimination
  assert(getmetatable(A) == mathly_meta, 'rref( A ): A must be a mathly metatable.')
  assert(B == nil or getmetatable(B) == mathly_meta, 'rref( A, B ): A and B must be mathly metatables.')
  local rows, columns = size(A)
  local ROWS = math.min(rows, columns)

  local bq = false
  local bcolumns = 0
  if B ~= nil then
    bq = true
    assert(#B == rows, 'rref(A, B): A and be must have the same number of rows.')
    bcolumns = #B[1]
  end

  for i = 1, ROWS do
    local largest = math.abs(A[i][i]) -- choose the pivotal entry
    local idx = i
    for j = i + 1, rows do
      local tmp = math.abs(A[j][i])
      if tmp > largest then
        idx, largest = j, tmp
      end
    end

    if largest > 1e-15 then -- none-zero
      if i ~= idx then -- interchange the two rows
        for j = i, columns do
          A[i][j], A[idx][j] = A[idx][j], A[i][j]
        end
        if bq then
          for j = 1, bcolumns do
            B[i][j], B[idx][j] = B[idx][j], B[i][j]
          end
        end
      end

      largest = A[i][i]  -- 'normalize' the row: 0 ... 0 1 x x x
      A[i][i] = 1
      for j = i + 1, columns do
        A[i][j] = A[i][j] / largest
      end
      if bq then
        for j = 1, bcolumns do
          B[i][j] = B[i][j] / largest
        end
      end

      for j = i + 1, rows do -- eliminate entries below A[i][i]
        local Aji = A[j][i]
        for k = i, columns do
          A[j][k] = A[j][k] - A[i][k] * Aji
        end
        if bq then
          for k = 1, bcolumns do
            B[j][k] = B[j][k] - B[i][k] * Aji
          end
        end
      end
    end
  end

  for i = ROWS, 2, -1 do
    local m = i
    if A[i][i] ~= 1 then -- A[i][i] must be 0, find the 1st none-zero entry
      j = i + 1
      while j <= columns and math.abs(A[i][j]) < 1e-15 do
        j = j + 1
      end
      if j <= columns then -- found it
        m = j
        local Aij = A[i][j]   -- 'normalize' the row, 0...0 1 xxx
        while j <= columns do
          A[i][j] = A[i][j] / Aij
          j = j + 1
        end
        if bq then
          for j = 1, bcolumns do
            B[i][j] = B[i][j] / Aij
          end
        end
      else
        m = columns + 1
      end
    end

    if m <= columns then -- eliminate entries above A[i][m]
      for j = i - 1, 1, -1 do
        local Ajm = A[j][m]
        for k = m, columns do
          A[j][k] = A[j][k] - A[i][k] * Ajm
        end
        if bq then
          for k = 1, bcolumns do
            B[j][k] = B[j][k] - B[i][k] * Ajm
          end
        end
      end
    end
  end
  return A
end

--// function linsolve( A, b, opt )
-- solve the linear system Ax = b for x, given that A is a square matrix; return the solution
-- note: A and b are modified
function linsolve( A, b, opt )
  assert(getmetatable(A) == mathly_meta, 'linsolve( A ): A must be a mathly metatable.')
  local B = b
  if b ~= nil then
    if getmetatable(b) ~= mathly_meta then
      if type(b) == 'table' then
        local x = flatten(b)
        B = mathly:new(x, #x, 1)
      else
        error('linsolve(A, b): b must be a table.')
      end
    end
  else
    error('linsolve(A, b): b is not provided.')
  end

  if opt ~= 'UT' and opt ~= 'LT' then
    rref(A, B)
    return B
  end

  local m, n = size(A)
  assert(m == n and n == #B, 'linsolve(A, b, ...): A must be square and the dimensions of A and b must match.')
  local y = zeros(1, n)
  if opt == 'UT' then -- solve it by back substitution
    y[n] = B[n][1] / A[n][n]
    for i = n - 1, 1, -1 do
      y[i] = (B[i][1] - sum(submatrix(A, i, i + 1, i, n) * r(subtable(y, i + 1, n)))) / A[i][i]
    end
  else -- solve it by forward substitution
    y[1] = B[1][1] / A[1][1]
    for i = 2, n do
      y[i] = (B[i][1] - sum(submatrix(A, i, 1, i, i - 1) * r(subtable(y, 1, i - 1)))) / A[i][i]
    end
  end
  return c(y)
end

--// function inv( A )
-- calculate the inverse of matrix A
-- rref([A | I]) gives [ I | B ], where B is the inverse of A
-- note: A is modified
function inv( A )
  assert(getmetatable(A) == mathly_meta, 'inv( A ): A must be a mathly metatable.')
  local rows, columns = size(A)
  assert(rows == columns, 'inv( A ): A must be square.')
  local B = eye(rows)
  rref(A, B)
  return setmetatable(B, mathly_meta)
end

--// function size ( A )
-- return rows and columns of matrix A, given that A is a valid vector, matrix, string, or a number.
function size( A )
  if type(A) == 'table' then
    if type(A[1]) == 'table' then
      return #A, #A[1]
    else
      return 1, #A
    end
  elseif type(A) == 'string' then
    return 1, #A
  else
    return 1, 1
  end
end

--// function repmat(A, m, n)
-- Return a mxn block matrix with each entry a copy of matrix A.
function repmat(A, m, n)
  local B = A
  if getmetatable(A) ~= mathly_meta then
    if type(A) == 'table' then
      B = mathly(A)
    else
      B = {{A}}
    end
  end
  if n == nil then n = m end

  local C = {}
  local row, col = size(B)
  for i = 1, m * row do C[i] = {} end
  for i = 1, m do
    local tmp1 = (i - 1) * row + 1
    for j = 1, n do
      local I = tmp1
      local tmp2 = (j - 1) * col + 1
      for ii = 1, row do
        local J = tmp2
        for jj = 1, col do
          C[I][J] = B[ii][jj]
          J = J + 1
        end
        I = I + 1
      end
    end
  end
  return setmetatable(C, mathly_meta)
end

--// function flipud(A)
-- Return a matrix with rows of matrix A reversed
function flipud(A)
  assert(getmetatable(A) == mathly_meta, 'flipud(A): A must be a mathly matrix.')
  local B = {}
  local rows, columns = size(A)
  for i = 1, rows do B[i] = {} end
  local I = 1
  for i = rows, 1, -1 do
    for j = 1, columns do
      B[I][j] = A[i][j]
    end
    I = I + 1
  end
  return setmetatable(B, mathly_meta)
end

--// function fliplr(A)
-- Return a matrix with columns of matrix A reversed
function fliplr(A)
  assert(getmetatable(A) == mathly_meta, 'flipud(A): A must be a mathly matrix.')
  local B = {}
  local rows, columns = size(A)
  for i = 1, rows do
    B[i] = {}
    local J = 1
    for j = columns, 1, -1 do
      B[i][J] = A[i][j]
      J = J + 1
    end
  end
  return setmetatable(B, mathly_meta)
end

--// function remake(A, opt)
-- Make A a lower (opt = 'LT'), upper (opt = 'UT'), or a symmetric (opt = 'SYM') matrix by replacing entries with 0's or so
function remake(A, opt)
  assert(getmetatable(A) == mathly_meta, 'remake(A, opt): A must be a mathly matrix.')
  local B
  local m, n = size(A)
  local minn = math.min(m, n)
  if opt == 'UT' then
    B = zeros(m, n)
    if m == 1 then B = r(B) end
    for i = 1, m do
      for j = i, n do
        B[i][j] = A[i][j]
      end
    end
  elseif opt == 'LT' then
    B = zeros(m, n)
    if m == 1 then B = r(B) end
    for i = 1, m do
      for j = 1, math.min(i, n) do
        B[i][j] = A[i][j]
      end
    end
  elseif opt == 'SYM' then
    B = {}
    for i = 1, minn do
      B[i] = {}
      for j = i, minn do
        B[i][j] = A[i][j]
      end
    end
    for i = 2, minn do
      for j = 1, i - 1 do
        B[i][j] = B[j][i]
      end
    end
    setmetatable(B, mathly_meta)
  elseif opt == 'DIAG' then
    return diag(diag(A))
  elseif type(opt) == 'table' and type(opt[1]) == 'number' then
    local opts = unique(flatten(opt)) -- that allows input {-1,0,2, seq(5,10)}
    B = zeros(m, n)
    if m == 1 then B = r(B) end
    local I, J
    for k = 1, #opts do
      for i = 1, m do
        I = i - opts[k]
        for j = i, n do
          if I > 0 and I <= m then
            B[I][j] = A[I][j]
          end
          I = I + 1
        end
      end
    end
  else
    B = A
  end
  return B
end

--// function reshape( A, m, n )
-- use entries of matrix A to generate a new mxn matrix, given that A is a valid vector or matrix
function reshape( A, m, n ) -- ~MATLAB, and better
  local rows, columns
  rows, columns = size(A)
  local total = rows * columns
  if n == nil then n = math.ceil(total / m) end

  local tbl, B
  if rows == 1 or columns == 1 then
    tbl = flatten(A)
  else
    tbl = {}
    for j = 1, columns do
      for i = 1, rows do
        tbl[#tbl + 1] = A[i][j]
      end
    end
  end

  k = 1; B = {}
  for i = 1, m do B[i] = {} end
  for j = 1, n do
    for i = 1, m do
      if k <= total then
        B[i][j] = tbl[k]
        k = k + 1
      else
        B[i][j] = 0
      end
    end
  end
  return setmetatable(B, mathly_meta)
end

--// length( A )
-- return the number of rows of a matrix
function length( A )
  if type(A) == 'table' and type(A[1]) == 'table' and #A == 1 then
    return length(A[1]) -- mathly{1, 2, 3} gives {{1, 2, 3}}
  end
  if type(A) == 'string' or type(A) == 'table' then
    return #A
  else
    return 1
  end
end

-- // function diag( A, k )
-- return the table of all entries of the k-th diagonal as a column vector
-- The second argument k is optional. Its default value is 0.
--
-- Which diagonal? If k = 0, the main diagonal; if k = j, the diagonal j rows above (if j > 0)
-- or -j rows below the main diagonal (if j < 0). E.g., k = 1, the diagonal right above the main
-- diagonal; k = -1, the diagonal right below the main diagonal.
--
-- // function diag(v), where v is a table or a row/column vector
-- return a nxn matrix with v as its main diagonal, where n = size of v

-- // function diag(v, k), where v is a table or a row/column vector
-- if k > 0, return a matrix with v as the diagonal k rows above the main diagonal.
-- if k < 0, return a matrix with v as the diagonal -k columns below the main diagonal
-- if k = 0, same as diag(v)
--
-- // function diag(v, m, n), where v is a table or a row/column vector
-- return a mxn matrix with vector v (or first elements in it) as its main diagonal
function diag( A, m, n )
  local v
  if getmetatable(A) == mathly_meta then
    local rows, columns = size(A)
    if rows == 1 or columns == 1 then -- row/column vector
      v = flatten(A) -- continue after last if .. then .. else ..
    else -- a matrix
      m = m or 0
      local x = {}
      local xi = 1
      for i = 1, math.min(rows, columns) do
        local j = i - m
        if j > 0 and j <= rows then
          x[xi] = {A[j][i]}
          xi = xi + 1
        end
      end
      return mathly(x) -- can't setmetatable(x, mathly_meta); otherwise, mathly data are not uniformly mxn matrices
    end
  elseif type(A) ~= 'table' then
    v = {A}
  else
    v = A
  end

  local z, siz
  if m == nil or (m ~= nil and n ~= nil) then
    if m == nil then m = #v; n = m end
    siz = math.min(#v, m, n)
    z = zeros(m, n)
    if m == 1 then z = r(z) end -- zeros(1, n) is not a mathly matrix
    for i = 1, siz do
      z[i][i] = v[i]
    end
  else -- return a matrix with with v as its diagonal |m| rows above/below the main diagonal
    siz = #v + math.abs(m)
    z = zeros(siz, siz)
    if m >= 0 then
      for i = 1, #v do
        local j = i + m
        z[i][j] = v[i]
      end
    else
      for i = 1, #v do
        local j = i - m
        z[j][i] = v[i]
      end
    end
  end
  return setmetatable(z, mathly_meta)
end
--[[
--// function eigs(A)
-- Return eigenvalues of a square matrix A.
function eigs(A) -- apply qr factorization
  assert(getmetatable(A) == mathly_meta, 'eigs(A): A must be a mathly matrix.')
  local row, col = size(A)
  assert(row == col, 'eigs(A): A must be a square matrix.')
  local Q, R

  local i = 1
  while true do
    q, r = qr(A)
    A = r * q
    if math.abs(A[i + 1][i]) < 1e-4 then
      i = i + 1
      if i == row then break end
    end
  end

--  while true do
--    Q, R = qr(A)
--    A = R * Q
--    if norm(diag(A, -1)) < 1e-5 then break end
--  end
  return diag(A)
end
--]]

--// function expand( A, m, n, v )
-- expand/shrink a matrix by adding value v's or dropping entries.
-- the default value of v is 0
function expand( A, m, n, v )
  assert(getmetatable(A) == mathly_meta, 'expand( A ): A must be a mathly matrix.')
  if m == nil then return A end
  if n == nil then n = m end
  if v == nil then v = 0 end

  local rows, columns = size(A)
  local row = math.min(m, rows)
  local col = math.min(n, columns)
  local z = {}
  for i = 1, row do
    z[i] = {}
    for j = 1, col do
      z[i][j] = A[i][j]
    end
    for j = col + 1, n do
      z[i][j] = v
    end
  end
  for i = row + 1, m do
    z[i] = {}
    for j = 1, n do
      z[i][j] = v
    end
  end
  return setmetatable(z, mathly_meta)
end

--// function submatrix( A, startrow, startcol, endrow, endcol, steprow, stepcol )
-- extract a submatrix of matrix A
function submatrix( A, startrow, startcol, endrow, endcol, steprow, stepcol )
--assert(getmetatable(A) == mathly_meta, 'submatrix( A ): A must be a mathly metatable.')
  local rows, columns = size(A)
  if startrow == nil or startrow < 1 then startrow = 1 end
  if startcol == nil or startcol < 1 then startcol = 1 end
  if endrow == nil or endrow > rows then endrow = rows end
  if endcol == nil or endcol > columns then endcol = columns end
  if startrow > endrow or startcol > endcol then
    -- print('submatrix: invalid arguments.')
    return setmetatable({}, mathly_meta)
  end
  if steprow == nil or steprow < 1 then steprow = 1 end
  if stepcol == nil or stepcol < 1 then stepcol = 1 end

  local B = {}
  local I, J
  I = 1
  for i = startrow, endrow, steprow do
    B[I] = {}; J = 1
    for j = startcol, endcol, stepcol do
      B[I][J] = A[i][j]
      J = J + 1
    end
    I = I + 1
  end
  return setmetatable(B, mathly_meta)
end

--// function subtable( A, startpos, endpos, step )
-- return a specified slice of a vector
function subtable( tbl, startpos, endpos, step )
  if startpos == nil or startpos < 1 then startpos = 1 end
  if endpos == nil or endpos > #tbl then endpos = #tbl end
  if startpos > endpos then
    -- print('subtable: invalid input.')
    return {}
  end
  if step == nil or step < 1 then step = 1 end

  local x = {}
  for i = startpos, endpos, step do
    x[#x + 1] = tbl[i]
  end
  return x
end

--// function lu(A)
-- Return L and U in LU factorization A = L * U, where L and U are lower and upper traingular matrices, respectively.
function lu(A) -- by Crout's method
  assert(getmetatable(A) == mathly_meta, 'lu(A): A must be a mathly square matrix.')
  local m, n = size(A)
  assert(n == m and n > 1, "lu(A): A is not square.\n")

  local L = zeros(n, n)
  local U = zeros(n, n)

  for i = 1, n do
    local s
    -- calculate L[i][1 : i]
    for j = 1, i do
      s = 0
      for k = 1, j - 1 do
        s = s + L[i][k] * U[k][j]
      end
      L[i][j] = A[i][j] - s
    end

    -- calculate U[i][i : end]
    U[i][i] = 1
    for j = i + 1, n do
      s = 0
      for k = 1, i - 1 do
        s = s + L[i][k] * U[k][j]
      end
      if math.abs(L[i][i]) < eps then
        error(sprintf('L[%d][%d] = 0. No LU factorization is found.', i, i))
      end
      U[i][j] = (A[i][j] - s) / L[i][i]
    end
  end

  return L, U
end

--// function qr(A)
-- Return QR factorization A=QR, where mxn matrix A = mxn matrix Q * nxn matrix R, Q has orthonormal
-- column vectors, and R is an invertible upper triangular matrix.
-- note: this implementation requires that m >= n.
function qr(A)  -- by Gram-Schmidt process
  assert(getmetatable(A) == mathly_meta, 'qr(A): A must be a mathly matrix.')
  local m, n = size(A)
  assert(m >= n, 'qr(A): A is a mxn matrix, where m >= n.')

  -- constructing Q
  local Q = copy(submatrix(A, 1, 1, m, 1)) -- A[:, 1]
  Q = Q * (1 / norm(Q))
  for i = 2, n do
    local u = submatrix(A, 1, i, m, i) -- A[:, i]
    local v = copy(u)            -- MATLAB: v = u
    for j = 1, i - 1 do
      local vj = submatrix(Q, 1, j, m, j) -- Q[:, j]
      v = v - (sum(u * vj) / sum(vj * vj)) * vj -- u .* vj, vj .* vj
    end
    v = v * (1 / norm(v))  -- normalizing the column vector
    Q = concath(Q, v)
  end

  -- calculating R
  local R = zeros(n, n)
  for i = 1, n do
    for j = i, n do
      R[i][j] = sum(submatrix(A, 1, j, m, j) * submatrix(Q, 1, i, m, i)) -- A[:, j] .* Q[:, i])
    end
  end

  return Q, R
end

--// det( A )
-- Calculate the determinant of a matrix
-- Note: A is modified
function det( A )
  assert(getmetatable(A) == mathly_meta, 'det( A ): A must be a mathly matrix.')
  local m, n = size(A)
  if m ~= n then
      print('det(A): A must be square.')
      return 0
  end

  local val = 1 -- by gauss elimination
  for i = 1, n - 1 do
    local maxi = i -- pivoting
    local maxx = math.abs(A[i][i])
    for k = i + 1, n do
      local absx = math.abs(A[k][i])
      if absx > maxx then maxi = k; maxx = absx end
    end
    if maxx < 10*eps then return 0 end -- matrix is not invertible

    if maxi ~= i then -- interchange two rows
      val = - val
      for k = i, n do
        A[i][k], A[maxi][k] = A[maxi][k], A[i][k]
      end
    end
    val = val * A[i][i] -- factor out A[i][i]
    for k = i + 1, n do -- 'normalize' A[i][..] --> {0 ... 0 1 x x x}
      A[i][k] = A[i][k] / A[i][i]
    end
    A[i][i] = 1

    for j = i + 1, n do -- elimination
      if math.abs(A[j][i]) > 10*eps then
        for k = i + 1, n do
          A[j][k] = A[j][k] - A[j][i] * A[i][k]
        end -- A[j][i] = 0 -- not necessary
      end
    end
  end
  return val * A[n][n]
end

--// mathly.concath( ... )
-- Concatenate matrices, horizontal
-- rows have to be the same, e.g.: #m1 == #m2
-- e.g., concath({{1},{2}}, {{2,3,4},{3,4,5}}, {{5,6},{6,7}})
function concath( ... )
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end
  if #args == 0 then return {} end

  local rows = #args[1]
  for i = 2, #args do
    assert(rows == #args[i], "The row numbers are not the same.")
  end

	local mtx = {}
	for i = 1, rows do
		mtx[i] = {}
		for j = 1,#args[1][1] do
			mtx[i][j] = args[1][i][j]
		end

    for k = 2, #args do
    	local offset = #mtx[i]
  		for j = 1, #args[k][1] do
  			mtx[i][j+offset] = args[k][i][j]
  		end
    end
	end
	return setmetatable(mtx, mathly_meta)
end

--// concatv ( ... )
-- Concatenate matrices, vertical
-- columns have to be the same; e.g.: #m1[1] == #m2[1]
-- e.g., concatv({{1,2,3},{2,3,4}}, {{3,4,5}}, {{4,5,6},{5,6,7}})
function concatv( ... )
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end
  if #args == 0 then return {} end

  local columns = #args[1][1]
  for i = 2, #args do
    assert(columns == #args[i][1], "The column numbers are not the same.")
  end

	local mtx = {}
	for i = 1, #args[1] do
		mtx[i] = {}
		for j = 1, #args[1][1] do
			mtx[i][j] = args[1][i][j]
		end
	end
	for k = 2, #args do
  	local offset = #mtx
  	for i = 1, #args[k] do
  		local _i = i + offset
  		mtx[_i] = {}
  		for j = 1, columns do
  			mtx[_i][j] = args[k][i][j]
  		end
  	end
  end
	return setmetatable(mtx, mathly_meta)
end

--// join( ... )
-- merge elements and tables into a single table
-- e.g., join(1, 2, {3, 4}, 5), join(1, {2, {3, 4}}, {5, 6})
function join( ... )
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end

  local tbl = {}
  for i = 1, #args do
    if type(args[i]) == 'table' then
      local x = args[i]
      if type(args[i][1]) == 'table' and #args[i][1] == 1 then
        -- convert a column vector to a table/row vector
        x = flatten(args[i])
      end
      for j = 1, #x do
        tbl[#tbl + 1] = x[j]
      end
    else
      tbl[#tbl + 1] = args[i]
    end
  end

  return tbl
end

--[[
        Set +, -, *, and ^ behaviours
--]]

-- type(m1) == 'table', type(m2) == 'number'
function mathly.numtableadd(m1, m2, op)
  local val = {}
  for i = 1, #m1 do
    if type(m1[i]) == 'table' then
      val[#val + 1] = mathly.numtableadd(m1[i], m2, op)
    else
      if op == '+' then
        val[#val + 1] = m1[i] + m2
      else
        val[#val + 1] = m1[i] - m2
      end
    end
  end
  return val
end

-- Special case: if m1 is a row/column mathly matrix, m2 can be a Lua table of any type.
-- This case saves the trouble of accessing b as b[i] rathern than b[i][1] while doing Ax - b or Ax + b
function mathly.add_sub_shared( m1, m2, op )
  local msg = 'x ' .. op .. ' y: both x and y must be numbers.'
  if type(m1) == 'number' and type(m2) == 'table' then
    return setmetatable(mathly.numtableadd(m2, m1, op), mathly_meta)
  elseif type(m2) == 'number' and type(m1) == 'table' then
    return setmetatable(mathly.numtableadd(m1, m2, op), mathly_meta)
  end

  msg = 'm1 ' .. op .. ' m2: dimensions do not match.'
	local mtx = {}
  local M1 = m1
	local M2 = m2

	if type(m1[1]) == 'table' then
	  if #m1[1] == 1 then -- m1: {{1},{2}, ...}, mathly column vector
	    M2 = flatten(m2)
	    if #M2 == #m1 then
	      for i = 1,#m1 do  M2[i] = { M2[i] } end
	    else
	      error(msg)
	    end
	  elseif #m1 == 1 and #m1[1] == #m2 then -- m1: {{1, 2, ...}}, mathly row vector
	    M2 = { flatten(m2) }
	  elseif type(m2[1]) == 'table' and #m1 == #m2 and #m1[1] == #m2[1] then
	    M2 = m2
	  else
	    error(msg)
	  end
	else -- m1: {1, 2, ...}
	  M1 = { m1 }
	  M2 = { flatten(m2) }
	end

	for i = 1,#M1 do
		local m3i = {}
		mtx[i] = m3i
		for j = 1,#M1[1] do
		  if op == '+' then
			  m3i[j] = M1[i][j] + M2[i][j]
		  else
		    m3i[j] = M1[i][j] - M2[i][j]
		  end
		end
	end
	return setmetatable( mtx, mathly_meta )
end

mathly_meta.__add = function( m1,m2 )
  return mathly.add_sub_shared(m1, m2, '+')
end

mathly_meta.__sub = function( m1,m2 )
  return mathly.add_sub_shared(m1, m2, '-')
end

-- MATLAB: a .* b
-- v1 determines the size and structure of the resulted vector
function mathly.matlabvmul( v1, v2 )
  local v22 = flatten(v2)
	local x = {}
  if type(v1[1]) ~= 'table' then -- v1 = {1, 2, ...}
		for i = 1,#v1 do x[i] = v1[i] * v22[i] end
  else -- v1 = {{1}, {2}, ...}
    for i = 1,#v1 do x[i] = { v1[i][1] * v22[i] } end
  end
  return setmetatable(x, mathly_meta)
end

--// mathly.mul ( A, B )
-- Multiply two matrices; m1 columns must be equal to m2 rows
-- if A and B are row/column vectors, find A .* B as in MATLAB and Julia
-- Special case: A is a mathly matrix, B is any kind of table, for solving Ax = B.
function mathly.mul( m1, m2 )
  if type(m1) == 'number' then
    return mathly.mulnum(m2, m1)
  elseif type(m2) == 'number' then
    return mathly.mulnum(m1, m2)
  end

	assert(getmetatable(m1) == mathly_meta or getmetatable(m2) == mathly_meta,
	       'm1 * m2: m1 or m2 must be a mathly metatable.')
	local mtx = {}
	local M1 = m1
	local M2 = m2
	assert(type(m2) == 'table', 'm1 * m2: m2 must be a table')

  local vmsg = 'v1 * v2: vectors v1 and v2 must be of same size.'
  local mmsg = 'A * B: dimensions do not match.'
	if type(m1[1]) ~= 'table' then -- m1: {1, 2, ...}
		if type(m2[1]) ~= 'table' then -- m2: {1, 2, ... }
			if #m1 == #m2 then
				return mathly.matlabvmul(m1, m2)
			else
				error(vmsg)
			end
		elseif #m1 == #m2 then -- m2: {{1, ...},, ...} --> (1xn) x (nxm)
			M1 = { m1 } -- M2 = m2
		elseif #m2 == 1 and #m2[1] == #m1 then -- mythly{1, 2} gives {{1, 2}}
			return mathly.matlabvmul(m1, m2[1])
		else
			error(mmsg)
		end
	elseif #m1[1] == 1 then -- m1: {{1}, ...}
		if type(m2[1]) ~= 'table' then -- m2: {1, ...} --> (nx1) x (1xm)
			M2 = { m2 } -- M1 = m1
		elseif type(m2[1]) == 'table' and #m2[1] == 1 then -- m2: {{1}, ...}
		  return mathly.matlabvmul(m1, m2)
		elseif #m2 == 1 then -- m2: {{1, ...}} --> (nx1) x (1xm)
			-- M2 = m2; M1 == m1
		else
			error(mmsg)
		end
	elseif #m1[1] == #m2 then -- m1: {{1, ...}, ...}
		if type(m2[1]) ~= 'table' then -- m2: {1, 2, ...} --> (mxn) x (nx1)
		  M2 = {}
		  for i = 1,#m2 do M2[i] = { m2[i] } end
		else
			M2 = m2 -- (mxn) x (nxr)
		end
	elseif #m1 == 1 and #m2 == 1 and #m1[1] == #m2[1] then -- both: {{1, 2, ...}}
	  return mathly.matlabvmul(m1[1], m2[1])
  else
		error(mmsg)
	end

	for i = 1,#M1 do
		mtx[i] = {}
		for j = 1,#M2[1] do
			local num = M1[i][1] * M2[1][j]
			for n = 2,#M1[1] do
				num = num + M1[i][n] * M2[n][j]
			end
			mtx[i][j] = num
		end
	end
	return setmetatable( mtx, mathly_meta )
end

-- Set multiply "*" behaviour
mathly_meta.__mul = function( m1,m2 )
	return mathly.mul( m1,m2 )
end

--// mathly.mulnum ( m1, num )
-- Multiply mathly with a number
-- num may be of type 'number' or 'complex number'
-- strings get converted to complex number, if that fails then to symbol
function mathly.mulnum( m1, num )
	assert(getmetatable(m1) == mathly_meta, 'm1 * m2: m1 or m2 must be a mathly metatable.')
	local mtx = {}
	for i = 1,#m1 do
		if type(m1[1]) == 'table' then
			mtx[i] = {}
			for j = 1,#m1[1] do
				mtx[i][j] = m1[i][j] * num
			end
		else
			mtx[i] = num * m1[i]
		end
	end
	return setmetatable( mtx, mathly_meta )
end

-- Set division "/" behaviour
mathly_meta.__div = function( m1,m2 )
	assert(getmetatable( m1 ) == mathly_meta and type(m2) == 'number',
	       'm1 / m2: m1 must be a mathly matrix while m2 must be a number.')
	return mathly.mul( m1,1/m2 )
end

-- Set unary minus "-" behavior
mathly_meta.__unm = function( mtx )
	return mathly.mulnum( mtx,-1 )
end

-- Power of matrix; mtx^(n)
-- n is a nonnegative integer
-- if m1 is square, m1 ^ n = m1 * m1 * ... * m1; if me1 is row/column vector, m1 ^ n ~ m1 .^ n as in MATLAB
function mathly.pow( m1, n )
	assert(n == math.floor(n) and n >= 0, "A ^ n: n must be a nonnegative integer.")
  local mtx = {}
	if #m1 == 1 then -- row vector, element wise
    for i = 1, #m1[1] do
      mtx[i] = m1[1][i] ^ n
    end
    return setmetatable({mtx}, mathly_meta)
  elseif #m1[1] == 1 then -- column vector
    for i = 1, #m1 do
      mtx[i] = { m1[i][1] ^ n }
    end
  else
  	if n == 0 then return setmetatable(eye( #m1 ), mathly_meta) end
  	mtx = copy( m1 )
  	for i = 2, n	do
  		mtx = mathly.mul( mtx, m1 )
  	end
  end
  return setmetatable(mtx, mathly_meta)
end

--[[
  Set power "^" behaviour
  if opt is any integer number will do mtx^opt (returning nil if answer doesn't exist)
  if opt is 'T' then it will return the transpose of a mathly matrix

  T = 'T' -- reserved by mathly
--]]
mathly_meta.__pow = function( m1, opt )
  if opt == 'T' then
    return setmetatable(transpose( m1 ), mathly_meta)
  else
	  return setmetatable(mathly.pow( m1, opt ), mathly_meta)
  end
end

function mathly.equal( m1, m2 )
  if getmetatable(m1) ~= mathly_meta then
    m1, m2 = m2, m1 -- m1 is a mathly matrix
  end
  if type(m2) ~= 'table' or #m1 ~= #m2 or type(m2[1]) ~= 'table' or #m1[1] ~= #m2[1] then
    return false
  else
    for i = 1, #m1 do
      if type(m2[i]) ~= 'table' or #m2[i] ~= #m1[1] then return false end
      for j = 1, #m1[1] do
        if m1[i][j] ~= m2[i][j] then return false end
      end
    end
  end
  return true
end

-- Set equal "==" behaviour
mathly_meta.__eq = function( ... )
	return mathly.equal( ... )
end

-- Set tostring "tostring( mtx )" behaviour
mathly_meta.__tostring = function( ... )
	return mathly.tostring( ... )
end

--// mathly.tostring ( mtx )
function mathly.tostring( mtx )
	if type(mtx[1]) == 'table' then
    local rowstrs = {}
		for i = 1,#mtx do
			rowstrs[i] = table.concat(map(tostring, mtx[i]), "\t")
		end
		return table.concat(rowstrs, "\n")
  else -- a row vector
    return table.concat(mtx, "\t")
  end
end

--// mathly ( rows [, comlumns [, value]] )
-- set __call behaviour of matrix
-- for mathly( ... ) as mathly.new( ... )
setmetatable( mathly, { __call = function( ... ) return mathly.new( ... ) end } )

-- set __call "mtx( )" behaviour
mathly_meta.__call = function( ... )
	disp( ... )
end

--// __index handling
mathly_meta.__index = {}
for k,v in pairs( mathly ) do
  mathly_meta.__index[k] = v
end


return mathly

--[[

Note: This project was started first right in the downloaded code of the Lua module, matrix.lua, found
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

David Wang, dwang at liberty dot edu, on 12/25/2024

--]]

