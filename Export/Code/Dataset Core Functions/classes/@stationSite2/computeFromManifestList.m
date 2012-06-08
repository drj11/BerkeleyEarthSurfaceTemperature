function ss = computeFromManifestList( ss, list, list2 )
% Generate a stationSite based on one or two lists of stationManifests

flags = [];

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    [country_codes_dictionary] = loadCountryCodes();
end

% Compute a site based on the secondary information, if given.
% The fields generated in this way will be overwritten by data in the
% primary list if there are any conflicts.
if nargin > 2
    ss = computeFromManifestList( ss, list2 );
    ss.secondary_manifests = ss.primary_manifests;
    ss.archive_keys = {};
    supplement_flags = ss.flags;
    
    flags = siteFlags('SUPPLEMENTAL_RECORDS');
end

edited = siteFlags('EDITED_RECORD');
corrections = zeros( length(list), 1 );
bad = zeros( length(list), 1 );
for k = 1:length(list)
    if ismember( edited, list(k).flags )
        corrections(k) = 1;
    end
end
for k = 1:length(list)
    if corrections(k) == 1
        for j = 1:length(list)
            if ~corrections(j)
                if strcmp( mn(k).key, mn(j).key )
                    bad(j) = 1;
                end
            end
        end
    end
end

ss.primary_manifests = md5hash;
for k = 1:length( list )
    ss.primary_manifests(k) = md5hash( list(k) );
end

% Exclude manifests that were corrected
list( logical(bad) ) = [];

% Location data
all_locations = [list(:).location];
good_locations = ~isnan( all_locations ) & ...
    ~isnan( [all_locations(:).latitude_uncertainty] );

% End date for record (preference is given to more recent data)
endx = [list(:).end_date];

% Names and IDs
names = [list(:).name];
ids = [list(:).ids];
country = [list(:).country_code];
sources = [list(:).source_code];
state = [list(:).state];
county = [list(:).county];

if ~iscell( state )
    state = {state};
end
if ~iscell( county )
    county = {county};
end
if ~iscell( names )
    names = {{names}};
end
if length(list) == 1
    names = {names};
end

% Determine which records don't reflect present day information.
current = ones(length(endx),1);
f = find( ~isnan(endx) ); % No date set, assume present day.
if ~isempty(f)
    max_end = max( endx(f) );
    f1 = find( endx(f) ~= max_end );
    
    if ~isempty( f1 )
        current(f(f1)) = 0;
    end
end

