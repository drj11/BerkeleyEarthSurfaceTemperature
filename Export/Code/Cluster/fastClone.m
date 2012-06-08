function C = fastClone( data )

node_ops = buildNodeTree;

C = Composite();
for k = 1:length(node_ops)
    if node_ops(k,1) == 0
        C{node_ops(k,2)} = data;
    end
end

spmd
    for k = 1:length(node_ops)
        if node_ops(k,1) == labindex
            labSend( C, node_ops(k,2) );            
        elseif node_ops(k,2) == labindex && node_ops(k,1) > 0
            C = labReceive( node_ops(k,1) );
        end
    end
end
