function node_res = buildNodeTree()

persistent node_ops hosts;

new = false;
if isempty(node_ops)
    new = true;
else
    try
        hosts{1};
    catch
        new = true;
    end
end

if ~new
    node_res = node_ops;
    return;
end

spmd
    hosts = char(java.net.InetAddress.getLocalHost.getHostName);
end
h2 = strvcat(hosts{:});

[~, ~, indices] = unique( h2, 'rows' );
indices = [0; indices];

[un, I] = unique( indices, 'first');
root_tree = buildTree(length(un));
root_tree2 = root_tree;
for k = 1:numel(root_tree2)
    root_tree2(k) = I(root_tree(k))-1;
end

node_ops = root_tree2;

for k = 1:length(un);
    J = find( indices == un(k) );
    subtree = buildTree( length(J) );
    subtree2 = subtree;
    for j = 1:numel(subtree2)
        subtree2(j) = J(subtree(j)) - 1;
    end
    node_ops = [node_ops; subtree2];
end

node_res = node_ops;



function subtree = buildTree( tree_size )

cloned = false( tree_size, 1 ); 
cloned(1) = true;

node_ops = zeros(100,2);
cnt = 1;
while ~all(cloned)
    pos = 1;
    cloned_update = cloned;
    while pos < length(cloned)
        if cloned(pos)
            pos2 = pos + 1;
            while pos2 <= length(cloned)
                if ~cloned_update(pos2)
                    cloned_update(pos2) = true;
                    node_ops(cnt,:) = [pos, pos2];
                    cnt = cnt + 1;
                    break;
                end
                pos2 = pos2 + 1;
            end
        end
        pos = pos + 1;
    end
    cloned = cloned_update;
end

subtree = node_ops(1:cnt-1,:);