% Deltermine best location
f = find( good_locations & current' );
best_location =  merge( all_locations(f) );

import_location = 0;
if ~isnan( best_location )
    ss.location = best_location;

    % Add flags regarding location conflicts
    if ~checkConsistency( all_locations(f) )
        flags(end+1) = siteFlags( 'LOCATION_CONFLICT' );
        scale = max( uncertaintyScale( ss.location ) );
        if scale > 15
            flags(end+1) = siteFlags( 'LARGE_LOCATION_CONFLICT' );
        end
        if scale > 100
            flags(end+1) = siteFlags( 'EXTREME_LOCATION_CONFLICT' );            
        end
    end

    f = (good_locations | ~isnan( [all_locations(:).elev] ));
    ss.all_locations = all_locations(f);
    ss.all_location_times = [list(f).range];
elseif isnan( ss.location ) 
    flags(end+1)  = siteFlags( 'MISSING_LOCATION' );
else
    % Location derived from supplment, import appropriate flags
    conflict_flag = siteFlags( 'LOCATION_CONFLICT' );
    large_conflict_flag = siteFlags( 'LARGE_LOCATION_CONFLICT' );
    extreme_conflict_flag = siteFlags( 'EXTREME_LOCATION_CONFLICT' );

    if ismember( conflict_flag, supplement_flags )
        flags(end+1) = conflict_flag;
    end
    if ismember( large_conflict_flag, supplement_flags )
        flags(end+1) = large_conflict_flag;
    end
    if ismember( extreme_conflict_flag, supplement_flags )
        flags(end+1) = extreme_conflict_flag;
    end
    
    import_location = 1;
end

% Consider all present-day country designators
cc = unique( country(logical(current)) );

% Exclude missing values 
f = ( cc == 0 | isnan(cc) );
cc(f) = [];

if length(cc) == 1
    ss.country = cc;
elseif isempty(cc)
    if isnan(ss.country)
        ss.country = 0;
        flags(end+1) = siteFlags( 'MISSING_COUNTRY' );
    else
        % Country derived from supplment, import appropriate flags
        remap_flag = siteFlags( 'COUNTRY_REMAP' );
        conflict_flag = siteFlags( 'COUNTRY_CONFLICT' );

        if ismember( conflict_flag, supplement_flags )
            flags(end+1) = conflict_flag;
        end
        if ismember( remap_flag, supplement_flags )
            flags(end+1) = remap_flag;
        end
    end
else
    % United States is assigned by presumption to many of the datasets
    % originating in the US, but it isn't necessarily correct.  If there is
    % a conflict we assume that the location outside of the United States
    % is more likely to be correct.
    ccUS = country_codes_dictionary( 'UNITED STATES' );
    cc2 = cc;
    cc2( cc2 == ccUS ) = [];

    l1 = length( cc2 );
    cc2 = unique( countryEquivalents( cc2 ) );
    l2 = length( cc2 );
    
    if l1 ~= l2
        flags(end+1) = siteFlags( 'COUNTRY_REMAP' );
    end
    
    ss.country = cc2;
    if length( cc2 ) > 1
        flags(end+1) = siteFlags( 'COUNTRY_CONFLICT' );
    end
end

% Normalize state info
for k = 1:length(state)
    if ~ischar(state{k})
        state{k} = '';       
    end
end

% All state
cc = unique( state(logical(current)) );
f = strcmp(cc, '');
cc(f) = [];
if length(cc) == 1
    ss.state = cc{1};
elseif isempty(cc)
    if ~isempty( ss.state ) 
        % Import from supplements
        conflict_flag = siteFlags( 'STATE_CONFLICT' );

        if ismember( conflict_flag, supplement_flags )
            flags(end+1) = conflict_flag;
        end
    end        
else
    ss.state = cc;
    flags(end+1) = siteFlags( 'STATE_CONFLICT' );
end

% Normalize County Info
for k = 1:length(county)
    if isnan(county{k})
        county{k} = '';
    end
end

cc = unique( county(logical(current)) );
f = strcmp(cc, '');
cc(f) = [];
f = ( isnumeric(cc) );
cc(f) = [];

if length(cc) == 1
    ss.county = cc{1};
elseif isempty(cc)
    if ~isempty( ss.county ) 
        % Import from supplemental
        conflict_flag = siteFlags( 'COUNTY_CONFLICT' );

        if ismember( conflict_flag, supplement_flags )
            flags(end+1) = conflict_flag;
        end
    end        
else
    ss.county = cc;
    flags(end+1) = siteFlags( 'COUNTY_CONFLICT' );
end

ss.sources = unique(sources);
if length( ss.sources ) > 1
    flags(end+1) = siteFlags( 'MULTIPLE_SOURCES' );
end

% Organize Possible Names
all_names = {};
current_names = [];
for j = 1:length(names)
    for k = 1:length(names{j})
        all_names{end+1} = names{j}{k};
        if current(j)
            current_names(end+1) = 1;
        else
            current_names(end+1) = 0;
        end
    end
end

% Primary name is assigned as the longest of the current names
f = ( current_names == 1 );
current_names = unique(all_names(f));
maxl = 0;
for k = 1:length(current_names) 
    if length(current_names{k}) > maxl
        maxl = length(current_names{k});
        ss.primary_name = current_names{k};
    end
end

% Remove names that are the same as the primary name or is blank
bad = zeros(1, length(all_names) );
for k = 1:length(all_names)
    if strcmp( all_names{k}, ss.primary_name ) || isempty( all_names{k} )
        bad(k) = 1;
    end
end
all_names(logical(bad)) = [];

all_names = unique(all_names);
ss.alt_names = all_names;

% Group IDs
all_ids = {};
for j = 1:length(ids)
    if ~iscell( ids{j} )
        ids{j} = cellstr( ids{j} );
    end
    for k = 1:length(ids{j})
        all_ids{end+1} = ids{j}{k};
    end
end

ss.ids = unique(all_ids);
        
if ~isempty( ss.alt_names )
    flags(end+1) = siteFlags( 'MULTIPLE_NAMES' );
end

% If location was imported from supplments, then use supplemental info on
% relocations and possible relocations, else derive that info here.
if ~import_location
    reloc_dates = [];
    if length(list) > 1
        reloc = [list(:).relocation];
        
        for k = 1:length(reloc)
            if ischar(reloc{k})
                if ~strcmp(reloc{k},'')
                    reloc_dates(end+1) = list(k).first;
                end
            end
        end
    end
    
    if ~isempty(reloc_dates)
        flags(end+1) = siteFlags( 'RELOCATED' );
    end
    ss.relocated = reloc_dates;
    
    
    possible_reloc = [];
    
    % For each source, find times at which the location changed
    for k = 1:length( ss.sources )
        f = find( sources == ss.sources(k) );
        if length(f) > 1
            firsts = [list(f).first];
            
            [firsts, I] = sort( firsts );
            f = f(I);
            
            for j = 1:length( f )-1
                if distance( all_locations(f(j)), all_locations(f(j+1)) ) > 0.001
                    if ~isnan(firsts( j + 1 ))
                        possible_reloc(end+1) = firsts(j+1);
                    end
                end
            end
        end
    end
    if ~isempty(possible_reloc)
        possible_reloc = setdiff( possible_reloc, reloc_dates );
        if ~isempty(possible_reloc)
            flags(end+1) = siteFlags( 'POSSIBLE_RELOCATION' );
        end
    end
    ss.possible_relocated = possible_reloc;
end

flag_list = [list(:).flags];
if iscell(flag_list)
    flag_list = unique([flag_list{:}]);
end

ss.flags = unique([flags, flag_list]);

% Store archive keys
ks = cell( length(list), 1 );
for k = 1:length(list);
    ks{k} = list(k).archive_key;
end

ss.archive_keys = unique( ks );


function cc = countryEquivalents(cc)
% Maps country codes onto their equivalents to deal with different and
% historical country designations between various source material.

equiv = [184, 250;
    211, 91;
    211, 92;
    60, 16;
    272, 264;
    47, 232;
    207, 264;
    240, 192;
    138, 91;
    9, 56;
    245, 57;
    71, 255;
    65, 16;
    163, 259;
    196, 259;
    136, 190;
    136, 259;
    273, 259;
    9, 228;
    68, 279;
    225, 279;
    53, 232;
    256, 91;
    12, 92;
    100, 92;
    138, 92
    9, 11;
    220, 279;
    9, 263;
    34, 279;
    55, 38;
    145, 91;
    246, 91;
    157, 206;
    9, 93;
    9, 16;
    400, 264;
    400, 46;
    170, 211;
    169, 259;
    169, 264;
    199, 57;
    19, 206;
    88, 50;
    221, 209;
    275, 128;
    266, 91;
    189, 16;
    253, 209;
    9, 229;
    96, 5;
    155, 279;
    26, 92;
    14, 263;
    213, 263;
    62, 209;
    9, 213;
    62, 96;
    ];

for k = 1:length(equiv(:,1))
    if ismember( equiv(k,1), cc ) && ismember( equiv(k, 2), cc )
        f = ( cc == equiv(k, 2) );
        cc(f) = equiv(k,1);
    end
end
