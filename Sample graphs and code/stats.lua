mathly = require('mathly')

--stats1.png
plot(pie({bins={5, 6, 1, 10, 7, 6}}, {style = {pull = {0, 0.1, 0, 0, 0, 0}}, names={'A', 'B', 'C', 'D', 'E', 'F'}, title='Demo'}))

--stats2.png
axisnotsquare()
plot(pareto({{'A', 382}, {'B', 22}, {'C', 91}, {'D', 53}, {'E', 19}, {'F', 35}}))

--stats3.png
mu, sigma = 72.11, 13.36
x = flatten(randn(1, 5000, mu, sigma))

function n(x, mu, sigma)
  local z = (x - mu) / sigma
  return exp(-0.5 * z^2) / (sqrt(2 * pi) * sigma)
end

X = linspace(mu - 4 * sigma, mu + 4 * sigma, 5000)
Y = n(X, mu, sigma) * 7.8

axisnotsquare(); showaxes(); shownotlegend()
plot(hist1(x, 12), X, Y, '--r')
