function res = stationCountryCode( s ) 
% Translate country code

persistent country_names_dictionary

if isempty( country_names_dictionary )
    [~, country_names_dictionary] = loadCountryCodes;
end

if nargin == 0
    ks = keys( country_names_dictionary );
    vs = values( country_names_dictionary );
    
    resp = {};
    rv = [];
    for j = 1:length(ks)
        kv = str2num( ks{j} );
        if ~isempty( kv )
            rv(end+1) = kv;
            resp{end+1} = [ks{j} ': ' vs{j}];
        end    
    end
    [~,I] = sort( rv );
    resp = resp(I);
    
    for j = 1:length(resp)
        display( resp{j} );
    end
    
    return;
end

if ischar( s )
    res = country_names_dictionary( s );
else
    res = country_names_dictionary( s ); 
end