mathly = require('mathly')

-- https://en.wikipedia.org/wiki/Legendre_polynomials
function legendrepoly(n, x)
  if n == 0 then
    return 1
  elseif n == 1 then
    return x
  else
    local N = n - 1
    return ((2*N + 1) * x * legendrepoly(N, x) - N * legendrepoly(N - 1, x)) / n
  end
end

function difflegendrepoly(n, x) -- d legendrepoly(n, x) / dx
  if n == 0 then
    return 0
  elseif n == 1 then
    return 1
  else
    local N = n - 1
    return (x * legendrepoly(n, x) - legendrepoly(n - 1, x)) * n / (x*x - 1)
  end
end

-- n zeros of legendrepoly(n) are all real and in (-1, 1)
-- they are symmetrical about 0
function solvelegendrepoly(n)
  if n == 0 then
    return {}
  elseif n == 1 then
    return {0.0}
  else
    local roots = {}
    local f = fstr2f('@(x) legendrepoly(' .. n .. ', x)')
    if isodd(n) then roots[#roots + 1] = 0.0 end -- 0 is a root
    local m = floor(n / 2) -- find m roots on (0, 1)
    local h = 1 / (100*m) -- large n requires large denominator; 100m works for n <= 30; for larger n, 150m, 200m, or so might be needed
    local a, b = 0.001*h, h
    local fa = f(a)
    for i = 1, m do
      local fb = f(b)
      while abs(fb) > eps and fa * fb > 0 do
        b = b + h
        fb = f(b)
      end
      if abs(fb) <= eps then
        roots[#roots + 1] = -b
        roots[#roots + 1] = b
      else --if fa * fb < 0 then
        local r = fzero(f, {a, b}, eps)
        roots[#roots + 1] = -r
        roots[#roots + 1] = r
      end
      a, b = b, b + h -- to find next root
      fa, fb = fb, f(b)
    end
    return roots
  end
end

gq = function(x) print('Please call find_and_activate_gauss_quadrature(n) first.') end

decimalPlaces = 16

function find_and_activate_gauss_quadrature(n, printq)
  printq = printq == nil
  local nodes = solvelegendrepoly(n)
  local weights = map(function(x) local y = difflegendrepoly(n, x); return 2 / ((1 - x*x) * y*y) end, nodes)

  local s, fmt1, fmt = '', '%20.' .. decimalPlaces .. 'f', '%.' .. decimalPlaces .. 'f'
  if printq then
    print(string.format('%20s', 'nodes') .. string.format('%20s', 'weights'))
    for i = 1, #nodes do
      print(string.format(fmt1, nodes[i]) .. string.format(fmt1, weights[i]))
    end
  end
  for i = 1, #nodes do
    if abs(weights[i]) < eps then -- skip
    else -- all weights are nonnegative
      if i > 1 then s = s .. ' + \n          ' end
      if abs(weights[i] - 1) > eps then
        s = s .. string.format(fmt, weights[i]) .. ' * '
      end
    end
    s = s .. 'f(' .. string.format(fmt, nodes[i]) .. '*A + B)'
  end

  gq = [[
function(f, a, b)
  a, b = a or -1, b or 1
  if type(f) == 'string' then f = fstr2f(f) end
  local A, B = (b - a)/2, (b + a)/2
  return (]] .. s ..') * A\nend'
  if printq then
    print('\nfunction gq(...) is defined as follows:\n' .. string.rep('-', 80))
    print(gq)
    print(string.rep('-', 80))
  end
  gq = eval(gq)
  if printq then
    print('Now, call gq(f) and gq(f, a, b) to evaluate the definite integral of f(x) on [-1, 1] and [a, b], respectively.')
  end
end

find_and_activate_gauss_quadrature(3) -- 3 nodes
gq('@(x) cos(x)')
  -- 1.6830035477269

-- see the effect of the number of nodes used
for n = 2, 16 do
  find_and_activate_gauss_quadrature(n, 'print-not-extra-info')
  printf("n = %2d: %17.15f%s\n", n, gq('@(x) exp(-x^2)', 0, 3), qq(n == 2, ' (integral of e^(-x^2) on [0, 3]; exact value: 0.886207348259521)', ''))
end
-- n =  2: 1.009105074049620 (integral of e^(-x^2) on [0, 3]; exact value: 0.886207348259521)
-- n =  3: 0.884543924798462
-- n =  4: 0.884135930176727
-- n =  5: 0.886529173751462
-- n =  6: 0.886182831984312
-- n =  7: 0.886208222740350
-- n =  8: 0.886207374010109
-- n =  9: 0.886207342187788
-- n = 10: 0.886207348745568
-- n = 11: 0.886207348233421
-- n = 12: 0.886207348260549
-- n = 13: 0.886207348259493
-- n = 14: 0.886207348259522
-- n = 15: 0.886207348259521
-- n = 16: 0.886207348259522

find_and_activate_gauss_quadrature(10) -- 10 nodes
gq('@(x) exp(-x^2)', 0, 3)
-- 0.88620734874557 (exact: 0.886207348259521)

find_and_activate_gauss_quadrature(12) -- 12 nodes
gq('@(x) exp(-x^2)', 0, 3)
-- 0.88620734826055 (exact: 0.886207348259521)

find_and_activate_gauss_quadrature(16) -- 20 nodes
gq('@(x) exp(-x^2)', 0, 3)
-- 0.88620734825952 (exact: 0.886207348259521)
