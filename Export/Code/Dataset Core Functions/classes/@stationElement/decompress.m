function se = decompress( se )

se.flags = expand( se.flags );
se.data = expand (se.data );
se.dates = expand( se.dates );
se.time_of_observation = expand( se.time_of_observation );
se.num_measurements = expand( se.num_measurements );
se.source = expand( se.source );