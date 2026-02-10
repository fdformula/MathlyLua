mathly = require('mathly')

-- return the inverse of a modulo m by Euclidean algorithm
-- https://rosettacode.org/wiki/Modular_inverse AWK code
function mod_inv(a, m)
  local m0, x0, x1 = m, 0, 1
  if m == 1 then return 1 end
  while a > 1 do
    x0, x1 = x1 - (a // m) * x0, x0
    m, a = a % m, m
  end
  if x1 < 0 then x1 = x1 + m0 end
  return x1
end

-- solve x ≡ a[i] (mod m[i]), i = 1, 2, ..., n, for x
-- where a = {a[1], a[2], ..., a[n]}, m = {m[1], m[2], ..., m[n]}
function chinese_remainder_theorem(a, m)
  local p = prod(m)
  local M = map(function(x) return p // x end, m)
  local y = map(mod_inv, M, m)
  local x = sum(tt(a) * M * y)

  local v = x % p
  print(string.format("x = %d ≡ %d (mod %d)", x, v, p))
  return v, p
end

chinese_remainder_theorem({2, 3, 2}, {3, 5, 7}) -- 23, 105
chinese_remainder_theorem({1, 2, 3}, {5, 6, 7}) -- 206, 210

chinese_remainder_theorem({1, 2, 3, 5, 3}, {5, 6, 7, 11, 17})
-- x = 272156 ≡ 36536 (mod 39270)
-- 36536   39270

