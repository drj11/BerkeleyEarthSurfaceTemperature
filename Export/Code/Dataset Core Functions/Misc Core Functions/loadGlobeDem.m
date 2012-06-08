function [lat, long, dem] = loadGlobeDem()

temperatureStartup;

froot = [temperature_data_dir 'Geographical Data' psep 'GLOBE_dem'];

lat = (-90+180/21600/2:180/21600:90-180/21600/2)';
long = (-180+360/43200/2:360/43200:180-180/43200/2)';

dem = zeros( 43200, 21600, 'int16' );

ipos = [0, 4800, 10800, 16800];

for k = 1:16
    c = char('a' + (k-1));
    
    fname = [froot psep c '10g'];
    fin = fopen(fname,'r');
    
    i = floor( (k-1)/4 );
    j = mod( k-1, 4 );
    
    if k <= 4 || k >= 13
        A = fread( fin, [10800, 4800], '*int16' );
        dem( 10800*j+(1:10800), ipos(i+1) + (1:4800) ) = A;
    else
        A = fread( fin, [10800, 6000], '*int16' );
        dem( 10800*j+(1:10800), ipos(i+1) + (1:6000) ) = A;
    end
end
    
dem( dem == -500 ) = 0; 

dem = dem';
dem = dem(end:-1:1,:);