function se = setTOB( se, tob )
% Set the time of observation fields

se.time_of_observation = tob;
se.md5hash = md5hash;

se = compress( se );
