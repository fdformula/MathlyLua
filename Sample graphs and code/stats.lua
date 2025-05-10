require 'mathly';
clear()

--stats1.png
axissquare(); shownotaxes(); shownotgridlines(); showlegend()
plot(pie({bins={5, 6, 1, 10, 7, 6}}, {offcenter = {{4, 0.1}}, style = '-fs', names={'A', 'B', 'C', 'D', 'E', 'F', 'G'}}))

--stats2.png
axisnotsquare()
plot(pareto({{'A', 382}, {'B', 22}, {'C', 91}, {'D', 53}, {'E', 19}, {'F', 35}}))

--stats3.png
mu, sigma = 72.11, 13.36
x = flatten(randn(1, 5000, mu, sigma))

function n(x, mu, sigma)
  local z = (x - mu) / sigma
  return math.exp(-0.5 * z^2) / (math.sqrt(2 * pi) * sigma)
end

X = linspace(mu - 4 * sigma, mu + 4 * sigma, 5000)
Y = map('@(x) n(x, mu, sigma) * 7.8', X)

axisnotsquare(); showaxes(); shownotlegend()
plot(hist1(x, 12), X, Y, '--r')
