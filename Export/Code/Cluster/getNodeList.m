function nodes = getNodeList( reserve_for_self )

if nargin < 1
    include_self = true;
end

node_file = getenv( 'PBS_NODEFILE' );

nodes = {};

fin = fopen( node_file, 'r' );
while ~feof( fin )
    A = fgetl( fin );
    found = false;
    sz = size( nodes );
    for j = 1:sz(1)
        if strcmp( nodes{j, 1}, A )
            nodes{j, 2} = nodes{j, 2} + 1;
            found = true;
            break;
        end
    end
    if ~found
        nodes(end+1,:) = {A, 1};
    end
end

if reserve_for_self
    config = pctconfig();
    selfname = config.hostname;
    
    for j = 1:length(nodes)
        if strcmpi( nodes{j,1}, selfname )
            nodes{j,2} = nodes{j,2} - reserve_for_self;
            if nodes{j,2} <= 0
                nodes(j,:) = [];
            end
            break;
        end
    end
end
