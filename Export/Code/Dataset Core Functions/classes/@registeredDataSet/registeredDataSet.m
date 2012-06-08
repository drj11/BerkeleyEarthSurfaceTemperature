function dp = registeredDataSet( varargin )

temperatureGlobals;

dp.path = '';
dp.size = 0;
dp.date = now;
dp.collection = '';
dp.type = '';
dp.version = '';

if nargin == 0    
    ds = dataSet();
    dp = class( dp, 'registeredDataSet', ds );
elseif nargin == 1
    if isa(varargin{1}, 'registeredDataSet' )
        dp = varargin{1};
    else
        error( 'RegisteredDataSet constructor called with arguments of wrong type' );
    end
elseif nargin == 3 || nargin == 2 
    collection = varargin{1};
    type = varargin{2};
    if nargin == 2
        version = 'LATEST';
    else
        version = varargin{3};
    end
    
    pth = findDataPath( collection, type, version );
    pth = [temperature_data_dir psep 'Registered Data Sets' psep pth];
    try
        A = load( [pth 'dataset.mat'], 'dataset' );
        dp = A.dataset;    
        
        dlist = dir( pth );
        sz = dlist(1).bytes;
        dp.size = sz;        
    catch 
        error( 'Requested dataset has not been downloaded to this computer.' );
    end
elseif nargin == 4 || nargin == 5
    collection = varargin{1};
    type = varargin{2};
    version = varargin{3};
    
    dp.collection = collection;
    dp.type = type;
    dp.version = version;
    
    if ~collectionExists( collection )
        error( 'Dataset Collection does not exist' );
    end
    
    ds = varargin{4};
    if ~isa( ds, 'dataSet' )
        error( 'Fourth argument must be a dataSet' );
    end
            
    dp.path = registeredDataPath( collection, type, version );
    
    pth = [temperature_data_dir psep 'Registered Data Sets' psep dp.path];
    checkPath( pth );
    
    if nargin == 5
        data = varargin{5};
        if ~isa( data, 'stationElement2' )
            error( 'Fifth argument must be data' );
        end
        
        hash1 = collapse( unique( md5hash( data ) ) );
        hash2 = collapse( unique( [ds(:).data] ) );
        if hash1 ~= hash2
            error( 'Provided data does not match dataset' );
        end
    else
        tb = typedHashTable( 'stationElement2' );
        data = load( tb, [ds(:).data] );
    end
    
    tb2 = typedHashTable( 'stationSite2' );
    sites = load( tb2, unique([ds(:).sites]) );
    tb3 = typedHashTable( 'stationManifest2' );
    
    PP = [sites(:).primary_manifests];
    bad = ( cellfun( @length, PP ) == 0 );
    PP(bad) = [];
    PP = [PP{:}];
    
    SS = [sites(:).secondary_manifests];
    bad = ( cellfun( @length, SS ) == 0 );
    SS(bad) = [];
    SS = [SS{:}];
    
    A = unique([PP SS]);
    if ~isempty(A)
        manifests = load( tb3, A );        
    else
        manifests = stationManifest2;
    end
    
    dp = class( dp, 'registeredDataSet', ds );
    dataset = dp;
    
    pth2 = [pth 'dataset.mat'];   
    checkPath( pth2 );
    save( pth2, 'dataset' );
    
    pth2 = [pth 'sites.mat'];   
    save( pth2, 'sites' );

    pth2 = [pth 'manifests.mat'];   
    save( pth2, 'manifests' );

    cnt = 1;
    for j = 1:5000:length(data)
        pth2 = [pth 'data_' num2str(cnt) '.mat'];   
        dat = data(j:min(j+4999, length(data)));
        save( pth2, 'dat' );
        cnt = cnt + 1;
    end
    while exist( [pth 'data_' num2str(cnt) '.mat'], 'file' )
        delete( [pth 'data_' num2str(cnt) '.mat'] );
        cnt = cnt + 1;
    end
    
    dlist = dir( pth );
    sz = 0;
    for j = 1:length(dlist)
        sz = sz + dlist(j).bytes;
    end
    dp.size = sz;
       
    addRegisteredDataset( collection, type, version, dp );
    convertToText( dp );
else
    error( 'registeredDataSet called with too many arguments' );
end    
