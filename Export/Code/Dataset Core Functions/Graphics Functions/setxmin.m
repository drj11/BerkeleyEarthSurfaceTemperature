function y=setxmin(xmin)
% resets maximum value of x axis
ax = axis; 
axis([xmin ax(2) ax(3) ax(4)])
