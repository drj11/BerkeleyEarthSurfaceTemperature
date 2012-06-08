function display( pt )
% Standard Display Function

if length(pt) == 1
    
    A.latitude = pt.latitude;
    A.longitude = pt.longitude;
    A.elevation = pt.elevation;
    A.latitude_uncertainty = pt.lat_uncertainty;
    A.longitude_uncertainty = pt.long_uncertainty;
    A.elevation_uncertainty = pt.elev_uncertainty;

    disp('  ');
    disp(A);
    
else 
    disp(' ');
    disp(['   ' num2str(length(pt)) ' geoPoints']);
    disp(' ');
end