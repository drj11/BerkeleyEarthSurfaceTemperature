function pt = geoPoint2( varargin )
% point = geoPoint( latitude, longitude [, elevation] );
%
% latitude and longitude are given in decimal degrees.
% elevation is given in meters and is optional.
%
% By convention 90 N is +90 latitude, and 90 S is -90 latitude.
% Further the prime meridian is 0 longitude, and values are
% negative in the Western Hemisphere and positive in the 
% Eastern Hemisphere.

pt = struct( 'latitude', NaN, ...
    'longitude', NaN, ...
    'elevation', NaN, ...
    'lat_uncertainty', NaN, ...
    'long_uncertainty', NaN, ...
    'elev_uncertainty', NaN, ...
    'x', NaN, ...
    'y', NaN, ...
    'z', NaN );

if nargin == 0
    pt = class( pt, 'geoPoint2' );
elseif nargin == 1
    if isa(varargin{1}, 'geoPoint2')
        pt = varargin{1};
    elseif isa( varargin{1}, 'geoPoint' )
        v = varargin{1};
        pt = geoPoint2( v.lat, v.long, v.elev );
    else
        error( 'Geopoint called with argument of wrong type' );
    end
elseif nargin >= 2 && nargin < 6
    pt.latitude = varargin{1};
    pt.longitude = varargin{2};
    
    if abs(pt.latitude) > 90
        error( 'Latitude should be between +/- 90' );
    end
    
    pt.longitude = mod(pt.longitude + 180, 360) - 180;

    pt.lat_uncertainty = NaN;
    pt.long_uncertainty = NaN;
    pt.elev_uncertainty = NaN;    
    
    if nargin > 2
        pt.elevation = varargin{3};
    else
        pt.elevation = NaN.*varargin{1};
    end

    pt.x = NaN;
    pt.y = NaN;
    pt.z = NaN;

    if length(pt.latitude) > 1
        for k = length(pt.latitude):-1:1
            pt(k).latitude = pt(1).latitude(k);
            pt(k).longitude = pt(1).longitude(k);
            pt(k).elevation = pt(1).elevation(k);
            pt(k).x = NaN;
            pt(k).y = NaN;
            pt(k).z = NaN;
            pt(k).lat_uncertainty = NaN;
            pt(k).long_uncertainty = NaN;
            pt(k).elev_uncertainty = NaN;    
        end
    end
    pt = class( pt, 'geoPoint2' );
    pt = computeXYZ( pt );    

elseif nargin == 6
    
    pt.latitude = varargin{1};
    pt.longitude = varargin{2};
    
    if abs(pt.latitude) > 90
        error( 'Latitude should be between +/- 90' );
    end
    
    pt.longitude = mod(pt.longitude + 180, 360) - 180;

    pt.elevation = varargin{3};    
    pt.lat_uncertainty = abs( varargin{4} );
    pt.long_uncertainty = abs( varargin{5} );
    pt.elev_uncertainty = abs( varargin{6} );    

    pt.x = NaN;
    pt.y = NaN;
    pt.z = NaN;

    if length(pt.latitude) > 1
        for k = length(pt.latitude):-1:1
            pt(k).latitude = pt(1).latitude(k);
            pt(k).longitude = pt(1).longitude(k);
            pt(k).elevation = pt(1).elevation(k);
            pt(k).x = NaN;
            pt(k).y = NaN;
            pt(k).z = NaN;
            pt(k).lat_uncertainty = pt(1).lat_uncertainty(k);
            pt(k).long_uncertainty = pt(1).long_uncertainty(k);
            pt(k).elev_uncertainty = pt(1).elev_uncertainty(k);    
        end
    end
    
    pt = class( pt, 'geoPoint2' );
    pt = computeXYZ( pt );    
   
end

