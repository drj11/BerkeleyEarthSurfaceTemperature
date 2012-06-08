function select = findByName( sites, name, varargin )

if isempty( name )
    error( 'Name Parameter is empty' );
end

names = {sites(:).primary_name};

primary = 1;
exact = 0;
start = 0;

for k = 3:nargin
    switch lower(varargin{k-2})
        case 'exact'
            exact = 1;
            start = 1;
        case 'alt'
            primary = 0;
        case 'start'
            start = 1;
    end
end

name = strtrim( upper(name) );

if exact
    positions = strcmpi( names, name );
else
    A = strfind( upper(names), name );
    positions = zeros(length(A),1);
    for k = 1:length(A)
        if ~isempty(A{k})
            positions(k) = min(A{k});
        end
    end
end

if ~primary
    for k = 1:length(sites)
        if positions(k) ~= 1 && ~isempty( sites(k).alt_names ) 
            if exact
                if positions(k) == 0               
                    pos2 = strmatch( upper( sites(k).alt_names ), name );
                    positions(k) = any(pos2);
                end
            else
                A2 = strfind( upper( sites(k).alt_names ), name );
                for j = 1:length(A2)
                    if isempty(A2{j})
                        continue;
                    end
                    if positions(k) == 0
                        positions(k) = min(A2{j});
                    else
                        positions(k) = min( min(A2{j}), positions(k) );
                    end
                end
            end
        end
    end
end
                
        
if start == 1
    f = (positions > 1);
    positions(f) = 0;
end

select = find( positions );