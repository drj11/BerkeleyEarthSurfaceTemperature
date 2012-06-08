function result = fastSum( C )

node_ops = buildNodeTree;
node_ops = node_ops(end:-1:1, [2,1]);

spmd
    for k = 1:length(node_ops)
        if node_ops(k,1) == labindex && node_ops(k,2) > 0
            labSend( C, node_ops(k,2) );            
        elseif node_ops(k,2) == labindex && node_ops(k,1) > 0
            C = C + labReceive( node_ops(k,1) );           
        end
    end
end

first = true;
for k = 1:length(node_ops)
    if node_ops(k,2) == 0
        if first
            result = C{node_ops(k,1)};
            first = false;
        else
            result = result + C{node_ops(k,1)};
        end            
    end
end
