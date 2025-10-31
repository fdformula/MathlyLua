--
-- 1. definite integral: integral(f, a, b)
-- 2. doubel integral:   integral2(f, g1, g2, a, b)
-- 3. triple integral:   integral3(f, g1, g2, h1, h2, a, b)
--
-- Gauss quadrature is the only method applied
--
-- by David Wang, dwang at liberty dot edu, on 10/30/2025 Thursday
--
-- Gauss quadrature of 12 nodes
-- see: https://pomax.github.io/bezierinfo/legendre-gauss.html
_Gw = {
  0.2491470458134028, 0.2491470458134028, 0.2334925365383548, 0.2334925365383548,
  0.2031674267230659, 0.2031674267230659, 0.1600783285433462, 0.1600783285433462,
  0.1069393259953184, 0.1069393259953184, 0.0471753363865118, 0.0471753363865118
}

_Gx = {
 -0.1252334085114689, 0.1252334085114689, -0.3678314989981802, 0.3678314989981802,
 -0.5873179542866175, 0.5873179542866175, -0.7699026741943047, 0.7699026741943047,
 -0.9041172563704749, 0.9041172563704749, -0.9815606342467192, 0.9815606342467192
}

MaxIntervalSize = 10

function integral(f, a, b)
  if type(f) == 'string' then
    f = fstr2f(f)
  elseif type(f) == 'number' then
    return (b - a) * f
  end
  local sign = 1
  if a > b then a, b = b, a; sign = -1 end
  local n, A, B, s, siz = 1, a, b, 0, b - a
  if b - a > MaxIntervalSize then
    n = ceil((b - a) / MaxIntervalSize)
    siz = (b - a) / n
    B = A + siz
  end
  local k = sign * (B - A)/2
  while B <= b do
    local k, h = (B - A)/2, (B + A)/2
    for i = 1, #_Gw do s = s + _Gw[i] * f(k * _Gx[i] + h) end
    A, B = B, B + siz
  end
  return k * s
end

function _make_function(f)
  if type(f) == 'number' then
    local v = f; return function(x, y, z) return v end -- extra arguments do not matter
  elseif type(f) == 'string' then
    return fstr2f(f)
  else
    return f
  end
end

-- double integral of f(x, y) implemented for a region:
--   y in [g1(x), g2(x)] and x in [a, b], or
--   x in [g1[y], g2[y]] and y in [a, b]
--
-- in polar coordinates: r -> y, theta -> x
--
function integral2(f, g1, g2, a, b)
  f, g1, g2 = table.unpack(map(_make_function, {f, g1, g2}))
  local function F(x) -- F(xi) = integral[f(xi, y), {y, g1(xi), g2(xi)}]
    local y1, y2, sign = g1(x), g2(x), 1
    if y1 > y2 then y1, y2 = y2, y1; sign = -1 end
    if y2 - y1 < eps then return 0 end -- f(x, y1) * (y2 - y1) end
    local n, A, B, s, siz = 1, y1, y2, 0, y2 - y1
    if y2 - y1 > MaxIntervalSize then
      n = ceil((y2 - y1) / MaxIntervalSize)
      siz = (y2 - y1) / n
      B = A + siz
    end
    local m = sign * (B - A)/2
    while B <= y2 do
      local k, h = (B - A)/2, (B + A)/2
      for i = 1, #_Gw do s = s + _Gw[i] * f(x, k * _Gx[i] + h) end
      A, B = B, B + siz
    end
    return m * s
  end
  local sign = 1
  if a > b then a, b = b, a; sign = -1 end
  if b - a < eps then return 0 end
  local n, A, B, s, siz = 1, a, b, 0, b - a
  if b - a > MaxIntervalSize then
    n = ceil((b - a) / MaxIntervalSize)
    siz = (b - a) / n
    B = A + siz
  end
  local m = sign * (B - A)/2
  while B <= b do
    local k, h = (B - A)/2, (B + A)/2
    for i = 1, #_Gw do s = s + _Gw[i] * F(k * _Gx[i] + h) end
    A, B = B, B + siz
  end
  return m * s
end

