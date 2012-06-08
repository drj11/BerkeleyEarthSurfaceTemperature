function ds = dataSet( varargin )

ds.name = '';

ds.types = [];
ds.frequencies = [];
ds.data = md5hash;
ds.sites = md5hash;

ds.hash = md5hash();

if nargin == 0    
    ds = class( ds, 'dataSet' );
elseif nargin == 1
    if isa(varargin{1}, 'dataSet' )
        ds = varargin{1};
    else
        error( 'DataSet constructor called with argument of wrong type' );
    end
elseif nargin == 2
    name = varargin{1};
    items = varargin{2};
    if ~ischar( name )
        error( 'First argument must be the name.' );
    end
    
    ds.name = name;
    
    if isa( items, 'md5hash' )
        tb = typedHashTable( 'stationElement2' );
        items2 = load( tb, items );
        if length( items2 ) < length(items) 
            length(items2)
            length(items)
            error( 'Can''t locate all requested entries' );
        end
    elseif isa( items, 'stationElement2' )
        items2 = items;
        items = [items2(:).hash];
    else
        error( 'Second argument has wrong type.' );
    end
        
    [ds.data, I] = sort( items );
    items2 = items2(I);
    ds.types = {items2(:).record_code};
    ds.frequencies = {items2(:).frequency};
    ds.sites = [items2(:).site];
    
    ds = class( ds, 'dataSet' );
else
    error( 'DataSet called with too many arguments' );
end    

ds.hash = computeHash( ds );