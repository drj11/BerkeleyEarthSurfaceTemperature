function stat_uncertainty = ...
    computeStatisticalUncertainty( se, sites, options, prior_results )

% Compute statistical uncertainty by either the sampling or bootstrappign
% technique.

temperatureGlobals;
session = sessionStart;

if nargin < 3
    options = BerkeleyAverageOptions;
end
if nargin < 4 && ~options.UseJackKnife
    error( 'Need prior results as fourth parameter' );
end

inner_loops = options.StatisticalUncertaintyInnerLoops;
outer_loops = options.StatisticalUncertaintyOuterLoops;
min_repeats = options.StatisticalUncertaintyMinRepeats;
min_align_date = options.StatisticalUncertaintyBenchmarkMinDate;
max_align_date = options.StatisticalUncertaintyBenchmarkMaxDate;

sessionSectionBegin( 'Compute Statistical Uncertainty' );
sessionWriteLog( ['Records: ' num2str( length(se) )] );
sessionWriteLog( ['Outer Loops: ' num2str( outer_loops )] );
sessionWriteLog( ['Inner Loops: ' num2str( inner_loops )] );
sessionWriteLog( ['Min Repeats: ' num2str( min_repeats )] );
sessionWriteLog( ['Min Align: ' num2str( min_align_date )] );
sessionWriteLog( ['Max Align: ' num2str( max_align_date )] );

frc = sessionFunctionCache;

parfor k = 1:length(se)
    % Precompute for missing hashes
    se(k) = compress( se(k) );
end

hash = collapse( [collapse( md5hash( se ) ), collapse( md5hash( sites ) ), ...
    md5hash( options ) ] );
result = get( frc, hash );

if ~isempty( result )
    stat_uncertainty = result;
    sessionSectionEnd( 'Compute Statistical Uncertainty' );
    return;
end

reset(RandStream.getDefaultStream);

types = {'monthly', 'annual', 'five_year', 'ten_year', 'twenty_year'};

o_times_sub = cell( outer_loops, length(types) );
o_values_sub = o_times_sub;

groups = cell( outer_loops, 2 );

% Compute all now (random number generator may get upset later)
RT = zeros( length(se), outer_loops );
for k = 1:outer_loops
    % Load individually so we will get the same random numbers in the k-th
    % row regardless of the number of outer loops.
    RT(:,k) = ceil( rand(length(se), 1)*inner_loops );
end
baseline_unc = zeros( outer_loops, 1 );

if nargin >= 4
    options.UseSeed = true; 
    options.SeedMonthlyTimes = prior_results.times_monthly;
    options.SeedMonthlyValues = prior_results.values_monthly;
end

