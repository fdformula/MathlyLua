--
-- 1. definite integral: integral(f, a, b)
-- 2. doubel integral:   integral2(f, g1, g2, a, b)
-- 3. triple integral:   integral3(f, g1, g2, h1, h2, a, b)
--
-- Simpson 1/3 method is the only method applied
--
-- by David Wang, dwang@liberty.edu, on 10/29/2025 Wednesday
--
function integral(f, a, b) -- integral[f(x), {x, a, b}]
  local N, s4, s2 = ceil(((b - a) / 0.5) / 2) * 2, 0, 0 -- h = 0.5
  if N < 60 then N = 60 end
  local h = (b - a) / N
  local x = linspace(a, b, N + 1)
  for i = 2, N, 2   do s4 = s4 + f(x[i]) end
  for i = 3, N-1, 2 do s2 = s2 + f(x[i]) end
  return (f(a) + 4*s4 + 2*s2 + f(b)) * h / 3
end

-- double integral of f(x, y) over a region:
--   y in [g1(x), g2(x)] and x in [a, b], or
--   x in [g1[y], g2[y]] and y in [a, b]
function integral2(f, g1, g2, a, b)
  if type(g1) == 'number' then
    local v = g1; g1 = function(x) return v end
  end
  if type(g2) == 'number' then
    local v = g2; g2 = function(x) return v end
  end

  local function F(x) -- F(xi) = integral[f(xi, y), {y, g1(xi), g2(xi)}]
    local y1, y2 = g1(x), g2(x)
    if y2 - y1 < 1e-15 then return 0 end -- important
    local N, s4, s2 = ceil(((y2 - y1) / 0.5) / 2) * 2, 0, 0
    if N < 60 then N = 60 end
    local h = (y2 - y1) / N
    local y = linspace(y1, y2, N + 1)
    for i = 2, N, 2   do s4 = s4 + f(x, y[i]) end
    for i = 3, N-1, 2 do s2 = s2 + f(x, y[i]) end
    return (f(x, y1) + 4*s4 + 2*s2 + f(x, y2)) * h / 3
  end

  local N, s4, s2 = ceil(((b - a) / 0.5) / 2) * 2, 0, 0
  if N < 60 then N = 60 end
  local h = (b - a) / N
  local x = linspace(a, b, N + 1)
  for i = 2, N, 2   do s4 = s4 + F(x[i]) end
  for i = 3, N-1, 2 do s2 = s2 + F(x[i]) end
  return (F(a) + 4*s4 + 2*s2 + F(b)) * h / 3
end

-- triple integral of f(x, y, z) over a solid:
--   z in [g1(x, y), g2(x, y)]
--   y in [h1[x], h2[y]]
--   x in [a, b]
--
-- here (x, y, z) can be (y, x, z), (y, z, x), (x, z, y), etc.
-- see integral2
function integral3(f, g1, g2, h1, h2, a, b)
  if type(g1) == 'number' then
    local v = g1; g1 = function(x, y) return v end
  end
  if type(g2) == 'number' then
    local v = g2; g2 = function(x, y) return v end
  end
  if type(h1) == 'number' then
    local v = h1; h1 = function(x) return v end
  end
  if type(h2) == 'number' then
    local v = h2; h2 = function(x) return v end
  end

  local function F(x) -- F(xi) = integral[f(xi, y, z), {z, g1(xi, y), g2(xi, y)}]
    local function G(y)
      local z1, z2 = g1(x, y), g2(x, y)
      if z2 - z1 < 1e-15 then return 0 end -- important
      local N, s4, s2 = ceil(((z2 - z1) / 0.5) / 2) * 2, 0, 0
      if N < 60 then N = 60 end
      local h = (z2 - z1) / N
      local z = linspace(z1, z2, N + 1)
      for i = 2, N, 2   do s4 = s4 + f(x, y, z[i]) end
      for i = 3, N-1, 2 do s2 = s2 + f(x, y, z[i]) end
      return (f(x, y, z1) + 4*s4 + 2*s2 + f(x, y, z2)) * h / 3
    end

    local y1, y2 = h1(x), h2(x)
    if y2 - y1 < 1e-15 then return 0 end -- important
    local N, s4, s2 = ceil(((y2 - y1) / 0.5) / 2) * 2, 0, 0
    if N < 60 then N = 60 end
    local h = (y2 - y1) / N
    local y = linspace(y1, y2, N + 1)
    for i = 2, N, 2   do s4 = s4 + G(y[i]) end
    for i = 3, N-1, 2 do s2 = s2 + G(y[i]) end
    return (G(y1) + 4*s4 + 2*s2 + G(y2)) * h / 3
  end

  local N, s4, s2 = ceil(((b - a) / 0.5) / 2) * 2, 0, 0
  if N < 60 then N = 60 end
  local h = (b - a) / N
  local x = linspace(a, b, N + 1)
  for i = 2, N, 2   do s4 = s4 + F(x[i]) end
  for i = 3, N-1, 2 do s2 = s2 + F(x[i]) end
  return (F(a) + 4*s4 + 2*s2 + F(b)) * h / 3
end

disp(integral(function(x) return x^2 end, 0, 1)) -- exact value 1/3
-- 0.33333333333333

disp(integral2(function(x, y) return x+y end, -- exact value 4
               0, function(x) return x end,
               0, 2))
-- 4.0
disp(integral2(function(x, y) return x*y end, -- exact: 3/8 = 0.375
               function(x) return x end, function(x) return 2*x end,
               0, 1))
-- 0.375

disp(integral3(function(x, y, z) return 2*(x+y+z) end, -- exact value 16/3
               function(x, y) return x - y end, function(x, y) return x + y end,
               function(x) return x end, function(x) return 2 * x end,
               0, 1))
-- 5.3333333333333

disp(integral3(function(x, y, z) return y*sin(x) + z*cos(x) end, -- exact value 2
               -1, 1, 0, 1, 0, pi))
-- 2.0000000835399
