--[[

LUA MODULE

  Mathly - Turning Lua into a Tiny, Free but Powerful MATLAB and More

DESCRIPTION

  With provided functions, it is much easier and faster to do math,
  especially linear algebra, and plot graphs of functions.

  Part of modules dkjson.lua, http://dkolf.de/dkjson-lua, and plotly.lua,
  https://github.com/kenloen/plotly.lua, is merged into this project
  to reduce dependecies and make it easier for users to download and use
  mathly. Though some changes have been made, full credit belongs to
  the original authors for whom I am grateful.

FUNCTIONS PROVIDED IN THIS MODULE

    all, any, apply, cc, clc, clear, copy, cross, det, diag, disp, display, dot,
    expand, eye, findroot, flatten, fliplr, flipud, format, fstr2f, fzero, hasindex,
    horzcat, inv, iseven, isinteger, ismatrix, ismember, isodd, isvector, lagrangepoly,
    length, linsolve, linspace, lu, map, match, max, mean, merge, min, mtable, namedargs,
    newtonpoly, norm, ones, polynomial, polyval, printf, prod, qq, qr, rand, randi,
    range, remake, repmat, reshape, round, rr, rref, save, seq, size, sort, sprintf,
    std, strcat, submatrix, subtable, sum, tblcat, text, tic, toc, transpose, tt,
    unique, var, vectorangle, vertcat, who, zeros

    dec2bin, dec2hex, dec2oct, bin2dec, bin2hex, bin2oct, oct2bin, oct2dec,
    oct2hex, hex2bin, hex2dec, hex2oct

    cat, cd, dir, isdir, isfile, iswindows, ls, mv, pwd, rm

    arc, circle, contourplot, directionfield, line, parametriccurve2d, point, polarcurve2d,
    polygon, scatter, text, wedge; boxplot, freqpolygon, hist, hist1, histfreqpolygon,
    pareto, pie, slopefield, vectorfield2d ← Graphics objects passed to 'plot'.

    animate, manipulate, plot; plot3d, plotparametriccurve3d, plotparametricsurface3d,
    plotsphericalsurface3d

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

local mathly = {_TYPE='module', _NAME='mathly', _VERSION='06.09.2025.1'}

local mathly_meta = {}

function abs(x)    return map(math.abs, x) end
function random(x) return map(math.random, x) end
function sqrt(x)   return map(math.sqrt, x) end
function exp(x)    return map(math.exp, x) end
function log(x)    return map(math.log, x) end
function ceil(x)   return map(math.ceil, x) end
function floor(x)  return map(math.floor, x) end
function cos(x)    return map(math.cos, x) end
function sin(x)    return map(math.sin, x) end
function tan(x)    return map(math.tan, x) end
function acos(x)   return map(math.acos, x) end
function asin(x)   return map(math.asin, x) end
function atan(x)   return map(math.atan, x) end
function deg(x)    return map(math.deg, x) end
function rad(x)    return map(math.rad, x) end

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
end

-- if s = 's', return input as a string; otherwise, evaluate the input expression and return the result
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

local function _set_matrix_meta(A, vecq)
  if type(A) ~= 'table' then return A end
  if vecq == nil then vecq = true end
  if #A == 1 then
    if vecq and type(A[1]) == 'table' then A = A[1] end
  elseif type(A[1]) == 'table' then
    for i = 1, #A do setmetatable(A[i], mathly_meta) end
  end
  if type(A) == 'table' then setmetatable(A, mathly_meta) end
  return A
end

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
    return _set_matrix_meta(map(round1, x))
  end
end

-- r: {start, stop[, step]}; -1 --> #x
local function _index_range(R, x)
  local r = copy(R)
  if r == nil or r == '*' then
    r = {1, #x, 1}
  elseif type(r) == 'number' then
    r = {r, r, 1}
  end
  if r[1] < 0 then r[1] = #x + r[1] + 1 end
  if r[2] < 0 then r[2] = #x + r[2] + 1 end
  if r[1] < 0 or r[1] > #x or r[2] < 0 or r[2] > #x then
    error('Invalid range {start, stop, step}: start or stop are out of boundary.')
  end
  if r[3] == nil then
    if r[1] < r[2] then r[3] = 1 else r[3] = -1 end
  elseif r[1] < r[2] and r[3] < 0 then
    error('Invalid range {start, stop, step}: if start < stop, step must be positive.')
  elseif r[1] > r[2] and r[3] > 0 then
    error('Invalid range {start, stop, step}: if start > stop, step must be negative.')
  end
  assert(isinteger(r[1]) and isinteger(r[2]) and isinteger(r[3]), 'Invalid range {start, stop, step}: start, stop, and step must be all integers.')
  return r
end

-- rr(x):            make x a row vector and return it
-- rr(x, i):         return the ith row of x
-- rr(x, i, irange): return ith row on specified columns
--
-- if i is a list of indice, return rows defined in the list and in order (the latter allows rearrangement and repetition of rows)
--
-- i = -1, last row; i = -2, the row before the last row; ... similar with start and stop
function rr(x, I, irange)
  if I == nil then
    return setmetatable({flatten(x)}, mathly_meta) -- convert x to a row vector
  else
    local matrixq = type(x[1]) == 'table'
    assert(getmetatable(x) == mathly_meta, 'rr(x, i...): x must be a mathly matrix.')
    irange = _index_range(irange or '*', qq(matrixq, x[1], x))
    local rows = {}
    if type(I) ~= 'table' then I = { I } end
    local X = qq(matrixq, x, {x})
    for m = 1, #I do
      local i = I[m]
      local siz = #X
      if i < 0 then i = siz + i + 1 end -- i = -1, -2, ...
      if i > 0 and i <= siz then
        local y = {}
        for j = irange[1], irange[2], irange[3] do
          y[#y + 1] = X[i][j]
        end
        rows[m] = y
      else
        error('rr(x, i...): i = ' .. tostring(i) .. ' is out of range.')
      end
    end
    return setmetatable(rows, mathly_meta)
  end
end

-- cc(x):            make x a column vector and return it
-- cc(x, i):         return the ith column of x
-- cc(x, i, irange): return ith column with on specified rows
--
-- if i is a list of indice, return columns defined in the list and in order (the latter allows rearrangement and repetition of columns)
-- i = -1, last columns; i = -2, the column before the last column; ...
function cc(x, I, irange)
  if I == nil then
    return setmetatable(map(function(x) return {x} end, flatten(x)), mathly_meta) -- convert x to a column vector
  else
    assert(getmetatable(x) == mathly_meta, 'cc(x, i...): x must be a mathly matrix.')
    irange = _index_range(irange, x)
    if type(I) ~= 'table' then I = { I } end
    local abs = math.abs
    local cols = mathly(math.ceil((abs(irange[2] - irange[1]) + 1) / abs(irange[3])), #I, 0)
    for jj = 1, #I do
      local j = I[jj]
      local siz = #x[1]
      if j < 0 then j = siz + j + 1 end -- j = -1, -2, ...
      if j > 0 and j <= siz then
        local ii = 1
        for i = irange[1], irange[2], irange[3] do
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

-- convert x to a table (columnwisely if it's a mathly matrix) or flatten it first
-- and return a slice of it
-- want row wise? see flatten(t)
--
-- tt or subtable? tt converts first, while subtable doesn't.
function tt(x, irange) -- make x an ordinary table
  local y = {}
  if getmetatable(x) == mathly_meta then -- column wise
    if #x == 1 then -- row vector
      y = x[1]
    else
      if type(x[1]) == 'table' then
        for j = 1, #x[1] do
          for i = 1, #x do y[#y + 1] = x[i][j] end
        end
      else
        for i = 1, #x do y[i] = x[i] end
      end
    end
  elseif type(x) == 'table' then
    y = flatten(x)
  else
    return {x}
  end

  irange = _index_range(irange, y)
  local z = {}
  for i = irange[1], irange[2], irange[3] do
    z[#z + 1] = y[i]
  end
  return setmetatable(z, mathly_meta)
end

local function _max_min_shared(f, x) -- column wise if x is a matrix
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
end

function max(x) return _max_min_shared(math.max, x) end
function min(x) return _max_min_shared(math.min, x) end

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

-- apply a function to each atomic entry in a table and keep the structure of the table
local function _map(f, ...)
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end
  if type(args[1]) ~= 'table' then
    return f(table.unpack(args))
  else
    local y = {}
    for k, v in pairs(args[1]) do
      local arg = {}
      for j = 1,#args do
        if type(args[j]) ~= 'table' then
          arg[#arg + 1] = args[j] -- 6/5/25
        else
          arg[#arg + 1] = args[j][k]
        end
      end
      if type(v) ~= 'table' then
        y[k] = f(table.unpack(arg))
      else
        y[k] = _map(f, table.unpack(arg))
      end
    end
    return y
  end
end

function map(f, ...)
  if type(f) == 'string' then f = fstr2f(f) end
  local metaq = false
  for _, v in pairs{...} do
    if getmetatable(v) == mathly_meta then
      metaq = true
      break
    end
  end
  local x = _map(f, ...)
  if metaq or isvector(x) or ismatrix(x) then x = _set_matrix_meta(x) end
  return x
end

-- call a function with arguments
function apply(f, args)
  if type(f) == 'string' then f = fstr2f(f) end
  return f(table.unpack(args))
end

-- 1. make a COPY of A, or
-- 2. COPY to A from B
function copy(A, rrange, crange, B, rrange1, crange1)
  local function _copy(x) -- for general purpose
    local y = {}
    for k, v in pairs(x) do
      if type(v) ~= 'table' then
        y[k] = v
      else
        y[k] = _copy(v)
      end
    end
    return y
  end

  if type(A) ~= 'table' then return A end
  if type(A[1]) ~= 'table' then crange, B, rrange1 = nil, crange, B end
  local mathlyq = getmetatable(A) == mathly_meta
  local v
  if B == nil then -- make a copy of A
    if not mathlyq and rrange == nil and crange == nil then
      v = _copy(A)
      goto endcopy
    else
      local y, I = {}, 1
      rrange = _index_range(rrange or {1, -1, 1}, A)
      if crange == nil then
        for i = rrange[1], rrange[2], rrange[3] do
          if type(A[i]) ~= 'table' then y[I] = A[i] else y[I] = _copy(A[i]) end
          I = I + 1
        end
      else
        crange = _index_range(crange, A[1])
        for i = rrange[1], rrange[2], rrange[3] do
          local J = 1
          y[I] = {}
          for j = crange[1], crange[2], crange[3] do
            y[I][J] = A[i][j]; J = J + 1
          end
          I = I + 1
        end
      end
      v = y
      goto endcopy
    end
  end

  -- copy to A from B
  rrange = _index_range(rrange, A)
  if type(A[1]) == 'table' then
    crange = _index_range(crange, A[1])
    if type(B) == 'table' then
      local b
      if getmetatable(B) ~= mathly_meta then
        if rrange[1] == rrange[2] then
          b = rr(B); crange1 = rrange1; rrange1 = {1, 1, 1}
        elseif crange[1] == crange[2] then
          b = cc(B); crange1 = {1, 1, 1}
        else
          b = mathly(B)
        end
      else
        b = B
      end
      rrange1 = _index_range(rrange1, b)
      crange1 = _index_range(crange1, b[1])
      if math.ceil((rrange[2] - rrange[1] + 1) / rrange[3]) > math.ceil((rrange1[2] - rrange1[1] + 1) / rrange1[3]) or
         math.ceil((crange[2] - crange[1] + 1) / crange[3]) > math.ceil((crange1[2] - crange1[1] + 1) / crange1[3]) then
        error('copy(A, rrange, crange, B, rrange1, crange1): not enough data in B for the copy.')
      end
      local I, J
      I = rrange1[1]
      for i = rrange[1], rrange[2], rrange[3] do
        J = crange1[1]
        for j = crange[1], crange[2], crange[3] do
          A[i][j] = b[I][J]
          J = J + crange1[3]
        end
        I = I + rrange1[3]
      end
    else
      for i = rrange[1], rrange[2], rrange[3] do
        for j = crange[1], crange[2], crange[3] do A[i][j] = B end
      end
    end
  else -- treat A and B as a simple table: copy(A, rrange, B, rrange1)
    if type(B) == 'number' then
      for i = rrange[1], rrange[2], rrange[3] do A[i] = B end
    else
      rrange1 = _index_range(rrange1, B)
      if math.ceil((rrange[2] - rrange[1] + 1) / rrange[3]) > math.ceil((rrange1[2] - rrange1[1] + 1) / rrange1[3]) then
        error('copy(A, irange, B, irange1): not enough data in table B for the copy.')
      end
      local I = rrange1[1]
      for i = rrange[1], rrange[2], rrange[3] do
        A[i] = B[I]; I = I + rrange1[3]
      end
    end
  end
  v = A
::endcopy::
  if mathlyq or isvector(v) or ismatrix(v) then _set_matrix_meta(v, false) end
  return v
end -- copy

-- Return the same data as in t but with no repetitions.
function unique(t)
  if type(t) ~= 'table' then return t end
  local x = copy(t)
  table.sort(x)
  local y
  local abs = math.abs
  if #x > 0 then y = {x[1]} else return {} end
  for i = 2, #x do
    if abs(x[i] - x[i - 1]) > eps then -- not equal
      y[#y + 1] = x[i]
    end
  end
  return setmetatable(y, mathly_meta)
end

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

-- x is a table or row/column vector: return 1 if all elements of the table make f(x) true.
-- x is a mathly matrix: return a row vector of 1's and 0's with each element indicating
--   if all of the elements of the corresponding column of the matrix make f(x) true.
--
-- f(x) return true or false (default to: x ~= 0)
--
-- mathlymatrixq? usually, ignore it. if just need yes (1) or no (0), set it to false.
function all(x, f, mathlymatrixq)
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
        return setmetatable(y, mathly_meta)
      end
    end
  end

  if type(x) == 'table' then
    return traverse(x)
  else
    error('all(x, f): x must be a table or mathly matrix.')
  end
end -- all

-- x is a table or row/column vector: return 1 if there is any element of the table which makes f(x) true.
-- x is a mathly matrix: return a row vector of 1's and 0's with each element indicating
--   if there is any element of the corresponding column of the matrix which makes f(x) true.
--
-- f(x) return true or false (default to: x ~= 0)
--
-- mathlyq? usually, ignore it. if just need yes (1) or no (0), set it to false.
function any(x, f, mathlyq)
  if mathlyq == nil then mathlyq = true end
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

  if mathlyq then
    if getmetatable(x) == mathly_meta then
      local m, n = size(x)
      if m > 1 and n > 1 then
        local y = zeros(1, #x[1])
        for j = 1, #x[1] do
          for i = 1, #x do
            if f(x[i][j]) then y[j] = 1; break end
          end
        end
        return setmetatable(y, mathly_meta)
      end
    end
  end

  if type(x) == 'table' then
    return traverse(x)
  else
    error('any(x, f): x must be a table or mathly matrix.')
  end
end -- any

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
function match(A, f)
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
end

local function _dec2bho(x, title, f)
  if isinteger(x) then
    return f(x)
  elseif type(x) == 'table' then
    local X = copy(x)
    demathly(X)
    return map(f, X)
  else
    error(title .. '(x): x must be an integer or a table of integers.')
  end
end

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
end

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
end

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
end

--// function _largest_width_dplaces(t)
-- find the largest width of integers/strings and number of decimal places
-- -3.14 --> 1, 2; 123 --> 3, 0
-- only format numbers in tables
local function _largest_width_dplaces(t) -- works with strings, numbers, and table of tables
  if type(t) ~= 'table' then t = {t} end
  local width, dplaces = 0, 0
  local x, w, d
  for i = 1, #t do
    if type(t[i]) == 'table' then
      w, d = _largest_width_dplaces(t[i])
      if w > width then width = w end
      if d > dplaces then dplaces = d end
    elseif type(t[i]) ~= 'string' then
      x = math.abs(t[i]) -- ignore sign
      if type(x) == 'integer' then
        w = #tostring(x)
      else
        w = #tostring(math.floor(t[i]))
        d = #tostring(x) - w -- decimal point counted
        if d > dplaces then dplaces = d end
      end
      if w > width then width = w end
    end
  end
  return width, dplaces
end

--[[ Lua 5.4.6
The largest number print or io.write prints each digit is ±9223372036854775807,
otherwise, ±9.2233720368548e+18 is printed ---]]

local function _set_disp_format(t)
  local iwidth, dplaces, dispwidth
  iwidth, dplaces = _largest_width_dplaces(t)
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
  elseif type(x) == 'number' then
    return string.format(_float_format, x)
  else
    return x
  end
end

local function _tostring1(x)
  if isinteger(x) then
    return string.format(_int_format1, x)
  elseif type(x) == 'number' then
    return string.format(_float_format1, x)
  else
    return x
  end
end

-- list all user defined variables (some may be defined by some loaded modules)
-- if a list of variables are needed by other code, pass false to it: who(false)
function who(userq) -- ~R
  if userq == nil then userq = true end
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
  if userq then -- print the list
    if #list >= 1 then io.write(list[1]) end
    for i = 2, #list do
      io.write(', ', list[i])
    end
    io.write('\n')
  else
    return list
  end
end

-- generate the string version of a variable y starting with 'y = '
-- firstq    -- print ',' or not before printing an entry
-- titleq    -- for save(...)
-- printnowq -- for display(x) with large matrices
local function _vartostring_lua(x, firstq, titleq, printnowq) -- print x, for general purpose
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

-- print a mathly matrix while display(x) prints a table with its structure
-- disp({{1, 2, 3, 4}, {2, -3, 4, 5}, {3, 4, -5, 6}})
function disp(A)
  if getmetatable(A) == mathly_meta then
    _set_disp_format(A)
    local rows, columns = size(A)
    if type(A[1]) ~= 'table' then
      for i = 1, columns do io.write(_tostring(A[i]), ' ') end
      io.write('\n')
    else
      for i = 1, rows do
        for j = 1, columns do io.write(_tostring(A[i][j]), ' ') end
        io.write('\n')
      end
    end
  else
    display(A)
  end
end

-- print a table with its structure while disp(x) prints a matrix
-- display({1, 2, {3, 4, opt = {height = 3, width = 5}, 6, 'string', false}, 7, 8})
function display(x) -- print x, for general purpose
  if x == nil then print('nil'); return end
  print(_vartostring_lua(x, nil, false, true))
end

function isvector(x)
  if type(x) ~= 'table' then return false end
  for k, v in pairs(x) do
    if type(k) ~= 'number' or type(v) ~= 'number' then return false end
  end
  return true
end

-- test if x is a matrix simply by type(x) == 'table' and type(x[1]) == 'table'
-- ismatrix(x) is time consuming but usually not necessary
function ismatrix(x)
  if type(x) ~= 'table' or type(x[1]) ~= 'table' then return false end
  local n = #x[1]
  for i = 1, #x do
    if type(x[i]) ~= 'table' or #x[i] ~= n then return false end
    for j = 1, #x[i] do
      if type(x[i][j]) ~= 'number' then return false end
    end
  end
  return true
end

-- generate the string version of MATLAB variable y starting with 'y ='
local function _vartostring_matlab(x)
  local s = _vartostring_lua(x, nil, true)
  x = load('return ' .. x)()
  if getmetatable(x) == mathly_meta or ismatrix(x) then -- save matrices
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
end

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

-- clear LUA console
function clc()
  local x = os.execute("cls") or os.execute('clear')
end

-- Ternary "operator" ~ C/C++ ? :
function qq(c, t, f) return (c and t) or f end -- if c then return t else return f end

local __is_windows = package.config:sub(1,1) == '\\'
function iswindows() return __is_windows end

--↓↓↓↓↓↓ basic file system commands ↓↓↓↓↓↓--
function pwd() return os.getenv("PWD") or io.popen("cd"):read() end

function isfile(fname)
  if __is_windows then
    local cmd1 = 'dir "' .. fname .. '" > nul 2>&1'
    local cmd2 = 'dir /A:D "' .. fname .. '" > nul 2>&1'
    return os.execute(cmd1) ~= nil and os.execute(cmd2) == nil
  else
    return os.execute('test -f "' .. fname .. '" > /dev/null') ~= nil
  end
end

function isdir(fname)
  local cmd
  if __is_windows then
    cmd = 'dir /A:D "' .. fname .. '" > nul 2>&1'
  else
    cmd = 'test -d "' .. fname .. '" > /dev/null 2>/dev/null'
  end
  return os.execute(cmd) ~= nil
end

-- allow characters ? and * in file names
function ls(path, re, printq)
  local files, folders = {}, {}
  if path == nil then
    path = pwd()
    if re == nil then re = '*' end
  elseif path:match('[%?|%*]') == nil and isdir(path) then
    if re == nil then re = '*' end
  end
  if printq == nil then printq = true end
  local sep = qq(iswindows(), '\\', '/')
  local rootq = path:sub(1, 1) == sep

  if re == nil then
    re = ''
    local path1 = ''
    for x in path:gmatch('([^' .. sep .. ']+)') do
      if path1 == '' then
        path1 = re
      else
        path1 = path1 .. sep .. re
      end
      re = x
    end
    if path1 == '' then path = pwd() else path = path1 end
    if rootq and not __is_windows then path = sep .. path end
  end
  re = re:gsub('%.', '%%.')
  re = re:gsub('%?', '.')
  re = re:gsub('%*', '.*')
  re = '^' .. re

  for f in io.popen(qq(__is_windows, "dir /b ", "ls -pa ") .. '"'.. path .. '"'):lines() do
    if f == './' or f == '../' then -- linux
    elseif isdir(path .. sep .. f) then
      folders[#folders + 1] = f
    elseif f:match('^%.+/$') == nil and f:match(re) ~= nil then
      files[#files + 1] = f
    end
  end
  if printq then
    for i = 1, #files   do print('   ' ..  files[i]) end
  end
  return files, path, folders
end
function dir(path) return ls(path) end

function cat(file)
  local f = io.open(file, "r")
  if f ~= nil then
    io.close(f)
    for x in io.lines(file) do print(x) end
  else
    print("File not found.")
  end
end

function cd(path) os.execute('cd "' .. fname .. '"') end

function mv(fname1, fname2)
  os.execute(qq(__is_windows, 'ren "', 'mv "') .. fname1 .. '" "' .. fname2 .. '"')
end

-- e.g., linux: rm(fname, '-fr'); windows: rm(fname, '/F /S')
function rm(fname, opt)
  if opt == nil then opt = '' end
  os.execute(qq(__is_windows, 'del ', 'rm ') .. opt .. ' "'.. fname .. '"')
end
--↑↑↑↑↑↑ basic file system commands ↑↑↑↑↑↑--

-- clear user-defined variables
function clear()
  local vars = who(false)
  for i = 1, #vars do
    load(string.format("%s = nil", vars[i]))()
  end
  if _ ~= nil then _ = nil end
  axisnotsquare()
  showaxes()
  showgridlines()
  shownotlegend()
end

-- generates an evenly spaced sequence/table of 'len' numbers on the interval [from, to]. same as linspace(...).
function seq(from, to, len) -- ~R, generate a sequence of numbers
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
  return setmetatable(lst, mathly_meta)
end

-- generates an evenly spaced sequence/table of 'len' numbers on the interval [from, to]. same as seq(...).
function linspace(from, to, len)
  len = len or 100
  assert(len > 0, 'linspace(from, to, len): len must be positive.')
  if from > to then from, to = to, from end
  return seq(from, to, len)
end

-- calculates the product of all elements of a table
-- calculates the product of all elements of each column in a matrix
function prod(x)
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

-- calculates the sum of all elements of a table
-- calculates the sum of all elements of each column in a matrix
function sum(x)
  if type(x) == 'number' then
    return x
  elseif type(x) == 'table' then
    if type(x[1]) == 'table' then -- a "matrix"
      if #x == 1 then -- {{1, 2, ...}} b/c mathly{1, 2, 3} gives {{1, 2, 3}}
         return sum(x[1])
      end
      local s = {}  -- column wise
      for j = 1,#x[1] do
        s[j] = 0
        for i = 1,#x do
          s[j] = s[j] + x[i][j]
        end
      end
      if #s == 1 then
        return s[1]
      else
        return setmetatable(s, mathly_meta)
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
end

-- calculates the mean of all elements of a table
-- calculates the mean of all elements of each column in a matrix
function mean(x)
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
      return setmetatable(means, mathly_meta)
    end
  end
end -- mean

local function _stdvar(x, opt, sqrtq)
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
        local avg = mean(copy(x, '*', j))
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
      return setmetatable(s, mathly_meta)
    end
  else
    error('std(x): x must be a table or matrix of numbers.')
  end
end -- _stdvar

-- calculates the standard deviation (or variance) of all elements of a table
-- calculates the standard deviation (or variance) of all elements of each column in a matrix
--
-- if opt = 0 (default), find the standard deviation (or variance) of a population
-- otherwise, find that of a sample
function std(x, opt) return _stdvar(x, opt, true) end
function var(x, opt) return _stdvar(x, opt, false) end

-- calculate the dot/inner product of two vectors
function dot(a, b)
  local t1, t2 = flatten(a), flatten(b)
  assert(#t1 == #t2, 'dot(a, b): a and b must be vectors of same size.')
  return sum(t1 * t2)
end

-- calculate the cross product of two vectors
function cross(a, b)
  local t1, t2 = flatten(a), flatten(b)
  assert(#t1 == 3 and #t2 ==3, 'cross(a, b): a and b must be 3D vectors.')
  return setmetatable({a[2] * b[3] - a[3] * b[2], a[3] * b[1] - a[1] * b[3], a[1] * b[2] - a[2] * b[1]}, mathly_meta)
end

-- calculate the angle between two vectors
function vectorangle(a, b)
  local t1, t2 = flatten(a), flatten(b)
  assert(#t1 == #t2, 'vectorangle(a, b): a and b must be vectors of same size.')
  local x = acos(dot(t1, t2) / (norm(t1) * norm(t2)))
  return x, '(' .. tostring(deg(x)) .. ' degree)'
end

-- generates a evenly spaced sequence/table of numbers starting at 'start' and likely ending at 'stop' by 'step'.
function range(start, stop, step) -- ~Python but inclusive
  if start == nil then error('range(start, stop, step): no input.') end
  if stop == nil then
    stop = start
    if start > 0 then start = 1 else start = -1 end
  end
  if step == nil then
    if start < stop then step = 1 else step = -1 end
  end
  if start <= stop and step < 0 then
    error(sprintf("range(%d, %d, step): step must be positive.\n", start, stop))
  elseif start >= stop and step > 0 then
    error(sprintf("range(%d, %d, step): step must be negative.\n", start, stop))
  end

  local v, k = {}, 1
  if step > 0 then
    while start <= stop + 100*eps do
      v[k] = start; k = k +1
      start = start + step
    end
  else
    while start >= stop - 100*eps do
      v[k] = start; k = k +1
      start = start + step
    end
  end
  return setmetatable(v, mathly_meta)
end

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
end

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
end

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

  local s = ''
  local non1stq = false
  for i = 1, #x do
    if coefs[i] ~= 0 then
      local op = ' + '
      local coef = coefs[i]
      if abs(coef) > 10*eps then
         if coef < 0 then
          if non1stq then s = s .. ' - ' else s = s .. ' -' end
          coef = -coef
        else
          if non1stq then s = s .. ' + ' end
        end
        if abs(coef - 1) > 10*eps then s = s .. tostring(coef) .. '*' end
        non1stq = true
        local firstq = true
        for j = 1, #x do
          if j ~= i then
            if not firstq then s = s .. '*' end
            if abs(x[j]) > 10*eps then
              if x[j] > 0 then
                s = s .. '(x - ' .. tostring(x[j]) .. ')'
              else
                s = s .. '(x + ' .. tostring(-x[j]) .. ')'
              end
            else
              s = s .. 'x'
            end
            firstq = false
          end
        end
      end
    end
  end
  if xx == nil then return s end
  return _set_matrix_meta(map(fstr2f('@(x) ' .. s), xx))
end -- lagrangepoly

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
  local s = ''
  local abs = math.abs
  for i = 1, n do -- coef a[i]
    local skipq = false -- Lua 5.4.6 doesn't provide 'continue'
    if i == 1 then
      s = s .. tostring(a[i]) -- sprintf("%g", a[i])
    else
      if abs(a[i]) < 10*eps then -- a[i] = 0
        skipq = true
      elseif a[i] > 0 then
        s = s .. ' + '
        if abs(a[i] - 1) > 10*eps then -- don't output 1
          s = s .. tostring(a[i]) .. '*'
        end
      else
        s = s .. ' - '
        if abs(a[i] + 1) > 10*eps then -- don't output 1
          s = s .. tostring(-a[i]) .. '*'
        end
      end
    end

    if not skipq then -- skip terms with coef 0
      local non1stq = false
      for j = 1, i - 1 do
        if non1stq then s = s .. '*' end
        if abs(x[j]) < 10*eps then -- x = 0
          s = s .. "x"
        elseif x[j] > 0 then
          s = s .. '(x - ' .. tostring(x[j]) .. ')' -- sprintf("(x - %g)", x[j])
        else
          s = s .. '(x + ' .. tostring(-x[j]) .. ')'
        end
        non1stq = true
      end
    end
  end
  if xx == nil then return s end
  return _set_matrix_meta(map(fstr2f('@(x) ' .. s), xx))
end -- newtonpoly

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
  local B = linsolve(mathly(A), y) -- coefs of polynomial

  local s = ''
  local not1stq = false
  local abs = math.abs
  for i = 1, #B do
    if abs(B[i]) > 10*eps then -- B[i] ~= 0
      local coef = B[i]
      if coef < 0 then
        if not1stq then s =  s .. ' - ' else s = s .. ' -' end
        coef = -coef
      else
        if not1stq then s = s .. ' + ' end
      end
      if abs(coef - 1) < eps then -- coef == 1
        if i == #B then coef = '1' else coef = '' end -- no 1*x^n
      else
        coef = tostring(coef)
        if i ~= #B then coef = coef .. '*' end
      end
      if i == #B then
        s = s .. coef
      elseif i == #B - 1 then
        s = s .. coef .. 'x'
      else
        s = s .. coef .. 'x^' .. tostring(#B - i)
      end
      not1stq = true
    end
  end
  if xx == nil then return s, B end
  return _set_matrix_meta(map(fstr2f('@(x) ' .. s), xx))
end -- polynomial

-- evaluate a polynomial p at x
-- example: polyval({6, -3, 4}, 5) -- evalue 6 x^2 - 3 x + 4 at x = 5
function polyval(p, x)
  local msg = 'polyval(p, x): invalid p. It must be a table of the coefficients of a polynomial.'

  if p == nil or type(p) ~= 'table' then
    error(msg)
  end

  p = tt(p)
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
  return _set_matrix_meta(vs)
end -- polyval

-- calculate the Euclidean/Frobenius norm of a vector/matrix
-- if x is a mxn matrix with m, n ≥ 2, MATLAB: norm(x, "fro")
function norm(x)
  if type(x) ~= 'number' and type(x) ~= 'table' then
    error('norm(x): x must be a table, vector or matrix of numbers.')
  end
  local v = flatten(x)
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
end

-- generates a table of r subtables of which each has c elements, with each element equal to val
-- if c == nil, c = r;
-- if r == 1 or c == 1, return a simple table (so that it can be accessed like a[i] as in MATLAB)
-- if val == nil, it is a random number.
local function _create_table(r, c, val)
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
  if c == nil then c = r end
  for i = 1, r do
    x[i] = {}
    for j = 1,c do x[i][j] = f() end
  end
  return _set_matrix_meta(x)
end

-- check "rigourously" if t can be a mathly ovject, a vector or a matrix
-- igore input like t = {1, 2, 3, date=19890604}
function mathly:new(t, c, val)
	if type(t) == "table" then -- check for a given matrix
		if c ~= nil then return reshape(t, c, val) end
    local n = -1 -- t is a flat table
    for _, v in pairs(t) do
      if type(v) == 'table' then n = #v; break end
    end
    if n < 0 then
      for i = 1, #t do
        if type(t[i]) ~= 'number' then error('mathly:new: invalid input', t[i]) end
      end
      return setmetatable(t, mathly_meta) -- a mathly table
    else
      for i = 1, #t do
        assert(type(t[i]) == 'table' and #t[i] == n,'mathly: invalid input:')
        for j = 1, #t[i] do
          if type(t[i][j]) ~= 'number' then
            error('mathly:new: invalid input', t[i][j])
          end
        end
      end
      -- return _set_matrix_meta(rows) -- let mathly{{1, 2}} be a mathly matrix
      for i = 1, #t do setmetatable(t[i], mathly_meta) end -- t is a mathly matrix
      return setmetatable(t, mathly_meta)
    end
	end
  assert(isinteger(t) and isinteger(c), 'mathly(rows, columns, ...): rows and columns must be integer.')
  return _create_table(t, c, val)
end

-- generates a special table, i.e., a rxr identity matrix
function eye(row)
  local A = {}
  for i = 1, row do
    A[i] = {}
    for j = 1, row do A[i][j] = 0 end
    A[i][i] = 1
    setmetatable(A[i], mathly_meta)
  end
  return setmetatable(A, mathly_meta)
end

-- return a rxc mathly matrix with each entry = 1 (c defaults to r)
function ones(r, c) return _create_table(r, c, 1) end

-- return a rxc mathly matrix with each entry = 0 (c defaults to r)
function zeros(r, c) return _create_table(r, c, 0) end

-- return a rxc mathly matrix with each entry = random number (c defaults to r)
function rand(r, c) return _create_table(r, c, 'random') end

-- return a mathly matrix with normally distributed random numbers
-- mu and sigma default to 0 and 1, respectively
function randn(r, c, mu, sigma)
  mu = mu or 0
  sigma = sigma or 1
  _next_gaussian_rand = nil -- 'global', reset
  local x = _create_table(r, c, 'gaussian')
  if mu == 0 and sigma == 1 then
    return x
  else
    return map(function(x) return mu + sigma * x end, x)
  end
end

--// randi(imax, m, n), randi({imin, imax}, m, n)
-- generate a mxn matrix of which each entry is a random integer in [1, imax] or [imin, imax]
function randi(imax, m, n)
  local imin = 1
  if type(imax) == 'number' then
    if imax < 1 then imin = 0 end
  elseif type(imax) == 'table' then
    imin, imax = imax[1], imax[2]
  end
  assert(isinteger(imin) and isinteger(imax),
         'randi(imax, m, n), randi({imin, imax}, m, n): imin and imax must be integer.')
  if imin > imax then imin, imax = imax, imin end
  if m == nil then return math.random(imin, imax) end
  if n == nil then n = m end

  local B = {}
  -- math.randomseed(os.time()) -- keep generating same seq? Lua 5.4.6
  for i = 1, m do
    B[i] = {}
    for j = 1, n do
      B[i][j] = math.random(imin, imax)
    end
  end
  return _set_matrix_meta(B)
end

--// tic()
-- start a time stamp to measure elapsed time
local elapsed_time = nil
-- os.clock() behaves differently in various platforms!!!
function _elapsed_time()
  if __is_windows then return os.clock() else return os.time() end
end
function tic() elapsed_time = _elapsed_time() end

-- return elapsed time from last calling tic()
function toc()
  if elapsed_time == nil then
    print("Please call tic() first.")
    return 0, ''
  end
  return _elapsed_time() - elapsed_time, 'secs.'
end

-- remove the structure of a table and returns the resulted table.
-- if t is a mathly matrix, the result is row wise (rather than column wise)
-- want column wise? use tt(t)
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
  return setmetatable(y, mathly_meta)
end

-- if t table has recursively an index, idx, return true.
function hasindex(t, idx)
  if type(t) ~= 'table' then
    return false
  elseif t[idx] ~= nil then
      return true
  else
    for _, v in pairs(t) do
      if type(v) == 'table' and hasindex(v, idx) then
        return true
      end
    end
    return false
  end
end

local function _hasanyindex(t, indice)
  for i = 1, #indice do
    if hasindex(t, indice[i]) then return true end
  end
  return false
end

function isinteger(x) return math.type(x) == 'integer' end

-- return true if x is an entry of a vector, e.g., ismember(5, {1,2,3,4,5,6}),
-- ismember('are', {'We', 'are', 'the', 'world'})
function ismember(x, v)
  for _, val in pairs(v) do
    if x == val then return true end
  end
  return false
end

local _axis_equalq       = false
local _xaxis_visibleq    = true
local _yaxis_visibleq    = true
local _gridline_visibleq = true
local _showlegendq       = false
local _vecfield_annotations = nil

-- plot the graphs of functions in a way like in MATLAB with more features
local plotly = {}
function plot(...)
  local axis_equalq = _axis_equalq
  local xaxis_visibleq = _xaxis_visibleq
  local yaxis_visibleq = _yaxis_visibleq
  local gridline_visibleq = _gridline_visibleq
  local showlegendq = _showlegendq

  _3d_plotq = false
  plotly.layout = {}

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
      goto end_for
    elseif type(v) == 'string' and string.sub(v, 1, 1) == '@' then -- @ is followed by expr in terms of x
      args[#args + 1] = fstr2f(v)
      adjustxrangeq = true
      goto end_for
    end

    if type(v) == 'table' then
      if v[1] == 'pareto' then
        for i = 1, #v[#v] do
          traces[#traces + 1] = v[#v][i][2]
        end
        v[#v] = nil
        v[1] = 'graph'
      end

      if v[1] == 'dotplot' or v[1] == 'text' then -- graph object: {'text', trace}
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
      elseif v.type == 'pie' then
        if v.layout ~= nil then  layout_arg[#layout_arg + 1] = {layout = v.layout} end
        traces[#traces + 1] = v
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
::end_for::
  end

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
            return exit_plot
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
              plotly.layout[k_] = v_
              if k_ == 'grid' then
                plotly.layout[k_]['pattern'] = 'independent'
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
        local f = traces[i][1][2]
        traces[i][1] = linspace(x_start, x_stop, math.ceil(math.abs(x_stop - x_start)) * 10)
        traces[i][2] = map(f, traces[i][1])
      end
    end
  end

  plotly.plots(traces):show()

::exit_plot::
  plotly.layout = {}
  _axis_equalq = axis_equalq
  _xaxis_visibleq = xaxis_visibleq
  _yaxis_visibleq = yaxis_visibleq
  _gridline_visibleq = gridline_visibleq
  _showlegendq = showlegendq
end -- plot

local function _plot_interval(start, stop, step)
  local tq = type(start) == 'table'
  if tq then
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
  if tq then return {start, stop, step} else return start, stop end
end

local function _set_resolution(r, n)
  n = n or 500
  if r == nil or type(r) ~= 'number' or r < n then r = n end
  return r
end

-- merge two tables of any structure into a single one
function merge(t1, t2)
  local t = {}
  if type(t1) ~= 'table' then
    if type(t2) ~= 'table' then
      if t1 ~= t2 then
        t = {t1, t2}
      else
        t = {t1}
      end
      goto endmerge
    end
  else
    if type(t2) ~= 'table' then t1, t2 = t2, t1 end
  end
  if type(t1) ~= 'table' then -- t2 is a table
    t = copy(t2)
    if not ismember(t1, t) then t[#t + 1] = t1 end
    goto endmerge
  end

  t = copy(t1)
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
::endmerge::
  if isvector(t) or ismatrix(t) then t = _set_matrix_meta(t) end
  return t
end -- merge

--// #data == #opts
function namedargs(dat, opts)
  local x = {}
  local options = nil
  local k = #dat + 1
  for i = 1, #dat do
    local optq = false
    if type(dat[i]) == 'table' and dat[i][1] == nil then -- more test
      for j = i, #opts do
        optq = dat[i][opts[j]] ~= nil
        if optq then break end
      end
    end
    if optq then -- a = {x=1, y=2}: a[1] == nil
      options = dat[i]; k = i; break
    else
      x[i] = dat[i]
    end
  end
  if options == nil then return x end
  if k == #opts then
    if options[opts[k]] ~= nil then
      x[k] = options[opts[k]]
    else
      x[k] = options
    end
  else
    while k <= #opts do
      x[k] = options[opts[k]]; k = k + 1
    end
  end
  return x -- table.unpack(results) -- Lua 5.4.6&5.4.7: doesn't work well
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
    xrange = _plot_interval(xrange)
    yrange = _plot_interval(yrange)
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
  thetarange = _plot_interval(thetarange or {0, 2*pi})
  phirange = _plot_interval(phirange or {0, pi})
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

-- Plot a surface defined by xyz = {x(u, v), y(u, v), z(u,v)}.
function plotparametricsurface3d(xyz, urange, vrange, title, resolution)
  local args = namedargs(
    {xyz, urange, vrange, title, resolution},
    {'xyz', 'urange', 'vrange', 'title', 'resolution'})
  xyz, urange, vrange, title, resolution = args[1], args[2], args[3], args[4], args[5]

  urange = _plot_interval(urange or {-5, 5})
  vrange = _plot_interval(vrange or urange)
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

-- xyz = { ... }, the parametric equations, x(t), y(t), z(t), in order, of a space curve,
-- trange is the range of t
function plotparametriccurve3d(xyz, trange, title, resolution, orientationq)
  local args = namedargs(
    {xyz, trange, title, resolution, orientationq},
    {'xyz', 'trange', 'title', 'resolution', 'orientationq'})
  xyz, trange, title, resolution, orientationq = args[1], args[2], args[3], args[4], args[5]

  trange = _plot_interval(trange or {0, 2 * pi})
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

local function _to_jscript_expr(expr)
  local gsub = string.gsub
  local jexpr = gsub(expr, "%^", "**")
  jexpr = gsub(jexpr, "sin", "Math.sin")
  jexpr = gsub(jexpr, "cos", "Math.cos")
  jexpr = gsub(jexpr, "tan", "Math.tan")
  jexpr = gsub(jexpr, "exp", "Math.exp")
  jexpr = gsub(jexpr, "log", "Math.log")
  jexpr = gsub(jexpr, "sqrt", "Math.sqrt")
  return jexpr
end

local _anmt_multifstrsq = false
local function _anmt_adjust_traces(traces, fregex)
  if type(traces) ~= 'table' or type(traces[1]) ~= 'table' then
    error('animate, manipulate: fstr can be and opts.enhancements must be a list of lists.')
  end
  for i = 1, #traces do
    local obj = traces[i]
    if obj.line then -- { x = {-4, 2}, y = {3, 4}, color = 'blue', width = 2, line = true}
    elseif obj.point then -- { x = 5.1, y = 9.2, color = 'blue', size = 3, point = true}
    elseif obj.parametriceqs or (type(obj.x) == 'string' and type(obj.y) == 'string') then
      _, s = string.match(obj.x, fregex)
      obj.x = _to_jscript_expr(s)
      _, s = string.match(obj.y, fregex)
      obj.y = _to_jscript_expr(s)
      obj.parametriceqs = true
    end
  end
end

local function _anmt_new_control(c, cs, rs, opts) -- each a-zA-Z but p, t, x, y, T, X, and Y is a control
  local t = #c == 1 and ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) and
            not ismember(c, {'p', 't', 'x', 'y', 'T', 'X', 'Y'}) and
            not ismember(c, cs)
  if t then
    if opts[c] ~= nil then
      if type(opts[c]) ~= 'table' then error('Range of ' .. c .. ' is invalid.') end
      local i = #cs + 1
      cs[i] = c
      rs[i] = opts[c]
      if rs[i][3] == nil then rs[i][3] = qq(rs[i][1] > rs[i][2], -1, 1) end
    else
      error("Range of control '" .. c .. "' is not specified.")
    end
  end
end

local function _anmt_scan_controls(str, cs, rs, opts)
  for c in string.gmatch(str, "[^(%@%s|%(|%)|%{|%}|%[|%]|%+|%-|%*|%^|%/)]+") do
    _anmt_new_control(c, cs, rs, opts)
  end
end

local function _anmt_parse_args(fstr, opts, animateq)
  _anmt_multifstrsq = false
  local cs = {} -- controls[i], ith control; a control is a single symbol such as a, h, and k in a*(x-h)^2+k
  local rs = {} -- ranges[i], ranges of the ith control
  if opts == nil then opts = {} end
  if animateq == true then
    cs[1] = 'p'; rs[1] = {0, 1, 1/100} -- 'p' (play), reserved for animation
    if opts ~= nil and type(opts.p) == 'table' and opts.p.default ~= nil then rs[1].default = opts.p.default end
  end
  if opts.controls ~= nil then
    if type(opts.controls) == 'string' then
      for i = 1, #opts.controls do
        _anmt_new_control(string.sub(opts.controls, i, i), cs, rs, opts)
      end
    else
      error("Field 'controls' must be a string.")
    end
  end

  local xr = opts.x or {-5, 5}
  if type(xr) ~= 'table' or xr[1] >= xr[2] then error('Range of x is invalid.') end

  local fregex = '^%s*@%s*(%(%s*[%w,%s]*%))%s*(.+)%s*$' -- catch expression of a function
  local xexpr, yexpr, s
  if type(fstr) == 'string' then
    s = fstr
    xexpr = nil
    _, yexpr = string.match(fstr, fregex)
  elseif type(fstr) == 'table' then
    if #fstr == 2 and type(fstr[1]) == 'string' and type(fstr[2]) == 'string' then
      _, xexpr = string.match(fstr[1], fregex)
      _, yexpr = string.match(fstr[2], fregex)
      s = fstr[1] .. ' ' .. yexpr
    elseif type(fstr[1]) == 'table' then -- fstr = {{...}, {...}, ...}
      _anmt_adjust_traces(fstr, fregex)
      s = ''
      _anmt_multifstrsq = true
    end
  else
    error("manipulate({xfstr, yfstr}, ...): xfstr and yfstr must be paramatric equations of x(t) and y(t) in strings.")
  end
  if type(opts.controls) == 'string' then
    local I = 1
    if animateq then I = 2 end -- skip 1st one: p
    for i = I, #cs do
      rs[#rs + 1] = opts[cs[i]]
    end
  else
    _anmt_scan_controls(s, cs, rs, opts)
  end

  local jxexpr, jyexpr, tr = nil, nil, nil
  if not _anmt_multifstrsq then
    jyexpr = _to_jscript_expr(yexpr)
    if xexpr ~= nil then
      jxexpr = _to_jscript_expr(xexpr)
      if opts.t == nil or type(opts.t) ~= 'table' or opts.t[1] >= opts.t[2] then
        print("Range of parameter 't' is not specified, or it is invalid. Default: { -6, 6, 0.1 }.")
        tr = {-6, 6, 0.1}
      else
        tr = opts.t
      end
    end
  end
  local jscode, enhancements = '', nil
  if opts ~= {} then
    enhancements = opts.enhancements
    if opts.javascript ~= nil and opts.javascript ~= '' then jscode = opts.javascript end
  end

  if enhancements ~= nil then -- point, line, parametriceqs
    _anmt_adjust_traces(enhancements, fregex)
  end

  local title = nil
  if type(opts.layout) == 'table' then title = opts.layout.title end
  return cs, rs, xr, opts.y, tr, title, xexpr, yexpr, jxexpr, jyexpr, enhancements, jscode
end -- _anmt_parse_args

-- key: nil - no cumulative effect of the primary graphics objects in fstr; otherwise - cumulative effect, by default,
-- and it has the info about the primary control
local function _amnt_write_subtraces(traces, tr, file, resolution, key)   -- traces = {{...}, {...}, ...}
  if type(traces) ~= 'table' or #traces == 0 then return end
  local fmt, head = string.format, ''
  local function toJS(v)
    if type(v) == 'string' then return _to_jscript_expr(v) else return tostring(v) end
  end
  local function write_traces()
    for i = 1, #traces do
      local obj, style = traces[i], '' -- Plotly JavaScript properties in string is allowed
      if type(obj.style) == 'string' then style = ", " .. obj.style end
      if obj.line then
        trace = fmt("{ 'x': [%s, %s], 'y': [%s, %s], 'mode': 'lines', 'line': { 'color': '%s', 'width': %d %s } }",
                    toJS(obj.x[1]), toJS(obj.x[2]), toJS(obj.y[1]), toJS(obj.y[2]), obj.color or 'black', obj.width or 3, style)
        file:write(fmt("  %smthlyTraces.push(%s);\n\n", head, trace))
      elseif obj.point then
        trace = fmt("{ 'x': [%s], 'y': [%s], 'mode': 'markers', 'marker': { 'color': '%s', 'size': %d %s } }",
                    toJS(obj.x), toJS(obj.y), obj.color or 'black', obj.size or 8, style)
        file:write(fmt("  %smthlyTraces.push(%s);\n\n", head, trace))
      elseif obj.parametriceqs then
        local tr1, res = obj.t, 500
        if tr1 == nil then tr1 = tr or {-6, 6} end
        if type(obj.resolution) == 'number' then res = min({500, obj.resolution}) end
        file:write(head .. "  if (true) {\n    " .. head .. "const t = [];\n")
        local step = tr1[3] or (tr1[2] - tr1[1]) / res
        file:write(fmt("    %sfor (let i = %s; i <= %s; i += %s) { t.push(i); }\n", head, tostring(tr1[1]), tostring(tr1[2]), tostring(step)))
        trace = fmt("{ 'x': t.map(t => %s), 'y': t.map(t => %s), 'mode': 'lines', 'line': { 'simplify': false, 'color': '%s', 'width': %d %s } }",
                    obj.x, obj.y, obj.color or 'black', obj.width or 3, style)
        file:write(fmt("    %smthlyTraces.push(%s);\n%s  }\n", head, trace, head))
      end
    end
  end

  if key == nil then
    write_traces()
  else -- cumulative
    head = '  '
    local k = key.keycontrol
    file:write(fmt("  const mthlyTmp = %s;\n", k))
    local step = 1
    if #key[k] >= 3 then step = key[k][3] end
    file:write(fmt("  for (let %s = %s; %s <= mthlyTmp; %s += %s) {\n",
                   k, tostring(key[k][1]), k, k, tostring(step)))
    write_traces()
    file:write("  }\n")
  end
end -- _amnt_write_subtraces

local function _amnt_write_traces(fstr, cs, opts, tr, file, xexpr, jxexpr, jyexpr, enhancements, resolution)
  local fmt, trace = string.format, '{ '
  if _anmt_multifstrsq then
    local k, t = nil, nil
    if not (opts.cumulative == false) then
      if type(opts.keycontrol) == 'string' then
        k = string.sub(opts.keycontrol, 1, 1)
      elseif type(cs) == 'table' and #cs == 1 then
        k = cs[1]
      end
      if type(opts[k]) == 'table' then
        t = {}
        t[k] = opts[k] -- range of the key control
        t.keycontrol = k
      end
      if t == nil then
        print('animate, manipulate: either opts.keycontrol or its range is not specified.')
      end
    end
    _amnt_write_subtraces(fstr, tr, file, resolution, t)
    goto enhc
  elseif xexpr == nil then
    trace = trace .. fmt("'x': x, 'y': x.map(x => %s),", jyexpr)
  else -- parametric eqs
    trace = trace .. fmt("'x': t.map(t => %s), 'y': t.map(t => %s),", jxexpr, jyexpr)
  end
  trace = trace .. " 'mode': 'lines', 'line': { 'simplify': false } }" -- false, color: 'red'}
  file:write(fmt("  mthlyTraces.push(%s);\n\n", trace))

::enhc::
  if type(enhancements) == 'table' then
    _amnt_write_subtraces(enhancements, tr, file, resolution, nil)
  end
end -- _amnt_write_traces

local function _write_manipulate_html(fstr, fname, cs, rs, xr, yr, tr, title, xexpr, yexpr, jxexpr, jyexpr, enhancements, animateq, jscode, opts)
  local file = io.open(fname, "w")
  local fmt = string.format
  if file == nil then
    print(fmt("Failed to create %s. The very device might not be writable.", fname))
    return
  end
  local s = [[<!DOCTYPE html>
<html>
<head>
 <title>Mathly Function Animation</title>
 <script src="%s"></script>
<style>
label {
 display: inline-block;
 width: 10px;
 left: 50px;
 text-align: left;
 vertical-align: middle;
 position: absolute;
}
input {
 display: inline-block;
 width: 200px;
 left: 65px;
 vertical-align: middle;
 position: absolute;
}
input:focus {outline: none;}
</style>
</head>
<body>
<input type='text' id='title' style="width:%dpx;left:0px;text-align:center;border:none;"></input>
<div id="mathlyDiv" style="width:%dpx;height:%dpx;display:inline-block;top:%dpx;position:absolute;"></div>
<!-- controls -->
]]
  local w, h, optsq, layout, resolution = 800, 600, type(opts) == 'table', nil, 500
  if optsq then
    if opts.resolution ~= nil and type(opts.resolution) == 'number' then
      resolution = max({500, abs(opts.resolution)})
    end
    if type(opts.layout) == 'table' then
      layout = opts.layout
      if type(layout.width)  == 'number' and layout.width > 0 then  w = layout.width end
      if type(layout.height) == 'number' and layout.height > 0 then h = layout.height end
    end
  end
  file:write(fmt(s, plotly_engine, w, w, h, 50 + 30 * qq(#cs > 1, #cs - 2, 0)))
  local top = 60 -- sliders
  for i = 1, #cs do
    s = [[<label for="mthlySldr%d" style='top:%dpx;'>%s:</label>
<input type="range" id="mthlySldr%d" min="%s" max="%s" value="%s" style='top:%dpx;' step="%s"></input><span id="mthlySldr%dvalue" style="left:%dpx;top:%dpx;position:absolute">&nbsp;</span>
]]
    if (rs[i][2] - rs[i][1]) / rs[i][3] < 5 then rs[i][3] = (rs[i][2] - rs[i][1]) / 5 end
    s = fmt(s, i, top, cs[i], i, tostring(rs[i][1]), tostring(rs[i][2]), tostring(rs[i][1]), top, tostring(rs[i][3]), i, 290, top)
    if i == 1 and animateq then
      file:write(fmt('<button type="button" onclick="mthlyPlay()" style="left:345px;top:%dpx;position:absolute">Play</button> <button type="button" onclick="mthlyStop()" style="left:395px;top:%dpx;position:absolute">Stop</button>\n', top, top))
    end
    top = top + 30
    file:write(s)
  end
  s = '<span id="displaytext" style="left:%dpx;top:%dpx;position:absolute">&nbsp;</span>\n'
  file:write(fmt(s, 74, top))
  file:write([[
<script type="text/javascript">
function displaytext() { return ""; } // to be overwritten
var x = [];
var t = [];
var X, Y, T, p;
]])
  if animateq then
    s = [[
var mthlyAutoPlayq = true;
function mthlyPlay() { mthlyAutoPlayq = true; }
function mthlyStop() { mthlyAutoPlayq = false; }
var mthlySldr1step = %s;
]]
    file:write(fmt(s, tostring(rs[1][3])))
  end

  local squareq = true
  if layout ~= nil and layout.square == false then squareq = false end
  file:write(fmt("\nconst mthlyLayout = {\n  'xaxis': { 'range': [%s, %s] }, // plot with fixed axes\n", tostring(xr[1]), tostring(xr[2])))
  if yr == nil then
    yr = xr
  elseif type(yr) ~= 'table' or yr[1] >= yr[2] then
    error('Range of y is invalid.')
  end
  file:write(fmt("  'yaxis': { 'range': [%s, %s]", tostring(yr[1]), tostring(yr[2])))
  if squareq then file:write(", 'scaleanchor': 'x', 'scaleratio': 1") end -- square aspect ratio
  file:write(" },\n  'showlegend': false\n};\n\n")
  if title == nil then
    if _anmt_multifstrsq then
      title = ''
    elseif xexpr == nil then
      title = 'y = ' .. yexpr
    else
      title = 'x(t) = ' .. xexpr .. ', y(t) = ' .. yexpr
    end
  end
  file:write("var title = document.getElementById('title');\ntitle.value = '" .. title .. "';\n")

  for i = 1, #cs do
    file:write(fmt("var mthlySldr%d = document.getElementById('mthlySldr%d');\n", i, i))
  end

  for i = 1, #cs do -- values of control sliders
    local v = rs[i].default;
    if v == nil then v = rs[i][1] end
    file:write(fmt("mthlySldr%d.value = %s;\n", i, tostring(v)))
    file:write(fmt("var %s = %s;\n", cs[i], tostring(v)))
  end -- why Number(...)? Values of sliders in JavaScript are STRINGS!

  if not animateq then file:write("p = 1;\n") end
  if xexpr ~= nil then -- parametric eqs
    s = fmt("for (let i = %s; i <= p * (%s %s %s) %s %s; i += %s) { t.push(i); }\n",
            tostring(tr[1]), tostring(tr[2]), qq(tr[1] > 0, '-', '+'), tostring(abs(tr[1])),
            qq(tr[1] > 0, '+', '-'), tostring(abs(tr[1])), tostring((tr[2] - tr[1]) / resolution))
  else
    s = fmt("for (let i = %s; i <= p * (%s %s %s) %s %s; i += %s) { x.push(i); }\n",
            tostring(xr[1]), tostring(xr[2]), qq(xr[1] > 0, '-', '+'), tostring(abs(xr[1])),
            qq(xr[1] > 0, '+', '-'), tostring(abs(xr[1])), tostring((xr[2] - xr[1]) / resolution))
  end
  file:write(s)

  -- X, Y, T - values at the last/present point of a curve
  if animateq then
    if xexpr ~= nil then
      file:write(fmt("let mthlyTmp = t[t.length - 1];\nif (true) { const t = mthlyTmp; X = %s; Y = %s; T = mthlyTmp; }\n", jxexpr, jyexpr))
    else
      file:write(fmt("let mthlyTmp = x[x.length - 1];\nif (true) { const x = mthlyTmp; X = mthlyTmp; Y = %s; }\n", jyexpr))
    end
  end

  file:write("\nvar mthlyTraces = [];\nfunction mthlyUpdateTraces() {\n  mthlyTraces = []; // or .length = 0;\n")
  if type(jscode) == 'string' and jscode ~= '' then file:write("\n  // vvvvv user's javascript vvvvv\n" .. jscode .. "  // ^^^^^ user's javascript ^^^^^\n\n") end
  _amnt_write_traces(fstr, cs, opts, tr, file, xexpr, jxexpr, jyexpr, enhancements, resolution)
  file:write('  document.getElementById("displaytext").innerHTML = displaytext();\n}\n')

  file:write("\nmthlyUpdateTraces();\nconst mthlyInitData = mthlyTraces;\n\n")

  file:write("var mthlyOldCs = [") -- previous values of controls
  for i = 1, #cs do
    if i > 1 then file:write(",") end
    file:write("99999999") -- assume each control is numerical
  end
  file:write("];\nvar mthlyNewCs = [];\n") -- new values of controls; need no initial values

  file:write("function mthlyAnimatePlot() {\n")
  if animateq then
    s = [[
  if (mthlyAutoPlayq) {
    let x = String(Number(mthlySldr1.value) + mthlySldr1step);
    mthlySldr1.value = String(x);
    if (x > 1) { mthlySldr1.value = '0'; }
    document.getElementById("mthlySldr1value").innerHTML = mthlySldr1.value;
  }
]]
    file:write(s)
  end

  for i = 1, #cs do -- values of control sliders
    file:write(fmt("  %s = Number(mthlySldr%d.value);\n", cs[i], i))
  end

  if animateq then
    if xexpr ~= nil then -- parametric eqs
      file:write(fmt("  t = []; for (let i = %s; i <= p * (%s %s %s) %s %s; i += %s) { t.push(i); };\n  T = t[t.length - 1];\n",
                     tostring(tr[1]), tostring(tr[2]), qq(tr[1] > 0, '-', '+'), tostring(abs(tr[1])),
                     qq(tr[1] > 0, '+', '-'), tostring(abs(tr[1])), tostring((tr[2] - tr[1]) / resolution)))
      file:write(fmt("  if (true) { const t = T; X = %s; Y = %s; };\n", jxexpr, jyexpr))
    else
      file:write(fmt("  x = []; for (let i = %s; i <= p * (%s %s %s) %s %s; i += %s) { x.push(i); };\n  X = x[x.length - 1];",
                     tostring(xr[1]), tostring(xr[2]), qq(xr[1] > 0, '-', '+'), tostring(abs(xr[1])),
                     qq(xr[1] > 0, '+', '-'), tostring(abs(xr[1])), tostring((xr[2] - xr[1]) / resolution)))
      file:write(fmt("  if (true) { const x = X; Y = %s; T = x; };\n", jyexpr))
    end
  end

  file:write("  // has any controls changed?\n  mthlyNewCs = [") -- new values of controls
  for i = 1, #cs do
    if i > 1 then file:write(", ") end
    file:write(cs[i])
  end
  file:write("];\n")

  if #cs == 1 then
    file:write("  if (Math.abs(mthlyOldCs[0] - mthlyNewCs[0]) < 0.00001) { return; }\n")
  else
    file:write(fmt([[
  var unchangedq = true;
  for (let i = 0; i < %d; i++) {
    if (Math.abs(mthlyOldCs[i] - mthlyNewCs[i]) > 0.00001) {
      unchangedq = false; break;
    }
  }
  if (unchangedq) { return; }
]], #cs))
  end

  file:write("  mthlyOldCs = [") -- new values of controls
  for i = 1, #cs do
    if i > 1 then file:write(", ") end
    file:write(cs[i])
  end
  file:write("]; // update values of controls\n\n")

  file:write('  mthlyUpdateTraces();\n')

  file:write([[
  Plotly.animate('mathlyDiv', {
    'data': mthlyTraces,
    'traces': mthlyTraces.keys() // update all traces
  }, {
    'transition': { 'duration': 0 },
    'frame': { 'duration': 0 }
  });
}

]])

  for i = 1, #cs do -- slider event handlers
    s = [[
document.getElementById("mthlySldr%dvalue").innerHTML = mthlySldr%d.value;
mthlySldr%d.addEventListener("input", function() { document.getElementById("mthlySldr%dvalue").innerHTML = mthlySldr%d.value; %smthlyAnimatePlot() });
]]
    file:write(fmt(s, i, i, i, i, i, qq(animateq, 'mthlyAutoPlayq = false; ', '')))
  end

  -- if the number of traces are various, like in cumulative cases, setting
  -- the initial traces to the largest number is a key!? 9/30/25
  file:write(fmt([[

Plotly.newPlot('mathlyDiv', mthlyInitData, mthlyLayout);
mthlyAnimatePlot();
setInterval(mthlyAnimatePlot, %d); // animate every 0.2 seconds
</script>
</body>
</html>
]], qq(_anmt_multifstrsq, 200, 200)))
  file:close()
end -- _write_manipulate_html

-- vvvvvvvvvvv from dkjson 2.8 (at the end of this source file) vvvvvvvvvvv --
local _open_cmd -- this needs to stay outside the function, or it'll re-sniff every time...
local function _open_url(url)
  local fmt = string.format
  if not _open_cmd then
    if __is_windows then
      _open_cmd = function(url)
        -- os.execute(fmt('start "%s"', url))
        os.execute(fmt('"%s" %s', win_browser, url))
      end
    elseif (io.popen("uname -s"):read'*a'):sub(1, 6) == "Darwin" then
      _open_cmd = function(url)
        -- I cannot test, but this should work on modern Macs.
        -- os.execute(fmt('open "%s"', url))
        os.execute(fmt('%s "%s"', mac_browser, url))
      end
    else -- that ought to only leave Linux
      _open_cmd = function(url)
        -- should work on X-based distros.
        -- os.execute(fmt('xdg-open "%s"', url))
        os.execute(fmt('%s "%s"', linux_browser, url))
      end
    end
  end
  _open_cmd(url)
end
-- ^^^^^^^^^^^ from dkjson 2.8 (at the end of this source file) ^^^^^^^^^^^ --

-- manipulate/animate interactively the graph of f(x) with 'controls' and enhancements
function manipulate(fstr, opts) -- Mathematica
  local cs, rs, xr, yr, tr, title, xexpr, yexpr, jxexpr, jyexpr, enhancements, jscode = _anmt_parse_args(fstr, opts, false)
  _write_manipulate_html(fstr, tmp_plot_html_file, cs, rs, xr, yr, tr, title, xexpr, yexpr, jxexpr, jyexpr, enhancements, false, jscode, opts)
  _open_url(tmp_plot_html_file)
  print("The graph is in " .. tmp_plot_html_file .. ' if you need it.')
end

function animate(fstr, opts) -- Mathematica
  local cs, rs, xr, yr, tr, title, xexpr, yexpr, jxexpr, jyexpr, enhancements, jscode = _anmt_parse_args(fstr, opts, true)
  _write_manipulate_html(fstr, tmp_plot_html_file, cs, rs, xr, yr, tr, title, xexpr, yexpr, jxexpr, jyexpr, enhancements, true, jscode, opts)
  _open_url(tmp_plot_html_file)
  print("The graph is in " .. tmp_plot_html_file .. ' if you need it.')
end

function mtable(str, opts) -- Mathematica
  local cs, rs = {}, {} -- controls & their ranges
  if opts == nil then opts = {} end
  -- scan for controls in str and set their ranges from opts
  if type(opts.controls) == 'string' then -- order of controls is in this string explicitly
    for i = 1, #opts.controls do
      _anmt_new_control(string.sub(opts.controls, i, i), cs, rs, opts)
    end
  elseif type(str) == 'string' then  -- order of controls is in str implicitly
    _anmt_scan_controls(str, cs, rs, opts)
  end
  if #cs == 0 then
    for k, v in pairs(opts) do
      if type(k) == 'string' then _anmt_new_control(k, cs, rs, opts) end
    end
    if #cs == 0 then print("No controls are specified."); return end
  end
  -- generate Lua code
  local code, idx = '', 1
  for i = 1, #cs do code = code .. string.format('local t%d = {}\n', i) end
  local function luacode(i)
    local head = ''; for j = 2, i do head = head .. '  ' end
    local t = string.format('t%d', idx); idx = idx + 1
    local T = string.format('t%d', idx)
    code = code .. head .. 'for ' .. cs[i] .. ' = ' .. tostring(rs[i][1]) .. ', ' .. tostring(rs[i][2]) ..', ' .. tostring(rs[i][3]) .. ' do\n'
    if i == #rs then
      code = code .. head .. string.format("  %s[#%s + 1] = ", t, t)
      local ty = type(str)
      if ty == 'number' then
        code = code .. tostring(str)
      elseif ty == 'string' then
        if string.sub(str, 1, 1) == '!' then -- '!a+b' will be "a+b" without evaluation
          code = code .. "'" .. string.sub(str, 2) .. "'"
        else
          code = code .. str
        end
      elseif ty == 'boolean' then
        code = code .. qq(str, 'true', 'false')
      else
        error("mytable(expr, ...): expr can't be a table, but you may use a string, e.g., '{1, 2, 3}' and '{1, i, {3, {j - 1}}, 5}'.")
      end
      code = code .. '\n'
    else
      luacode(i + 1)
      code = code .. head .. string.format('  %s[#%s + 1] = %s; %s = {}\n', t, t, T, T)
    end
    code = code .. head .. "end\n"
  end
  luacode(1)
  code = code .. "return t1\n"
  if opts.printcode == true then print(code) end
  -- run generated Lua code dynamically
  local stat, v = pcall(load, code)
  if stat then stat, v = pcall(v) end
  return v
end -- mtable

local function _freq_distro(x, nbins, xmin, xmax, width)
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
  local g = {'graph-hist'} -- special graph object, https://plotly.com/javascript/bar-charts/
  local freqs = {}
  local allintq = all(x, isinteger, false) == 1
  nbins = nbins or 10

  if xrange ~= nil then
    xmin, xmax = _plot_interval(xrange[1], xrange[2])
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
    g[#g + 1] = labels
    g[#g + 1] = freqs[j]
  end
  return g
end -- hist

local function _xmin_xmax_width(x, xrange, nbins, allintq)
  local xmin, xmax, width
  if xrange ~= nil then
    xmin, xmax = _plot_interval(xrange[1], xrange[2])
  else
    xmin, xmax = x[1], x[#x]
  end
  if allintq then
    width = math.ceil((xmax - xmin + 1) / nbins)
  else
    width = (xmax - xmin) / nbins
  end
  return xmin, xmax, width
end

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
  local g = {'graph'}
  local x1 = xmin
  local freqp_xy = {{xmin - width / 2}, {0}}
  for i = 1, nbins do
    local x2 = x1 + width
    if histq then
      local gobj = polygon({{x1, 0}, {x1, freqs[i]}, {x2, freqs[i]}, {x2, 0}}, style)
      g[#g + 1] = gobj[2]
      g[#g + 1] = gobj[3]
      g[#g + 1] = gobj[4]
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
    g[#g + 1] = freqp_xy[1]
    g[#g + 1] = freqp_xy[2]
    g[#g + 1] = style1
    for i = 1, nbins + 2 do -- points
      g[#g + 1] = {freqp_xy[1][i]}
      g[#g + 1] = {freqp_xy[2][i]}
      g[#g + 1] = style1
    end
  end
  return g
end -- hist1

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

  local g = {'pareto'}
  local x1 = 0
  local freqxy = {{0}, {0}}
  local width = 20
  for i = 1, #dat do
    local x2 = x1 + width
    local gobj = polygon({{x1, 0}, {x1, freqs[i]}, {x2, freqs[i]}, {x2, 0}}, style)
    g[#g + 1] = gobj[2]
    g[#g + 1] = gobj[3]
    g[#g + 1] = gobj[4]
    freqxy[1][i + 1] = x2
    freqxy[2][i + 1] = freqxy[2][i] + freqs[i]
    x1 = x2
  end

  g[#g + 1] = freqxy[1]
  g[#g + 1] = freqxy[2]
  g[#g + 1] = style1
  for i = 1, #dat + 1 do -- points
    g[#g + 1] = {freqxy[1][i]}
    g[#g + 1] = {freqxy[2][i]}
    g[#g + 1] = style1 -- {symbol='circle', size=8, color='red'}
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
  g[#g + 1] = {names = names}

  g[#g + 1] = texts
  shownotxaxis(); shownotlegend()
  return g
end -- pareto

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

-- if x is a table of tables/rows, each row is a data set; otherwise, x is a table and a single data set.
function boxplot(x, names)
  local args = namedargs({x, names}, {'x', 'names'})
  x, names = args[1], args[2]

  if type(x) == 'table' then
    if type(x[1]) ~= 'table' then x = { x } end
  else
    error('boxplot(x, ...): x must be a table.')
  end

  local g = {'graph-box'} -- special graph object, https://plotly.com/javascript/bar-charts/
  g[2] = 'x' -- horizontal -- gobj: {'graph-box', 'x', data...}, 'x' or 'y'
  if #x > 3 then g[2] = 'y' end -- vertical
  for j = 1, #x do
    g[j + 2] = x[j]
  end
  if names ~= nil then g[#g + 1] = names end
  return g
end

function pie(x, nbins, style, names, title)
  local args = namedargs({x, nbins, style, names, title}, {'x', 'nbins', 'style', 'names', 'title'})
  x, nbins, style, names, title = args[1], args[2], args[3], args[4], args[5]

  _axis_equalq       = true
  _xaxis_visibleq    = false
  _yaxis_visibleq    = false
  _gridline_visibleq = false
  _showlegendq       = false

  local freqs, xmin, xmax, width
  local binsq = x['bins'] ~= nil -- x = {bins = {freq1, freq2, ...}}
  local namesq = type(names) == 'table'
  local allintq = all(x, isinteger, false) == 1
  if binsq then
    freqs = x['bins']
    freqs = tt(rr(freqs) / sum(freqs))
    nbins = #freqs
  else
    if nbins == nil then
      if namesq then nbins = #names else nbins = 10 end
    end
    x = flatten(x)
    if nbins >= #x then
      freqs = tt(rr(x) / sum(x)); nbins = #x
      binsq = true
    else
      x = sort(x)
      xmin, xmax, width = _xmin_xmax_width(x, nil, nbins, allintq)
      freqs = _freq_distro(x, nbins, xmin, xmax, width)
    end
  end

  local labels = {}
  for i = 1, nbins do
    if namesq and i <= #names then
      labels[i] = names[i]
    elseif binsq then
      labels[i] = 'class ' .. i
    else
      local x2 = xmin + width
      if allintq then
        labels[i] = sprintf("[%d, %d]", xmin, x2 - 1)
      else
        labels[i] = sprintf("[%.2f, %.2f)", xmin, x2)
      end
      xmin = x2
    end
  end

  local gobj = {type = 'pie', values = freqs, labels = labels, textinfo = "label+percent", hoverinfo = 'label+percent'}
  gobj = merge(style, gobj)
  if title ~= nil then gobj.layout = {title = {text = title}} end
  return gobj
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
  angles = _plot_interval(angles or {0, 2*pi})
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
end

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
end

-- xy = {x(t), y(t)}
function parametriccurve2d(xy, trange, style, resolution, orientationq)
  local args = namedargs(
    {xy, trange, style, resolution, orientationq},
    {'xy', 'trange', 'style', 'resolution', 'orientationq'})
  xy, trange, style, resolution, orientationq = args[1], args[2], args[3], args[4], args[5]

  trange = _plot_interval(trange or {-5, 5})
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
end

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
end

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
end

function dotplot(x, y, style)
  local args = namedargs(
    {x, y, style},
    {'x', 'y', 'style'})
  x, y, style = args[1], args[2], args[3]
  if style == nil or type(style) ~= 'table' then
    style = { size = 8, symbol = 'circle', opacity = 1 }
  end
  return { 'dotplot', {x = x, y = y, mode = 'markers', marker = style }}
end

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
end

-- dy/dx = f(x, y)
function slopefield(f, xrange, yrange, scale)
  local args = namedargs(
    {f, xrange, yrange, scale},
    {'f', 'xrange', 'yrange', 'scale'})
  f, xrange, yrange, scale = args[1], args[2], args[3], args[4]

  if type(f) == 'string' then f = fstr2f(f) end
  xrange = _plot_interval(xrange or {-5, 5, 0.5})
  yrange = _plot_interval(yrange or xrange)
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
end

directionfield = slopefield

-- f(x, y) returns a vector {xcomponent, ycomponent}
function vectorfield2d(f, xrange, yrange, scale)
  local args = namedargs(
    {f, xrange, yrange, scale},
    {'f', 'xrange', 'yrange', 'scale'})
  f, xrange, yrange, scale = args[1], args[2], args[3], args[4]

  if type(f) == 'string' then f = fstr2f(f) end
  xrange = _plot_interval(xrange or {-5, 5, 0.5})
  yrange = _plot_interval(yrange or xrange)
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

-- transpose a matrix
function transpose(A)
  assert(getmetatable(A) == mathly_meta, 'transpose(A): A must be a mathly metatable.')
	local B = {}
	local m, n = size(A)
	if type(A[1]) ~= 'table' then -- m == 1
  	for i = 1,n do B[i] = { A[i] } end
	else
  	for i = 1,n do
  		B[i] = {}
  		for j = 1,m do B[i][j] = A[j][i] end
  	end
  end
	return _set_matrix_meta(B)
end

-- calculate the reduced row-echlon form of matrix A
-- if B is provided, it works on [ A | B]; useful for finding the inverse of A or
-- solving Ax = b by rref [ A | b ]
function rref(a, b) -- gauss-jordan elimination
  assert(getmetatable(a) == mathly_meta, 'rref(A): A must be a mathly metatable.')
  assert(b == nil or getmetatable(b) == mathly_meta, 'rref(A, B): A and B must be mathly matrices.')
  local rows, columns = size(a)
  local ROWS = math.min(rows, columns)

  local bq = false
  local bcolumns = 0
  if b ~= nil then
    bq = true
    assert(#b == rows, 'rref(A, B): A and be must have the same number of rows.')
  end

  local A = copy(a) -- 4/23/25
  local B = copy(b) --
  if bq then
    if type(B[1]) ~= 'table' then B = cc(B) end
    bcolumns = #B[1]
  end

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
        A[i], A[idx] = A[idx], A[i]
        if bq then B[i], B[idx] = B[idx], B[i] end
      end

      largest = A[i][i]  -- 'normalize' the row: 0 ... 0 1 x x x
      A[i][i] = 1
      for j = i + 1, columns do
        A[i][j] = A[i][j] / largest
      end
      if bq then B[i] = B[i] / largest end

      for j = i + 1, rows do -- eliminate entries below A[i][i]
        local Aji = A[j][i]
        for k = i, columns do
          A[j][k] = A[j][k] - A[i][k] * Aji
        end
        if bq then B[j] = B[j] - B[i] * Aji end
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
        if bq then B[i] = B[i] / Aij end
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
        if bq then  B[j] = B[j] - B[i] * Ajm end
      end
    end
  end
  if bq then
    if type(B[1]) == 'table' and #B[1] == 1 then B = B^T end
    return A, B
  else
    return A
  end
end -- rref

-- solve the linear system Ax = b for x, given that A is a square matrix; return the solution
function linsolve(A, b, opt)
  assert(getmetatable(A) == mathly_meta, 'linsolve(A): A must be a mathly metatable.')
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
  local y = zeros(m, #B[1])
  for j = 1, #B[1] do
    if opt == 'UT' then -- back substitution
      y[n][j] = B[n][j] / A[n][n]
      for i = n - 1, 1, -1 do
        local s = B[i][j]
        for k = i + 1,  n do s = s - A[i][k] * y[k][j] end
        y[i][j] = s / A[i][i]
      end
    else -- forward substitution
      y[1][j] = B[1][j] / A[1][1]
      for i = 2, n do
        local s = B[i][j]
        for k = 1, i - 1 do s = s - A[i][k] * y[k][j] end
        y[i][j] = s / A[i][i]
      end
    end
  end
  if #y[1] == 1 then y = tt(y) end
  return _set_matrix_meta(y)
end -- linsolve

-- calculate the inverse of matrix A
-- rref([A | I]) gives [ I | B ], where B is the inverse of A
function inv(A)
  assert(getmetatable(A) == mathly_meta, 'inv(A): A must be a mathly metatable.')
  local rows, columns = size(A)
  assert(rows == columns, 'inv(A): A must be square.')
  local v1, v2 = rref(A, eye(rows))
  return v2
end

-- return rows and columns of matrix A, given that A is a valid vector, matrix, string, or a number.
function size(A)
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
  return _set_matrix_meta(C)
end -- repmat

-- flipud - Return a matrix with rows of matrix A reversed (upside down)
-- fliplr - Return a matrix with columns of matrix A reversed (from left to right)
function flipud(A) local a = rr(A, range(#A, 1, -1));    return _set_matrix_meta(a) end
function fliplr(A) local a = cc(A, range(#A[1], 1, -1)); return _set_matrix_meta(a) end

-- reverse and return a table. if it is a matrix, it is flattened columnwisely first to a table and then reversed
function reverse(t)
  if type(t) == 'string' then
    return string.reverse(t)
  else
    return tt(t, {-1, 1, -1})
  end
end

function sort(t, compf)
  if type(compf) == 'string' then compf = fstr2f(compf) end
  table.sort(t, compf)
  if isvector(t) then t = _set_matrix_meta(t) end
  return t
end

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
  elseif opt == 'DIAG' then
    B = diag(diag(A))
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
  return _set_matrix_meta(B)
end -- remake

-- use entries of matrix A to generate a new mxn matrix, given that A is a valid vector or matrix
function reshape(A, m, n)
  local rows, columns = size(A)
  local total = rows * columns
  if n == nil then n = math.ceil(total / m) end

  local t
  if rows == 1 or columns == 1 then
    t = flatten(A)
  else
    t = {}
    for j = 1, columns do
      for i = 1, rows do
        t[#t + 1] = A[i][j]
      end
    end
  end

  local k = 1
  local B = {}
  for i = 1, m do B[i] = {} end
  for j = 1, n do
    for i = 1, m do
      if k <= total then
        B[i][j] = t[k]
        k = k + 1
      else
        B[i][j] = 0
      end
    end
  end
  return setmetatable(B, mathly_meta)
end -- reshape

-- return the number of rows of a matrix
function length(A)
  if type(A) == 'table' and type(A[1]) == 'table' and #A == 1 then
    return length(A[1]) -- mathly{1, 2, 3} gives {{1, 2, 3}}
  end
  if type(A) == 'string' or type(A) == 'table' then
    return #A
  else
    return 1
  end
end

-- // function diag(A, k)
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
function diag(A, m, n)
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

-- expand/shrink a matrix by adding value v's or dropping entries.
-- the default value of v is 0
function expand(A, m, n, v)
  assert(getmetatable(A) == mathly_meta, 'expand(A): A must be a mathly matrix.')
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

-- extract a submatrix of matrix A if B is not specified, or set the submatrix of A with B (A is modified!)
-- 1. make a COPY of A, or
-- 2. COPY to A from B
function submatrix(A, rrange, crange, B, rrange1, crange1)
  assert(type(A) == 'table' and type(A[1]) == 'table', 'submatrix(A, ...): A must be a matrix.')
  return copy(A, rrange, crange, B, rrange1, crange1)
end

-- return a specified slice of a vector
function subtable(A, irange, B, irange1)
  assert(type(A) == 'table' and type(A[1]) ~= 'table', "subtable(A, irange, B, irange1): table A can't be a matrix.")
  local a = copy(A, irange, B, irange1)
  return _set_matrix_meta(a)
end

-- Return L and U in LU factorization A = L * U, where L and U are lower and upper traingular matrices, respectively.
function lu(A) -- by Crout's method
  assert(getmetatable(A) == mathly_meta, 'lu(A): A must be a mathly square matrix.')
  local s, n = size(A)
  assert(n == s and n > 1, "lu(A): A is not square.\n")
  local abs = math.abs

  local L = zeros(n, n)
  local U = zeros(n, n)

  for i = 1, n do -- calculate L[i][1 : i]
    for j = 1, i do
      s = 0
      for k = 1, j - 1 do
        s = s + L[i][k] * U[k][j]
      end
      L[i][j] = A[i][j] - s
    end

    U[i][i] = 1  -- calculate U[i][i : end]
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

-- Return QR factorization A=QR, where mxn matrix A = mxn matrix Q * nxn matrix R, Q has orthonormal
-- column vectors, and R is an invertible upper triangular matrix.
-- note: this implementation requires that m >= n.
function qr(A)  -- by Gram-Schmidt process
  assert(getmetatable(A) == mathly_meta, 'qr(A): A must be a mathly matrix.')
  local m, n = size(A)
  assert(m >= n, 'qr(A): A is a mxn matrix, where m >= n.')

  -- constructing Q
  local Q = copy(A, '*', 1) -- A(:, 1)
  Q = Q * (1 / norm(Q))
  for i = 2, n do
    local u = copy(A, '*', i) -- A(:, i)
    local v = copy(u)
    for j = 1, i - 1 do
      local vj = copy(Q, '*', j) -- Q(:, j)
      v = v - (sum(u * vj) / sum(vj * vj)) * vj -- u .* vj, vj .* vj
    end
    v = v * (1 / norm(v))  -- normalizing the column vector
    Q = horzcat(Q, v)
  end

  -- calculating R
  local R = zeros(n, n)
  for i = 1, n do
    for j = i, n do
      R[i][j] = sum(copy(A, '*', j) * copy(Q, '*', i)) -- A(:, j) .* Q(:, i)
    end
  end
  return Q, R
end -- qr

-- Calculate the determinant of a matrix
function det(B)
  assert(getmetatable(B) == mathly_meta, 'det(A): A must be a mathly matrix.')
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

-- Concatenate matrices, horizontal
-- rows have to be the same, e.g.: #m1 == #m2
-- e.g., horzcat({{1},{2}}, {{2,3,4},{3,4,5}}, {{5,6},{6,7}})
function horzcat(...)
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end
  if #args == 0 then return {} end

  local rows = #args[1]
  for i = 2, #args do
    assert(rows == #args[i], "The row numbers are not the same.")
  end

	local t = {}
	for i = 1, rows do
		t[i] = {}
		for j = 1,#args[1][1] do
			t[i][j] = args[1][i][j]
		end

    for k = 2, #args do
    	local offset = #t[i]
  		for j = 1, #args[k][1] do
  			t[i][j+offset] = args[k][i][j]
  		end
    end
	end
  return _set_matrix_meta(t)
end

-- Concatenate matrices, vertical
-- columns have to be the same; e.g.: #m1[1] == #m2[1]
-- e.g., vertcat({{1,2,3},{2,3,4}}, {{3,4,5}}, {{4,5,6},{5,6,7}})
function vertcat(...)
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end
  if #args == 0 then return {} end

  local columns = #args[1][1]
  for i = 2, #args do
    assert(columns == #args[i][1], "The column numbers are not the same.")
  end

	local t = {}
	for i = 1, #args[1] do
		t[i] = {}
		for j = 1, #args[1][1] do
			t[i][j] = args[1][i][j]
		end
	end
	for k = 2, #args do
  	local offset = #t
  	for i = 1, #args[k] do
  		local _i = i + offset
  		t[_i] = {}
  		for j = 1, columns do
  			t[_i][j] = args[k][i][j]
  		end
  	end
  end
  return _set_matrix_meta(t)
end -- vertcat

-- merge elements and FLATTENED tables into a single table
-- e.g., tblcat(1, {2, {3, 4}}, {{5, 6}, 7})
function tblcat(...)
  local args = {}
  for _, v in pairs{...} do
    args[#args + 1] = v
  end

  local t = {}
  for i = 1, #args do
    if type(args[i]) == 'table' then
      local x = flatten(args[i])
      for j = 1, #x do
        t[#t + 1] = x[j]
      end
    else
      t[#t + 1] = args[i]
    end
  end
  if isvector(t) then t = _set_matrix_meta(t) end
  return t
end

-----------[[ Set behaviours of +, -, *, and ^ -----------]]

function mathly.numtableadd(t, n, op)
  local function do_it(t)
    local v = {}
    for i = 1, #t do
      if type(t[i]) == 'table' then
        v[#v + 1] = do_it(t[i])
      else
        if op == '+' then
          v[#v + 1] = t[i] + n
        else
          v[#v + 1] = t[i] - n
        end
      end
    end
    return v
  end
  return _set_matrix_meta(do_it(t))
end

-- Special case: if m1 is a row/column mathly matrix, m2 can be a Lua table of any type.
-- This case saves the trouble of accessing b as b[i] rathern than b[i][1] while doing Ax - b or Ax + b
function mathly.add_sub_shared(m1, m2, op)
  if type(m1) == 'number' and type(m2) == 'table' then
    if op == '-' then
      return mathly.numtableadd(-m2, m1, '+')
    else
      return mathly.numtableadd(m2, m1, '+')
    end
  elseif type(m2) == 'number' and type(m1) == 'table' then
    return mathly.numtableadd(m1, m2, op)
  end

  local rc = 0
	if getmetatable(m1) == mathly_meta then
	  if type(m1[1]) ~= 'table' then rc = 1 elseif #m1[1] == 1 then rc = 2 end
	elseif getmetatable(m2) == mathly_meta then
	  if type(m2[1]) ~= 'table' then rc = 1 elseif #m2[1] == 1 then rc = 2 end
	end

  local msg = 'm1 ' .. op .. ' m2: dimensions do not match.'
	local t = {}
  local M1, M2 -- removed qq(..(qq(..)))
  if rc == 0 then
    M1, M2 = m1, m2
  elseif rc == 1 then
    M1, M2 = rr(m1), rr(m2)
  else
    M1, M2 = cc(m1), cc(m2)
  end

	local d11, d12 = size(M1)
	local d21, d22 = size(M2)
	if d11 ~= d21 or d12 ~= d22 then error(msg) end

	for i = 1,#M1 do
		local x = {}
		for j = 1,#M1[1] do
		  if op == '+' then
			  x[j] = M1[i][j] + M2[i][j]
		  else
		    x[j] = M1[i][j] - M2[i][j]
		  end
		end
		t[i] = x
	end

	if rc == 1 then t = tt(t) end
	return _set_matrix_meta(t)
end -- mathly.add_sub_shared

mathly_meta.__add = function(m1, m2)
  return mathly.add_sub_shared(m1, m2, '+')
end

mathly_meta.__sub = function(m1, m2)
  return mathly.add_sub_shared(m1, m2, '-')
end

-- MATLAB: a .* b
-- v1 determines the size and structure of the resulted vector
function mathly.matlabvmul(v1, v2)
  local v22 = flatten(v2)
	local x = {}
  if type(v1[1]) ~= 'table' then -- v1 = {1, 2, ...}
		for i = 1,#v1 do x[i] = v1[i] * v22[i] end
  else -- v1 = {{1}, {2}, ...}
    for i = 1,#v1 do x[i] = { v1[i][1] * v22[i] } end
  end
  return _set_matrix_meta(x)
end

-- Multiply two matrices; m1 columns must be equal to m2 rows
-- if A and B are row/column vectors, find A .* B as in MATLAB and Julia
-- Special case: A is a mathly matrix, B is any kind of table, for solving Ax = B.
function mathly.mul(m1, m2)
  if type(m1) == 'number' then
    return mathly.mulnum(m2, m1)
  elseif type(m2) == 'number' then
    return mathly.mulnum(m1, m2)
  end

	assert(getmetatable(m1) == mathly_meta or getmetatable(m2) == mathly_meta,
	       'm1 * m2: m1 or m2 must be a mathly metatable.')
	local t = {}
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
		t[i] = {}
		for j = 1,#M2[1] do
			local num = M1[i][1] * M2[1][j]
			for n = 2,#M1[1] do
				num = num + M1[i][n] * M2[n][j]
			end
			t[i][j] = num
		end
	end
	return _set_matrix_meta(t)
end -- mathly.mul

-- Set multiply "*" behaviour
mathly_meta.__mul = function(m1, m2)
	return mathly.mul(m1, m2)
end

-- Multiply mathly with a number
-- num may be of type 'number' or 'complex number'
-- strings get converted to complex number, if that fails then to symbol
function mathly.mulnum(m1, num)
	assert(getmetatable(m1) == mathly_meta, 'm1 * m2: m1 or m2 must be a mathly metatable.')
	local t = {}
	for i = 1,#m1 do
		if type(m1[1]) == 'table' then
			t[i] = {}
			for j = 1,#m1[1] do
				t[i][j] = m1[i][j] * num
			end
		else
			t[i] = num * m1[i]
		end
	end
	return _set_matrix_meta(t)
end

-- Set division "/" behaviour
mathly_meta.__div = function(m1, m2)
  local err = 'm1 / m2: the dimensions of m1 and m2 do not match.'
  local function adjust(m1, m2)
    if type(m1[1]) ~= 'table' then
      local m, n = size(m2)
      if m == 1 then
        m1 = rr(m1)
      elseif n == 1 then
        m1 = cc(m1)
      else
        error(err)
      end
    end
    return m1
  end
  if type(m2) == 'number' then
    return map(function(x) return x/m2 end, m1)
  elseif type(m1) == 'number' then
    return map(function(x) return m1/x end, m2)
  elseif type(m1) == 'table' and type(m2) == 'table' then
    m1 = adjust(m1, m2)
    m2 = adjust(m2, m1)
    local m, n = size(m1)
    local M, N = size(m2)
    if m ~= M or n ~= N then error(err) end
    local tmp = map(function(x, y) return x/y end, m1, m2)
    return _set_matrix_meta(tmp)
  else
    error('m1 / m2: the type of m1 or m2 is not allowed.')
  end
end -- mathly_meta.__div

-- Set unary minus "-" behavior
mathly_meta.__unm = function(t)
	return mathly.mulnum(t, -1)
end

-- Power of matrix; A^n
-- n is a nonnegative integer
-- if m1 is square, m1 ^ n = m1 * m1 * ... * m1; if m1 is row/column vector, m1 ^ n ~ m1 .^ n as in MATLAB
function mathly.pow(m1, n)
	assert(isinteger(n) and n >= 0, "A ^ n: n must be a nonnegative integer.")
  local t = {}
  if type(m1[1]) ~= 'table' then
    for i = 1, #m1 do t[i] = m1[i] ^ n end
	elseif #m1 == 1 then -- row vector, element wise
    for i = 1, #m1[1] do t[i] = m1[1][i] ^ n end
    t = {t}
  elseif #m1[1] == 1 then -- column vector
    for i = 1, #m1 do t[i] = { m1[i][1] ^ n } end
  else
    assert(#m1 == #m1[1], "A ^ n: A must be a square matrix.")
  	if n == 0 then return setmetatable(eye(#m1), mathly_meta) end
  	t = copy(m1)
  	for i = 2, n	do t = mathly.mul(t, m1) end
  end
  return _set_matrix_meta(t)
end

--[[
  Set power "^" behaviour
  if opt is any integer number will do t^opt (returning nil if answer doesn't exist)
  if opt is 'T' then it will return the transpose of a mathly matrix

  T = 'T' -- reserved by mathly
--]]
mathly_meta.__pow = function(m1, opt)
  if opt == 'T' then
    return setmetatable(transpose(m1), mathly_meta)
  else
	  return setmetatable(mathly.pow(m1, opt), mathly_meta)
  end
end

function mathly.equal(m1, m2)
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
mathly_meta.__eq = function(...)
	return mathly.equal(...)
end

-- Set concat ".." behaviour
mathly_meta.__concat = function(...)
	return horzcat(...)
end

-- Set tostring "tostring(t)" behaviour
mathly_meta.__tostring = function(...)
	return mathly.tostring(...)
end

--// mathly.tostring (t)
function mathly.tostring(t)
  _set_disp_format(t)
	if type(t[1]) == 'table' then
    local rowstrs = {}
		for i = 1,#t do
			rowstrs[i] = table.concat(_map(_tostring, t[i]), " ")
		end
		return table.concat(rowstrs, "\n")
  else -- a row vector
    return table.concat(_map(_tostring1, t), " ")
  end
end

--// mathly (rows [, comlumns [, value]])
-- set __call behaviour of matrix
-- for mathly(...) as mathly.new(...)
setmetatable(mathly, { __call = function(...) return mathly.new(...) end })

-- set __call "matrix()" behaviour
mathly_meta.__call = function(...)
	disp(...)
end

--// __index handling
mathly_meta.__index = {}
for k,v in pairs(mathly) do
  mathly_meta.__index[k] = v
end

--------------- end of mathly.lua -----------------


--[[ The following code is obtained from URL: https://github.com/kenloen/plotly.lua
     All variables in functions are made 'local' in addition to some changes. Some
     functions have been removed. All credit belongs to the original auther. --]]

local json = { version = "dkjson 2.8" }

-- https://cdn.plot.ly/plotly-latest.min.js
plotly.cdn_main = "<script src='" .. plotly_engine .. "'></script>"
plotly.id_count = 1
plotly.layout = {}

local _writehtml_failedq = false

-- From: https://stackoverflow.com/questions/11163748/open-web-browser-using-lua-in-a-vlc-extension#18864453
-- Attempts to open a given URL in the system default browser, regardless of Operating System.
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
  self:update_layout(plotly.layout)
  if self['layout']['width'] == nil and self['layout']['height'] == nil then
    self['layout']['width'] = 600 -- 4x3
    self['layout']['height'] = 450
  elseif self['layout']['height'] == nil then
    self['layout']['height'] = self['layout']['width']
  elseif self['layout']['width'] == nil then
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
  local div_id
  if not self.div_id then div_id = "plot" .. plotly.id_count end
  plotly.id_count = plotly.id_count+1
  local plot = [[<div id='%s'>
<script type="text/javascript">
  var data = %s
  var layout = %s
  Plotly.newPlot(%s, data, layout);
</script>
</div>
]] -- simplified
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
  if file ~= nil then
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

-- plot multiple functions/traces on a single figure
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

local function _dk_isarray (t)
  local max, n, arraylen = 0, 0, 0
  for k,v in _dk_pairs (t) do
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
cases, it is easier to start a small project from scratch than debugging and using others' code. In
addition, matrix.lua addresses a column vector like a[i][1] and a row vector a[1][i], rather than a[i]
in both cases, which is quite ugly and unnatural. Furthermore, basic plotting utility is not provided in
matrix.lua. Therefore, this mathly module was developed. But anyway, the work in matrix.lua is highly
appreciated.

David Wang, dwang at liberty dot edu, on 12/25/2024

--]]