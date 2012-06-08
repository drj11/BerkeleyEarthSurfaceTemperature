function varargout = unitConversion( value, a, b, reload )

persistent conversion_table conversion_list
if isempty( conversion_table ) || (nargin > 3 && reload == 1)
    [conversion_table, conversion_list] = loadConversionTable();
end

if nargin == 1
    val = conversion_table( value );
    varargout{1} = val.index;
    return;
end

if ischar( a )
    persistent last_a_key last_a_value    
    if strcmp( a, last_a_key )
        A = last_a_value;
    else
        A = conversion_table( a );
        last_a_key = a;
        last_a_value = A;
    end
else
    A = conversion_list( a );
end
if ischar( b )
    persistent last_b_key last_b_value
    if strcmp( b, last_b_key )
        B = last_b_value;
    else
        B = conversion_table( b );
        last_b_key = b;
        last_b_value = B;
    end
else
    B = conversion_list( b );
end

if ~strcmp( A.type, B.type )
    error( ['Conversion between non equivalent types: ' num2str(a) ', ' num2str(b)] );
end

v = A.factor * ( value + A.offset );
v = v / B.factor - B.offset; 


if nargout > 1
    v = num2cell(v);
    varargout = v;
else
    varargout{1} = v;
end



function [conversion_table, conversion_list] = loadConversionTable()

conversion_table = dictionary();

