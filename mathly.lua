--[[

LUA MODULE

  Mathly - Turning Lua into a Tiny, Free but Powerful MATLAB

DESCRIPTION

  With provided functions, it is much easier and faster to do math,
  especially linear algebra, and plot graphs of functions.

  Part of modules dkjson.lua, http://dkolf.de/dkjson-lua, and plotly.lua,
  https://github.com/kenloen/plotly.lua, is merged into this project
  to reduce dependecies and make it easier for users to download and use
  mathly. Though some changes have been made, full credit belongs to
  the original authors for whom I am grateful.

API and Usage

  List of functions provided in this module:

    all, any, apply, cc, clc, clear, contourplot, copy, cross, det, diag, disp,
    display, dot, expand, eye, findroot, flatten, fliplr, flipud, format, fstr2f,
    fzero, hasindex, horzcat, inv, iseven, isinteger, ismember, isodd, lagrangepoly,
    length, linsolve, linspace, lu, map, match, max, mean, merge, min, namedargs,
    newtonpoly, norm, ones, polynomial, polyval, printf, prod, qr, rand, randi, range,
    remake, repmat, reshape, round, rr, rref, save, seq, size, sort, sprintf, std,
    strcat, submatrix, subtable, sum, tblcat, text, tic, toc, transpose, tt, unique,
    var, vertcat, who, zeros

    dec2bin, dec2hex, dec2oct, bin2dec, bin2hex, bin2oct, oct2bin, oct2dec,
    oct2hex, hex2bin, hex2dec, hex2oct

    arc, circle, line, parametriccurve2d, point, polarcurve2d, polygon, scatter,
    text, wedge; boxplot, freqpolygon, hist, hist1, histfreqpolygon, pareto, pie,
    slopefield (All are graphics objects passed to function 'plot'.)

    plot; plot3d, plotparametriccurve3d, plotparametricsurface3d, plotsphericalsurface3d

    axissquare, axisnotsquare; showaxes, shownotaxes; showxaxis, shownotxaxis;
    showyaxis, shownotyaxis; showgridlines, shownotgridlines;
    showlegend, shownotlegend

  See code and mathly.html.

HOME PAGE

  https://github.com/fdformula/MathlyLua

LICENSE

  Licensed under MIT license and/or the same terms as Lua itself.

  Developers:

    David Wang - original author

--]]
require 'browser-setting'

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
eps = 2.220446049250313e-16  -- machine epsilon
phi = 1.6180339887499        -- golden radio
T = 'T' -- reserved by mathly, transpose of a matrix, A^T

function div(a, d) return a // d end
function mod(a, d) return a % d  end

function  printf(...) io.write(string.format(table.unpack{...})) end
function sprintf(...) return string.format(table.unpack{...}) end

function demathly(x) return setmetatable(x, nil) end -- force x not to be a mathly matrix

function eval(str)
  local stats, val = pcall(load, 'return ' .. str)
  if stats then stats, val = pcall(val) end
  if stats then
    return val
  else
    error('[string "' .. string.sub(val, 17))
  end
end --eval

--// input(prompt, s)
-- s = 's' --> return input as a string; otherwise, evaluate the input expression and return the result
function input(prompt, s)
  local ans
  io.write(prompt)
  ans = io.read()
  if s == 's' then -- no evaluation
    return ans
  else
    return eval(ans)
  end
end

function iseven(x) return x % 2 == 0 end
function isodd(x)  return x % 2 == 1 end

function round(x, dplaces)
  dplaces = dplaces or 0
  local function round1(x)
    local negativeq = false
    if x < 0 then negativeq = true; x = -x end
    if dplaces == 0 then
      x = math.tointeger(math.floor(x + 0.5))
    else
      local tmp = 10 ^ dplaces
      x = math.floor(x * tmp + 0.5) / tmp
    end
    if negativeq then x = -x end
    return x
  end
  if type(x) ~= 'table' then
    return round1(x)
  else
    local tmp = map(round1, x)
    if getmetatable(x) == mathly_meta then
      setmetatable(tmp, mathly_meta)
    end
    return tmp
  end
end -- round

--// _adjust_index(siz, start, stop, normalq)
-- adjust values of indices, start and stop. they must be in the range from 1 to siz. the can be -1, -2, ...
-- if normalq is missing, start <= stop is required
local function _adjust_index(siz, start, stop, normalq)
  start = start or 1
  if start < 0 then start = siz + start + 1 end -- -1, -2, ... --> siz, siz - 1
  if start < 1 or start > siz then error('start = ' .. tostring(start) .. ' is out of range.') end

  stop = stop or siz
  if stop < 0 then stop = siz + stop + 1 end
  if stop < 1 or stop > siz then error('stop = ' .. tostring(stop) .. ' is out of range.') end

  if normalq == nil and stop < start then error('Invalid input, stop < start: '.. tostring(stop) .. ' < ' .. tostring(start) .. '.') end
  return start, stop
end

local function _adjust_index_step(siz, start, stop, step)
  start, stop = _adjust_index(siz, start, stop, false)
  if step == nil then
    if start <= stop then step = 1 else step = -1 end
  end
  if step == 0 or (step > 0 and start > stop) or (step < 0 and start < stop) then
    error('Invalid input, start, stop, step: ' .. tostring(start) .. ', ' .. tostring(stop) .. ', ' .. tostring(step) .. '.')
  end
  return start, stop, step
end

