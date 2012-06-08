function res = getSingleFile( ht, index, keys )

pth = [ht.dir num2str(index) '_data.mat'];

% Do NOT try to filter this by keys, the performance of doing that is
% ridiculously bad.  Instead we need to do a good job of partitioning our
% data into different files, so that loading an entire file is OK most of
% the time.
vals = load( pth );

res = cell(length(keys),1);

for k = 1:length(res)
    try
        res{k} = vals.(keys{k});
    catch e
        if strcmp (e.identifier, 'MATLAB:nonExistentField' )
            if keys{k}(1) == 's'
                res{k} = [];
            else
                warning( 'primitiveHashTable:get', ...
                    ['Key ' keys{k}(3:end) ' not found']);
                res{k} = [];
            end
        else
            throw(e);
        end            
    end
end