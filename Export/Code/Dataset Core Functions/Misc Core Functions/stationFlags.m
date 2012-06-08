function v = stationFlags( s, reload )

if nargin == 2
    v = dataFlags( s, reload );
elseif nargin == 1
    v = dataFlags( s );
elseif nargin == 0
    dataFlags;
end