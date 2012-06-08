function display( pt )

if length(pt) == 1
    
    A.latitude = pt.latitude;
    A.longitude = pt.longitude;
    A.elevation = pt.elevation;

    disp('  ');
    disp(A);
    
else 
    disp(' ');
    disp(['   ' num2str(length(pt)) ' geoPoints']);
    disp(' ');
end