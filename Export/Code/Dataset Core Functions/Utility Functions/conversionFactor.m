function v = conversionFactor( value, a, b )

persistent conversion_table
if isempty( conversion_table )
    conversion_table = loadConversionTable();
end

A = conversionTable( a );
B = conversionTable( b );

if ~strcmp( A.type, B.type )
    error( 'Conversion between non equivalent types' );
end

v = B.factor * value + B.offset;
v = ( v - A.offset ) / A.factor;


function conversion_table = loadConversionTable()

conversion_table = dictionary();

rst = {
    {'m', 'distance', 1},
    {'cm', 'distance', 0.01},
    {'mm', 'distance', 0.001},
    {'km', 'distance', 1000},
    {'ft', 'distance', 0.3048},
    {'yd', 'distance', 0.9144},
    {'mi', 'distance', 1609.344},

    {'s', 'time', 1},
    {'ms', 'time', 0.001},
    {'min', 'time', 60},
    {'hr', 'time', 3600},
    {'day', 'time', 86400},
    {'wk', 'time', 604800 },
    {'yr', 'time', 31556926},

    {'C', 'temperature', 1, 0},
    {'F', 'temperature', 9/5, 32},
    {'K', 'temperature', 1, 273.15},
    
    {'Pa', 'pressure', 1},
    {'atm', 'pressure', 101325},
    {'bar', 'pressure', 100000},
    {'torr', 'pressure', 133.322},
    {'mm Hg', 'pressure', 133.322},
    
    {'kg', 'mass', 1},
    {'g', 'mass', 1000},
    {'lb', 'mass' 0.45359237},
    
    {'m / s', 'velocity', 1},
    {'mph', 'velocity', 0.44704},
    {'kph', 'velocity', 0.277777778},
    {'km / day', 'velocity', 0.0115740741},
    {'ft / min', 'velocity', 0.00508},
    {'kt', 'velocity', 0.514444444},
   };

for k = 1:length(rst)
    A.type = rst{k}{2};
    A.factor = rst{k}{3};
    if length(rst{k}) > 3
        A.offset = rst{k}{4};
    else
        A.offset = 0;
    end
    
    conversion_table(rst{k}{1}) = A;
end