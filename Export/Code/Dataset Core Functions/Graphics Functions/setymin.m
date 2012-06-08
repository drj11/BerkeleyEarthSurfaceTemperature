function y=setymin(ymin)
% resets maximum value of x axis
ax = axis; 
axis([ax(1) ax(2) ymin ax(4)])