for outer_loop = 1:outer_loops
    R = RT(:, outer_loop);
    
    sessionSectionBegin( ['Starting Outer Loop ' num2str( outer_loop )] );
    
    subset = cell( inner_loops, 1 ) ;
    for inner_loop = 1:inner_loops
        if options.UseJackKnife
            f = find( R ~= inner_loop );
        else
            f = find( R == inner_loop );
        end            
        
        sessionSectionBegin( ['Starting Inner Loop ' num2str( outer_loop ) '.' num2str( inner_loop )] );

        % Compute the temperature average for our new sample
        results = BerkeleyAverageCore( se(f), sites(f), options );
        
        % Save sampling results
        if options.SaveResults
            target = options.OutputDirectory;
            if options.OutputPrefix
                pref = options.OutputPrefix;
                pref( pref == ' ' ) = '_';
                target = [target psep pref '.'];
            else
                target = [target psep 'results.'];
            end
            
            calling_records = length(se(f));
            if options.UseJackKnife
                target = [target 'jk_stat' num2str(outer_loop) '_' num2str(inner_loop) '.'];
            else
                target = [target 'stat' num2str(outer_loop) '_' num2str(inner_loop) '.'];
            end            
            target = [target num2str(calling_records) 's.' datestr(now, 30) '.mat'];
            
            checkPath( target );
            save( target, 'results' );
        end
        
        % Remove fields we don't current need to conserve memory.
        results = rmfield( results, 'location_pts' );
        results = rmfield( results, 'occurence_table' );
        results = rmfield( results, 'map_pts' );
        results = rmfield( results, 'convergence' );
        results = rmfield( results, 'geographic_anomaly' );
        results = rmfield( results, 'local_anomaly' );
        results = rmfield( results, 'baselines' );
        results = rmfield( results, 'coverage_map' );
        results.map = zipMatrix( results.map );
        subset{inner_loop} = results;
        clear results;
        
        sessionSectionEnd( ['Starting Inner Loop ' num2str( outer_loop ) '.' num2str( inner_loop )] );
    end        
    
    for m = 1:length(types)
        time_field = ['times_' types{m}];
        value_field = ['values_' types{m}];
        
        times2 = subset{1}.(time_field);
        for k = 2:inner_loops        
            times2 = union( times2, subset{k}.(time_field) );
        end

        if options.UseJackKnife
            [~, I] = intersect( prior_results.(time_field), times2 );
            orig_values = prior_results.(value_field)(I);            
        end
        
        res = zeros( length(times2), inner_loops ).*NaN;
        for k = 1:inner_loops
            if options.UseJackKnife
                [~, I, I2] = intersect( subset{k}.(time_field), times2 );
                res( I2, k ) = inner_loops*orig_values(I2) - ...
                    (inner_loops-1)*subset{k}.(value_field)(I);
            else
                [~, I, I2] = intersect( subset{k}.(time_field), times2 );
                res( I2, k ) = subset{k}.(value_field)(I);
            end
        end    
        [res, shifts] = alignGroup( times2, res, options );
        if m == 1
            baseline_unc(outer_loop) = std(shifts) / sqrt(inner_loops);
        end
        
        % Code to cut out instabilities that can occur if too few records
        % are present and portion of the problem is underdetermined.
        nm = median( res( ~isnan(res) ) );
        f = ( res > nm + 20 | res < nm - 20 );
        res(f) = NaN;
        
        s_res = zeros( length(times2), 1 );
        for k = 1:length(times2)
            f = ( ~isnan( res(k,:) ) );
            if sum(f) >= options.StatisticalUncertaintyMinRepeats
                s_res(k) = std( res(k,f) ) / sqrt( sum(f) );
            else
                s_res(k) = NaN;
            end
        end            
        
        if m == 1
            groups{outer_loop, 1} = times2;
            groups{outer_loop, 2} = res;
        end
        
        f = ( isnan( s_res ) );
        times2(f) = [];
        s_res(f) = [];

        o_times_sub{outer_loop, m} = times2;
        o_values_sub{outer_loop, m} = s_res;
    end
                
    sessionSectionEnd( ['Starting Outer Loop ' num2str( outer_loop )] );

end

% Put each set of values on the same time scale as original solution
stat_uncertainty = struct;
for m = 1:length(types)
    times = o_times_sub{1,m};
    for k = 1:outer_loops
        times = intersect( times, o_times_sub{k,m} );
    end

    res = zeros( length(times), outer_loops ).*NaN;
    for k = 1:outer_loops
        [~, I, I2] = intersect( o_times_sub{k,m}, times );
        res( I2, k ) = o_values_sub{k,m}(I);
    end
    res = mean(res, 2);

    time_field = ['times_' types{m}];
    unc_field = ['unc_' types{m}];
    
    stat_uncertainty.(time_field) = times;
    stat_uncertainty.(unc_field) = res;
end

% Uncertainty in global average
stat_uncertainty.global_average = mean(baseline_unc);

% Build comparison groups after removing effect of global average
% uncertainty.
for m = 1:outer_loops
    times = groups{m,1};
    
    f = ( times > options.StatisticalUncertaintyBenchmarkMinDate & ...
        times < options.StatisticalUncertaintyBenchmarkMaxDate );

    count = 0;
    mns = 0;
    for k = 1:length(groups{m,2}(1,:))
        f2 = f & ~isnan( groups{m,2}(:,k) );
        if any( f2 )
            mn = mean( groups{m,2}(f2,k) );
            if abs(mn) < 50  % remove instabilities
                mns = mns + mn;
                count = count + 1;
            end
        end
    end
    bs = mns / count;  
    
    groups{m,2} = groups{m,2} - bs;
end

stat_uncertainty.groups = groups;

save( frc, hash, stat_uncertainty );

sessionSectionEnd( 'Compute Statistical Uncertainty' );
        
        
function [new_group, shifts] = alignGroup( times, group, options )
% Align a group of time series to share the same mean over a reference 
% interval.

f = ( times > options.StatisticalUncertaintyBenchmarkMinDate & ...
    times < options.StatisticalUncertaintyBenchmarkMaxDate );

count = 0;
mns = 0;
for k = 1:length(group(1,:))
    f2 = f & ~isnan( group(:,k) );
    if any( f2 )
        mn = mean( group(f2,k) );
        if abs(mn) < 50  % remove instabilities
            mns = mns + mn;
            count = count + 1;
        end
    end
end
bs = mns / count;

shifts = zeros( length(group(1,:)), 1 );
for k = 1:length(group(1,:))
    shifts(k) = bs - mean(group(f,k));
    group(:,k) = group(:,k) + shifts(k);
end
    
new_group = group;

        