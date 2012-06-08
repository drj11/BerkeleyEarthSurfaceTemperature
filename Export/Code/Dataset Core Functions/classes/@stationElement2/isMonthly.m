function res = isMonthly( se )
% Determine if station element is monthly frequency

persistent month_code
if isempty( month_code )
    month_code = stationFrequencyType( 'm' );
end

mm = [se(:).frequency];

res = (mm == month_code);
