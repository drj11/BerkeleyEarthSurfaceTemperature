function se = clean( se )

[s, I] = sort( se.dates );

se.data = double( se.data );
se.time_of_observation = double( se.time_of_observation );
se.num_measurements = double( se.num_measurements );
se.source = double( se.source );
se.flags = double( se.flags );

se.dates = s;
se.data = se.data(I);
se.time_of_observation = se.time_of_observation(I);
se.num_measurements = se.num_measurements(I);
se.source = se.source(I,:);
se.flags = se.flags(I,:);

if se.auto_compress
    se = compress( se );
end