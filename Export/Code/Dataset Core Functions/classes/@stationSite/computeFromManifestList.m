function ss = computeFromManifestList( ss, list )

%global country_names_dictionary country_codes_dictionary

all_locations = [list(:).location];

latx = [all_locations(:).lat]';
longx = [all_locations(:).long]';
elevx = [all_locations(:).elev]';

endx = [list(:).end_date];
names = [list(:).name];
ids = [list(:).ids];
country = [list(:).country_code];
sources = [list(:).source_code];
state = [list(:).state];
county = [list(:).county];
flags = [];

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

current = ones(length(latx),1);

f = find( ~isnan(endx) );
if ~isempty(f)
    
    max_end = max( endx(f) );
    f1 = find( endx(f) ~= max_end );
    
    if ~isempty( f1 )
        current(f(f1)) = 0;
    end
end

lat = NaN;
long = NaN;
elev = NaN;

%%%% Special Correction for Bad Processing !!!!
%%%% Remove once the manifests are reprocessed.

f = (sources == 1 | sources == 2 | sources == 36);

latx(f) = fix(latx(f)) + sign(latx(f)).*mod(abs(latx(f)),1)*100/60;
longx(f) = fix(longx(f)) + sign(longx(f)).*mod(abs(longx(f)),1)*100/60;    
    
all_locations(f) = geoPoint( latx(f), longx(f), [all_locations(f).elev] );

%%%%
%%%%


f = find(~isnan(latx) & current);
if ~isempty(f)
    [lat, selected1] = determineBestPrecision(latx(f));
    [long, selected2] = determineBestPrecision(longx(f));
    
    selected = union(selected1, selected2);
    if length(selected) > 1
        max_dist = 0;
        for k = 1:length(selected)-1
            dist = max( distance( all_locations( f(selected(k)) ), all_locations( f(selected(k+1:end)) ) ) );
            if dist > max_dist
                max_dist = dist;
            end
        end
        if max_dist > 0.050
            flags(end+1) = siteFlags( 'LOCATION_CONFLICT' );            
        end
        if max_dist > 10
            flags(end+1) = siteFlags( 'LARGE_LOCATION_CONFLICT' );            
        end
        if max_dist > 100
            flags(end+1) = siteFlags( 'EXTREME_LOCATION_CONFLICT' );            
        end
    end                
end
f = find(~isnan(elevx) & current);
if ~isempty(f)
    elev = determineBestPrecision(elevx(f));
end

ss.location = geoPoint( lat, long, elev );

cc = unique( country(logical(current)) );
f = ( cc == 0 | isnan(cc) );
cc(f) = [];
if length(cc) == 1
    ss.country = cc;
elseif isempty(cc)
    ss.country = 0;
    flags(end+1) = siteFlags( 'MISSING_COUNTRY' );
else
    cc2 = unique( country(logical(current) & ~(sources' == 1) ));
    f = ( cc2 == 0 | isnan(cc2) );
    cc2(f) = [];
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

for k = 1:length(state)
    if ~ischar(state{k})
        state{k} = '';       
    end
end

cc = unique( state(logical(current)) );
f = strcmp(cc, '');
cc(f) = [];
if length(cc) == 1
    ss.state = cc{1};
elseif isempty(cc)
    ss.state = '';
else
    ss.state = cc;
    flags(end+1) = siteFlags( 'STATE_CONFLICT' );
end

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
    ss.county = '';
else
    ss.county = cc;
    flags(end+1) = siteFlags( 'COUNTY_CONFLICT' );
end

ss.sources = unique(sources);
if length( ss.sources ) > 1
    ss2 = ss.sources;
    
    % Can have both USSOD-C/FO and USSOD without a conflict.
    ss2( ss2 == 31 ) = [];
    if length(ss2) > 1
        flags(end+1) = siteFlags( 'MULTIPLE_SOURCES' );
    end
end

all_names = {};
current_names = [];
name_source = [];
for j = 1:length(names)
    for k = 1:length(names{j})
        all_names{end+1} = names{j}{k};
        if current(j)
            current_names(end+1) = 1;
        else
            current_names(end+1) = 0;
        end
        name_source(end+1) = sources(j);
    end
end

f = ( current_names == 1 );

% Exclude Hadley Centre Names from Primary due to 
% Widespread Name Corruption
sn = sum( name_source(f) == 35 );
if sn > 0 && sn < length(f)
    f = f & ( name_source ~= 35 );
end

current_names = unique(all_names(f));
maxl = 0;
for k = 1:length(current_names) 
    if length(current_names{k}) > maxl
        maxl = length(current_names{k});
        ss.primary_name = current_names{k};
    end
end

bad = zeros(1, length(all_names) );
for k = 1:length(all_names)
    if strcmp( all_names{k}, ss.primary_name )
        bad(k) = 1;
    end
end
all_names(logical(bad)) = [];

all_names = unique(all_names);
ss.alt_names = all_names;

all_ids = {};
for j = 1:length(ids)
    for k = 1:length(ids{j})
        all_ids{end+1} = ids{j}{k};
    end
end

ss.other_ids = unique(all_ids);
        
ss.all_locations = all_locations;
ss.all_location_times = [list(:).range];

uids = [list(:).uid];
if ~iscell( uids )
    uids = {uids};
end
ss.associated_uids = unique( vertcat(uids{:}) );


if ~isempty( ss.alt_names )
    flags(end+1) = siteFlags( 'MULTIPLE_NAMES' );
end

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
    possible_reloc = setdiff( possible_reloc, reloc_dates);
    if ~isempty(possible_reloc)
        flags(end+1) = siteFlags( 'POSSIBLE_RELOCATION' );
    end
end
ss.possible_relocated = possible_reloc;

ss.flags = flags;


function cc = countryEquivalents(cc)

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
    62, 96;
    9, 213;
    ];

for k = 1:length(equiv(:,1))
    if ismember( equiv(k,1), cc ) && ismember( equiv(k, 2), cc )
        f = ( cc == equiv(k, 2) );
        cc(f) = equiv(k,1);
    end
end
