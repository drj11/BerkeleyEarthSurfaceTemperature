function se = plus( a, b )

if a.frequency ~= b.frequency
    error( 'Frequency mismatch' );
elseif a.record_type ~= b.record_type
    error( 'Type mismatch' );
end

l1 = length(a.dates);
l2 = length(b.dates);

a.dates(l1+1:l1+l2) = b.dates;
a.data(l1+1:l1+l2) = b.data;
a.time_of_observation(l1+1:l1+l2) = b.time_of_observation;
a.num_measurements(l1+1:l1+l2) = b.num_measurements;

ls = length(b.source(1,:));
lf = length(b.flags(1,:));

a.flags(l1+1:l1+l2,1:lf) = b.flags;
a.source(l1+1:l1+l2,1:ls) = b.source;

se = a;
se = clean( se );