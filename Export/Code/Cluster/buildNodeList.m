function [nodes, fname] = buildNodeList( node_number, threads, reserve_for_self )

temperatureGlobals;

if nargin < 3
    include_self = true;
end
if nargin < 2
    threads = 1;
end

nodelist = getNodeList( reserve_for_self );
nodes = {};

for k = 1:length(nodelist)
    while nodelist{k, 2} >= threads && length(nodes) < node_number
        nodes{end+1} = nodelist{k,1};
        nodelist{k,2} = nodelist{k,2} - threads;
    end
    if length(nodes) >= node_number
        break;
    end
end

if length(nodes) < node_number
    error( 'Cluster:BuildNodeList', 'Insufficient Nodes Available' );
end

if nargout > 1
    fname = [temperature_temp_dir 'nodelist'];
    fout = fopen( fname, 'wt' );
    for k = 1:length(nodes)
        fprintf( fout, '%s\n', nodes{k} );
    end
    fclose( fout );
end
