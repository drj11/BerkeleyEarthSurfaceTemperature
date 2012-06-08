function result = formatTimeDifference( s )
% string = formatTimeDifference( seconds )
% 
% Returns a formatted string expressing the difference in time in days,
% hours, minutes, and seconds from a raw difference in seconds.

s = abs(s);

d = floor( s / (60*60*24) );
s = s - d*60*60*24;
h = floor( s / (60*60) );
s = s - h*60*60;
m = floor( s / 60 );
s = s - m*60;

result = '';
if d > 0
    result = [num2str(d) ' days, '];
end
if d > 0 || h > 0
    result = [result num2str(h) ' hours, '];
end
if d > 0 || h > 0 || m > 0
    result = [result num2str(m) ' minutes, '];
end
result = [result num2str(s) ' seconds.'];
