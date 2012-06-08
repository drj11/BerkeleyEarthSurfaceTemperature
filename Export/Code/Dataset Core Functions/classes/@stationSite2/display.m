function display( ss )

if length(ss) > 1
    disp( [' ' num2str(length(ss)) ' StationSites'] );
    return;
end

persistent country_names_dictionary
if isempty( country_names_dictionary )
    [~, country_names_dictionary] = loadCountryCodes;
end

stationSite = struct();
stationSite.name = ss.primary_name;
if ~isempty(ss.alt_names)
    stationSite.alt_names = ss.alt_names;
end

if length(ss.country) > 1
    stationSite.country = 'Conflict';
else
    if ~isnan( ss.country )
        stationSite.country = country_names_dictionary( ss.country );
    else
        stationSite.country = NaN;
    end
end

if ~isempty(ss.state)
    stationSite.state = ss.state;
end
if ~isempty(ss.county)
    stationSite.county = ss.county;
end
stationSite.hash = num2str( ss.hash );
stationSite.ids = ss.ids;
stationSite.lat = ss.location.lat;
stationSite.long = ss.location.long;
stationSite.elev = ss.location.elev;
stationSite.sources = ss.sources;

disp(stationSite);