-- triple integral of f(x, y, z) implemented for a solid:
--   z in [g1(x, y), g2(x, y)]
--   y in [h1[x], h2[y]]
--   x in [a, b]
--
-- here (x, y, z) can be (y, x, z), (y, z, x), (x, z, y), etc.
--
-- in spherical coordinates (rho, theta, phi): rho -> z, phi -> y, theta -> x
--
-- see integral2
function integral3(f, g1, g2, h1, h2, a, b)
  f, g1, g2, h1, h2 = table.unpack(map(_make_function, {f, g1, g2, h1, h2}))
  local function F(x) -- F(xi) = integral[f(xi, y, z), {z, g1(xi, y), g2(xi, y)}]
    local function G(y)
      local z1, z2, sign = g1(x, y), g2(x, y), 1
      if z1 > z2 then z1, z2 = z2, z1; sign = -1 end
      if z2 - z1 < eps then return 0 end
      local n, A, B, s, siz = 1, z1, z2, 0, z2 - z1
      if z2 - z1 > MaxIntervalSize then
        n = ceil((z2 - z1) / MaxIntervalSize)
        siz = (z2 - z1) / n
        B = A + siz
      end
      local m = sign * (B - A)/2
      while B <= z2 do
        local k, h = (B - A)/2, (B + A)/2
        for i = 1, #_Gw do s = s + _Gw[i] * f(x, y, k * _Gx[i] + h) end
        A, B = B, B + siz
      end
      return m * s
    end
    local y1, y2, sign = h1(x), h2(x), 1
    if y1 > y2 then y1, y2 = y2, y1; sign = -1 end
    if y2 - y1 < eps then return 0 end
    local n, A, B, s, siz = 1, y1, y2, 0, y2 - y1
    if y2 - y1 > MaxIntervalSize then
      n = ceil((y2 - y1) / MaxIntervalSize)
      siz = (y2 - y1) / n
      B = A + siz
    end
    local m = sign * (B - A)/2
    while B <= y2 do
      local k, h = (B - A)/2, (B + A)/2
      for i = 1, #_Gw do s = s + _Gw[i] * G(k * _Gx[i] + h) end
      A, B = B, B + siz
    end
    return m * s
  end

  local sign = 1
  if a > b then a, b = b, a; sign = -1 end
  if b - a < eps then return 0 end
  local n, A, B, s, siz = 1, a, b, 0, b - a
  if b - a > MaxIntervalSize then
    n = ceil((b - a) / MaxIntervalSize)
    siz = (b - a) / n
    B = A + siz
  end
  local m = sign * (B - A)/2
  while B <= b do
    local k, h = (B - A)/2, (B + A)/2
    for i = 1, #_Gw do s = s + _Gw[i] * F(k * _Gx[i] + h) end
    A, B = B, B + siz
  end
  return m * s
end

----------------- test -----------------

disp(integral('@(x) x^2', 1, 20))
-- 2666.3333333333 (exact: 7999/3 = 2666.3333333333)
disp(integral(10, 1, 20))
-- 190 (exact)
disp(integral('@(x) exp(-x^2)', -10, 10))
-- 1.7725140943124 (exact: about sqrt(pi) = 1.7724538509055)

disp(integral2('@(x, y) x + y', 0, 1, 0, 1))
-- 1.0 (exact: 1)
disp(integral2('@(x, y) x * y', '@(x) x', '@(x) 2*x', 0, 1))
-- 0.375 (exact: 3/8 = 0.375)
disp(integral2('@(x, y) x + 2*y', '@(x) 2 * x^2', '@(x) 1 + x^2', -1, 1))
-- 2.1333333333333 (exact: 32/15 = 2.1333333333333)

-- in polar coordinates: r -> y, theta -> x
disp(integral2('@(x, y) y^3', 0, '@(x) 2*cos(x)', -pi/2, pi/2))
-- 4.7123889803824 (exact: 3*pi/2 = 4.7123889803847)

disp(integral3('@(x, y, z) 2*(x + y + z)', '@(x, y) x - y', '@(x, y) x + y', '@(x) x', '@(x) 2 * x', 0, 1))
-- 5.3333333333333 (exact value 16/3 = 5.3333333333333)
disp(integral3('@(x, y, z) y*sin(x) + z*cos(x)', -1, 1, 0, 1, 0, pi))
-- 2.0 (exact value 2)

-- in spherical coordinates: rho -> z, phi -> y, theta -> x
disp(integral3('@(x, y, z) z^2 * sin(y)', 0, '@(x, y) cos(y)', 0, pi/4, 0, 2*pi))
-- 0.39269908169872 (exact: pi/8 = 0.39269908169872)
