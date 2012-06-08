function exportResultsTables( results, name, description, min_year )

temperatureGlobals;

fname1 = [temperature_document_dir filesep 'Private Documents' filesep ...
    'Results Tables' filesep name '_summary.txt'];
fname2 = [temperature_document_dir filesep 'Private Documents' filesep ...
    'Results Tables' filesep name '_complete.txt'];
checkPath( fname1 );

fout1 = fopen( fname1, 'w' );
fout2 = fopen( fname2, 'w' );

if ischar( description )
    description = cellstr( description );
end

if isempty( description )
    description = {' '};
end

description = sprintf( '%%   %s\n', description{:} );
description(end) = '';

f =  results.times_monthly > 1950 & results.times_monthly < 1980 ;
normal = mean( results.values_monthly(f) );

head1 = {
    '% This file contains a brief summary of the land-surface average results ',
    '% produced by the Berkeley Averaging method.  Temperatures are in ',
    '% Celsius and reported as anomalies relative to the 1950-1980 average. ',
    '% Uncertainties represent the 95% confidence interval for statistical ',
    '% and spatial undersampling effects.',
    '% ',
    '% The current dataset presented here is described as: '
    '% ',
    description,
    '% ',
    '% ',
    ['% This analysis was run on ', results.execution_started],
    '% ',
    ['% Results are based on ', num2str( results.initial_time_series ), ...
    ' time series '],
    ['%   with ' num2str( results.data_points ) ' data points'],
    '% ', 
%    ['% Estimated 1950-1980 absolute temperature: ' sprintf( '%4.2f', normal ) ' +/- ' ...
%        sprintf( '%4.2f', results.statistical_uncertainty.global_average*1.96 )],
%    '% ',
%    '% ',
    '% ',
    '% Year, Annual Anomaly, Annual Unc., Five-year Anomaly, Five-year Unc.',
    ' '};
    
fprintf( fout1, '%s\n', head1{:} );

f = find( abs( mod( results.times_annual, 1 ) - 0.5) < 1/24 );
A = [round( results.times_annual(f) - 0.5 ), results.values_annual(f)-normal, results.uncertainty_annual(f)*1.96];
A(:, end+1:end+2) = NaN;
f = find( abs( mod( results.times_five_year, 1 ) - 0.5) < 1/24 );
A(3:end-2, 4:5) = [results.values_five_year(f)-normal, results.uncertainty_five_year(f)*1.96];

A( all( isnan(A(:,2:end)),2 ), : ) = [];
A( A(:,1) < min_year, : ) = [];

fprintf( fout1, '  %4i    %8.3f     %8.3f         %8.3f        %8.3f\n', A' );
fclose( fout1 );


head2 = {
    '% This file contains a detailed summary of the land-surface average ',
    '% results produced by the Berkeley Averaging method.  Temperatures are ',
    '% in Celsius and reported as anomalies relative to the 1950-1980 average. ',
    '% Uncertainties represent the 95% confidence interval for statistical ',
    '% and spatial undersampling effects.',    
    '% ',
    '% The current dataset presented here is described as: '
    '% ',
    description,
    '% ',
    '% ',
    ['% This analysis was run on ', results.execution_started],
    '% ',
    ['% Results are based on ', num2str( results.initial_time_series ), ...
    ' time series '],
    ['%   with ' num2str( results.data_points ) ' data points'],
    '% ', 
    ['% Estimated 1950-1980 absolute temperature: ' sprintf( '%4.2f', normal ) ' +/- ' ...
        sprintf( '%4.2f', results.statistical_uncertainty.global_average*1.96 )],
    '% ',
    '% ',
    '% For each month, we report the estimated land-surface average for that ',
    '% month and its uncertainty.  We also report the corresponding values for ',
    '% year, five-year, ten-year, and twenty-year moving averages CENTERED about ',
    '% that month (rounding down if the center is in between months).  For example, '
    '% the annual average from January to December 1950 is reported at June 1950. ',
    '% '
    '%                  Monthly          Annual          Five-year        Ten-year        Twenty-year'
    '% Year, Month,  Anomaly, Unc.,   Anomaly, Unc.,   Anomaly, Unc.,   Anomaly, Unc.,   Anomaly, Unc.',
    ' '};
    
fprintf( fout2, '%s\n', head2{:} );

A = [floor(results.times_monthly), floor( rem(results.times_monthly,1)*12 )+1, results.values_monthly-normal, results.uncertainty_monthly*1.96];
A(:, end+1:end+8) = NaN;
A(6:end-6, 5:6) = [results.values_annual-normal, results.uncertainty_annual*1.96];
A(30:end-30, 7:8) = [results.values_five_year-normal, results.uncertainty_five_year*1.96];
A(60:end-60, 9:10) = [results.values_ten_year-normal, results.uncertainty_ten_year*1.96];
A(120:end-120, 11:12) = [results.values_twenty_year-normal, results.uncertainty_twenty_year*1.96];

A( all( isnan(A(:,2:end)),2 ), : ) = [];
A( A(:,1) < min_year, : ) = [];

fprintf( fout2, '  %i    %2i    %6.3f %6.3f    %6.3f %6.3f    %6.3f %6.3f    %6.3f %6.3f    %6.3f %6.3f\n', A' );
fclose( fout2 );