function y=setxmax(xmax)
% resets maximum value of x axis
ax = axis; 
axis([ax(1) xmax ax(3) ax(4)])
