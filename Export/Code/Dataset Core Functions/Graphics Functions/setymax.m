function y=setymax(ymax)
% sets axis([0 .06 0 ymax])
ax = axis; 
axis([ax(1) ax(2) ax(3) ymax])