--// function rr(x, i, start, stop)
-- rr(x):                 make x a row vector and return it
-- rr(x, i):              return the ith row of x
-- rr(x, i, start, stop): return submatrix(x, i, start, i, stop), stop defaults to #x[1]
--
-- if i is a list of indice, return rows defined in the list and in order (the latter allows rearrangement and repetition of rows)
--
-- i = -1, last row; i = -2, the row before the last row; ... similar with start and stop
function rr(x, I, start, stop, step)
  if I == nil then
    return setmetatable({ flatten(x) }, mathly_meta) -- convert x to a row vector
  else
    assert(getmetatable(x) == mathly_meta, 'rr(x, i...): x must be a mathly matrix.')
    start, stop, step = _adjust_index_step(#x[1], start, stop, step)
    local rows = {}
    if type(I) ~= 'table' then I = { I } end
    for m = 1, #I do
      local i = I[m]
      local siz = #x
      if i < 0 then i = siz + i + 1 end -- i = -1, -2, ...
      if i > 0 and i <= siz then
        local y = {}
        local k = 1
        for j = start, stop, step do
          y[k] = x[i][j]
          k = k + 1
        end
        rows[m] = y
      else
        error('rr(x, i...): i = ' .. tostring(i) .. ' is out of range.')
      end
    end
    return setmetatable(rows, mathly_meta)
  end
end

--// function cc(x, i, start, stop)
-- cc(x):                 make x a column vector and return it
-- cc(x, i):              return the ith column of x
-- cc(x, i, start, stop): return submatrix(x, start, i, stop, i), stop defaults to #x
--
-- if i is a list of indice, return columns defined in the list and in order (the latter allows rearrangement and repetition of columns)
-- i = -1, last columns; i = -2, the column before the last column; ...
function cc(x, I, start, stop, step)
  if I == nil then
    return setmetatable(map(function(x) return {x} end, flatten(x)), mathly_meta) -- convert x to a column vector
  else
    assert(getmetatable(x) == mathly_meta, 'cc(x, i...): x must be a mathly matrix.')
    start, stop, step = _adjust_index_step(#x, start, stop, step)
    if type(I) ~= 'table' then I = { I } end
    local abs = math.abs
    local cols = mathly(math.ceil((abs(stop - start) + 1) / abs(step)), #I, 0)
    for jj = 1, #I do
      local j = I[jj]
      local siz = #x[1]
      if j < 0 then j = siz + j + 1 end -- j = -1, -2, ...
      if j > 0 and j <= siz then
        local ii = 1
        for i = start, stop, step do
          cols[ii][jj] = x[i][j]
          ii = ii + 1
        end
      else
        error('cc(x, i...): i = ' .. tostring(i) .. ' is out of range.')
      end
    end
    return setmetatable(cols, mathly_meta)
  end
end

-- tt(x, startpos, endpos, step)
-- convert x to a table (columnwisely if its a mathly matrix) or flatten it first
-- and return a slice of it
-- want row wise? see flatten(tbl)
--
-- t or subtable? t converts first, while subtable doesn't.
function tt(x, start, stop, step) -- make x an ordinary table
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

  start, stop, step = _adjust_index_step(#y, start, stop, step)

  local z = {}
  local k = 1
  for i = start, stop, step do
    z[k] = y[i]
    k = k + 1
  end
  return z
end -- tt

local function _max_min_shared( f, x ) -- column wise if x is a matrix
  if type(x) == 'table' then
    if type(x[1]) == 'table' then -- a matrix
      if #x == 1 then return _max_min_shared(f, x[1]) end -- mathly{1, 2} gives {{1,2}}
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
end -- _max_min_shared

function max( x ) return _max_min_shared(math.max, x) end
function min( x ) return _max_min_shared(math.min, x) end

--// function fstr2f(str)
-- convert a MATLAB-style anonymous function in string to a function handle
-- e.g., fstr2f('@(x) x^2 - 2*x + 1') returns an anonymous function, function(x) return x^2 -2*x + 1 end.
function fstr2f(str)
  str = string.gsub(str, '%s+', ' ')
  local head, body = string.match(str, '^%s*@%s*(%(%s*[%w,%s]*%))%s*(.+)%s*$')
  if head ~= nil then
    return eval('function' .. head .. ' return ' .. body .. ' end')
  else
    error('Poor function: ' ..  str .. ". Example: '@(x) 3*x^2 - 5 * sin(x) + 1'")
  end
end

--// map( func, x )
-- applys a function to each atomic entry in a table and keeps the structure of the table
local function _map( func, ... ) -- ~Mathematica
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end

  if type(args[1]) ~= 'table' then
    return func(table.unpack(args))
  else
    local y = {}
    for k, v in pairs(args[1]) do
      local arg = {}
      for j = 1,#args do
        arg[#arg + 1] = args[j][k]
      end

      if type(v) ~= 'table' then
        y[k] = func(table.unpack(arg))
      else
        y[k] = _map(func, table.unpack(arg))
      end
    end
    return y
  end
end -- _map

function map(func, ...)
  if type(func) == 'string' then func = fstr2f(func) end
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
end -- map

--// apply( func, args )
-- calls a function with arguments
function apply( func, args )
  if type(func) == 'string' then func = fstr2f(func) end
  return func(table.unpack(args))
end

--// copy ( x )
-- make a copy of x
function copy( x ) -- for general purpose
  local y = {}
  if type(x) ~= 'table' then
    return x
  else
    for k, v in pairs(x) do
      if type(v) ~= 'table' then
        y[k] = v
      else
        y[k] = copy(v)
      end
    end
    if getmetatable( x ) == mathly_meta then
      return setmetatable(y, mathly_meta)
    else
      return y
    end
  end
end -- copy

--// function unique(tbl)
-- Return the same data as in tbl but with no repetitions.
function unique(tbl)
  if type(tbl) ~= 'table' then return tbl end
  local x = copy(tbl)
  table.sort(x)
  local y
  local abs = math.abs
  if #x > 0 then y = {x[1]} else return {} end
  for i = 2, #x do
    if abs(x[i] - x[i - 1]) > eps then -- not equal
      y[#y + 1] = x[i]
    end
  end
  return y
end -- unique

--// format(fmt)
-- Reset or specify the format of the output of disp(...)
-- fmt:
--   'bank',  2 decimal places
--   'short', 4 decimal places (default)
--   'long', 15 decimal places
local _int_format    = "%12d"   -- 'global' for disp(...)
local _float_format  = "%12.4f" --

local _int_format1   = "%d"     -- 'global' for display(...)
local _float_format1 = "%.4f"   --

local _disp_format   = 'short'  -- 'global'
function format(fmt)
  if fmt == 'long' or fmt == 'bank' then
    _disp_format = fmt
  else
    _disp_format = 'short'
  end
end

--// function all( x, f )
-- x is a table or row/column vector: return 1 if all elements of the table make f(x) true.
-- x is a mathly matrix: return a row vector of 1's and 0's with each element indicating
--   if all of the elements of the corresponding column of the matrix make f(x) true.
--
-- f(x) return true or false (default to: x ~= 0)
--
-- mathlymatrixq? usually, ignore it. if just need yes (1) or no (0), set it to false.
function all( x, f, mathlymatrixq )
  if mathlymatrixq == nil then mathlymatrixq = true end
  if f == nil then
    f = function(x) return math.abs(x) > eps end  -- x ~= 0
  elseif type(f) == 'string' then
    f = fstr2f(f)
  end
  local function traverse(x)
    for i = 1, #x do
      if type(x[i]) == 'table' then
        if traverse(x[i]) == 0 then return 0 end
      elseif not f(x[i]) then return 0 end
    end
    return 1
  end

  if mathlymatrixq then
    if getmetatable(x) == mathly_meta then
      local m, n = size(x)
      if m > 1 and n > 1 then
        local y = zeros(1, #x[1])
        for j = 1, #x[1] do
          local i = 1
          while i <= #x do
            if not f(x[i][j]) then break end
            i = i + 1
          end
          if i > #x then y[j] = 1 end
        end
        return setmetatable(rr(y), mathly_meta)
      end
    end
  end

  if type(x) == 'table' then
    return traverse(x)
  else
    error('all(x, f): x must be a table or mathly matrix.')
  end
end -- all

--// function any( x, f )
-- x is a table or row/column vector: return 1 if there is any element of the table which makes f(x) true.
-- x is a mathly matrix: return a row vector of 1's and 0's with each element indicating
--   if there is any element of the corresponding column of the matrix which makes f(x) true.
--
-- f(x) return true or false (default to: x ~= 0)
--
-- mathlymatrixq? usually, ignore it. if just need yes (1) or no (0), set it to false.
function any( x, f, mathlymatrixq )
  if mathlymatrixq == nil then mathlymatrixq = true end
  if f == nil then
    f = function(x) return math.abs(x) > eps end  -- x ~= 0
  elseif type(f) == 'string' then
    f = fstr2f(f)
  end
  local function traverse(x)
    for i = 1, #x do
      if type(x[i]) == 'table' then
        if traverse(x[i]) == 1 then return 1 end
      elseif f(x[i]) then return 1 end
    end
    return 0
  end

  if mathlymatrixq then
    if getmetatable(x) == mathly_meta then
      local m, n = size(x)
      if m > 1 and n > 1 then
        local y = zeros(1, #x[1])
        for j = 1, #x[1] do
          for i = 1, #x do
            if f(x[i][j]) then y[j] = 1; break end
          end
        end
        return setmetatable(rr(y), mathly_meta)
      end
    end
  end

  if type(x) == 'table' then
    return traverse(x)
  else
    error('any(x, f): x must be a table or mathly matrix.')
  end
end -- any

--// function match( A, f )
-- Return elements of A that satisfy specified conditions. (f defaults to A).
--
-- If f is a boolean function, return 1) a table of elements of A (rowwisely) that satisfy
--   f(x) and 2) a table of elements of A with those elements replaced by 0 when
--   they fail to satisfy f(x).
--
-- If f is a table/matrix, return 1) a table of elements of A (rowwisely) that correspond
-- to nonzero elements of f and 2) A with entries replaced with corresponding zero elements of f.
--
-- note: 'select' seems to be a better name . however, Lua already uses it.
function match( A, f )
  if type(A) ~= 'table' then error('match(A, ...): A must be a table.') end
  if type(f) == 'string' then f = fstr2f(f) end
  local B
  local abs = math.abs
  if f == nil then
    B = A
  elseif type(f) == 'function' then
    B = map(function(x) if f(x) then return x else return 0 end end, A)
  elseif type(f) == 'table' then
    B = map(function(x, y) if abs(x) > 10*eps then return y else return 0 end end, f, A)
  else
    error('match(A, f): f must be a boolean function or a table.')
  end

  local X = {}
  local k = 1
  map(function(x, y) if abs(x) > 10*eps then X[k] = y; k = k + 1 end end, B, A)
  return X, B
end -- match

local function _dec2bho(x, title, f)
  if isinteger(x) then
    return f(x)
  elseif type(x) == 'table' then
    local metaq = getmetatable(x) == mathly_meta
    if metaq then demathly(x) end
    local y = map(f, x)
    if metaq then setmetatable(x, mathly_meta) end
    return y
  else
    error(title .. '(x): x must be an integer or a table of integers.')
  end
end -- _dec2bho

--// calculate the (64-bit) binary expansion of signed decimal integer x
function dec2bin(x)
  local function _dec2bin(x)
    local str = ''
    while x ~= 0 do
      str = (x & 1) .. str
      x = x >> 1
    end
    if str == '' then str = '0' end
    return str
  end
  return _dec2bho(x, 'dec2bin', _dec2bin)
end -- dec2bin

--// calculate the hexadecimal expansion of signed decimal integer x
function dec2hex(x) return _dec2bho(x, 'dec2hex', function(x) return sprintf('%x', x) end) end

--// calculate the octal expansion of signed decimal integer x
function dec2oct(x) return _dec2bho(x, 'dec2oct', function(x) return sprintf('%o', x) end) end

--// convert unsigned binary/octal/hexadecimal integer x to decimal integer
local function _bho2dec(x, title, base)
  local function __bho2dec(x)
    local val = 0
    x = string.lower(x) -- unnecessary in Lua 5.4.6
    for i = 1, #x do
      local v = string.sub(x, i, i)
      if v >= '0' and v <= '9' then
        v = string.byte(v) - string.byte('0')
        if base == 2 and v > 1 then
          error(x .. ': invalid binary number.')
        elseif base == 8 and v > 7 then
          error(x .. ': invalid octal number.')
        end
      elseif base == 16 then
        if v >= 'a' and v <= 'f' then
          v = string.byte(v) - string.byte('a') + 10
        else
          error(x .. ': invalid hexadecimal number.')
        end
      else
        error(x .. ': invalid number.')
      end
      val = val * base + v -- Lua 5.4.6, 1 + '67' = 68
    end
    return val
  end

  if type(x) == 'string' then
    return __bho2dec(x)
  elseif type(x) == 'table' then
    return map(__bho2dec, x)
  else
    error(title .. '(x): x must be a string or a table of strings.')
  end
end -- _bho2dec

function bin2dec(x) return _bho2dec(x, 'bin2dec', 2) end
function oct2dec(x) return _bho2dec(x, 'oct2dec', 8) end
function hex2dec(x) return _bho2dec(x, 'hex2dec', 16) end

function bin2oct(x) return dec2oct(bin2dec(x)) end
function bin2hex(x) return dec2hex(bin2dec(x)) end
function oct2bin(x) return dec2bin(oct2dec(x)) end
function oct2hex(x) return dec2hex(oct2dec(x)) end
function hex2bin(x) return dec2bin(hex2dec(x)) end
function hex2oct(x) return dec2oct(hex2dec(x)) end

--// calculate the greatest common divisor
function gcd(x, y)
  local function __gcd(x, y) -- euclidean algorithm
    while y ~= 0 do
      x, y = y, x % y
    end
    return x
  end
  local function _gcd(x, y)
    assert(isinteger(x) and x >= 0 and isinteger(y) and y >= 0,
           'gcd(x, y): x and y must be nonnegative integers.')
    if x < y then x, y = y, x end
    return __gcd(x, y)
  end
  if type(x) == 'number' then
    return _gcd(x, y)
  elseif type(x) == 'table' then
    return map(_gcd, x, y)
  else
    error('gcd(x, y): x and y must be nonnegative integers or tables of nonnegative integers with the same structure.')
  end
end -- gcd

--// calculate b^n mod m
function powermod(b, n, m)
  assert(isinteger(b) and b >= 0 and
         isinteger(n) and n >= 0 and
         isinteger(m) and m > 0,
         'powermod(b, n, m): b, n, and m must be nonnegative integers with m > 0.')
  if b == 0 or m == 1 then return 0 end
  local x = 1
  local power = b % m
  local a = dec2bin(n) --  binary modular exponentiation
  for i = #a, 1, -1 do
    if string.sub(a, i, i) == '1' then x = (x * power) % m end
    power = (power * power) % m
  end
  return x
end -- powermod

--// function _largest_width_dplaces(tbl)
-- find the largest width of integers/strings and number of decimal places
-- -3.14 --> 1, 2; 123 --> 3, 0
-- only format numbers in tables
local function _largest_width_dplaces(tbl) -- works with strings, numbers, and table of tables
  if type(tbl ) ~= 'table' then tbl = { tbl} end
  local width, dplaces = 0, 0
  local num, w, d
  for i = 1, #tbl do
    if type(tbl[i]) == 'table' then
      w, d = _largest_width_dplaces(tbl[i])
      if w > width then width = w end
      if d > dplaces then dplaces = d end
    elseif type(tbl[i]) ~= 'string' then
      num = math.abs(tbl[i]) -- ignore sign
      if type(num) == 'integer' then
        w = #tostring(num)
      else
        w = #tostring(math.floor(tbl[i]))
        d = #tostring(num) - w -- decimal point counted
        if d > dplaces then dplaces = d end
      end
      if w > width then width = w end
    end
  end
  return width, dplaces
end -- _largest_width_dplaces

--[[ Lua 5.4.6
The largest number print or io.write prints each digit is ±9223372036854775807,
otherwise, ±9.2233720368548e+18 is printed ---]]

local function _set_disp_format( mtx ) -- mtx must be a mathly matrix
  local iwidth, dplaces, dispwidth
  iwidth, dplaces = _largest_width_dplaces(mtx)
  local allintq = dplaces == 0

  if _disp_format == 'long' then
    dplaces = 13
  elseif _disp_format == 'short' then
    dplaces = 4
  else -- 'bank'
    dplaces = 2
  end

  if (allintq and iwidth > 12) or (not allintq and iwidth + dplaces > 16) then -- 1.2345e+3
    dispwidth = dplaces + 7 -- -1.2345e+10
    _float_format   = string.format('%%%d.%de', dispwidth, dplaces)
    _float_format1  = string.format('%%.%de', dplaces)
    if iwidth < dispwidth then -- 1 sign
      if allintq then
        _int_format = string.format('%%%dd', iwidth)
      else
        _int_format = string.format('%%%dd', dispwidth)
      end
      _int_format1  = '%d'
    else
      _int_format   = _float_format
      _int_format1  = _float_format1
    end
    return
  end

  if allintq then
    dispwidth = iwidth + 1 -- 1 sign
  else
    dispwidth = iwidth + dplaces + 2 -- 1? 1 sign
  end
  _float_format  = string.format('%%%d.%df', dispwidth, dplaces)
  _float_format1 = string.format('%%.%df', dplaces)
  _int_format = string.format('%%%dd', dispwidth)
  _int_format1   = '%d'
end -- _set_disp_format

local function _tostring(x)
  if isinteger(x) then
    return string.format(_int_format, x)
  else
    return string.format(_float_format, x)
  end
end

local function _tostring1(x)
  if type(x) == 'string' then
    return x
  elseif isinteger(x) then
    return string.format(_int_format1, x)
  else
    return string.format(_float_format1, x)
  end
end

--// function who()
-- list all user defined variables (some may be defined by some loaded modules)
-- if a list of variables are needed by other code, pass false to it: who(false)
function who(usercalledq) -- ~R
  if usercalledq == nil then usercalledq = true end
  local list = {}
  for k,v in pairs(_G) do
    if type(v) ~= 'function' then
      if not ismember(k,
        {'e', 'eps', 'pi', 'phi', 'T', 'mathly', 'm', '_G', 'coroutine', 'utf8',
         '_VERSION', 'io', 'package', 'os', 'arg', 'debug', 'string', 'table', 'math',
         'linux_browser', 'mac_browser', 'win_browser', 'plotly_engine',
         'tmp_plot_html_file'}) then
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
end -- who

--// function _vartostring_lua( x, firstq, titleq, printnowq )
-- generate the string version of a variable y starting with 'y = '
-- firstq    -- print ',' or not before printing an entry
-- titleq    -- for save(...)
-- printnowq -- for display(x) with large matrices
local function _vartostring_lua( x, firstq, titleq, printnowq ) -- print x, for general purpose
  if titleq == nil then titleq = true end
  if firstq == nil then firstq = true end

  local function print1(x)
    local typ = type(x)
    local s = ''
    if typ == 'string' then
      s = "'" .. x .. "'"
    elseif typ == 'boolean' then
      if x then s = 'true' else s = 'false' end
    elseif typ == 'number' then
      s = tostring(x)
    end
    return s
  end

  local str = ''
  if titleq then
    str = str .. x .. ' = '
    x = load('return ' .. x)()
  end
  local s = print1(x)
  if #s > 0 then
    if not firstq then str = str .. ', ' end
    str = str .. s
    if printnowq then printf(str); str = '' end
  else
    str = str .. '{'; firstq = true
    local i = 1
    for k, v in pairs(x) do
      if not firstq then str = str .. ', ' end
      if type(k) == 'string' then
        str = str .. k .. ' = '
      else -- type(k) is an index
        while k > i do -- x = {1, 2, 3}; x[2] = nil -- Lua 5.4.6, x[3] == 3, #x == 3
          str = str .. 'nil, '; i = i + 1
        end
      end
      local s = print1(v)
      if #s > 0 then
        str = str .. s
      else
        if printnowq then printf(str); str = '' end
        str = str .. _vartostring_lua(v, firstq, false)
      end
      if printnowq then printf(str); str = '' end
      firstq = false
      i = i + 1
    end
    str = str .. '}'
  end
  if titleq then str = str .. '\n\n' end
  return str
end -- _vartostring_lua

--// disp( A )
-- print a mathly matrix while display(x) prints a table with its structure
-- disp({{1, 2, 3, 4}, {2, -3, 4, 5}, {3, 4, -5, 6}})
function disp( A )
  if getmetatable(A) == mathly_meta then
    _set_disp_format(A)
    local rows, columns = size(A)
    for i = 1, rows do
      io.write('\n')
      for j = 1, columns do
        io.write(_tostring(A[i][j]), ' ')
      end
    end
    io.write('\n\n')
  else
    display(A)
  end
end -- disp

--// display( x )
-- print a table with its structure while disp(x) prints a matrix
-- display({1, 2, {3, 4, opt = {height = 3, width = 5}, 6, 'string', false}, 7, 8})
function display( x ) -- print x, for general purpose
  if x == nil then print('nil'); return end
  print(_vartostring_lua(x, nil, false, true))
end

local function _ismatrixq(x)
  if type(x) ~= 'table' or type(x[1]) ~= 'table' then return false end
  local n = #x[1]
  for i = 1, #x do
    if type(x[i]) ~= 'table' or #x[i] ~= n then return false end
    for j = 1, #x[i] do
      if type(x[i][j]) ~= 'number' then return false end
    end
  end
  return true
end -- _ismatrixq

-- generate the string version of MATLAB variable y starting with 'y ='
local function _vartostring_matlab( x )
  local s = _vartostring_lua(x, nil, true)
  x = load('return ' .. x)()
  if getmetatable(x) == mathly_meta or _ismatrixq(x) then -- save matrices
    s = string.gsub(s, "}, {", ";\n")
    s = string.gsub(s, "{{", "[")
    s = string.gsub(s, "}}", "]")
  elseif type(x) == 'table' then -- flatten a table. matlab: [1,2,[5,6,[7,[8]]]] --> [1, 2, 5, 6, 7, 8]
    s = string.gsub(s, "}+", "}")
    s = string.gsub(s, "{+", "{")
    s = string.gsub(s, "}, {", ", ")
    s = string.gsub(s, ", {", ", ")
    s = string.gsub(s, "}, ", ", ")
    s = string.gsub(s, "{", "[")
    s = string.gsub(s, "}", "]")
  end
  return s
end -- _vartostring_matlab

--// function save(fname, ...)
-- save variables and their values to a Lua or MATLAB script file
function save(fname, ...)
  local vars = {}
  for _, v in pairs{...} do
    if type(v) == 'table' then
      for i = 1, #v do vars[#vars + 1] = v[i] end
    else
      vars[#vars + 1] = v
    end
  end
  if #vars == 0 then vars = who(false) end

  local matlabq = string.lower(string.sub(fname, #fname - 1)) == '.m'
  local file = io.open(fname, "w")
  if file ~= nil then
    local stamp = ' mathly saved on ' .. os.date() .. '\n\n'
    if not matlabq then
      file:write('--' .. stamp .. "mathly = require('mathly')\n\n")
    else
      file:write('%' .. stamp)
    end
    for i = 1, #vars do
      local x = load('return ' .. vars[i])()
      if x == nil then
        print(vars[i] .. ' is undefined.')
      else
        if matlabq then
          file:write(_vartostring_matlab(vars[i]))
        else
          file:write(_vartostring_lua(vars[i], nil, true))
          if getmetatable(x) == mathly_meta then
            file:write(vars[i] .. ' = mathly(' .. vars[i] .. ')\n\n')
          end
        end
      end
    end
    file:close()
  else
    error(string.format("Failed to create %s. The device might not be writable.", fname))
  end
end -- save

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
  _axis_equalq       = false
  _xaxis_visibleq    = true
  _yaxis_visibleq    = true
  _gridline_visibleq = true
  _showlegendq       = false
end -- clear

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
end -- seq

--// linspace( from, to, len )
-- generates an evenly spaced sequence/table of 'len' numbers on the interval [from, to]. same as seq(...).
function linspace( from, to, len )
  len = len or 100
  assert(len > 0, 'linspace( from, to, len ): len must be positive.')
  if from > to then from, to = to, from end
  return seq(from, to, len)
end

--// prod( x )
-- calculates the product of all elements of a table
-- calculates the product of all elements of each column in a matrix
function prod( x )
  if type(x) == 'number' then
    return x
  elseif type(x) == 'table' then
    if type(x[1]) == 'table' then -- a "matrix"
      local prods = {}  -- column wise
      for j = 1,#x[1] do
        prods[j] = 1
        for i = 1,#x do
          prods[j] = prods[j] * x[i][j]
        end
      end
      return setmetatable(rr(prods), mathly_meta)
    else
      local s = 1
      for i = 1,#x do s = s * x[i] end
      return s
    end
  else
    return 0
  end
end -- prod

--// sum( x )
-- calculates the sum of all elements of a table
-- calculates the sum of all elements of each column in a matrix
function sum( x )
  if type(x) == 'number' then
    return x
  elseif type(x) == 'table' then
    if type(x[1]) == 'table' then -- a "matrix"
      if #x == 1 then -- {{1, 2, ...}} b/c mathly{1, 2, 3} gives {{1, 2, 3}}
         return sum(x[1])
      end
      local sums = {}  -- column wise
      for j = 1,#x[1] do
        sums[j] = 0
        for i = 1,#x do
          sums[j] = sums[j] + x[i][j]
        end
      end
      if #sums == 1 then
        return sums[1]
      else
        return setmetatable(rr(sums), mathly_meta)
      end
    else
      local s = 0
      for i = 1,#x do s = s + x[i] end
      return s
    end
  else
    return 0
  end
end -- sum

-- // function strcat(s1, s2, ...)
function strcat(...)
  local s = ''
  for _, v in pairs{...} do
    if type(v) == 'string' then
      s = s .. v
    elseif type(v) == 'number' then
      s = s .. string.char(v)
    elseif type(v) == 'table' then
      s = s .. strcat(table.unpack(v))
    end
  end
  return s
end -- strcat

--// mean( x )
-- calculates the mean of all elements of a table
-- calculates the mean of all elements of each column in a matrix
function mean( x )
  if type(x) == 'number' then
    return x
  elseif type(x) == 'string' then
    return mean(table.pack(string.byte(x, 1, #x)))
  elseif type(x) == 'table' then
    if type(x[1]) == 'number' then
      local s = 0
      for i = 1, #x do s = s + x[i] end
      return s / #x
    elseif type(x[1]) == 'string' then
      return mean(strcat(table.unpack(x)))
    else
      assert(getmetatable(x) == mathly_meta, 'mean(A, ...): A must be a mathly matrix')
      local m, n = size(x)
      if m == 1 then
        return mean(x[1])
      elseif n == 1 then
        return mean(flatten(x))
      end

      local means = {}  -- column wise
      for j = 1, n do
        means[j] = 0
        for i = 1, m do
          means[j] = means[j] + x[i][j]
        end
        means[j] = means[j] / #x
      end
      return setmetatable(rr(means), mathly_meta)
    end
  end
end -- mean

local function _stdvar( x, opt, sqrtq )
  opt = opt or 0
  if type(x) == 'number' then
    return 0
  elseif type(x) == 'table' then
    if type(x[1]) == 'number' then
      local avg = mean(x)
      local s = sum((rr(x) - avg) ^ 2)
      if opt == 0 then
        s = s / (#x - 1)
      else
        s = s / #x
      end
      if sqrtq then s = math.sqrt(s) end
      return s
    else -- a "matrix"
      assert(getmetatable(x) == mathly_meta, 'std(x): x should be a mathly matrix here')
      local m, n = size(x)
      if m == 1 then
        return _stdvar(x[1], opt, sqrtq)
      elseif n == 1 then
        return _stdvar(flatten(x), opt, sqrtq)
      end

      local s = {}  --  column wise
      for j = 1, n do
        local avg = mean(submatrix(x, 1, j, #x, j))
        s[j] = 0
        for i = 1, m do
          s[j] = s[j] + (x[i][j] - avg)^2
        end
        if opt == 0 then
          s[j] = s[j] / (m - 1)
        else
          s[j] = s[j] / m
        end
        if sqrtq then s[j] = math.sqrt(s[j]) end
      end
      return setmetatable(rr(s), mathly_meta)
    end
  else
    error('std(x): x must be a table or matrix of numbers.')
  end
end -- _stdvar

--// std( x, opt )
--// var( x, opt )
-- calculates the standard deviation (or variance) of all elements of a table
-- calculates the standard deviation (or variance) of all elements of each column in a matrix
--
-- if opt = 0 (default), find the standard deviation (or variance) of a population
-- otherwise, find that of a sample
function std( x, opt ) return _stdvar(x, opt, true) end
function var( x, opt ) return _stdvar(x, opt, false) end

--// dot( a, b )
-- calculates the dot/inner product if two vectors
function dot( a, b )
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
end -- dot

--// dot( m1, m2 )
-- calculates the dot/inner product if two vectors
function cross( a, b ) -- Mathematica
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
end -- cross

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
end -- range

--// find and return the zero/root of function f on specified interval
function fzero(f, intv, tol) -- matlab
  if type(f) == 'string' then f = fstr2f(f) end
  if type(intv) == 'number' then intv = {intv - 1, intv + 1} end
  if type(f) ~= 'function' or type(intv) ~= 'table' then
    error('fzero(f, interval): f must be a function, and interval must be specified.')
  end

  local a, b = intv[1], intv[2]
  if b < a then a, b = b, a end
  local fa = f(a)
  if fa * f(b) > 0 then
    error('fzero(f, {a, b} ...): f(x) must have different signs at x=a and x=b.')
  end

  tol = tol or eps
  if tol < 0 then tol = -tol end
  local mid, fmid
  repeat
    mid = (a + b) / 2; fmid = f(mid)
    if fa * fmid > 0 then
      a = mid; fa = fmid
    else
      b = mid
    end
  until math.abs(fmid) < eps or b - a < tol
  return mid
end -- fzero

function findroot(f, i, t) return fzero(f, i, t) end -- mathematica

--// for lagrangepoly(...), newtonpoly(...), polynomial(...), and scatter(...)
local function _converse_poly_input(data) -- {{x1, y1}, {x2, y2}, ...}
  local x, y = {}, {}
  if type(data) == 'table' and type(data[1]) == 'table' then
    for i = 1, #data do
      x[i] = data[i][1]
      y[i] = data[i][2]
    end
  end
  return x, y
end -- _converse_poly_input

--// lagrangepoly(x, y, xx)
-- return the Lagrange function or the value(s) of the Lagrange function defined by data x and y, tables of numbers
--
-- if xx is provided, return the value(s) of the Lagrange polynomial for data (x, y)'s
-- otherwise, return the string of the Lagrange polynomial for data (x, y)'s, e.g, 'function f(x) return -3*(x - 2) + 4*(x - 1) end'
function lagrangepoly(x, y, xx)
  local X, Y = _converse_poly_input(x)
  if #X ~= 0 then xx = y; x, y = X, Y end
  assert(type(x) == 'table' and type(y) == 'table' and #x == #y, 'lagrangepoly(x, y ...): x and y must be tables of the same size.')
  local coefs = {}
  local k = 1
  local abs = math.abs -- it's faster to access to local variables
  for i = 1, #x do
    local tmp = y[i]
    if abs(tmp) > 10*eps then -- tmp ~= 0
      for j = 1, #x do
        if j ~= i then
          tmp = tmp / (x[i] - x[j])
        end
      end
    else
      tmp = 0
    end
    coefs[k] = tmp; k = k + 1
  end

  local str = ''
  local non1stq = false
  for i = 1, #x do
    if coefs[i] ~= 0 then
      local op = ' + '
      local coef = coefs[i]
      if abs(coef) > 10*eps then
         if coef < 0 then
          if non1stq then str = str .. ' - ' else str = str .. ' -' end
          coef = -coef
        else
          if non1stq then str = str .. ' + ' end
        end
        if abs(coef - 1) > 10*eps then str = str .. tostring(coef) .. '*' end
        non1stq = true
        local firstq = true
        for j = 1, #x do
          if j ~= i then
            if not firstq then str = str .. '*' end
            if abs(x[j]) > 10*eps then
              if x[j] > 0 then
                str = str .. '(x - ' .. tostring(x[j]) .. ')'
              else
                str = str .. '(x + ' .. tostring(-x[j]) .. ')'
              end
            else
              str = str .. 'x'
            end
            firstq = false
          end
        end
      end
    end
  end
  if xx == nil then return str end
  load('function _lagRaNgEtMp(x) return ' .. str .. ' end')()
  local tmp = map(_lagRaNgEtMp, xx) -- evaluate the polynomial at points xx
  _lagRaNgEtMp = nil -- delete it
  return tmp
end -- lagrangepoly

--// function newtonpoly(x, y, xx)
-- if xx is provided, return the value(s) of the Newton interpolating polynomial for data (x, y)'s;
-- otherwise, return the polynomial, e.g, 'function f(x) return -3*(x - 1) + 4*(x - 1)*(x-2) end'
function newtonpoly(x, y, xx)
  local X, Y = _converse_poly_input(x)
  if #X ~= 0 then xx = y; x, y = X, Y end
  assert(type(x) == 'table' and type(y) == 'table' and #x == #y, 'newtonpoly(x, y ...): x and y must be tables of the same size.')

  local n = length(x)
  local a = zeros(1, n)

  -- calculate coefs a(i) as in a1 + a2(x -x1) + a3(x-x1)(x-x2) + ... + an(x-x1)...
  a[1] = y[1]
  local f = copy(y)
  for column = 2, n do
    -- calculate a(i) and update fval
    local row = 1
    for i = column, n do
      f[row] = (f[row + 1] - f[row]) / (x[row + column - 1] - x[row])
      row = row + 1
    end
    a[column] = f[1]
  end

  -- prepare the string of the polynomial: a1 + a2(x -x1) + a3(x-x1)(x-x2) + ... + an(x-x1)...
  local str = ''
  local abs = math.abs
  for i = 1, n do -- coef a[i]
    local skipq = false -- Lua 5.4.6 doesn't provide 'continue'
    if i == 1 then
      str = str .. tostring(a[i]) -- sprintf("%g", a[i])
    else
      if abs(a[i]) < 10*eps then -- a[i] = 0
        skipq = true
      elseif a[i] > 0 then
        str = str .. ' + '
        if abs(a[i] - 1) > 10*eps then -- don't output 1
          str = str .. tostring(a[i]) .. '*'
        end
      else
        str = str .. ' - '
        if abs(a[i] + 1) > 10*eps then -- don't output 1
          str = str .. tostring(-a[i]) .. '*'
        end
      end
    end

    if not skipq then -- skip terms with coef 0
      local non1stq = false
      for j = 1, i - 1 do
        if non1stq then str = str .. '*' end
        if abs(x[j]) < 10*eps then -- x = 0
          str = str .. "x"
        elseif x[j] > 0 then
          str = str .. '(x - ' .. tostring(x[j]) .. ')' -- sprintf("(x - %g)", x[j])
        else
          str = str .. '(x + ' .. tostring(-x[j]) .. ')'
        end
        non1stq = true
      end
    end
  end
  if xx == nil then return str end
  load('function _newTonTmP(x) return ' .. str .. ' end')()
  local tmp = map(_newTonTmP, xx) -- evaluate the polynomial at points xx
  _newTonTmP = nil -- delete it
  return tmp
end -- newtonpoly

--// polynomial(x, y, xx)
-- if xx is provided, return the value(s) of a polynomial, defined by data (x, y)'s, at xx;
-- otherwise, return the string and the coefficeints of the polynomial
function polynomial(x, y, xx)
  local X, Y = _converse_poly_input(x)
  if #X ~= 0 then xx = y; x, y = X, Y end
  assert(type(x) == 'table' and type(y) == 'table' and #x == #y and #x > 1,
         'polynomial(x, y...): x and y must be tables of the same size (≥ 2).')
  local A = {}
  for i = 1, #x do
    A[i] = {}
    for j = 1, #x-2 do
      A[i][j] = x[i] ^ (#x - j)
    end
    A[i][#x - 1] = x[i]
    A[i][#x] = 1
  end
  local B = tt(linsolve(mathly(A), y)) -- coefs of polynomial

  local str = ''
  local not1stq = false
  local abs = math.abs
  for i = 1, #B do
    if abs(B[i]) > 10*eps then -- B[i] ~= 0
      local coef = B[i]
      if coef < 0 then
        if not1stq then str =  str .. ' - ' else str = str .. ' -' end
        coef = -coef
      else
        if not1stq then str = str .. ' + ' end
      end
      if abs(coef - 1) < eps then -- coef == 1
        if i == #B then coef = '1' else coef = '' end -- no 1*x^n
      else
        coef = tostring(coef)
        if i ~= #B then coef = coef .. '*' end
      end
      if i == #B then
        str = str .. coef
      elseif i == #B - 1 then
        str = str .. coef .. 'x'
      else
        str = str .. coef .. 'x^' .. tostring(#B - i)
      end
      not1stq = true
    end
  end
  if xx == nil then return str, B end
  load('function _polynOmiAlTmP(x) return ' .. str .. ' end')()
  local tmp = map(_polynOmiAlTmP, xx)
  _polynOmiAlTmP = nil -- delete it
  return tmp
end -- polynomial

--// polyval( p, x )
-- evaluate a polynomial p at x
-- example: polyval({6, -3, 4}, 5) -- evalue 6 x^2 - 3 x + 4 at x = 5
function polyval( P, x )
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
end -- polyval

--// norm( v )
-- calculate the Euclidean norm of a vector
function norm( v )
  return math.sqrt(dot(v, v))
end

-- https://en.wikipedia.org/wiki/Box-Muller_transform
_next_gaussian_rand = nil -- reset
local function _gaussian_rand()
  if _next_gaussian_rand ~= nil then
    local tmp = _next_gaussian_rand
    _next_gaussian_rand = nil
    return tmp
  end

  local theta, rho, x, y
  theta = 2 * pi * math.random()
  rho = math.sqrt(-2 * math.log(1 - math.random()))
  x = rho * math.cos(theta)
  y = rho * math.sin(theta)
  _next_gaussian_rand = y
  return x
end -- _gaussian_rand

--// _create_table( r, c, val )
-- generates a table of r subtables of which each has c elements, with each element equal to val
-- if c == nil, c = r;
-- if r == 1 or c == 1, return a simple table (so that it can be accessed like a[i] as in MATLAB)
-- if val == nil, it is a random number.
local function _create_table( row, col, val, metaq )
  if metaq == nil then metaq = false end
  local x = {}
  local function f()
    if val == nil or val == 'random' then
      return math.random() -- math.randomseed(os.time()) -- keep generating same seq? Lua 5.4.6
    elseif val == 'gaussian' then
      return _gaussian_rand()
    else
      return val
    end
  end
  if col == nil then col = row end
  for i = 1,row do
    x[i] = {}
    for j = 1,col do
      x[i][j] = f()
    end
  end
  if row == 1 and not metaq then
    return x[1]
  else
    return setmetatable(x, mathly_meta)
  end
end -- _create_table

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
  return _create_table(rows, columns, value, true)
end -- mathly:new

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
end -- eye

--// ones( r, c )
-- generates a table of r subtables of which each has c elements, with each element equal to 1
-- if c == nil, c = r.
function ones( row, col ) return _create_table(row, col, 1) end

-- generates a table of r subtables of which each has c elements, with each element equal to 0
-- if c == nil, c = r.
function zeros( row, col ) return _create_table(row, col, 0) end

--// rand( r, c )
-- generates a table of r subtables of which each has c elements, with each element equal to a random number
-- if c == nil, c = r.
function rand( row, col ) return _create_table(row, col, 'random') end

--// function randn( row, col, mu, sigma )
-- return a matrix with normally distributed random numbers
-- mu and sigma default to 0 and 1, respectively
function randn( row, col, mu, sigma )
  mu = mu or 0
  sigma = sigma or 1
  _next_gaussian_rand = nil -- 'global', reset
  local x = _create_table(row, col, 'gaussian')
  if mu == 0 and sigma == 1 then
    return x
  else
    return map(function(x) return mu + sigma * x end, x)
  end
end -- randn

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
end -- randi

--// tic()
-- starts a time stamp to measure elapsed time
local elapsed_time = nil
function tic() elapsed_time = os.clock() end

--// toc()
-- prints elapsed time from last calling tic() if no values are passed to it;
-- returns elapsed time from last calling tic() if any none-nil value is passed to it.
function toc(print_not)
  if elapsed_time == nil then
    print("Please call tic() first.")
    if print_not ~= nil then return 0 end
  end
  local tmp = os.clock() - elapsed_time
  if print_not == nil then
    print(string.format("%.3f secs.", tmp))
  else
    return tmp
  end
end -- toc

--// flatten( tbl )
-- removes the structure of a table and returns the resulted table.
-- if tbl is a mathly matrix, the result is row wise (rather than column wise)
-- want column wise? use tt(tbl)
--
-- flatten({{1},{2,3}}) returns {1, 2, 3}
-- flatten({1,{2,3}}) returns {1, 2, 3}
function flatten(x)
  local y = {}
  local j = 1
  local function flat(x)
    if type(x) == 'table' then
      for k, v in pairs(x) do
        if type(v) == 'table' then
          flat(v)
        elseif v ~= nil then
          y[j] = v; j = j + 1
        end
      end
    elseif x ~= nil then
      y[j] = x; j = j + 1
    end
  end
  flat(x)
  return y
end -- flatten

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
end -- hasindex

local function _hasanyindex(tbl, indice)
  for i = 1, #indice do
    if hasindex(tbl, indice[i]) then return true end
  end
  return false
end

function isinteger( x ) return math.type(x) == 'integer' end

--// function ismember( x, v )
-- return true if x is an entry of a vector, e.g., ismember(5, {1,2,3,4,5,6}),
-- ismember('are', {'We', 'are', 'the', 'world'})
function ismember( x, v )
  for _, val in pairs(v) do
    if x == val then return true end
  end
  return false
end

local _vecfield_annotations = nil
local __layout = {}

--// function plot(...)
-- plot the graphs of functions in a way like in MATLAB with more features
local plotly = {}
function plot(...)
  _3d_plotq = false
  __layout = {}

  local args = {}
  local x_start = nil -- range of x for a plot
  local x_stop
  local adjustxrangeq = false
  local traces = {}
  local layout_arg = {}
  for _, v in pairs{...} do
    if type(v) == 'function' then
      args[#args + 1] = v
      adjustxrangeq = true
      goto endfor
    elseif type(v) == 'string' and string.sub(v, 1, 1) == '@' then -- @ is followed by expr in terms of x
      args[#args + 1] = fstr2f(v)
      adjustxrangeq = true
      goto endfor
    end

    if type(v) == 'table' then
      if v[1] == 'pareto' then
        for i = 1, #v[#v] do
          traces[#traces + 1] = v[#v][i][2]
        end
        v[#v] = nil
        v[1] = 'graph'
      end

      if v[1] == 'text' then -- text graph object: {'text', trace}
        traces[#traces + 1] = v[2]
      elseif v[1] == 'contour' then -- contourplot graph object: {'contour', x, y, z}
        local trace = {type = 'contour', x = v[2], y = v[3], z = v[4]}
        for k, v in pairs(v[5]) do trace[k] = v end
        traces[#traces + 1] = trace
        x_start, x_stop = v[2][1], v[2][#v[2]]
      elseif v[1] == 'slopefield' then
        x_start, x_stop = v[2][1], v[2][2]
        for i = 1, #v[3] do
          args[#args + 1] = v[3][i][2]
          args[#args + 1] = v[3][i][3]
          args[#args + 1] = v[3][i][4]
        end
        shownotlegend()
      elseif v[1] == 'vectorfield2d' then
        x_start, x_stop = v[2][1], v[2][2]
        traces[#traces + 1] = {type = 'scatter', x = {}, y = {}}
        _vecfield_annotations = v[3]
      elseif v[1] == 'graph-hist' then -- group histogram graph object: {'graph-hist', x, y}
        for i = 2, #v, 2 do
          local trace = {}
          trace[1] = v[i]
          trace[2] = v[i + 1]
          trace['type'] = 'bar'
          traces[#traces + 1] = trace
        end
        layout_arg[#layout_arg + 1] = {layout = {barmode = 'group', bargap = 0.01}}
      elseif v[1] == 'graph-box' then -- boxplot: {'graph-box', 'x', data}, 'x' or 'y'
        local count = #v
        if type(v[count][1]) == 'string' then count = count - 1 end -- it is names
        for i = 3, count do
          local trace = {}
          if v[2] == 'x' then trace['x'] = v[i] else trace['y'] = v[i] end
          trace['type'] = 'box'
          traces[#traces + 1] = trace
        end
        if count < #v then args[#args + 1] = {names = v[#v]} end
      elseif v[1] == 'graph' then -- graph objects: {'graph', x, y, style}
        for i = 2, #v, 3 do
          if #v == 5 and i == 5 then break end -- orientation
          if type(v[i]) == 'table' and _hasanyindex(v[i], {'layout', 'names'}) then  -- last item as seen in hist1(...)!
            args[#args + 1] = v[i]
            break
          end
          local xmin, xmax = min(v[i]), max(v[i])
          if x_start == nil then
            x_start, x_stop = xmin, xmax
          else
            x_start, x_stop = math.min(xmin, x_start), math.max(xmax, x_stop)
          end
          args[#args + 1] = v[i]     -- x
          args[#args + 1] = v[i + 1] -- y
          args[#args + 1] = v[i + 2] -- style
        end

        if #v == 5 then -- show orientation of parametric curves
          local points = v[5]
          for i = 1, #points do
            args[#args + 1] = points[i][1] -- x
            args[#args + 1] = points[i][2] -- y
            args[#args + 1] = points[i][3] -- style
          end
        end
      else
        args[#args + 1] = v
      end
    else
      args[#args + 1] = v
    end
::endfor::
  end

  plotly.layout = {}

  local i = 1
  while i <= #args do
    if type(args[i]) == 'function' then
      args[i] = {0, args[i]}
      table.insert(args, i + 1, {0, 0}) -- pretend to be x, y, ...; to be modified before plotting
    elseif i <= #args and type(args[i]) == 'table' and _hasanyindex(args[i], {'range', 'layout', 'names'})  then
      layout_arg[#layout_arg + 1] = args[i] -- to be processed finally
      i = i + 1
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
          else
            x_start, x_stop = math.min(1, x_start), math.max(#args[i], x_stop)
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

          traces_tmp[#traces_tmp + 1] = trace
          for j = 1, #traces_tmp do
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

              if string.find(specs, 'fs') then     -- fill to Self
                trace['fill'] = 'toself'
              elseif string.find(specs, 'fn') then -- No fill
                trace['fill'] = 'none'
              elseif string.find(specs, 'fa') then -- fill to the x-Axis
                trace['fill'] = 'tozeroy'
              elseif string.find(specs, 'ff') then -- fill to previous Function
                trace['fill'] = 'tonexty'
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
                if type(k) == 'string' then
                  k = string.lower(k)
                  optq = ismember(k, {'layout', 'color', 'size', 'width', 'mode', 'symbol', 'name'})
                  if optq then break end
                end
              end
              if optq then -- this arg is options
                for k, v in pairs(args[i]) do
                  if type(k) == 'string' then
                    local key = string.lower(k)
                    if key == 'layout' then
                      layout_arg[#layout_arg + 1] = {layout = v} -- to be processed finally
                    else
                      trace[key] = v
                    end
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

  local xrange = nil
  for i = 1, #layout_arg do  -- processed finally
    local names = {}
    for k, v in pairs(layout_arg[i]) do -- layout settings are merged into the 1st trace
      if k == 'layout' then
        for k_, v_ in pairs(v) do
          if type(k_) == 'string' then
            k_ = string.lower(k_)
            if k_ == 'name' then
              traces[1][k_] = v_
            elseif ismember(k_, {'autosize', 'grid', 'width', 'height', 'title', 'xaxis', 'yaxis', 'margin'}) then
              __layout[k_] = v_
              if k_ == 'grid' then
                __layout[k_]['pattern'] = 'independent'
              end
            end
          end
        end
      elseif k == 'range' then
        xrange = v
      elseif k ~= 'names' then
        traces[1][k] = v
      end
    end
    if layout_arg[i]['names'] ~= nil then names = layout_arg[i]['names'] end
    if #names > 0 then
      for j = 1, math.min(#traces, #names) do
        traces[j]['name'] = names[j]
      end
    end
    i = i + 1
  end

  if adjustxrangeq then
    if x_start == nil then
      if xrange ~= nil then
        x_start, x_stop = xrange[1], xrange[2]
      else
        x_start, x_stop = -5, 5
      end
    end
    x_start = x_start - 0.1
    x_stop = x_stop + 0.1
    for i = 1, #traces do
      if #traces[i] > 0 and #traces[i][1] >= 2 and type(traces[i][1][2]) == 'function' then
        local func = traces[i][1][2]
        traces[i][1] = linspace(x_start, x_stop, math.ceil(math.abs(x_stop - x_start)) * 10)
        traces[i][2] = map(func, traces[i][1])
      end
    end
  end

  plotly.plots(traces):show()
  plotly.layout = {}
  __layout = {}
end -- plot

local function _correct_range(start, stop, step)
  local tblq = type(start) == 'table'
  if tblq then
    stop = start[2]
    step = start[3]
    start = start[1]
  end
  if step == nil then
    step = 1
  elseif step < 0 then
    error('In a range of the format {start, stop, step}: step must be positive.')
  end
  if start > stop then start, stop = stop, start end
  if tblq then return {start, stop, step} else return start, stop end
end -- _correct_range

local function _set_resolution(r, n)
  n = n or 500
  if r == nil or type(r) ~= 'number' or r < n then r = n end
  return r
end

--// function merge(t1, t2)
-- merge two tables of any structure into a single one
function merge(t1, t2)
  if type(t1) ~= 'table' then
    if type(t2) ~= 'table' then
      if t1 ~= t2 then
        return {t1, t2}
      else
        return {t1}
      end
    end  else
    if type(t2) ~= 'table' then t1, t2 = t2, t1 end
  end
  if type(t1) ~= 'table' then -- t2 is a table
    local t = copy(t2)
    if not ismember(t1, t) then t[#t + 1] = t1 end
    return t
  end

  local t = copy(t1)
  for k2, v2 in pairs(t2) do
    if type(k2) == 'string' then
      if t1[k2] == nil then
        t[k2] = copy(t2[k2])
      else -- merge
        if type(t1[k2]) == 'table' and type(v2) == 'table' then
          t[k2] = merge(t1[k2], t2[k2]) -- merge
        else
          t[k2] = copy(v2) -- t2 overwrites t1
        end
      end
    else -- it's a number index
      if not ismember(v2, t) then t[#t + 1] = v2 end
    end
  end
  return t
end -- merge

--// #data == #opts
function namedargs(data, opts)
  local results = {}
  local options = nil
  local k = #data + 1
  for i = 1, #data do
    local optq = false
    if type(data[i]) == 'table' and data[i][1] == nil then -- more test
      for j = i, #opts do
        optq = data[i][opts[j]] ~= nil
        if optq then break end
      end
    end
    if optq then -- a = {x=1, y=2}: a[1] == nil
      options = data[i]; k = i; break
    else
      results[i] = data[i]
    end
  end
  if options == nil then return results end
  if k == #opts then
    if options[opts[k]] ~= nil then
      results[k] = options[opts[k]]
    else
      results[k] = options
    end
  else
    while k <= #opts do
      results[k] = options[opts[k]]; k = k + 1
    end
  end
  return results -- table.unpack(results) -- Lua 5.4.6&5.4.7: doesn't work well
end -- namedargs

local _3d_plotq = false

--// data for a 3D plot:
-- given that x = {x1, x2, ..., xm} and y = {y1, y2, ..., yn},
--   X = {{x1, x1, ..., x1}, {x2, x2, ..., x2}, ..., {xm, xm, ..., xm}}, #X = m, #X[i] = n
--   Y = {{y1, y2, ..., yn}, {y1, y2, ..., yn}, ..., {y1, y2, ..., yn}}, #Y = m, #Y[i] = n
--   Z = {{z11, ..., z1n},   {z21, ..., z2n},   ..., {zm1, ..., zm2}},   #Z = m, #Z[i] = n
--   where zij = f(xi, yj) if a surface is defined by z = f(x, y)

--// function plot3d(f, xrange, yrange, title)
-- plot a surface generated by z = f(x, y); it is not designed as general as plot(...) for 2d graphs

-- if f is a function, xrange = {xstart, xstop}, y = {ystart, ystop}
-- otherwise, X = f, Y = xrange, Z = yrange, which allows users to set up data and use it to display a graph
function plot3d(f, xrange, yrange, title, resolution)
  local args = namedargs(
    {f, xrange, yrange, title, resolution},
    {'f', 'xrange', 'yrange', 'title', 'resolution'})
  f, xrange, yrange, title, resolution = args[1], args[2], args[3], args[4], args[5]

  xrange = xrange or {-5, 5}
  yrange = yrange or xrange
  local X, Y, Z = {}, {}, {}
  if type(f) == 'string' then f = fstr2f(f) end
  if type(f) == 'function' then
    xrange = _correct_range(xrange)
    yrange = _correct_range(yrange)
    resolution = _set_resolution(resolution, 100)
    local n = max(math.ceil(max(xrange[2] - xrange[1], yrange[2] - yrange[1])) * 10, resolution)
    local x = linspace(xrange[1], xrange[2], n)
    local y = linspace(yrange[1], yrange[2], n)
    for i = 1, #x do
      local xtmp, ztmp = {}, {}
      for j = 1, #y do xtmp[j] = x[i]; ztmp[j] = f(x[i], y[j]) end -- xtmp = mathly(1, #y, x[i])
      X[i] = xtmp
      Y[i] = y
      Z[i] = ztmp
    end
  else
    X = f
    Y = xrange
    Z = yrange
  end

  _3d_plotq = true
  plotly.layout = {}
  if title ~= nil then plotly.layout.title = title end
  plotly.layout.margin = { l = 20, r = 20, b = 20, t = 40}

  local trace = {x = X, y = Y, z = Z, type = 'surface'}
  plotly.plots({trace}):show()
  plotly.layout = {}
  _3d_plotq = false
end -- plot3d

--// function plotsphericalsurface3d(rho, thetarange, phirange, title)
-- plot rho, a spherical function of theta and phi, where theta is in the range thetarange = {θ1, θ2}
-- and phi is in the range phirange = {φ1, φ2}
function plotsphericalsurface3d(rho, thetarange, phirange, title, resolution)
  local args = namedargs(
    {rho, thetarange, phirange, title, resolution},
    {'rho', 'thetarange', 'phirange', 'title', 'resolution'})
  rho, thetarange, phirange, title, resolution = args[1], args[2], args[3], args[4], args[5]

  if type(rho) == 'number' then
    local tmp = rho
    rho = function(t, p) return tmp end
  elseif type(rho) == 'string' then
    rho = fstr2f(rho)
  end
  thetarange = _correct_range(thetarange or {0, 2*pi})
  phirange = _correct_range(phirange or {0, pi})
  resolution = _set_resolution(resolution, 100)

  local X, Y, Z = {}, {}, {}
  local m = max(math.ceil(max((thetarange[2] - thetarange[1]) * 10)), resolution)
  local n = max(math.ceil(max((phirange[2] - phirange[1]) * 10)), resolution)
  local theta = linspace(thetarange[1], thetarange[2], m)
  local phi = linspace(phirange[1], phirange[2], n)

  for i = 1, m do
    local x, y, z = {}, {}, {}
    for j = 1, n do
      x[j] = rho(theta[i], phi[j]) * math.sin(phi[j]) * math.cos(theta[i])
      y[j] = rho(theta[i], phi[j]) * math.sin(phi[j]) * math.sin(theta[i])
      z[j] = rho(theta[i], phi[j]) * math.cos(phi[j])
    end
    X[i] = x
    Y[i] = y
    Z[i] = z
  end
  plot3d(X, Y, Z, title)
end -- plotsphericalsurface3d

--// function plotparametricsurface3d(x, y, z, urange, vrange, title)
-- Plot a surface defined by xyz = {x(u, v), y(u, v), z(u,v)}.
function plotparametricsurface3d(xyz, urange, vrange, title, resolution)
  local args = namedargs(
    {xyz, urange, vrange, title, resolution},
    {'xyz', 'urange', 'vrange', 'title', 'resolution'})
  xyz, urange, vrange, title, resolution = args[1], args[2], args[3], args[4], args[5]

  urange = _correct_range(urange or {-5, 5})
  vrange = _correct_range(vrange or urange)
  resolution = _set_resolution(resolution, 100)

  local x, y, z = {}, {}, {}
  local m = max(math.ceil(max((urange[2] - urange[1]) * 20)), resolution)
  local n = max(math.ceil(max((vrange[2] - vrange[1]) * 20)), resolution)
  local u = linspace(urange[1], urange[2], m)
  local v = linspace(vrange[1], vrange[2], n)

  for i = 1, 3 do
    if type(xyz[i]) == 'string' then xyz[i] = fstr2f(xyz[i]) end
  end

  for i = 1, m do
    local xtmp, ytmp, ztmp = {}, {}, {}
    for j = 1, n do
      xtmp[j] = xyz[1](u[i], v[j])
      ytmp[j] = xyz[2](u[i], v[j])
      ztmp[j] = xyz[3](u[i], v[j])
    end
    x[i] = xtmp
    y[i] = ytmp
    z[i] = ztmp
  end
  plot3d(x, y, z, title)
end -- plotparametricsurface3d

--// function plotparametriccurve3d(xyz, trange, title)
-- xyz = { ... }, the parametric equations, x(t), y(t), z(t), in order, of a space curve,
-- trange is the range of t
function plotparametriccurve3d(xyz, trange, title, resolution, orientationq)
  local args = namedargs(
    {xyz, trange, title, resolution, orientationq},
    {'xyz', 'trange', 'title', 'resolution', 'orientationq'})
  xyz, trange, title, resolution, orientationq = args[1], args[2], args[3], args[4], args[5]

  trange = _correct_range(trange or {0, 2 * pi})
  resolution = _set_resolution(resolution)

  local x, y, z
  local n = math.max(math.ceil((trange[2] - trange[1]) * 50), resolution)
  local t = linspace(trange[1], trange[2], n)

  for i = 1, 3 do
    if type(xyz[i]) == 'string' then xyz[i] = fstr2f(xyz[i]) end
  end

  x = map(xyz[1], t)
  y = map(xyz[2], t)
  z = map(xyz[3], t)

  _3d_plotq = true
  plotly.layout = {}
  if title ~= nil then plotly.layout.title = title end
  plotly.layout.margin = { l = 20, r = 20, b = 20, t = 40}

  local traces = {{x = x, y = y, z = z, type = 'scatter3d', mode = 'lines', showlegend = false}}
  if orientationq then
    local n, siz, t = 7, 12, trange[1]
    local h = (trange[2] - trange[1]) / (2 * n)
    for i = 1, n do
      traces[#traces + 1] = {
        x = {xyz[1](t)}, y = {xyz[2](t)}, z = {xyz[3](t)},
        type = 'scatter3d', mode = 'markers', showlegend = false,
        marker = {size = siz, color = 'blue', opacity = 0.8}}
      siz, t = siz - 1.25, t + h
    end
  end
  plotly.plots(traces):show(); traces = nil
  plotly.layout = {}
  _3d_plotq = false
end -- plotparametriccurve3d

local function _freq_distro(x, nbins, xmin, xmax, width)
  local freqs
  nbins = nbins or 10
  x = sort(x)

  local freqs = {}
  local x1 = xmin
  local j = 1
  for k = 1, nbins do
    freqs[k] = 0
    local x2 =  x1 + width
    while j <= #x do
      if x[j] < x2 then
        freqs[k] = freqs[k] + 1
        j = j + 1
      else
        break
      end
    end
    freqs[k] = freqs[k] / #x -- relative freq
    x1 = x2
  end
  return freqs
end -- _freq_distro

--// hist(x, nbins, style)
-- if x is a table of tables/rows, each row is a data set; otherwise, x is a table and a single data set.
function hist(x, nbins, style, xrange)
  local args = namedargs(
    {x, nbins, style, xrange},
    {'x', 'nbins', 'style', 'xrange'})
  x, nbins, style, xrange = args[1], args[2], args[3], args[4]

  if type(x) == 'table' then
    if type(x[1]) ~= 'table' then x = { x } end
  else
    error('hist(x, ...): x must be a table.')
  end

  local xmin, xmax, width
  local gdata = {'graph-hist'} -- special graph object, https://plotly.com/javascript/bar-charts/
  local freqs = {}
  local allintq = all(x, isinteger, false) == 1
  nbins = nbins or 10

  if xrange ~= nil then
    xmin, xmax = _correct_range(xrange[1], xrange[2])
  else
    local tmp = flatten(x)
    xmin, xmax = min(tmp), max(tmp)
  end
  if allintq then
    width = math.ceil((xmax - xmin + 1) / nbins)
  else
    width = (xmax - xmin) / nbins
  end

  for i = 1, #x do
    freqs[i] = _freq_distro(x[i], nbins, xmin, xmax, width)
  end

  local labels = {}
  local x1 = xmin
  for i = 1, nbins do
    local x2 = x1 + width
    if allintq then
      labels[#labels + 1] = sprintf("[%d, %d]", x1, x2 - 1)
    else
      labels[#labels + 1] = sprintf("[%.4f, %.4f)", x1, x2)
    end
    x1 = x2
  end

  for j = 1, #x do
    gdata[#gdata + 1] = labels
    gdata[#gdata + 1] = freqs[j]
  end
  return gdata
end -- hist

local function _xmin_xmax_width(x, xrange, nbins, allintq)
  local xmin, xmax, width
  if xrange ~= nil then
    xmin, xmax = _correct_range(xrange[1], xrange[2])
  else
    xmin, xmax = x[1], x[#x]
  end
  if allintq then
    width = math.ceil((xmax - xmin + 1) / nbins)
  else
    width = (xmax - xmin) / nbins
  end
  return xmin, xmax, width
end -- _xmin_xmax_width

--// function hist1(x, nbins, style)
-- another version of histogram, as see in most textbooks
-- the output can be treated as an ordinary graph object such as a curve
function hist1(x, nbins, style, xrange, freqpolygonq, style1, histq) -- style1: for freqpolygon
  local args = namedargs(
    {x, nbins, style, xrange, freqpolygonq, style1, histq},
    {'x', 'nbins', 'style', 'xrange', 'freqpolygonq', 'style1', 'histq'})
  x, nbins, style, xrange, freqpolygonq, style1, histq = args[1], args[2], args[3], args[4], args[5], args[6], args[7]

  if histq == nil then histq = true end
  nbins = nbins or 10
  x = sort(flatten(x))
  local xmin, xmax, width = _xmin_xmax_width(x, xrange, nbins, all(x, isinteger) == 1)
  local freqs = _freq_distro(x, nbins, xmin, xmax, width)
  local gdata = {'graph'}
  local x1 = xmin
  local freqp_xy = {{xmin - width / 2}, {0}}
  for i = 1, nbins do
    local x2 = x1 + width
    if histq then
      local gobj = polygon({{x1, 0}, {x1, freqs[i]}, {x2, freqs[i]}, {x2, 0}}, style)
      gdata[#gdata + 1] = gobj[2]
      gdata[#gdata + 1] = gobj[3]
      gdata[#gdata + 1] = gobj[4]
    end
    if freqpolygonq then
      freqp_xy[1][i + 1] = x1 + width / 2
      freqp_xy[2][i + 1] = freqs[i]
    end
    x1 = x2
  end
  if freqpolygonq then
    freqp_xy[1][nbins + 2] = x1 + width / 2
    freqp_xy[2][nbins + 2] = 0
  end

  if freqpolygonq then
    style1 = style1 or '-ro'
    gdata[#gdata + 1] = freqp_xy[1]
    gdata[#gdata + 1] = freqp_xy[2]
    gdata[#gdata + 1] = style1
    for i = 1, nbins + 2 do -- points
      gdata[#gdata + 1] = {freqp_xy[1][i]}
      gdata[#gdata + 1] = {freqp_xy[2][i]}
      gdata[#gdata + 1] = style1
    end
  end
  return gdata
end -- hist1(x, nbins, style, xrange, freqpolygonq, style1, histq)

--// function pareto(data, style, style1) -- style1: for freq curve
-- data = {{label1, value1}, {label2, value2}, ..., {namen, valuen}}
function pareto(data, style, style1) -- style1: for freq curve
  local args = namedargs(
    {data, style, style1},
    {'data', 'style', 'style1'})
  data, style, style1 = args[1], args[2], args[3]

  if style == nil then style = '-fs' end
  if style1 == nil then style1 = '-ro' end

  local total = 0
  local dat = {}
  for i = 1, #data do
    total = total + data[i][2]
    dat[i] = data[i]
  end
  for i = 1, #dat - 1 do -- sort data by values from highest to lowest; same data set, no performance issue
    local maxi, maxx = i, dat[i][2]
    for j = i + 1, #dat do
      if dat[j][2] > maxx then maxi, maxx = j, dat[j][2] end
    end
    if maxi ~= i then
      dat[i], dat[maxi] = dat[maxi], dat[i]
    end
  end
  local freqs = {}
  for i = 1, #dat do
    freqs[i] = dat[i][2] -- / total
  end

  local gdata = {'pareto'}
  local x1 = 0
  local freqxy = {{0}, {0}}
  local width = 20
  for i = 1, #dat do
    local x2 = x1 + width
    local gobj = polygon({{x1, 0}, {x1, freqs[i]}, {x2, freqs[i]}, {x2, 0}}, style)
    gdata[#gdata + 1] = gobj[2]
    gdata[#gdata + 1] = gobj[3]
    gdata[#gdata + 1] = gobj[4]
    freqxy[1][i + 1] = x2
    freqxy[2][i + 1] = freqxy[2][i] + freqs[i]
    x1 = x2
  end

  gdata[#gdata + 1] = freqxy[1]
  gdata[#gdata + 1] = freqxy[2]
  gdata[#gdata + 1] = style1
  for i = 1, #dat + 1 do -- points
    gdata[#gdata + 1] = {freqxy[1][i]}
    gdata[#gdata + 1] = {freqxy[2][i]}
    gdata[#gdata + 1] = style1 -- {symbol='circle', size=8, color='red'}
  end

  -- 'plot' the names
  x1 = 0
  local texts = {}
  local shiftx, shifty = width * 0.4, dat[1][2]*0.04
  for i = 1, #dat do
    local shift = (width - #dat[i][1])/2
    if shift < shiftx then shift = shiftx end
    texts[i] = text(x1 + shift, -shifty, data[i][1])
    x1 = x1 + width
  end

  x1 = #dat * width + shiftx
  local n, percent = 5, 20
  if #dat > 10 then n, percent = 10, 10 end
  for i = 1, n do
    local scale = i * percent
    local y1 = (scale / 100) * total + shifty
    texts[#texts + 1] = text(x1, y1, tostring(scale) .. '%')
  end

  local names = {}
  for i = 1, #dat * 5 do names[i] = '' end
  gdata[#gdata + 1] = {names = names}

  gdata[#gdata + 1] = texts
  shownotxaxis(); shownotlegend()
  return gdata
end -- pareto(data, style, style1)

function freqpolygon(x, nbins, style, xrange)
  local args = namedargs(
    {x, nbins, style, xrange},
    {'x', 'nbins', 'style', 'xrange'})
  x, nbins, style, xrange = args[1], args[2], args[3], args[4]

  return hist1(x, nbins, nil, xrange, true, style, false)
end

function histfreqpolygon(x, nbins, style, xrange, style1)
  local args = namedargs(
    {x, nbins, style, xrange, style1},
    {'x', 'nbins', 'style', 'xrange', 'style1'})
  x, nbins, style, xrange, style1 = args[1], args[2], args[3], args[4], args[5]

  return hist1(x, nbins, style, xrange, true, style1, true)
end

--// boxplot(x, nbins, style)
-- if x is a table of tables/rows, each row is a data set; otherwise, x is a table and a single data set.
function boxplot(x, names)
  local args = namedargs({x, names}, {'x', 'names'})
  x, names = args[1], args[2]

  if type(x) == 'table' then
    if type(x[1]) ~= 'table' then x = { x } end
  else
    error('boxplot(x, ...): x must be a table.')
  end

  local gdata = {'graph-box'} -- special graph object, https://plotly.com/javascript/bar-charts/
  gdata[2] = 'x' -- horizontal -- gobj: {'graph-box', 'x', data...}, 'x' or 'y'
  if #x > 3 then gdata[2] = 'y' end -- vertical
  for j = 1, #x do
    gdata[j + 2] = x[j]
  end
  if names ~= nil then gdata[#gdata + 1] = names end
  return gdata
end -- boxplot

-- offcenter:
--  1. 0.1, all bins are away from the center by 0.1
--  2. {{2, 0.1}, {5, 0.3}, ...}, the 2nd, 5th ... bins are away from the center by ...
function pie(x, nbins, radius, style, offcenter, names) -- nbins, ..., names: space hodlers, also saving the step: local nbins, ..., names
  local args = namedargs(
    {x, nbins, radius, style, offcenter, names},
    {'x', 'nbins', 'radius', 'style', 'offcenter', 'names'})
  x, nbins, radius, style, offcenter, names = args[1], args[2], args[3], args[4], args[5], args[6]

  local freqs, xmin, xmax, width
  local binsq = x['bins'] ~= nil
  if binsq then
    freqs = x['bins']
    freqs = tt(rr(freqs) / sum(freqs))
    nbins = #freqs
  else
    nbins = nbins or 10
    x = sort(flatten(x))
    xmin, xmax, width = _xmin_xmax_width(x, nil, nbins, all(x, isinteger) == 1)
    freqs = _freq_distro(x, nbins, xmin, xmax, width)
  end

  radius = radius or 1
  local data = {'graph'}
  local angle1 = 0
  for i = 1, nbins do
    local angle2
    if i == nbins then
      angle2 = 2 * pi
    else
      angle2 = angle1 + freqs[i]*2*pi
    end
    local center = {0, 0}
    local off = 0
    if offcenter ~= nil then
      if type(offcenter) == 'number' then
        off = offcenter
      elseif type(offcenter) == 'table' and type(offcenter[1]) == 'table' then
        for j = 1, #offcenter do
          if offcenter[j][1] == i then
            off = offcenter[j][2]
            break
          end
        end
      end
      local mid = (angle1 + angle2) / 2
      local r = math.abs(off)
      center[1], center[2] = r * math.cos(mid), r * math.sin(mid)
    end
    local v = wedge(radius, center, {angle1, angle2}, style)
    data[#data + 1] = v[2]
    data[#data + 1] = v[3]
    data[#data + 1] = v[4]
    angle1 = angle2
  end

  local labels = {}
  local allintq = all(x, isinteger, false)
  if binsq then
    for i = 1, nbins do labels[i] = '' end
  else
    local x1 = xmin
    local allintq = all(x, isinteger, false) == 1
    for i = 1, nbins do
      local x2 = x1 + width
      if allintq then
        labels[i] = sprintf("[%d, %d]", x1, x2 - 1)
      else
        labels[#labels + 1] = sprintf("[%.2f, %.2f)", x1, x2)
      end
      x1 = x2
    end
  end
  for i = 1, nbins do
    if binsq then
      if type(names) == 'table' and i <= #names then
        labels[i] = names[i] .. sprintf(" (%.2f%%)", freqs[i] * 100)
      else
        labels[i] = sprintf("%.2f%%", freqs[i] * 100)
      end
    else
      labels[i] = labels[i] .. sprintf(" (%.2f%%)", freqs[i] * 100)
    end
  end
  data[#data + 1] = {names=labels}
  return data
end -- pie

--// plot a wedge of a disk/circle
-- radius: r
-- center: center {x, y}
-- angles: {angle1, angle2}
function wedge(r, center, angles, style, wedgeq)
  local args = namedargs(
    {r, center, angles, style, wedgeq},
    {'r', 'center', 'angles', 'style', 'wedgeq'})
  r, center, angles, style, wedgeq = args[1], args[2], args[3], args[4], args[5]

  center = center or {0, 0}
  angles = _correct_range(angles or {0, 2*pi})
  if wedgeq == nil then wedgeq = true end
  local theta = angles[2] - angles[1]
  local arcpts = math.ceil(300 * theta/(2*pi))
  local inc = theta / arcpts
  local x = {}
  local y = {}
  local k = 1
  theta =  angles[1]
  if wedgeq then
    x[1] = center[1]
    y[1] = center[2]
    k = k + 1
  end
  for i = 1, arcpts + 1 do
    x[k] = center[1] + r * math.cos(theta)
    y[k] = center[2] + r * math.sin(theta)
    k = k + 1
    theta = theta + inc
  end
  local data = {'graph'}
  local opt = '-'
  if wedgeq then
    x[k] = center[1]
    y[k] = center[2]
    opt = '-fs'
  end
  data[2] = x
  data[3] = y
  if style == nil then
    data[4] = opt
  else
    data[4] = style
  end
  return data
end -- wedge

--// plot an arc of a circle
-- radius: r
-- center: center {x, y}
-- angles: {angle1, angle2}
function arc(r, center, angles, style)
  local args = namedargs(
    {r, center, angles, style},
    {'r', 'center', 'angles', 'style'})
  r, center, angles, style = args[1], args[2], args[3], args[4]

  return wedge(r, center, angles, style, false)
end

function circle(r, center, style)
  local args = namedargs(
    {r, center, style},
    {'r', 'center', 'style'})
  r, center, style = args[1], args[2], args[3]

  if center == nil then center = {0, 0} end
  return arc(r, center, {0, 2*pi}, style)
end

function polygon(xy, style)
  local args = namedargs({xy, style}, {'xy', 'style'})
  xy, style = args[1], args[2]

  local x, y = {}, {}
  local k = 1
  for i = 1, #xy do
    x[k], y[k] = xy[i][1], xy[i][2]
    k = k + 1
  end
  x[k] = xy[1][1]
  y[k] = xy[1][2]
  local data = {'graph', x, y}
  data[4] = style or '-fs'
  return data
end -- polygon

function line(point1, point2, style)
  local args = namedargs({point1, point2, style}, {'point1', 'point2', 'style'})
  point1, point2, style = args[1], args[2], args[3]

  local data = {'graph', {point1[1], point2[1]}, {point1[2], point2[2]}}
  if style == nil then data[4] = '-' else data[4] = style end
  return data
end

-- style: e.g., {symbol='circle-open', size=10, color='blue'}
function point(x, y, style)  -- plot a point at (x, y)
  local args = namedargs({x, y, style}, {'x', 'y', 'style'})
  x, y, style = args[1], args[2], args[3], args[4], args[5], args[6], args[7]

  if type(x) == 'number' then
    x, y = {x}, {y}
  else
    local X, Y = _converse_poly_input(x)
    if #X ~= 0 then style = y; x, y = X, Y end
  end
  assert(type(x) == 'table' and type(y) == 'table' and #x == #y, 'point(x, y ...): x and y must be two numbers or two tables of the same size.')

  local data = {'graph'}
  for i = 1, #x do
    data[#data + 1] = {x[i]}
    data[#data + 1] = {y[i]}
    if style == nil then
      data[#data + 1] = {symbol='circle', size=8, showlegend = false}
    else
      data[#data + 1] = style
    end
  end
  return data
end -- point

--// function text(x, y, txt, style)
-- write text txt at (x, y) on a graph)
--
-- style: {family = 'sans serif', size = 18, color = '#ff0000'}
function text(x, y, txt, style)
  local args = namedargs(
    {x, y, txt, style},
    {'x', 'y', 'txt', 'style'})
  x, y, txt, style = args[1], args[2], args[3], args[4]

  style = style or {color = 'black'}
  local trace = {{x}, {y}}
  trace['text'] = txt
  trace['textfont'] = style
  trace['mode'] = 'text'
  trace['type'] = 'scatter'
  trace['textposition'] = 'bottom'
  trace['name'] = ''
  return {'text', trace}
end -- text

--// function parametriccurve2d(xy, trange, style, resolution)
-- xy = {x(t), y(t)}
function parametriccurve2d(xy, trange, style, resolution, orientationq)
  local args = namedargs(
    {xy, trange, style, resolution, orientationq},
    {'xy', 'trange', 'style', 'resolution', 'orientationq'})
  xy, trange, style, resolution, orientationq = args[1], args[2], args[3], args[4], args[5]

  trange = _correct_range(trange or {-5, 5})
  resolution = _set_resolution(resolution)
  local data = {'graph'}
  local ts = linspace(trange[1], trange[2], math.max(math.ceil((trange[2] - trange[1]) * 50), resolution))

  for i = 1, 2 do
    if type(xy[i]) == 'string' then xy[i] = fstr2f(xy[i]) end
  end

  data[2] = map(xy[1], ts)
  data[3] = map(xy[2], ts)
  ts = nil
  if style == nil then
    data[4] = '-'
  else
    data[4] = style
  end
  if orientationq then
    local points = {}
    local n, siz, t = 7, 12, trange[1]
    local h = (trange[2] - trange[1]) / (2 * n)
    for i = 1, n do
      points[i] = {{xy[1](t)}, {xy[2](t)}, {symbol='circle', size=siz, color='blue', opacity = 0.8, showlegend = false}}
      siz, t = siz - 1.25, t + h
    end
    data[5] = points
  end
  return data
end -- parametriccurve2d

--//function polarcurve2d(r, trange, style, resolution)
-- r(θ), a polar function
function polarcurve2d(r, trange, style, resolution, orientationq)
  local args = namedargs(
    {r, trange, style, resolution, orientationq},
    {'r', 'trange', 'style', 'resolution', 'orientationq'})
  r, trange, style, resolution, orientationq = args[1], args[2], args[3], args[4], args[5]

  if type(r) == 'number' then
    local f = r
    r = function(t) return f end
  elseif type(r) == 'string' then
    r = fstr2f(r)
  end
  return parametriccurve2d({
      function(t) return r(t) * math.cos(t) end,
      function(t) return r(t) * math.sin(t) end
    }, trange or {0, 2*pi}, style, resolution, orientationq)
end -- polarcurve2d

--// function scatter(x, y, style)
-- x and y are tables of the same size
function scatter(x, y, style)
  local args = namedargs(
    {x, y, style},
    {'x', 'y', 'style'})
  x, y, style = args[1], args[2], args[3]

  local X, Y = _converse_poly_input(x)
  if #X ~= 0 then style = y; x, y = X, Y end
  x = flatten(x)
  y = flatten(y)
  assert(#x == #y, 'scatter(x, y): x and y must be tables of the same size.')
  local data = {'graph', x, y}
  if style == nil then
    data[4] = {symbol='circle-open', size=8, showlegend = false}
  else
    data[4] = style
  end
  return data
end -- scatter

local function _contour_data(x)
  if type(x) ~= 'table' then
    error('contourplot(f, x, y, style): x and y must be ranges or tables of numbers.')
  end
  x = flatten(x)
  if #x <= 3 then
    return linspace(x[1], x[2], x[3] or 100)
  else
    return x
  end
end -- _contour_data

--// function contourplot(f, x, y, style)
-- x and y are tables of the same size
function contourplot(f, x, y, style)
  local args = namedargs(
    {f, x, y, style},
    {'f', 'x', 'y', 'style'})
  f, x, y, style = args[1], args[2], args[3], args[4]

  if type(f) == 'string' then f = fstr2f(f) end
  x = _contour_data(x)
  if y == nil then
    y = x
  else
    y = _contour_data(y)
  end

  local z = {}
  for i = 1, #x do
    z[i] = {}
		for j = 1, #y do
			z[i][j] = f(x[i], y[j])
		end
	end
  return {'contour', x, y, z, style or {colorscale = 'Jet', contours = {coloring = 'lines'}}}
end -- contourplot

-- dy/dx = f(x, y)
function slopefield(f, xrange, yrange, scale)
  local args = namedargs(
    {f, xrange, yrange, scale},
    {'f', 'xrange', 'yrange', 'scale'})
  f, xrange, yrange, scale = args[1], args[2], args[3], args[4]

  if type(f) == 'string' then f = fstr2f(f) end
  xrange = _correct_range(xrange or {-5, 5, 0.5})
  yrange = _correct_range(yrange or xrange)
  if type(f) ~= 'function' or type(xrange) ~= 'table' or type(yrange) ~= 'table' then
    error('slopefield(f, xrange, yrange, scale): f is a function as in dy/dx = f(x, y), xrange and yrange are of the format {begin, end, step}.')
  end
  scale = scale or 1
  if scale < 0 then scale = -scale end
  local len = (xrange[2] - xrange[1]) / 50 * scale -- length of a dash
  local k, dashes = 1, {}
  for x = xrange[1], xrange[2], xrange[3] do
    for y = yrange[1], yrange[2], yrange[3] do
      local slope = f(x, y)
      local xinc = len / math.sqrt(1 + slope^2)
      local by = y + slope * xinc
      xinc = xinc / 2 -- place the dash to the midpoint
      dashes[k] = line({x - xinc, y}, {x + xinc, by}, {width=0.5, color='black'})
      k = k + 1
    end
  end
  return {'slopefield', xrange, dashes}
end -- slopefield

function directionfield(f, xrange, yrange, scale) return slopefield(f, xrange, yrange, scale) end

-- f(x, y) returns a vector {xcomponent, ycomponent}
function vectorfield2d(f, xrange, yrange, scale)
  local args = namedargs(
    {f, xrange, yrange, scale},
    {'f', 'xrange', 'yrange', 'scale'})
  f, xrange, yrange, scale = args[1], args[2], args[3], args[4]

  if type(f) == 'string' then f = fstr2f(f) end
  xrange = _correct_range(xrange or {-5, 5, 0.5})
  yrange = _correct_range(yrange or xrange)
  if type(f) ~= 'function' or type(xrange) ~= 'table' or type(yrange) ~= 'table' then
    error('vectorfield2d(f, xrange, yrange, scale): f is a vector function, xrange and yrange are of the format {begin, end, step}.')
  end
  scale = scale or 5
  if scale < 0 then scale = -scale end
  local k, annotations = 1, {}
  for x = xrange[1], xrange[2], xrange[3] do
    for y = yrange[1], yrange[2], yrange[3] do
      local v = f(x, y)
      annotations[k] = {
        x = x, y = y, -- head
        -- axref = 'pixel', yxref = 'pixel',
        ax = -v[1] * scale, ay = v[2] * scale,  -- tail
        -- if axref is "pixel" (deafult?), ax is specified in pixels relative to x. ax > 0 moves the tail to the right; otherwise, to the left.
        -- if ayref is 'pixel', ay is specified in pixels relative to y. ay > 0 moves the tail upwards; otherwise, downwards.
        showarrow = true, text = '',
        arrowhead = 1, -- default: 1 - a simple line arrowhead; 5 - a simple line, angled arrowhead
        arrowsize = 1, arrowwidth = 0.8, arrowcolor = 'black'
      }
      k = k + 1
    end
  end
  return {'vectorfield2d', xrange, annotations}
end -- vectorfield2d

local _axis_equalq       = false
local _xaxis_visibleq    = true
local _yaxis_visibleq    = true
local _gridline_visibleq = true
local _showlegendq       = false

function axissquare()    _axis_equalq = true  end
function axisnotsquare() _axis_equalq = false end

function showaxes()    _xaxis_visibleq = true;  _yaxis_visibleq = true  end
function shownotaxes() _xaxis_visibleq = false; _yaxis_visibleq = false end

function showxaxis()    _xaxis_visibleq = true  end
function shownotxaxis() _xaxis_visibleq = false end
function showyaxis()    _yaxis_visibleq = true  end
function shownotyaxis() _yaxis_visibleq = false end

function showgridlines()    _gridline_visibleq = true end
function shownotgridlines() _gridline_visibleq = false end

function showlegend()    _showlegendq = true  end
function shownotlegend() _showlegendq = false end

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
function rref( a, b ) -- gauss-jordan elimination
  assert(getmetatable(a) == mathly_meta, 'rref( A ): A must be a mathly metatable.')
  assert(b == nil or getmetatable(b) == mathly_meta, 'rref( A, B ): A and B must be mathly metatables.')
  local rows, columns = size(a)
  local ROWS = math.min(rows, columns)

  local bq = false
  local bcolumns = 0
  if b ~= nil then
    bq = true
    assert(#b == rows, 'rref(A, B): A and be must have the same number of rows.')
    bcolumns = #b[1]
  end

  local A = copy(a) -- 4/23/25
  local B = copy(b) --

  local abs = math.abs
  for i = 1, ROWS do
    local largest = abs(A[i][i]) -- choose the pivotal entry
    local idx = i
    for j = i + 1, rows do
      local tmp = abs(A[j][i])
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
      while j <= columns and abs(A[i][j]) < 1e-15 do
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
  if bq then return A, B else return A end
end -- rref

--// function linsolve( A, b, opt )
-- solve the linear system Ax = b for x, given that A is a square matrix; return the solution
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
    local v1, v2 = rref(A, B)
    return v2
  end

  local m, n = size(A)
  assert(m == n and n == #B, 'linsolve(A, b, ...): A must be square and the dimensions of A and b must match.')
  local y = zeros(1, n)
  if opt == 'UT' then -- solve it by back substitution
    y[n] = B[n][1] / A[n][n]
    for i = n - 1, 1, -1 do
      y[i] = (B[i][1] - sum(submatrix(A, i, i + 1, i, n) * rr(subtable(y, i + 1, n)))) / A[i][i]
    end
  else -- solve it by forward substitution
    y[1] = B[1][1] / A[1][1]
    for i = 2, n do
      y[i] = (B[i][1] - sum(submatrix(A, i, 1, i, i - 1) * rr(subtable(y, 1, i - 1)))) / A[i][i]
    end
  end
  return cc(y)
end -- linsolve

--// function inv( A )
-- calculate the inverse of matrix A
-- rref([A | I]) gives [ I | B ], where B is the inverse of A
function inv( A )
  assert(getmetatable(A) == mathly_meta, 'inv( A ): A must be a mathly metatable.')
  local rows, columns = size(A)
  assert(rows == columns, 'inv( A ): A must be square.')
  local v1, v2 = rref(A, eye(rows))
  return setmetatable(v2, mathly_meta)
end -- inv

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
end -- size

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
end -- repmat

--// function flipud(A)
-- Return a matrix with rows of matrix A reversed (upside down)
--// function fliplr(A)
-- Return a matrix with columns of matrix A reversed (from left to right)
function flipud(A) return rr(A, range(#A, 1, -1)) end
function fliplr(A) return cc(A, range(#A[1], 1, -1)) end

--// function reverse(tbl)
-- reverse and return a table. if it is a matrix, it is flattened columnwisely first to a table and then reversed
function reverse(tbl)
  if type(tbl) == 'string' then
    return string.reverse(tbl)
  else
    return tt(tbl, -1, 1, -1)
  end
end
function sort(tbl, compf)
  if type(compf) == 'string' then compf = fstr2f(compf) end
  table.sort(tbl, compf)
  return tbl
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
    if m == 1 then B = rr(B) end
    for i = 1, m do
      for j = i, n do
        B[i][j] = A[i][j]
      end
    end
  elseif opt == 'LT' then
    B = zeros(m, n)
    if m == 1 then B = rr(B) end
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
    if m == 1 then B = rr(B) end
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
end -- remake

--// function reshape( A, m, n )
-- use entries of matrix A to generate a new mxn matrix, given that A is a valid vector or matrix
function reshape( A, m, n )
  local rows, columns = size(A)
  local total = rows * columns
  if n == nil then n = math.ceil(total / m) end

  local tbl
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

  local k = 1
  local B = {}
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
end -- reshape

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
end -- length

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
  if m == nil or n ~= nil then
    if m == nil then m = #v; n = m end
    siz = math.min(#v, m, n)
    z = zeros(m, n)
    if m == 1 then z = rr(z) end -- zeros(1, n) is not a mathly matrix
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
end -- diag
--[[
--// function eigs(A)
-- Return eigenvalues of a square matrix A.
function eigs(A) -- apply qr factorization
  assert(getmetatable(A) == mathly_meta, 'eigs(A): A must be a mathly matrix.')
  local row, col = size(A)
  assert(row == col, 'eigs(A): A must be a square matrix.')
  local Q, R

  local i = 1
  local abs = math.abs
  while true do
    q, r = qr(A)
    A = r * q
    if abs(A[i + 1][i]) < 1e-4 then
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
end -- expand

--// function submatrix( A, startrow, startcol, endrow, endcol, steprow, stepcol )
-- extract a submatrix of matrix A
function submatrix( A, startrow, startcol, endrow, endcol, steprow, stepcol )
  assert(getmetatable(A) == mathly_meta, 'submatrix( A ): A must be a mathly metatable.')
  local rows, columns = size(A)
  startrow, endrow, steprow = _adjust_index_step(rows, startrow, endrow, steprow)
  startcol, endcol, stepcol = _adjust_index_step(columns, startcol, endcol, stepcol)

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
end -- submatrix

--// function subtable( A, startpos, endpos, step )
-- return a specified slice of a vector
function subtable( tbl, startpos, endpos, step )
  startpos, endpos, step = _adjust_index_step(#tbl, startpos, endpos, step)
  local x = {}
  for i = startpos, endpos, step do
    x[#x + 1] = tbl[i]
  end
  return x
end -- subtable

--// function lu(A)
-- Return L and U in LU factorization A = L * U, where L and U are lower and upper traingular matrices, respectively.
function lu(A) -- by Crout's method
  assert(getmetatable(A) == mathly_meta, 'lu(A): A must be a mathly square matrix.')
  local m, n = size(A)
  assert(n == m and n > 1, "lu(A): A is not square.\n")
  local abs = math.abs

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
      if abs(L[i][i]) < eps then
        error(sprintf('L[%d][%d] = 0. No LU factorization is found.', i, i))
      end
      U[i][j] = (A[i][j] - s) / L[i][i]
    end
  end

  return L, U
end -- lu

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
    Q = horzcat(Q, v)
  end

  -- calculating R
  local R = zeros(n, n)
  for i = 1, n do
    for j = i, n do
      R[i][j] = sum(submatrix(A, 1, j, m, j) * submatrix(Q, 1, i, m, i)) -- A[:, j] .* Q[:, i])
    end
  end

  return Q, R
end -- qr

--// det( A )
-- Calculate the determinant of a matrix
function det( B )
  assert(getmetatable(B) == mathly_meta, 'det( A ): A must be a mathly matrix.')
  local m, n = size(B)
  if m ~= n then
      print('det(A): A must be square.')
      return 0
  end
  local A = copy(B)

  local val = 1 -- by gauss elimination
  local abs = math.abs
  for i = 1, n - 1 do
    local maxi = i -- pivoting
    local maxx = abs(A[i][i])
    for k = i + 1, n do
      local absx = abs(A[k][i])
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
      if abs(A[j][i]) > 10*eps then
        for k = i + 1, n do
          A[j][k] = A[j][k] - A[j][i] * A[i][k]
        end -- A[j][i] = 0 -- not necessary
      end
    end
  end
  return val * A[n][n]
end -- det

--// mathly.horzcat( ... )
-- Concatenate matrices, horizontal
-- rows have to be the same, e.g.: #m1 == #m2
-- e.g., horzcat({{1},{2}}, {{2,3,4},{3,4,5}}, {{5,6},{6,7}})
function horzcat( ... )
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
end -- horzcat

--// vertcat ( ... )
-- Concatenate matrices, vertical
-- columns have to be the same; e.g.: #m1[1] == #m2[1]
-- e.g., vertcat({{1,2,3},{2,3,4}}, {{3,4,5}}, {{4,5,6},{5,6,7}})
function vertcat( ... )
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
end -- vertcat

--// tblcat( ... )
-- merge elements and FLATTENED tables into a single table
-- e.g., tblcat(1, {2, {3, 4}}, {{5, 6}, 7})
function tblcat( ... )
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end

  local tbl = {}
  for i = 1, #args do
    if type(args[i]) == 'table' then
      local x = flatten(args[i])
      for j = 1, #x do
        tbl[#tbl + 1] = x[j]
      end
    else
      tbl[#tbl + 1] = args[i]
    end
  end
  return tbl
end -- tblcat

-----------[[ Set behaviours of +, -, *, and ^ -----------]]

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
end -- mathly.numtableadd

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
end -- mathly.add_sub_shared

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
end -- mathly.matlabvmul

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
end -- mathly.mul

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
end -- mathly.mulnum

-- Set division "/" behaviour
mathly_meta.__div = function( m1,m2 )
  local err = 'm1 / m2: the dimensions of m1 and m2 do not match.'
  if type(m2) == 'number' then
    return map(function(x) return x/m2 end, m1)
  elseif type(m1) == 'number' then
    return map(function(x) return m1/x end, m2)
  elseif type(m1) == 'table' and type(m2) == 'table' then
    if type(m1[1]) ~= 'table' then
      local m, n = size(m2)
      if m == 1 then
        m1 = rr(m1)
      elseif n == 1 then
        m1 = cc(m1)
      else
        error(err)
      end
    elseif type(m2[1]) ~= 'table' then
      local m, n = size(m1)
      if m == 1 then
        m2 = rr(m2)
      elseif n == 1 then
        m2 = cc(m2)
      else
        error(err)
      end
    end
    local m, n = size(m1)
    local M, N = size(m2)
    if m ~= M or n ~= N then error(err) end
    return map(function(x, y) return x/y end, m1, m2)
  else
    error('m1 / m2: the type of m1 or m2 is not allowed.')
  end
end -- mathly_meta.__div

-- Set unary minus "-" behavior
mathly_meta.__unm = function( mtx )
	return mathly.mulnum( mtx,-1 )
end

-- Power of matrix; mtx^(n)
-- n is a nonnegative integer
-- if m1 is square, m1 ^ n = m1 * m1 * ... * m1; if me1 is row/column vector, m1 ^ n ~ m1 .^ n as in MATLAB
function mathly.pow( m1, n )
	assert(isinteger(n) and n >= 0, "A ^ n: n must be a nonnegative integer.")
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
end -- mathly.pow

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
end -- mathly.equal

-- Set equal "==" behaviour
mathly_meta.__eq = function( ... )
	return mathly.equal( ... )
end

-- Set concat ".." behaviour
mathly_meta.__concat = function( ... )
	return horzcat( ... )
end

-- Set tostring "tostring( mtx )" behaviour
mathly_meta.__tostring = function( ... )
	return mathly.tostring( ... )
end

--// mathly.tostring ( mtx )
function mathly.tostring( mtx )
  _set_disp_format(mtx)
	if type(mtx[1]) == 'table' then
    local rowstrs = {}
		for i = 1,#mtx do
			rowstrs[i] = table.concat(map(_tostring, mtx[i]), " ")
		end
		return table.concat(rowstrs, "\n")
  else -- a row vector
    return table.concat(map(_tostring1, mtx), " ")
  end
end -- mathly.tostring

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

--------------- end of mathly.lua -----------------


--[[ The following code is obtained from URL: https://github.com/kenloen/plotly.lua
     All variables in functions are made 'local' in addition to some changes. Some
     functions have been removed. All credit belongs to the original auther. --]]

local json = { version = "dkjson 2.8" }

-- https://cdn.plot.ly/plotly-latest.min.js
plotly.cdn_main = "<script src='" .. plotly_engine .. "'></script>" -- dwang
plotly.id_count = 1
plotly.layout = {} -- dwang

local _writehtml_failedq = false -- dwang

-- From: https://stackoverflow.com/questions/11163748/open-web-browser-using-lua-in-a-vlc-extension#18864453
-- Attempts to open a given URL in the system default browser, regardless of Operating System.
local _open_cmd -- this needs to stay outside the function, or it'll re-sniff every time...
local function _open_url(url)
  if not _open_cmd then
    if package.config:sub(1,1) == '\\' then -- windows
      _open_cmd = function(url)
        -- Should work on anything since (and including) win'95
        --- os.execute(string.format('start "%s"', url)) -- dwang
        os.execute(string.format('"%s" %s', win_browser, url)) -- dwang
      end
    -- the only systems left should understand uname...
    elseif (io.popen("uname -s"):read'*a') == "Darwin" then -- OSX/Darwin ? (I can not test.)
      _open_cmd = function(url)
        -- I cannot test, but this should work on modern Macs.
        -- os.execute(string.format('open "%s"', url)) -- dwang
        os.execute(string.format('%s "%s"', mac_browser, url)) --dwang
      end
    else -- that ought to only leave Linux
      _open_cmd = function(url)
        -- should work on X-based distros.
        -- os.execute(string.format('xdg-open "%s"', url)) --dwang
        os.execute(string.format('%s "%s"', linux_browser, url)) --dwang
      end
    end
  end

  _open_cmd(url)
end -- _open_url

-- Figure metatable
local figure = {}

---Adding a trace for the figure. All options can be found here: https://plotly.com/javascript/reference/index/
---Easy to call like: figure:add_trace{x=x, y=y, ...}
---@param self table
---@param trace table
function figure.add_trace(self, trace)
  self["data"][#self["data"]+1] = trace
end

local _dash_style = {["-"] = "solid", [":"] = "dot", ["--"] = "dash"}
local _mode_shorthand = {["m"] = "markers", ["l"]="lines", ["m+l"]="lines+markers", ["l+m"]="lines+markers"}


--[[Adding a trace for the figure with shorthand for common options (similar to matlab or matplotlib).
All js options can be found here: https://plotly.com/javascript/reference/index/
Easy to call like: figure:plot{x, y, ...}
Shorthand options:
| key | explanation |
| :----: | :---------: |
| *1* | x-values  |
| *2* | y-values   |
| *ls* | line-style (options: "-", ".", "--")  |
| *lw* | line-width (numeric value - default 2) |
| *ms* | marker-size (numeric value - default 2) |
| *c* or *color* | sets color of line and marker |
| *mode* | shorter mode forms (options: "m"="markers", "l"="lines", "m+l" or "l+m"="markers+lines") |
]]
---@param self plotly.figure
---@param trace table
---@return plotly.figure
function figure.plot(self, trace)
  if not trace["line"] then trace["line"] = {} end
  if not trace["marker"] then trace["marker"] = {} end
  for name, val in pairs(trace) do
    if name == "ls" or name == 'style' then
      trace["line"]["dash"] = _dash_style[val]
      trace[name] = nil
    elseif name == "lw" or name == 'width' then
      trace["line"]["width"] = val
      trace[name] = nil
    elseif name == 1 then
      trace["x"] = val
      trace[name] = nil
    elseif name == 2 then
      trace["y"] = val
      trace[name] = nil
    elseif name == "ms" or name == 'size' then
      trace["marker"]["size"] = val
      trace[name] = nil
    elseif name == 'symbol' then
      trace["marker"]["symbol"] = val
      trace[name] = nil
    elseif name == "c" or name == "color" then
      trace["marker"]["color"] = val
      trace["line"]["color"] = val
      trace[name] = nil
    elseif name == "mode" and _mode_shorthand[val] then
      trace["mode"] = _mode_shorthand[val]
    end
  end

  self:add_trace(trace)
  self:update_layout(plotly.layout)
  return self
end -- figure.plot

---Updates the plotly figure layout (options can be seen here: https://plotly.com/javascript/reference/layout/)
function figure.update_layout(self, layout)
  for name, val in pairs(layout) do
    self["layout"][name] = val
  end
end

function figure.toplotstring(self)
  if self['layout'] == nil then self['layout'] = {} end
  if self['layout']['xaxis'] == nil then self['layout']['xaxis'] = {} end
  if self['layout']['yaxis'] == nil then self['layout']['yaxis'] = {} end
  if (not _3d_plotq) and _axis_equalq then
    self['layout']['xaxis']['scaleanchor'] = 'y'
    self['layout']['yaxis']['scaleratio'] = 1
  end

  if _3d_plotq then
    if self['layout']['zaxis'] == nil then self['layout']['zaxis'] = {} end
  else -- only valid for 2d graphs
    self['layout']['xaxis']['visible'] = _xaxis_visibleq
    self['layout']['xaxis']['showgrid'] = _gridline_visibleq
    self['layout']['yaxis']['visible'] = _yaxis_visibleq
    self['layout']['yaxis']['showgrid'] = _gridline_visibleq
    self['layout']['showlegend'] = _showlegendq
  end

  if _vecfield_annotations ~= nil then
    self['layout']['showlegend'] = false
    self['layout']['annotations'] = _vecfield_annotations
    _vecfield_annotations = nil
  end
  self:update_layout(__layout)
  if self['layout']['width'] == nil and self['layout']['height'] == nil then
    self['layout']['width'] = 600 -- 4x3
    self['layout']['height'] = 450
  elseif self['layout']['height'] == nil then
    self['layout']['height'] = self['layout']['width']
  else
    self['layout']['width'] = self['layout']['height']
  end
  if self['layout']['grid'] ~= nil then
    if type(self['layout']['grid']['rows']) == 'string' then
      self['layout']['grid']['rows'] = tonumber(self['layout']['grid']['rows'])
    end
    if type(self['layout']['grid']['columns']) == 'string' then
      self['layout']['grid']['columns'] = tonumber(self['layout']['grid']['columns'])
    end
    if self['layout']['grid']['columns'] == nil or
       self['layout']['grid']['rows'] == nil or
       self['layout']['grid']['rows'] * self['layout']['grid']['columns'] < #self['data'] then
      return '<html><body>Invalid grid: rows and/or columns not defined, or rows * columns &lt; the number of traces.</body></html>'
    end

    -- plotly-2.9.0.min.js, hopefully all versions, determines if grid options are used
    -- by checking whether the texts of xaxis and yaxis are different for traces
    for i = 1,#self['data'] do
      local s = tostring(i)
      self['data'][i]['xaxis'] = 'x' .. s -- they are different :-)
      self['data'][i]['yaxis'] = 'y' .. s
      if _3d_plotq then self['data'][i]['zaxis'] = 'z' .. s end
    end
  end

  -- Converting input
  local data_str = json.encode (self["data"])
  local layout_str = json.encode (self["layout"])
  local div_id -- dwang
  if not self.div_id then div_id = "plot" .. plotly.id_count end
  plotly.id_count = plotly.id_count+1
  local plot = [[<div id='%s'>
<script type="text/javascript">
  var data = %s
  var layout = %s
  Plotly.newPlot(%s, data, layout);
</script>
</div>
]] -- dwang, simplified
  return string.format(plot, div_id, data_str, layout_str, div_id)
end -- figure.toplotstring

function figure.tohtmlstring(self)
  local header = "<html>\n<meta charset=\"utf-8\">\n<head>" .. plotly.cdn_main .. "</head>\n"
  return header.."<body>\n" .. self:toplotstring() .. "</body>\n</html>"
end

---Saves the figure to an HTML file with *filename*
function figure.tofile(self, filename)
  _writehtml_failedq = false
  local html_str = self:tohtmlstring()
  local file = io.open(filename, "w")
  if file ~= nil then -- dwang
    file:write(html_str)
    file:close()
  else
    _writehtml_failedq = true
    print(string.format("Failed to create %s. The very device might not be writable.", filename))
  end
  return self
end -- figure.tofile

---Opens/shows the plot in the browser
function figure.show(self)
  self:tofile(tmp_plot_html_file)
  if not _writehtml_failedq then
    _open_url(tmp_plot_html_file) -- keep the file
    print("The graph is in " .. tmp_plot_html_file .. ' if you need it.')
  end
end

function plotly.figure()
  local fig = {data={}, layout={}, config={}}
  setmetatable(fig, {__index=figure})
  return fig
end

-- dwang, plot multiple functions/traces on a single figure
function plotly.plots(traces)
  local fig = plotly.figure()
  for i = 1, #traces do
    fig:plot(traces[i])
  end
  return fig
end



--[[ The code above is obtained from URL: https://github.com/kenloen/plotly.lua
     All variables in functions are made 'local' in addition to some changes. Some
     functions have been removed. All credit belongs to the original auther. --]]


--[[ The following code is obtained from URL: http://dkolf.de/dkjson-lua
     Names are changed to _dk_ and some functions or so have been removed.
     All credit belongs to the original auther. --]]

-- global dependencies:
local _dk_pairs, _dk_type, _dk_tostring = pairs, type, tostring
local _dk_error = error
local _dk_floor, _dk_huge = math.floor, math.huge
local _dk_gsub, _dk_strsub, _dk_strbyte, _dk_strfind, _dk_strformat =
      string.gsub, string.sub, string.byte, string.find, string.format
local _dk_strmatch = string.match
local _dk_concat = table.concat

local function _dk_isarray (tbl)
  local max, n, arraylen = 0, 0, 0
  for k,v in _dk_pairs (tbl) do
    if k == 'n' and _dk_type(v) == 'number' then
      arraylen = v
      if v > max then
        max = v
      end
    else
      if _dk_type(k) ~= 'number' or k < 1 or _dk_floor(k) ~= k then
        return false
      end
      if k > max then
        max = k
      end
      n = n + 1
    end
  end
  if max > 10 and max > arraylen and max > n * 2 then
    return false -- don't create an array with too many holes
  end
  return true, max
end -- _dk_isarray

local _dk_escapecodes = {
  ["\""] = "\\\"", ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f",
  ["\n"] = "\\n",  ["\r"] = "\\r",  ["\t"] = "\\t"
}

local function _dk_escapeutf8 (uchar)
  local value = _dk_escapecodes[uchar]
  if value then
    return value
  end
  local a, b, c, d = _dk_strbyte (uchar, 1, 4)
  a, b, c, d = a or 0, b or 0, c or 0, d or 0
  if a <= 0x7f then
    value = a
  elseif 0xc0 <= a and a <= 0xdf and b >= 0x80 then
    value = (a - 0xc0) * 0x40 + b - 0x80
  elseif 0xe0 <= a and a <= 0xef and b >= 0x80 and c >= 0x80 then
    value = ((a - 0xe0) * 0x40 + b - 0x80) * 0x40 + c - 0x80
  elseif 0xf0 <= a and a <= 0xf7 and b >= 0x80 and c >= 0x80 and d >= 0x80 then
    value = (((a - 0xf0) * 0x40 + b - 0x80) * 0x40 + c - 0x80) * 0x40 + d - 0x80
  else
    return ""
  end
  if value <= 0xffff then
    return _dk_strformat ("\\u%.4x", value)
  elseif value <= 0x10ffff then
    -- encode as UTF-16 surrogate pair
    value = value - 0x10000
    local highsur, lowsur = 0xD800 + _dk_floor (value/0x400), 0xDC00 + (value % 0x400)
    return _dk_strformat ("\\u%.4x\\u%.4x", highsur, lowsur)
  else
    return ""
  end
end -- _dk_escapeutf8

local function _dk_fsub (str, pattern, repl)
  -- gsub always builds a new string in a buffer, even when no match
  -- exists. First using find should be more efficient when most strings
  -- don't contain the pattern.
  if _dk_strfind (str, pattern) then
    return _dk_gsub (str, pattern, repl)
  else
    return str
  end
end -- _dk_fsub

local function _dk_quotestring (value)
  -- based on the regexp "escapable" in https://github.com/douglascrockford/JSON-js
  value = _dk_fsub (value, "[%z\1-\31\"\\\127]", _dk_escapeutf8)
  if _dk_strfind (value, "[\194\216\220\225\226\239]") then
    value = _dk_fsub (value, "\194[\128-\159\173]", _dk_escapeutf8)
    value = _dk_fsub (value, "\216[\128-\132]", _dk_escapeutf8)
    value = _dk_fsub (value, "\220\143", _dk_escapeutf8)
    value = _dk_fsub (value, "\225\158[\180\181]", _dk_escapeutf8)
    value = _dk_fsub (value, "\226\128[\140-\143\168-\175]", _dk_escapeutf8)
    value = _dk_fsub (value, "\226\129[\160-\175]", _dk_escapeutf8)
    value = _dk_fsub (value, "\239\187\191", _dk_escapeutf8)
    value = _dk_fsub (value, "\239\191[\176-\191]", _dk_escapeutf8)
  end
  return "\"" .. value .. "\""
end -- _dk_quotestring
json._dk_quotestring = _dk_quotestring

local function _dk_replace(str, o, n)
  local i, j = _dk_strfind (str, o, 1, true)
  if i then
    return _dk_strsub(str, 1, i-1) .. n .. _dk_strsub(str, j+1, -1)
  else
    return str
  end
end

-- locale independent _dk_num2str functions
local _dk_decpoint, _dk_numfilter

local function _dk_updatedecpoint ()
  _dk_decpoint = _dk_strmatch(_dk_tostring(0.5), "([^05+])")
  -- build a filter that can be used to remove group separators
  _dk_numfilter = "[^0-9%-%+eE" .. _dk_gsub(_dk_decpoint, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0") .. "]+"
end

_dk_updatedecpoint()

local function _dk_num2str (num)
  return _dk_replace(_dk_fsub(_dk_tostring(num), _dk_numfilter, ""), _dk_decpoint, ".")
end

local _dk_encode2 -- forward declaration

local function _dk_addpair (key, value, prev, level, buffer, buflen, tables, globalorder, state)
  local kt = _dk_type (key)
  if kt ~= 'string' and kt ~= 'number' then
    return nil, "type '" .. kt .. "' is not supported as a key by JSON."
  end
  if prev then
    buflen = buflen + 1
    buffer[buflen] = ","
  end
  -- When Lua is compiled with LUA_NOCVTN2S this will fail when
  -- numbers are mixed into the keys of the table. JSON keys are always
  -- strings, so this would be an implicit conversion too and the failure
  -- is intentional.
  buffer[buflen+1] = _dk_quotestring (key)
  buffer[buflen+2] = ":"
  return _dk_encode2 (value, level, buffer, buflen + 2, tables, globalorder, state)
end -- _dk_addpair

local function _dk_appendcustom(res, buffer, state)
  local buflen = state.bufferlen
  if _dk_type (res) == 'string' then
    buflen = buflen + 1
    buffer[buflen] = res
  end
  return buflen
end -- _dk_appendcustom

local function _dk_exception(reason, value, state, buffer, buflen, defaultmessage)
  defaultmessage = defaultmessage or reason
  local handler = state._dk_exception
  if not handler then
    return nil, defaultmessage
  else
    state.bufferlen = buflen
    local ret, msg = handler (reason, value, state, defaultmessage)
    if not ret then return nil, msg or defaultmessage end
    return _dk_appendcustom(ret, buffer, state)
  end
end -- _dk_exception

_dk_encode2 = function (value, level, buffer, buflen, tables, globalorder, state)
  local valtype = _dk_type (value)
  if value == nil then
    buflen = buflen + 1
    buffer[buflen] = "null"
  elseif valtype == 'number' then
    local s
    if value ~= value or value >= _dk_huge or -value >= _dk_huge then
      -- This is the behaviour of the original JSON implementation.
      s = "null"
    else
      s = _dk_num2str (value)
    end
    buflen = buflen + 1
    buffer[buflen] = s
  elseif valtype == 'boolean' then
    buflen = buflen + 1
    buffer[buflen] = value and "true" or "false"
  elseif valtype == 'string' then
    buflen = buflen + 1
    buffer[buflen] = _dk_quotestring (value)
  elseif valtype == 'table' then
    if tables[value] then
      return _dk_exception('reference cycle', value, state, buffer, buflen)
    end
    tables[value] = true
    level = level + 1
    local isa, n = _dk_isarray (value)
    local msg
    if isa then -- JSON array
      buflen = buflen + 1
      buffer[buflen] = "["
      for i = 1, n do
        buflen, msg = _dk_encode2 (value[i], level, buffer, buflen, tables, globalorder, state)
        if not buflen then return nil, msg end
        if i < n then
          buflen = buflen + 1
          buffer[buflen] = ","
        end
      end
      buflen = buflen + 1
      buffer[buflen] = "]"
    else -- JSON object
      local prev = false
      buflen = buflen + 1
      buffer[buflen] = "{"
      local order = globalorder
      if order then
        local used = {}
        n = #order
        for i = 1, n do
          local k = order[i]
          local v = value[k]
          if v ~= nil then
            used[k] = true
            buflen, msg = _dk_addpair (k, v, prev, level, buffer, buflen, tables, globalorder, state)
            if not buflen then return nil, msg end
            prev = true -- add a seperator before the next element
          end
        end
        for k,v in _dk_pairs (value) do
          if not used[k] then
            buflen, msg = _dk_addpair (k, v, prev, level, buffer, buflen, tables, globalorder, state)
            if not buflen then return nil, msg end
            prev = true -- add a seperator before the next element
          end
        end
      else -- unordered
        for k,v in _dk_pairs (value) do
          buflen, msg = _dk_addpair (k, v, prev, level, buffer, buflen, tables, globalorder, state)
          if not buflen then return nil, msg end
          prev = true -- add a seperator before the next element
        end
      end
      buflen = buflen + 1
      buffer[buflen] = "}"
    end
    tables[value] = nil
  else
    return _dk_exception ('unsupported type', value, state, buffer, buflen,
      "type '" .. valtype .. "' is not supported by JSON.")
  end
  return buflen
end -- _dk_encode2

function json.encode (value, state)
  state = state or {}
  local oldbuffer = state.buffer
  local buffer = oldbuffer or {}
  state.buffer = buffer
  _dk_updatedecpoint()
  local ret, msg = _dk_encode2 (value, state.level or 0,
                   buffer, state.bufferlen or 0, state.tables or {}, state.keyorder, state)
  if not ret then
    _dk_error (msg, 2)
  elseif oldbuffer == buffer then
    state.bufferlen = ret
    return true
  else
    state.bufferlen = nil
    state.buffer = nil
    return _dk_concat (buffer)
  end
end -- json.encode

--[[ The above code is obtained from URL: http://dkolf.de/dkjson-lua
     Names are changed to _dk_ and some functions or so have been removed.
     All credit belongs to the original auther. --]]


return mathly

--[[

1. Most functions provided in this mathly module, e.g., copy, disp, and display, can't be applied to tables
like x = {1, 2, age=20, 10, year=2024} with fields, for instance, age. It is designed simply for numerical
computing.

2. Part of modules dkjson.lua (http://dkolf.de/dkjson-lua) and plotly.lua (https://github.com/kenloen/plotly.lua)
is merged into this project to reduce dependencies and make it easier for users to download and use mathly. Though
some changes have been made, full credit belongs to the original authors for whom the original author of mathly
is very grateful.

3. This project was started first right in the downloaded code of the Lua module, matrix.lua, found
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