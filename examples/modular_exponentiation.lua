-- calculate b^n mod m, i.e., mod(b^n, m)
mathly = require('mathly')

-- version 1
function recursive_modular_exp(b, n, m)
  if n == 0 then
    return 1
  else
    local tmp = recursive_modular_exp(b, div(n, 2), m)
    local x = mod(tmp * tmp, m)
    if iseven(n) then
      return x
    else
      return mod(x * mod(b, m), m)
    end
  end
end

recursive_modular_exp(350, 20260303, 23)


-- version 2
function binary_modular_exp(b, n, m)
  local a = dec2bin(n)
  local x, power = 1, mod(b, m)
  for i = #a, 1, -1 do
    if a:sub(i, i) == '1' then x = mod(x * power, m) end
    power = mod(power * power, m)
  end
  return x
end

binary_modular_exp(350, 20260303, 23)

