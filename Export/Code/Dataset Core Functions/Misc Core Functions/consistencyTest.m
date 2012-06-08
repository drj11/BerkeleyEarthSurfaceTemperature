function [val, len] = consistencyTest( data1, data2 )
% Simple (i.e. quick) test of data record consisency during intervals of
% overlap.

date1 = data1.datenum;
date2 = data2.datenum;

[dates, I1, I2] = intersect( date1, date2 );

if isempty( dates )
    val = 1;
    len = 0;
    return;
end

dat1 = data1.data;
dat2 = data2.data;
unc1 = data1.uncertainty;
unc2 = data2.uncertainty;

dat1 = dat1(I1);
dat2 = dat2(I2);
unc1 = unc1(I1);
unc2 = unc2(I2);

upper1 = [dat1 + unc1, dat2 + unc2];
lower1 = [dat1 - unc1, dat2 - unc2];

upper1 = min(upper1, [], 2);
lower1 = max(lower1, [], 2);

f = (upper1 >= lower1);
val = sum(f) / length(dates);
len = length(dates);

    