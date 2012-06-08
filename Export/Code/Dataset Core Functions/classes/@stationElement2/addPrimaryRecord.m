function se = addPrimaryRecord( se, hash )
% Appends a primary record hash to the stationElement record

if length(se) > 1
    error( 'Not Designed for Multiple Update' );
end

if isempty( se.primary_record_ids )
    se.primary_record_ids = hash;
else
    se.primary_record_ids(end+1) = hash;
    se.primary_record_ids = sort( se.primary_record_ids );
end

se.md5hash = md5hash;

