function se = decompress( se )
% Decompresses all fields in memory.  Can make for faster access at the
% expense of larger storage requierments.

se.flags = expand( se.flags );
se.data = expand( se.data );
se.uncertainty = expand( se.uncertainty );
se.dates = expand( se.dates );
se.time_of_observation = expand( se.time_of_observation );
se.num_measurements = expand( se.num_measurements );
se.source = expand( se.source );