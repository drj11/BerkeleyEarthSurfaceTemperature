function se = select( se0, I )
% Returns a station element with only indices I included

se = se0;

se.data = se.data(I);
se.dates = se.dates(I);
se.time_of_observation = se.time_of_observation(I);
se.num_measurements = se.num_measurements(I);
se.flags = se.flags(I,:);
se.source = se.source(I,:);

se.md5hash = md5hash;