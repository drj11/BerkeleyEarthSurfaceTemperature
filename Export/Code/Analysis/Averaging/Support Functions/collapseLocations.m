function [locations, indices] = collapseLocations( locations, max_move )

% In order to improve computational performance, we treat station sites
% that are closely located in space as if they occur at the same location
% for the purpose of computing the initial Kriging coeffients.  This
% functions performs the "collapse" that replaces closely colocated
% stations location information with an effective value in-between.  The
% station time series remain separate and independent, and only the
% positions used for Kriging coefficient purposes are adjusted.

temperatureGlobals;
session = sessionStart;

if nargin < 2
    max_move = 50;
end

frc = sessionFunctionCache();

sessionSectionBegin( 'Performing Location Collapse' );
sessionSectionBegin( 'Build Hash Table' );

hashes = md5hash;
hashes( length(locations) ) = md5hash;
parfor k = 1:length( locations )
    hashes(k) = md5hash( locations(k) );
end

sessionSectionEnd( 'Build Hash Table' );

result = get( frc, {collapse( hashes ), max_move} );
if ~isempty( result )
    locations = result{1};
    indices = result{2};
    sessionSectionEnd( 'Performing Location Collapse' );
    return;
end

sessionWriteLog( [num2str( length(locations) ) ' locations and max move '...
    num2str(max_move) ' km'] );

sessionSectionBegin( 'Build Distance Table' );

mask = false( length(locations) );
len_D = length(locations);

X = single([locations(:).x]);
Y = single([locations(:).y]);
Z = single([locations(:).z]);

parfor k = 1:length(X)
    template = false( 1, len_D );
    template( k+1:end ) = (((X(k)-X(k+1:end)).^2 + ...
        (Y(k)-Y(k+1:end)).^2 + ...
        (Z(k)-Z(k+1:end)).^2 ).^(1/2) < max_move*2 );
    mask(k, :) = template;
end
clear X Y Z

mask = mask | mask';
mask( diagonalIndices( length(mask) ) ) = true;
sessionSectionEnd( 'Build Distance Table' );
sessionSectionBegin( 'Build Target List' );

multiple = sum(mask, 2);
bad = false( len_D, 1 );
kill = bad;

indices = 1:length(locations);

index_list = cell( len_D, 1 );
for k = 1:len_D
    index_list{k} = k;
end

% Repeatedly loop of location list removing closely associated groups
% until all locations are seperated by at least the min separation
% distance.
[next, fk] = max(multiple);
targets = locations;
while next > 1
    I = mask(fk,:) & ~bad';
    
    f = find(I);
    target = center( targets(I) );
    dd = distance( target, targets(I) );
    sel = ( dd < max_move );
    I(f(~sel)) = false;
    if sum(sel) <= 1
        if sum(sel) == 0
            I(fk) = true;
        end
        demult = sum(mask(:,I),2);
        mask(:,I) = false;    
        multiple = multiple - demult;
        multiple(I) = 0;
        [next, fk] = max(multiple);
        continue;
    elseif sum(sel) == 2 && length(f) > 2
        target = center( targets(I) );
    end        
    
    bad(I) = true;
    
    f = find(I);
    kill(f(2:end)) = true;
    
    targets(f(1)) = target;

    demult = sum(mask(:,I),2);
    mask(:,I) = false;    
    multiple = multiple - demult;
    multiple(I) = 0;
    [next, fk] = max(multiple);
end

targets(kill) = [];
index_list(kill) = [];
sessionWriteLog( [num2str( length(targets) ) ' target locations'] );
sessionSectionEnd( 'Build Target List' );

sessionSectionBegin( 'Generate Reference Table' );

targets(end+1) = geoPoint2();

X = single([locations(:).x]);
Y = single([locations(:).y]);
Z = single([locations(:).z]);

tX = single([targets(:).x]);
tY = single([targets(:).y]);
tZ = single([targets(:).z]);

% Now that we have a list of effective station locations to use, assign
% each actual location to its nearest effective location.

parfor k = 1:length(X)
    template = ((X(k)-tX).^2 + ...
        (Y(k)-tY).^2 + ...
        (Z(k)-tZ).^2 ).^(1/2);
    [mn, fk] = min(template);
    if ~isnan(mn)
        indices(k) = fk;
    else
        indices(k) = length(targets);
    end    
end
clear X Y Z tX tY tZ

un = unique(indices);
bad = setdiff( 1:length(targets), un );
for k = length(bad):-1:1
    indices( indices >= bad(k) ) = indices( indices >= bad(k) ) - 1;
end
targets( bad ) = [];
locations = targets;

sessionWriteLog( [num2str( length(locations) ) ' total locations used'] );
sessionSectionEnd( 'Generate Reference Table' );

save( frc, {collapse( hashes ), max_move}, {locations, indices} );

sessionSectionEnd( 'Performing Location Collapse' );
