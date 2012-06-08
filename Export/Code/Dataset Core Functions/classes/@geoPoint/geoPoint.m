function pt = geoPoint( varargin )
% point = geoPoint( latitude, longitude [, elevation] );
%
% latitude and longitude are given in decimal degrees.
% elevation is given in meters and is optional.
%
% By convention 90 N is +90 latitude, and 90 S is -90 latitude.
% Further the prime meridian is 0 longitude, and values are
% negative in the Western Hemisphere and positive in the 
% Eastern Hemisphere.

if nargin == 0
    pt.latitude = NaN;
    pt.longitude = NaN;
    pt.elevation = NaN;
    
    pt.x = NaN;
    pt.y = NaN;
    pt.z = NaN;
    
    pt = class( pt, 'geoPoint' );
elseif nargin == 1
    if isa(varargin{1}, 'geoPoint')
        pt = varargin{1};
    else
        error( 'Geopoint called with argument of wrong type' );
    end
elseif nargin >= 2
    pt.latitude = varargin{1};
    pt.longitude = varargin{2};
    
    if abs(pt.latitude) > 90
        error( 'Latitude should be between +/- 90' );
    end
    
    pt.longitude = mod(pt.longitude + 180, 360) - 180;
    
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
        end
    end
    
    pt = class( pt, 'geoPoint' );
    pt = computeXYZ( pt );    
   
end
