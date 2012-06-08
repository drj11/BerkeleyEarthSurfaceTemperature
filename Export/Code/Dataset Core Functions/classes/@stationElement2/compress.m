function se = compress( se )
% Compress stationElement into a compact memory representation.

persistent minMemSize;
if isempty(minMemSize)
    zm = zipMatrix;
    minMemSize = memSize(zm);
end

if ~isa( se.dates, 'zipMatrix' )
    if ~isa( se.dates, 'uint32' )
        se.dates = uint32( se.dates );
    end
    if minMemSize < 4*length(se.dates)        
        dt = zipMatrix( se.dates );
        if memSize( dt ) < 4*length(se.dates)
            se.dates = dt;
        end
    end
end

if ~isa( se.time_of_observation, 'zipMatrix' )
    if ~isa( se.time_of_observation, 'uint8' )
        f = isnan( se.time_of_observation );
        se.time_of_observation(f) = 255;
        se.time_of_observation = uint8( se.time_of_observation );
    end
    if minMemSize < length( se.time_of_observation )        
        tob = zipMatrix( se.time_of_observation );
        if memSize( tob ) < length( se.time_of_observation )
            se.time_of_observation = tob;
        end
    end
end

if ~isa( se.data, 'zipMatrix' )
    if ~isa( se.data, 'single' )
        se.data = single( se.data );
    end
    if minMemSize < 4*length(se.data)        
        rd = zipMatrix( se.data );
        if memSize( rd ) < 4*length(se.data)
            se.data = rd;
        end
    end
end

if ~isa( se.uncertainty, 'zipMatrix' )
    if ~isa( se.uncertainty, 'single' )
        se.uncertainty = single( se.uncertainty );
    end
    if minMemSize < 4*length(se.uncertainty)        
        rd = zipMatrix( se.uncertainty );
        if memSize( rd ) < 4*length(se.uncertainty)
            se.uncertainty = rd;
        end
    end
end

if ~isa( se.num_measurements, 'zipMatrix' )
    if ~isa( se.num_measurements, 'uint16' )
        f = isnan( se.num_measurements );
        se.num_measurements(f) = 65535;
        se.num_measurements = uint16( se.num_measurements );
    end
    if minMemSize < 2*length( se.num_measurements )        
        nm = zipMatrix( se.num_measurements );
        if memSize( nm ) < 2*length( se.num_measurements )
            se.num_measurements = nm;
        end
    end
end

if ~isa( se.source, 'zipMatrix' )
    if ~isa( se.source, 'uint8' )
        f = isnan( se.source );
        se.source(f) = 0;
        se.source = uint8( se.source );
    end
    if minMemSize < length(se.source)        
        nm = zipMatrix( se.source );
        if memSize( nm ) < length(se.source)
            se.source = nm;
        end
    end
end

if ~isa( se.flags, 'zipMatrix' )
    if ~isa( se.flags, 'uint16' )
        f = isnan( se.flags );
        se.flags(f) = 0;
        se.flags = uint16( se.flags );
    end
    if minMemSize < 2*length(se.flags)        
        nm = zipMatrix( se.flags );
        if memSize( nm ) < 2*length(se.flags)
            se.flags = nm;
        end
    end
end

if ~isa( se.record_flags, 'zipMatrix' )
    if ~isa( se.record_flags, 'uint16' )
        f = isnan( se.record_flags );
        se.record_flags(f) = 0;
        se.record_flags = uint16( se.record_flags );
    end
    if minMemSize < 2*length(se.record_flags)        
        nm = zipMatrix( se.record_flags );
        if memSize( nm ) < 2*length(se.record_flags)
            se.record_flags = nm;
        end
    end
end

se = reallyComputeHash( se );
