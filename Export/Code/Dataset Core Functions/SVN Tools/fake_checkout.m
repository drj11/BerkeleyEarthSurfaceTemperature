function fake_checkout( source, dest )
% Simulate the effect of SVN checkout if no

temperatureGlobals;

checkPath( dest );
disp( ['Populating: ' dest(length(temperature_root_dir)+1:end) ] );

A = urlread_basicAuth( ['http://' source] );

items = regexp( cellstr(A), '<li><a[^>]*>([^<]*)</a></li>', 'tokens');

dirs = {};
for k = 1:length(items)
    for j = 1:length(items{k})
        if strcmp( items{k}{j}, '..' )
            continue;
        end
        name = items{k}{j}{1};
        if name(end) == '/'
            dirs{end+1} = name;
        else
            urlread_basicAuth( ['http://' source name], [dest name] );
        end
    end
end
for k = 1:length(dirs)
    fake_checkout( [source dirs{k}], [dest dirs{k}(1:end-1) psep] );
end