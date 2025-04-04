plotparametriccurve3d(
  {function(t) return math.cos(t) end,
   function(t) return math.sin(t) end,
   function(t) return t end}, {0,6*pi}, "Helix", nil, 1)

plotparametriccurve3d(
  {function(t) return t*math.cos(t) end,
   function(t) return t*math.sin(t) end,
   function(t) return t end}, {0, 8*pi}, nil, nil, 1)

plot(
  parametriccurve2d({function(t) return 3*cos(t) end, function(t) return 3*sin(t) end}, nil, nil, nil, 1),
  parametriccurve2d({function(t) return sin(t) end, function(t) return 2*cos(t) end},
  nil, nil, nil, 1))   