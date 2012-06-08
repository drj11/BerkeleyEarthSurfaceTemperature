function [se, sites, site_table, site_index] = ...
    loadTemperatureData( archive, class, version, kind )
% [stationElement, stationSite] ...
%    = loadTemperatureData( DataSet, Type, Version );
% [stationElement, stationSite, site_table, site_index] ...
%    = loadTemperatureData( DataSet, Type, Version );
% loadTemperatureData();
% 
% Basic function that loads temperature data

temperatureGlobals;

if nargin == 3 || (nargin == 1 && isa( archive, 'registeredDataSet' ))
    if nargin == 1
        rdd = archive;
    else
        try 
            rdd = registeredDataSet( archive, class, version );
        catch
            error( 'Unable to locate requested Dataset' );
        end
    end
    
    if nargout == 0
        error( 'No output assigned' );
    elseif nargout == 1
        se = getData( rdd );
    else
        [se, sites] = getData( rdd );
        
        site_list = [se(:).sites];
        hashes = md5hash( sites );
        hashes = num2str( hashes );
        hashes = cellstr( hashes );
        [hashes, I] = sort( hashes );
        sites = sites(I);
        
        target = zeros( length(se), 1 );
        for k = 1:length(site_list)
            p = quickSearch( site_list(k).hash, hashes );
            target(k) = p;
        end
                    
        if nargout == 2
            sites = sites( target );
        else
            site_table = target;
            
            if nargout == 4
                un = unique( target );
                cnt = zeros( length(un), 1 );
                site_index = target.*0;
                for k = 1:length(target)
                    cnt( target(k) ) = cnt( target(k) ) + 1;
                    site_index( k ) = cnt( target(k) );
                end
            end
        end
    end
    return;
end

if nargin == 0 
    DatasetSelector;
    return;
end

% Version 1 styls selectors;        
if nargout ~= 2 
    compact_mode = 1;
else
    compact_mode = 0;
end
    
if nargin == 1
    dd = dir( [temperature_data_dir 'Registered Data Sets' psep archive...
        psep 'Matlab' psep] );
    classes = {};
    for k = 1:length(dd)
        if ~strcmp( dd(k).name, '..' ) && ~strcmp( dd(k).name, '.' ) && ...
                ~strcmp( dd(k).name, '.svn' )
            if dd(k).isdir 
                classes{end+1} = dd(k).name;
            end
        end
    end
    
    display( ' ' );
    display( 'No class parameter was given.' )
    display( 'Possible Values Are: ' )
    display( ' ' );
    display( strvcat( classes ) );
    display( ' ' );
    return;
elseif nargin == 2
    dd = dir( [temperature_data_dir 'Registered Data Sets' psep archive...
        psep 'Matlab' psep class psep '*.mat'] );
    freqs = {};
    for k = 1:length(dd)
        f = find( dd(k).name == '_' );
        if isempty(f)
            continue;
        end
        f = f(end);
        
        freqs{end+1} = dd(k).name(1:f-1);
    end
    freqs = unique( freqs );
    
    display( ' ' );
    display( 'No frequency parameter was given.' )
    display( 'Possible Values Are: ' )
    display( ' ' );
    display( strvcat( freqs ) );
    display( ' ' );
    return;
elseif nargin == 3
    frequency = version;
    if ~ischar( frequency )
        frequency = stationFrequencyType( frequency );
    end
    
    dd = dir( [temperature_data_dir 'Registered Data Sets' psep archive...
        psep 'Matlab' psep class psep frequency '_*.mat'] );
    kinds = {};
    for k = 1:length(dd)
        f = find( dd(k).name == '_' );
        if isempty(f)
            continue;
        end
        f = f(end);
        
        kinds{end+1} = dd(k).name(f+1:end-4);
    end
    freqs = unique( kinds );
    
    display( ' ' );
    display( 'No type parameter was given.' )
    display( 'Possible Values Are: ' )
    display( ' ' );
    display( strvcat( kinds ) );
    display( ' ' );
    return;
end

frequency = version;
if ~ischar( frequency )
    frequency = stationFrequencyType( frequency );
end
if ~ischar( kind )
    kind = stationRecordType( kind );
    kind = kind.abbrev;
end

name = [temperature_data_dir 'Registered Data Sets' psep archive...
    psep 'Matlab' psep class psep frequency '_' kind '.mat'];
if ~exist( name, 'file' )
    error( 'File not found' );
end

load( name, 'se', 'site_table', 'site_index' );

if nargout == 1
    return;
end

[~,I] = sort( site_table );
site_table = site_table(I);
se = se(I);
site_index = site_index(I);

name2 = [temperature_data_dir 'Registered Data Sets' psep archive ...
    psep 'Matlab' psep 'StationSites.mat'];
if ~exist( name, 'file' )
    error( 'Station location file is missing.' );
end

load( name2, 'sites' );

if compact_mode
    return;
else
    ids = sites(:).id;
    [ids,I] = sort(ids);
    sites = sites(I);
    
    sites_new = stationSite;
    sites_new(1:length(se)) = sites_new(1);
    
    for k = 1:length(site_table)
        if isnan( site_table(k) )
            sites_new(k) = stationSite();
            continue;
        end
        fk = quickSearch( site_table(k), ids );       
        sites_new(k) = sites(fk);
    end
    
    sites = sites_new;
end
    