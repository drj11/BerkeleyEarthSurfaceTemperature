function [a,b] = nodesAvailable()

nodelist = getNodeList();

a = length(nodelist(:,1));
b = 0;
for k = 1:a
    b = b + nodelist{k,2};
end

