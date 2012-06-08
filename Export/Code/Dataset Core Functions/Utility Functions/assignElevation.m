function elev = assignElevation( sites )

load simpleDem

elev = zeros( length( sites ), 1 );

for k = 1:length(sites)
    e = sites(k).elev;
    lt = sites(k).lat;
    lg = sites(k).long;
    
    fk2 = findk( sd_lat, lt );
    fk1 = findk( sd_long, lg );
    
    if isnan(e)
        elev(k) = sd_means( fk2, fk1 );
    elseif e > double( sd_maxs( fk2, fk1 ) ) + sd_devs( fk2, fk1 ) || ...
            e < double( sd_mins( fk2, fk1 ) ) - sd_devs( fk2, fk1 )
        elev(k) = sd_means( fk2, fk1 );
    else
        elev(k) = e;
    end
end


    