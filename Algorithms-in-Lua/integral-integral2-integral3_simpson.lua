--
-- 1. definite integral: integral(f, a, b)
-- 2. doubel integral:   integral2(f, g1, g2, a, b)
-- 3. triple integral:   integral3(f, g1, g2, h1, h2, a, b)
--
-- Simpson 1/3 method is the only method implemented here
--
-- by David Wang, dwang at liberty dot edu, on 10/29/2025 Wednesday
--
DefaultH = 0.05

function integral(f, a, b) -- integral[f(x), {x, a, b}]
  if type(f) == 'string' then
    f = fstr2f(f)
  elseif type(f) == 'number' then
    return (b - a) * f
  end
  local sign = 1
  if a > b then a, b = b, a; sign = -1 end
  local N, s4, s2 = ceil(((b - a) / DefaultH) / 2) * 2, 0, 0
  local h = (b - a) / N
  local x = linspace(a, b, N + 1)
  for i = 2, N, 2   do s4 = s4 + f(x[i]) end
  for i = 3, N-1, 2 do s2 = s2 + f(x[i]) end
  return sign * (f(a) + 4*s4 + 2*s2 + f(b)) * h / 3
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

-- double integral ∫∫ f(x, y) dydx over a region:
--   y in [g1(x), g2(x)]
--   x in [a, b]
-- the order of the arguments of the integrand, from right to left, is the order of integration
-- so,
-- with polar coordinates: ∫∫f(θ,r)drdθ
function integral2(f, g1, g2, a, b)
  f, g1, g2 = table.unpack(map(_make_function, {f, g1, g2}))
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
  local N, s4, s2 = ceil(((b - a) / DefaultH) / 2) * 2, 0, 0
  local h = (b - a) / N
  local x = linspace(a, b, N + 1)
  for i = 2, N,   2 do s4 = s4 + F(x[i]) end
  for i = 3, N-1, 2 do s2 = s2 + F(x[i]) end
  return sign * (F(a) + 4*s4 + 2*s2 + F(b)) * h / 3
end

-- triple integral ∫∫∫ f(x, y, z) dzdydx over a solid:
--   z in [g1(x, y), g2(x, y)]
--   y in [h1[x], h2[y]]
--   x in [a, b]
-- the order of the arguments of the integrand, from right to left, is the order of integration
-- so,
-- with spherical coordinates:   ∫∫∫f(θ,φ,ρ)dρdφdθ
-- with cylindrical coordinates: ∫∫∫f(θ,r,z)dzdrdθ
function integral3(f, g1, g2, h1, h2, a, b)
  f, g1, g2, h1, h2 = table.unpack(map(_make_function, {f, g1, g2, h1, h2}))
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

----------------- test -----------------

disp(integral('@(x) x^2', 1, 20))
-- 2666.3333333334 (exact: 7999/3 = 2666.3333333333)
disp(integral(10, 1, 20))
-- 190 (exact)
disp(integral('@(x) exp(-x^2)', -10, 10))
-- 1.7724538509055 (exact: about sqrt(pi) = 1.7724538509055)

disp(integral2('@(x, y) x + y', 0, 1, 0, 1))
-- 1.0 (exact: 1)
disp(integral2('@(x, y) x * y', '@(x) x', '@(x) 2*x', 0, 1))
-- 0.375 (exact: 3/8 = 0.375)
disp(integral2('@(x, y) x + 2*y', '@(x) 2 * x^2', '@(x) 1 + x^2', -1, 1))
-- 2.1333283333333 (exact: 32/15 = 2.1333333333333)

-- in polar coordinates: f(θ, r): ∫∫ f(θ, r) drdθ
disp(integral2('@(theta, r) r^3', 0, '@(theta) 2*cos(theta)', -pi/2, pi/2))
-- 4.7123889803847 (exact: 3*pi/2 = 4.7123889803847)

disp(integral2('@(x, y) sqrt(x^2 + y^2)', '@(x) -sqrt(4 - x^2)', '@(x) sqrt(4 - x^2)', -2, 2))
-- 16.740594748532 (exact: 16*pi/3 = 16.755160819146)
disp(integral2('@(theta, r) r^2', 0, 2, 0, 2*pi))
-- 16.755160819146 (exact: 16*pi/3 = 16.755160819146)


disp(integral3('@(x, y, z) 2*(x + y + z)', '@(x, y) x - y', '@(x, y) x + y', '@(x) x', '@(x) 2 * x', 0, 1))
-- 5.3333333333333 (exact value 16/3 = 5.3333333333333)
disp(integral3('@(x, y, z) y*sin(x) + z*cos(x)', -1, 1, 0, 1, 0, pi))
-- 2.00000006453 (exact value 2)

-- in spherical coordinates: f(θ, φ, ρ): ∫∫∫ f(θ, φ, ρ) dρdφdθ
disp(integral3('@(theta, phi, rho) rho^2 * sin(phi)', 0, '@(theta, phi) cos(phi)', 0, pi/4, 0, 2*pi))
-- 0.39270030284801 (exact: pi/8 = 0.39269908169872)
