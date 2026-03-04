mathly = require('mathly')

-- find b^n mod m
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
