function rot = randomRotation()
% rot = randomRotation()
% Generate a uniformly distributed random rotation matrix
% 
% Based on "Fast Random Rotation Matrices" by James Avro

r = rand(3,1);

R = [cos(2*pi*r(1)) sin(2*pi*r(1)) 0;
     -sin(2*pi*r(1)) cos(2*pi*r(1)) 0;
     0 0 1];
 
 v = [cos(2*pi*r(2)) * sqrt(r(3)); sin(2*pi*r(2)) * sqrt(r(3)); sqrt(1-r(3))];
 
 
 H = eye(3) - 2*v*v';
 
 rot = -H*R;