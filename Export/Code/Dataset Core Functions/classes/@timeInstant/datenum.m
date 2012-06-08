function val = datenum( ti );

v = zeros(length(ti), 6);

v(:,1:3) = 1;

years = [ti.year];
f = find(~isnan(years));
v(f,1) = years(f);

months = [ti.month];
f = find(~isnan(months));
v(f,2) = months(f);

days = [ti.day];
f = find(~isnan(days));
v(f,3) = days(f);

hours = [ti.hour];
f = find(~isnan(hours));
v(f,4) = hours(f);

mins = [ti.minute];
f = find(~isnan(mins));
v(f,5) = mins(f);

seconds = [ti.second];
f = find(~isnan(seconds));
v(f,6) = seconds(f);

val = datenum(v);