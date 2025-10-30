--
-- 1. definite integral: integral(f, a, b)
-- 2. doubel integral:   integral2(f, g1, g2, a, b)
-- 3. triple integral:   integral3(f, g1, g2, h1, h2, a, b)
--
-- Simpson 1/3 method is the only method applied
--
-- by David Wang, dwang@liberty.edu, on 10/29/2025 Wednesday
--
DefaultH = 0.05

function integral(f, a, b) -- integral[f(x), {x, a, b}]
  if type(f) == 'string' then f = fstr2f(f) end
  local sign = 1
  if a > b then a, b = b, a; sign = -1 end
  if b - a < eps then return 0 end
  local N, s4, s2 = ceil(((b - a) / DefaultH) / 2) * 2, 0, 0
  local h = (b - a) / N
  local x = linspace(a, b, N + 1)
  for i = 2, N, 2   do s4 = s4 + f(x[i]) end
  for i = 3, N-1, 2 do s2 = s2 + f(x[i]) end
  return sign * (f(a) + 4*s4 + 2*s2 + f(b)) * h / 3
end

-- double integral of f(x, y) implemented for a region:
--   y in [g1(x), g2(x)] and x in [a, b], or
--   x in [g1[y], g2[y]] and y in [a, b]
--
-- in polar coordinates: r -> y, theta -> x
--
function integral2(f, g1, g2, a, b)
  if type(f) == 'string' then f = fstr2f(f) end
  if type(g1) == 'number' then
    local v = g1; g1 = function(x) return v end
  elseif type(g1) == 'string' then
    g1 = fstr2f(g1)
  end
  if type(g2) == 'number' then
    local v = g2; g2 = function(x) return v end
  elseif type(g2) == 'string' then
    g2 = fstr2f(g2)
  end

  local function F(x) -- F(xi) = integral[f(xi, y), {y, g1(xi), g2(xi)}]
    local y1, y2, sign = g1(x), g2(x), 1
    if y1 > y2 then y1, y2 = y2, y1; sign = -1 end
    if y2 - y1 < eps then return 0 end -- f(x, y1) * (y2 - y1) end
    local N, s4, s2 = ceil(((y2 - y1) / DefaultH) / 2) * 2, 0, 0
    local h = (y2 - y1) / N
    local y = linspace(y1, y2, N + 1)
    for i = 2, N,   2 do s4 = s4 + f(x, y[i]) end
    for i = 3, N-1, 2 do s2 = s2 + f(x, y[i]) end
    return sign * (f(x, y1) + 4*s4 + 2*s2 + f(x, y2)) * h / 3
  end

  local sign = 1
  if a > b then a, b = b, a; sign = -1 end
  if b - a < eps then return 0 end
  local N, s4, s2 = ceil(((b - a) / DefaultH) / 2) * 2, 0, 0
  local h = (b - a) / N
  local x = linspace(a, b, N + 1)
  for i = 2, N,   2 do s4 = s4 + F(x[i]) end
  for i = 3, N-1, 2 do s2 = s2 + F(x[i]) end
  return sign * (F(a) + 4*s4 + 2*s2 + F(b)) * h / 3
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
  if type(f) == 'string' then f = fstr2f(f) end
  if type(g1) == 'number' then
    local v = g1; g1 = function(x, y) return v end
  elseif type(g1) == 'string' then
    g1 = fstr2f(g1)
  end
  if type(g2) == 'number' then
    local v = g2; g2 = function(x, y) return v end
  elseif type(g2) == 'string' then
    g2 = fstr2f(g2)
  end
  if type(h1) == 'number' then
    local v = h1; h1 = function(x) return v end
  elseif type(h1) == 'string' then
    h1 = fstr2f(h1)
  end
  if type(h2) == 'number' then
    local v = h2; h2 = function(x) return v end
  elseif type(h2) == 'string' then
    h2 = fstr2f(h2)
  end

  local function F(x) -- F(xi) = integral[f(xi, y, z), {z, g1(xi, y), g2(xi, y)}]
    local function G(y)
      local z1, z2, sign = g1(x, y), g2(x, y), 1
      if z1 > z2 then z1, z2 = z2, z1; sign = -1 end
      if z2 - z1 < eps then return 0 end
      local N, s4, s2 = ceil(((z2 - z1) / DefaultH) / 2) * 2, 0, 0
      local h = (z2 - z1) / N
      local z = linspace(z1, z2, N + 1)
      for i = 2, N, 2   do s4 = s4 + f(x, y, z[i]) end
      for i = 3, N-1, 2 do s2 = s2 + f(x, y, z[i]) end
      return sign * (f(x, y, z1) + 4*s4 + 2*s2 + f(x, y, z2)) * h / 3
    end

    local y1, y2, sign = h1(x), h2(x), 1
    if y1 > y2 then y1, y2 = y2, y1; sign = -1 end
    if y2 - y1 < eps then return 0 end
    local N, s4, s2 = ceil(((y2 - y1) / DefaultH) / 2) * 2, 0, 0
    local h = (y2 - y1) / N
    local y = linspace(y1, y2, N + 1)
    for i = 2, N,   2 do s4 = s4 + G(y[i]) end
    for i = 3, N-1, 2 do s2 = s2 + G(y[i]) end
    return sign * (G(y1) + 4*s4 + 2*s2 + G(y2)) * h / 3
  end

  local sign = 1
  if a > b then a, b = b, a; sign = -1 end
  local N, s4, s2 = ceil(((b - a) / DefaultH) / 2) * 2, 0, 0
  local h = (b - a) / N
  local x = linspace(a, b, N + 1)
  for i = 2, N,   2 do s4 = s4 + F(x[i]) end
  for i = 3, N-1, 2 do s2 = s2 + F(x[i]) end
  return sign * (F(a) + 4*s4 + 2*s2 + F(b)) * h / 3
end

--
----------------- test -----------------
--
disp(integral('@(x) x^2', 0, 1))
-- 0.33333333333333 (exact value 1/3)

disp(integral2('@(x, y) x + y', 0, 1, 0, 1))
-- 1.0 (exact: 1)
disp(integral2('@(x, y) x * y', '@(x) x', '@(x) 2*x', 0, 1))
-- 0.375 (exact: 3/8 = 0.375)
disp(integral2('@(x, y) x + 2*y', '@(x) 2 * x^2', '@(x) 1 + x^2', -1, 1))
-- 2.1333283333333 (exact: 32/15 = 2.1333333333333)

-- in polar coordinates: r -> y, theta -> x
disp(integral2('@(x, y) y^3', 0, '@(x) 2*cos(x)', -pi/2, pi/2))
-- 4.7123889803847 (exact: 3*pi/2 = 4.7123889803847)

disp(integral3('@(x, y, z) 2*(x + y + z)', '@(x, y) x - y', '@(x, y) x + y', '@(x) x', '@(x) 2 * x', 0, 1))
-- 5.3333333333333 (exact value 16/3 = 5.3333333333333)
disp(integral3('@(x, y, z) y*sin(x) + z*cos(x)', -1, 1, 0, 1, 0, pi))
-- 2.00000006453 (exact value 2)

-- in spherical coordinates: rho -> z, phi -> y, theta -> x
disp(integral3('@(x, y, z) z^2 * sin(y)', 0, '@(x, y) cos(y)', 0, pi/4, 0, 2*pi))
-- 0.39270030284801 (exact: pi/8 = 0.39269908169872)
