function val = daysInMonth( ti );

years = [ti.year];
months = [ti.month];

val = zeros(length(ti),1);

norm = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
f = find( ~isnan(months) );
val(f) = norm(months(f));

f = find(months == 2 & mod(years, 4) == 0 & (mod(years, 100) ~= 0 | mod(years, 400) == 0));
if length(f) > 0
    val(f) = 29;
end
