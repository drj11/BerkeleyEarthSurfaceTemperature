function val = yearnum( ti )

if( ~isnan( ti.yearnum ) )
    val = ti.yearnum;
    return;
end

years = [ti.year];

dur = 365*ones(length(years), 1);
f = ( mod(years, 4) == 0 & (mod(years, 100) ~= 0 | mod(years, 400) == 0) );
dur(f) = 366;

dates = datenum( ti );

v = zeros(length(ti),6);
v(:,2:3) = 1;
v(:,1) = years;

dates2 = datenum(v);

years = years + (dates - dates2) ./ dur;

if length(years) > 1
    val = NaN;
else
    val = years;
end