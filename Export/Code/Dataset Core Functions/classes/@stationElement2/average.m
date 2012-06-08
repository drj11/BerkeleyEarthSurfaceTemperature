function sx = average( se, bf )
% stationElement = average( stationElement_array, bad_flags )
%
% Takes an array of stationElements and returns a record that is an
% average.  This works for both collections of records of a single type and
% "mergers" such as TAVG = (TMAX + TMIN) / 2.

% If sent a single record, simply return it.
if length(se) == 1
    sx = se;
    return;
end

% Default, no flags.
if nargin < 2
    bf = [];
end

output_site = se(1).site;

% Check for same frequency type
for k = 2:length(se)
    if ~se(k).frequency == se(1).frequency
        error('Unable to Average - Differing frequency');
    end
    if se(k).site ~= se(1).site
        output_site = md5hash;
    end
end

% Determine data type
[output_type, average_type, allow_missing] = determineOutputType( se );

% Currrently multi-valued records are handled by collapsing them to single
% valued record.  This is probably not ideal, but it simplifies the logic
% considerably.
for k = 1:length(se)
    se(k) = makeSingleValued( se(k), bf );
end

st = structureMerge( se );
if allow_missing
    [st, counts] = mergeCore( st, bf, 'average_similar', length(se) );
else    
    if average_type == 2
        [st, counts] = mergeCore( st, bf, 'average_dissimilar', 2 );    
    elseif average_type == 3
        [st, counts] = mergeCore( st, bf, 'average_dissimilar', 3 );    
    end
end

st.site = output_site;
st.record_type = output_type;

if isempty( st.data )
    sx = stationElement2;
    return;
end

freq_type = upper( stationFrequencyType( st.frequency ) );

% Add Flags
f = ( counts > 1 );
if any( f )
    % Kind of data flag
    switch average_type
        case 1
            st.flags(f, end+1) = dataFlags( [freq_type '_AVERAGE_VALUE'] );
        case 2
            st.flags(f, end+1) = dataFlags( [freq_type '_AVERAGE_MAX_MIN'] );
        case 3
            st.flags(f, end+1) = dataFlags( [freq_type '_AVERAGE_TRIPLE'] );
    end
end   


% Clean up flags and source
st.flags = cleanFlags( st.flags );
st.source = cleanFlags( st.source );

% Replace very fine differences with nearest thousandths.  This is useful
% in support of the compression algorithms.
dd = abs(diff( st.data ));
f = ( dd > 1e-7 );
if min(dd(f)) < 0.001
    st.data = round( st.data * 1000 ) / 1000;
    st.uncertainty = round( st.uncertainty * 10000 ) / 10000;
end

sx = class( st, 'stationElement2' );

if sx.auto_compress
    sx = compress( sx );
else
    sx.md5hash = md5hash;
end



function [output_type, average_type, allow_missing] = determineOutputType( se )
% Looks at the array and determines the right kind of averaging to perform.

allow_missing = 1;
average_type = 1;

for k = 1:length(se)
    se(k) = makeEquivalent( se(k) );
end
input_types = [se.record_type];

% All records of same type
if max(input_types) == min(input_types)
    output_type = input_types(1);
elseif length(input_types) == 2
    % MIN / MAX averaging
    tmax = stationRecordType( 'TMAX' );
    tmin = stationRecordType( 'TMIN' );
    tavg = stationRecordType( 'TAVG' );
    
    f1 = ( input_types == tmax.index );
    f2 = ( input_types == tmin.index );
    if sum(f1) && sum(f2)
        output_type = tavg.index;
        allow_missing = 0;
        average_type = 2;
    else        
        error( 'Incompatible Record Types' );
    end
elseif length(input_types) == 3
    % Triple Observed Average
    ot7 = stationRecordType( 'OT07' );
    ot14 = stationRecordType( 'OT14' );
    ot21 = stationRecordType( 'OT21' );
    
    f1 = ( input_types == ot7.index );
    f2 = ( input_types == ot14.index );
    f3 = ( input_types == ot21.index );
    if sum(f1) && sum(f2) && sum(f3)
        v1 = stationRecordType( 'TAVG' );
        output_type = v1.index;
        average_type = 3;
        allow_missing = 0;
    else        
        error( 'Incompatible Record Types' );
    end
else  
    error( 'Incompatible Record Types' );
end
