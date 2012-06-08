function ss = setLocation( ss, loc )
% Replace's the location information in the site.
%
% Use of this function is discouraged as it overwrite the orginal record.

ss.location = loc;
ss.hash = computeHash( ss );