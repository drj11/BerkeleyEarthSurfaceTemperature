function [lat, long, means, maxs, mins, devs] = sampleGlobeDem( width )

[lat1, long1, dem] = loadGlobeDem;

sz = size( dem );

lat = zeros( length(lat1)/width, 1 );
long = zeros( length(long1)/width, 1 );

means = zeros( sz / width, 'single' );
maxs = zeros( sz / width, 'int16' ) - 10000;
mins = maxs + 30000;
devs = means;

for k = 1:width
    lat = lat + lat1(k:width:end);
    long = long + long1(k:width:end);
end
lat = lat / width;
long = long / width;

for k = 1:width
    for j = 1:width
        A = dem(k:width:end, j:width:end);
        means = means + single(A);
        f = (A > maxs);
        maxs(f) = A(f);
        f = (A < mins);
        mins(f) = A(f);
    end
end

if nargout > 3
    means = means / width^2;
    for k = 1:width
        for j = 1:width
            A = single( dem(k:width:end, j:width:end) );
            devs = devs + (A - means).^2;
        end
    end
    
    devs = sqrt( devs / (width^2 - 1) );
end