rst = {
    {'m', 'distance', 1},
    {'cm', 'distance', 0.01},
    {'mm', 'distance', 0.001},
    {'km', 'distance', 1000},
    {'ft', 'distance', 0.3048},
    {'yd', 'distance', 0.9144},
    {'mi', 'distance', 1609.344},
    {'in', 'distance', 0.0254},

    {'s', 'time', 1},
    {'ms', 'time', 0.001},
    {'min', 'time', 60},
    {'hr', 'time', 3600},
    {'day', 'time', 86400},
    {'wk', 'time', 604800 },
    {'yr', 'time', 31556926},

    {'C', 'temperature', 1, 0},
    {'F', 'temperature', 5/9, -32},
    {'K', 'temperature', 1, -273.15},
    
    {'Pa', 'pressure', 1},
    {'atm', 'pressure', 101325},
    {'bar', 'pressure', 100000},
    {'torr', 'pressure', 133.322},
    {'mm Hg', 'pressure', 133.322},
    {'in Hg', 'pressure', 0.190516194},
    
    {'kg', 'mass', 1},
    {'g', 'mass', 1000},
    {'lb', 'mass' 0.45359237},
    
    {'m / s', 'velocity', 1},
    {'mph', 'velocity', 0.44704},
    {'kph', 'velocity', 0.277777778},
    {'km / day', 'velocity', 0.0115740741},
    {'ft / min', 'velocity', 0.00508},
    {'kt', 'velocity', 0.514444444},
    
    {'degrees', 'direction', 1},
    
    {'%', 'percent', 1},
    {'fraction', 'percent', 0.01},

    {'unknown', 'unknown', 1},    

    {'Weather Codes', 'NA', 1},             %non-dimenstional
    
    {'ussod_C', 'temperature', 1, 0},       %Celcius
    {'ussod_CM', 'length', 0.01},           %cm
    {'ussod_D', 'temperature', 5/9},        %F degree days
    {'ussod_DT', 'direction', 10},          %tens of degrees
    {'ussod_DW', 'direction', 1},           %degrees
    {'ussod_F', 'temperature', 5/9, -32},   %Fahrenheit
    {'ussod_FN', 'distance', 0.03048},      %Tenths of feet
    {'ussod_FT', 'distance', 0.3048},       %Feet
    {'ussod_HF', 'distance', 30.48},        %Hundreds of feet
    {'ussod_HI', 'distance', 0.000254},     %Hundredths of inches
    {'ussod_HM', 'distance', 16.09344},     %Hundredths of miles
    {'ussod_HT', 'distance', 0.000254},     %Hundredths of inches (measured to tenths)
    {'ussod_I',  'distance', 0.0254},       %inches
    {'ussod_IH', 'pressure', 0.00190516194},    %Hundredths of in Hg
    {'ussod_IT', 'pressure', 0.000190516194},   %Thousandths of in Hg
    {'ussod_M',  'distance', 1609.344},     %miles
    {'ussod_ME', 'distance', 1},            %meters
    {'ussod_MH', 'velocity', 0.44704},      %mph
    {'ussod_MM', 'distance', 0.001},        %mm
    {'ussod_MN', 'time', 60},               %minute
    {'ussod_MT', 'pressure', 10000},        %tenths of millibars
    {'ussod_NA', 'NA', 1},                  %non-dimenstional
    {'ussod_N1', 'NA', 0.1},                %Tenths non-dimenstional
    {'ussod_N2', 'NA', 0.01},               %Hundredths non-dimenstional
    {'ussod_OS', 'percent', 1/8*0.01},      %Oktas
    {'ussod_P',  'percent', 1},             %Percent
    {'ussod_TC', 'temperature', 0.1, 0},    %Tenths of degree C
    {'ussod_TD', 'temperature', 0.1},       %Tenths fo Fahrenheit degree days
    {'ussod_TF', 'temperature', 5/90, -320},  %Tenths of Fahrenheit
    {'ussod_TH', 'time', 360},              %Tenths of hours
    {'ussod_TI', 'distance', 0.00254},      %Tenths of inches
    {'ussod_TK', 'velocity', 0.0514444444}, %Tenths of knots
    {'ussod_TL', 'velocity', 0.044704},     %Tenths of mph
    {'ussod_TM', 'distance', 0.0001},       %Tenths of mm
    {'ussod_TP', 'percent',  0.1},          %Tenths of percent
    {'ussod_TS', 'percent',  10},           %Tenths of sky cover

    {'ussod_DG', 'direction',  1},          %Degrees ???
    {'ussod_TN', 'unknown',  1},          %Degrees ???

    {'GHCND_PRCP', 'distance',  0.0001},          %Tenths of mm
    {'GHCND_SNOW', 'distance',  0.001},          %mm
    {'GHCND_SNWD', 'distance',  0.001},          %mm
    {'GHCND_TMAX', 'temperature',  0.1},          %Tenths of C
    {'GHCND_TMIN', 'temperature',  0.1},          %Tenths of C
    {'GHCND_EVAP', 'temperature',  0.1},          %Tenths of C
    {'GHCND_MNPN', 'temperature',  0.1},          %Tenths of C
    {'GHCND_MXPN', 'temperature',  0.1},          %Tenths of C
    {'GHCND_SN', 'temperature',  0.1},          %Tenths of C
    {'GHCND_TOBS', 'temperature',  0.1},          %Tenths of C
    {'GHCND_WDMV', 'distance',  1000},          %km
    {'GHCND_WT', 'NA',  1},                     %Weather Codes
    {'GHCND_WTEQ', 'NA',  0.0001},              %tenths of mm

    {'GSOD_AWND', 'velocity',  0.514444444},     %Knots
    {'GSOD_DPTP', 'temperature', 5/9, -32},      %F
    {'GSOD_F2MN-S', 'velocity', 0.514444444},    %Knots  (check this)
    {'GSOD_FLAGS', 'NA', 1},                     %Weather Codes
    {'GSOD_FSIN-S', 'velocity', 0.514444444},    %Knots  (check this)
    {'GSOD_PRCP', 'distance',  0.0254},          %inch
    {'GSOD_PRES', 'pressure', 100},              %millibar
    {'GSOD_SLVP', 'pressure', 100},              %millibar
    {'GSOD_SNWD', 'distance',  0.0254},          %inch
    {'GSOD_TAVG', 'temperature', 5/9, -32},      %F
    {'GSOD_TMAX', 'temperature', 5/9, -32},      %F
    {'GSOD_TMIN', 'temperature', 5/9, -32},      %F
    {'GSOD_VISI', 'distance', 1000},             %km
    
    {'ussom_C', 'temperature', 1, 0},       %Celcius
    {'ussom_D', 'temperature', 5/9},        %F degree days
    {'ussom_F', 'temperature', 5/9, -32},   %Fahrenheit
    {'ussom_HI', 'distance', 0.000254},     %Hundredths of inches
    {'ussom_I',  'distance', 0.0254},       %inches
    {'ussom_M',  'distance', 1609.344},     %miles
    {'ussom_MH', 'velocity', 0.44704},      %mph
    {'ussom_MM', 'distance', 0.001},        %mm
    {'ussom_NA', 'NA', 1},                  %non-dimenstional
    {'ussom_TC', 'temperature', 0.1, 0},    %Tenths of degree C
    {'ussom_TF', 'temperature', 5/90, -320},%Tenths of Degrees Fahrenheit
    {'ussom_TI', 'distance', 0.00254},      %Tenths of inches
    {'ussom_TM', 'distance', 0.0001},       %Tenths of mm
    };

for k = 1:length(rst)
    A.type = rst{k}{2};
    A.factor = rst{k}{3};
    if length(rst{k}) > 3
        A.offset = rst{k}{4};
    else
        A.offset = 0;
    end
    A.index = k;
    
    conversion_table(rst{k}{1}) = A;
    if k == 1
        conversion_list = A;
    else
        conversion_list(k) = A;
    end
end