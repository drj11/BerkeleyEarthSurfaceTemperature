function dd = dictionary( varargin )

if nargin == 0
    dd.keys = {};
    dd.values = {};
    
    dd = class( dd, 'dictionary' );
elseif nargin == 1;
    if isa( varargin{1}, 'dictionary' )
        dd = varargin{1};
    else
        error( 'Unatticipated input.' );
    end
elseif nargin == 2
    ks = varargin{1};
    vs = varargin{2};
    if length(ks) ~= length(vs)
        error( 'Lengths do not match' );
    end
    if isa( vs, 'char' )
        vs = cellstr( vs );
    end    
    if ~isa( vs, 'cell' )
        vs2 = cell(length(vs),1);
        for k = 1:length(vs)
            vs2{k} = vs(k);
        end
        vs = vs2;
    end
    if isa( ks, 'char' )
        ks = cellstr( ks );
    end    
    if ~isa( ks, 'cell' )
        ks2 = cell(length(ks),1);
        for k = 1:length(ks)
            ks2{k} = num2str(ks(k));
        end
        ks = ks2;
    end
    
    [s,I] = sort( ks );
    ks = s;
    vs = vs(I);
    
    dd.keys = ks;
    dd.values = vs;
    dd = class( dd, 'dictionary' );
    
else
    error( 'Too many inputs.' );
end
            
        
    