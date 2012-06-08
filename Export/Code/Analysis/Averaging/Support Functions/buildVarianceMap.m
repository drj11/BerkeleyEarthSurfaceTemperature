function [variance_map, variance_months, variance_annual, ...
    variance_five_year, variance_ten_year, variance_twenty_year] = ...
    buildVarianceMap( map, coverage_map )
% variance_map = buildVarianceMap( map, coverage_map )
%
% Creates an estimated variance map from the temperature field and 
% coverage map.  This is used in the analytical estimates of spatial
% uncertainty.

temperatureGlobals;
session = sessionStart();

variance_map = [];
variance_months = [];
variance_annual = [];
variance_five_year = [];
variance_ten_year = [];
variance_twenty_year = [];

sessionSectionBegin( 'Build Variance Maps' );

frc = sessionFunctionCache;
hash = collapse( [ md5hash( map ), md5hash( coverage_map ), md5hash( nargout ) ] );

results = get( frc, hash );
if ~isempty( results )
    variance_map = results{1};    
    variance_months = results{2};
    variance_annual = results{3};    
    variance_five_year = results{4};
    variance_ten_year = results{5};
    variance_twenty_year = results{6};
    sessionWriteLog( 'Loaded from Cache' );
    sessionSectionEnd( 'Build Variance Maps' );
    return;
end


sz = size( map );
variance_map = zeros( sz(1), 1 );
variance_months = zeros( sz(1), 12 );

tm = 1:sz(2);

sessionSectionBegin( 'Build Monthly Variance Map' );

for k = 1:sz(1)
    if mod(k, 20) == 0
        timePlot2( 'Build Monthly Variance Map', k/sz(1) );
    end
    
    f = ( coverage_map(k,:) > 0.4 );
    if sum(f) >= 5*12
        variance_map(k) = sqrt(sum( (map(k,f)./coverage_map(k,f)).^2.*coverage_map(k,f), 2 ) ./ sum( coverage_map(k,f), 2 ));
    else
        variance_map(k) = NaN;
    end
    
    if nargout > 1
        for j = 1:12        
            f2 = f;
            f2( mod( tm, 12 )+1 ~= j ) = false;
            if sum(f2) >= 20
                variance_months(k,j) = sqrt(sum( (map(k,f2)./coverage_map(k,f2)).^2.*coverage_map(k,f2), 2 ) ./ sum( coverage_map(k,f2), 2 ));
            else
                variance_months(k,j) = NaN;
            end
        end
    end
end

sessionSectionEnd( 'Build Monthly Variance Map' );

variance_expanded = zeros( sz(1), 240 );
for m = 1:20
    variance_expanded(:, (m-1)*12 + (1:12) ) = variance_months;
end

timePlot2( 'Build Monthly Variance Map', 1 );

block_size = 1000;

if nargout > 2

    sessionSectionBegin( 'Build Temporal Correlation Table' );
    
    r = zeros( length(map), 12*20 );
    for block = 1:block_size:length(map)
        timePlot2( 'Build Temporal Correlation Table', block/length(map) );
        max_k = min( length(map), block + 99 );
        parfor k = block:max_k
            f = find( coverage_map(k,:) > 0.25 );
            V = map( k, f )./coverage_map(k,f);
            
            r_temp = r(k,:);
            for j = 1:12*20-1
                V1 = V(1:end-j);
                V2 = V(j+1:end);
                fx = find( f(j+1:end) - f(1:end-j) ~= j );

                V1(fx) = [];
                V2(fx) = [];
                if length(V1) > 10*12
                    r_temp(j+1) = correlate( V1, V2 );
                else
                    r_temp(j+1) = NaN;
                end
            end
            r(k, :) = r_temp;
        end
    end
    timePlot2( 'Build Temporal Correlation Table', 1 );
    r(:,1) = 1;

    sessionSectionEnd( 'Build Temporal Correlation Table' );
    sessionSectionBegin( 'Build Long-term Variance Maps' );

    lengths = [12, 60, 120, 240];

    for mm = 1:length(lengths)

        T = zeros( lengths(mm) );
        for k = 1:lengths(mm)
            T(k, k:end) = 1:lengths(mm)+1-k;
            T(k, k-1:-1:1 ) = 2:k;
        end

        variance2 = zeros( length(map), 1 );
        for k = 1:length(map)
            r_a = r(k, 1:lengths(mm));
            R = r_a(T);
            variance2(k) = 1/lengths(mm)*sqrt( ...
                variance_expanded(k,1:lengths(mm))*R*variance_expanded(k,1:lengths(mm))' );
        end
        
        switch mm
            case 1
                variance_annual = variance2;
            case 2
                variance_five_year = variance2;
            case 3
                variance_ten_year = variance2;
            case 4
                variance_twenty_year = variance2;
        end
                
    end
    
    sessionSectionEnd( 'Build Long-term Variance Maps' );
    
end

results = { variance_map, variance_months, variance_annual, ...
    variance_five_year, variance_ten_year, variance_twenty_year };

save( frc, hash, results );

sessionSectionEnd( 'Build Variance Maps' );

