function num = MDCEavailable( lmstat )

if nargin < 1
    lmstat = '"/global/software/centos-5.x86_64/modules/matlab/matlab-R2009b/etc/lmstat"';
end

cur = cd();  % lmstat errors if called from some directories.
cd( '/' );
[~, output] = system( [lmstat ' -f Matlab_Distrib_Comp_Engine'] );
cd( cur ); % Restore current directory

pat = 'Total of (?<total>[0-9]*) licenses issued;  Total of (?<used>[0-9]*) licenses? in use';

res = regexp( output, pat, 'names' );

num = str2double( res.total ) - str2double( res.used );
