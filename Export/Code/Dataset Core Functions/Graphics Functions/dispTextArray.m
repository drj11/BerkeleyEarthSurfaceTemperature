function res = dispTextArray( labels, content )

if ischar( labels )
    labels = cellstr( labels );
end
if ischar( content )
    content = cellstr( content );
end

if length(labels) ~= length( content )
    error( 'Labels do not have same length as content' );
end

lengths = zeros( length(labels), 1);
for k = 1:length( labels )
    lengths(k) = length( labels{k} );
end
c_lengths = zeros( length(content), 1);
for k = 1:length(content)
    if isnumeric( content{k} ) 
        content{k} = num2str( content{k} );        
    elseif ischar( content{k} )
        content{k} = ['"' content{k} '"'];
    else
        error( 'Can''t use this data type' );
    end
    c_lengths(k) = length(content{k});
end

cc = max(c_lengths);

full = max(lengths);

if full + cc > 63 
    cut = 63 - cc - 3;
    for k = 1:length(labels)
        if lengths(k) > cut
            labels{k} = textwrap( labels(k), cut );            
            lengths2 = zeros( length(labels{k}), 1 );
            for j = 1:length(labels{k})
                lengths2(j) = length(labels{k}{j});
            end
            lengths(k) = max( lengths2 );    
        end        
    end    
end
full = max(lengths);

res = {};
for k = 1:length(labels)
    if iscell( labels{k} )
        for j = 1:length(labels{k})
            if j < length(labels{k})
                if j > 1
                    res{end+1} = [blanks( full - lengths( k ) + 3 ), ...
                        labels{k}{j}];
                else
                    res{end+1} = [blanks( full - lengths( k ) ), ...
                        labels{k}{j}];                    
                end
            else
                if j > 1
                    res{end+1} = [blanks( full - lengths( k ) + 3 ), ...
                        labels{k}{j}, ...
                        blanks( lengths( k ) - length( labels{k}{j} ) - 3 ) ...
                        ': ' content{k}];
                else
                    res{end+1} = [blanks( full - lengths( k ) ), ...
                        labels{k}{j}, ...
                        blanks( lengths( k ) - length( labels{k}{j} ) ) ...
                        ': ' content{k}];
                end                    
            end
        end        
    else
        if lengths(k) == 0
            res{end+1} = ' ';
        else
            res{end+1} = [blanks( full - lengths(k) ), labels{k} ': ' content{k}];
        end
    end
end

res = char(res);