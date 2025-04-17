--[[
  Solve tridiagnoal system Ax = B by Thomas method

  David Wang, dwang at liberty dot edu

  input: a, d, b,where a is above diagnal, d is diagonal, and b is below diagonal, of A
         B
  output: numerical solution for Ax = B

      (d1 a1 0  0  0  ... 0  0 )
      (b2 d2 a2 0  0  ... 0  0 )
      (0  b3 d3 a3 0  ... 0  0 )
  A = (0  0  b4 d4 a4 ... 0  0 )
      ( ...................... )
      (0  0  0  0  0  ... bn dn)
--]]

require 'mathly'

function tridiagonal_system(a, d, b, B)
  local n = length(d)
  if length(a) ~= n - 1 or length(b) ~= n or length(B) ~= n then
    error("Error: vectors a, d, b, and B are not conformant.\n")
  end

  a[1] = a[1] / d[1]
  B[1] = B[1] / d[1]
  for i = 2, n - 1 do
    local tmp = d[i] - b[i] * a[i - 1]
    a[i] = a[i] / tmp
    B[i] = (B[i] - b[i] * B[i - 1]) / tmp
  end
  B[n] = (B[n] - b[n] * B[n - 1]) / (d[n] - b[n] * a[n - 1])

  local x = zeros(1, n)
  x[n] = B[n]
  for i = n - 1, 1, -1 do
    x[i] = B[i] - a[i] * x[i + 1]
  end

  return x
end

--------- Test ---------
function test()
  -- size of matrix A
  local n = 10

  -- randomly generate A and B
  local A = randi({0, 100}, n, n)
  local B = randi({0, 100}, 1, n)

  A = remake(A, {-1, 0, 1}) -- make A tridiagonal
  -- this line can be the following code if translated to other language
  --[[
  for i = 1, n do
    for j = 1, i - 2 do
      A[i][j] = 0
    end
    for j = i + 2, n do
      A[i][j] = 0
    end
  end
  --]]
  print('The coefficient matrix:')
  disp(A)

  -- extract vectors a, b, d from tridiagonal matrix A
  -- a - entries above diagonal
  -- b - entries below diagonal, except b[1], a space holder that can be assigned any value
  -- d - entries on diagonal
  local a = tt(diag(A, 1))
  local d = tt(diag(A, 0))
  local b = tblcat(0, diag(A, -1)) -- b[1] = 0, a space holder
  -- these three lines can be the following code if translated to other language
--[[
  local a = zeros(1, n-1)
  local b = zeros(1, n)
  local d = zeros(1, n)

  b[1] = 0
  d[1] = A[1][1]
  a[1] = A[1][2]
  for i = 2, n - 1 do
    b[i] = A[i][i - 1]
    d[i] = A[i][i]
    a[i] = A[i][i + 1]
  end
  b[n] = A[n][n - 1]
  d[n] = A[n][n]
--]]

  -- call user-defined function 'tridiagonal_system' to solve the tridiagonal system
  local x = tridiagonal_system(a, d, b, copy(B))    -- MATLAB: B rather than copy(B)

  -- verify if implementation is correct or not
  print("Deviation of solution for Ax = b from the solution found by built-in method:")
  disp(norm(inv(A) * B - x))
end

test()

