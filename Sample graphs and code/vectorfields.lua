require 'mathly';

clear()
axissquare()
plot(vectorfield2d('@(x,y) {sin(y), sin(x)}', {-pi, pi, pi/8}, {-pi, pi, pi/8}, 20)) -- vfield1.png
plot(vectorfield2d('@(x,y) {-y, -x}', {scale=10}),
     {layout={width=800, height=600, title='<b>F</b>(x, y) = {-y, -x}'}}) -- vfield2.png
plot(vectorfield2d('@(x,y) {3*cos(3*x), 2*cos(2*y)}', {-1, 1, 1/10}, {-1.5, 1.5, 1/10}, 15),
     {layout={width=600, height=700}}) -- vfield3.png
