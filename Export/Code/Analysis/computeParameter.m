function [value, stat_unc, spat_unc, tot_unc] = computeParameter( function_handle, result_set, months )
% [value, stat_unc] = computeParameter( function_handle, result_set, months )
%
% Applies a function to the average temperature time series contained in
% "result_set" (generated by Berkeley Average) and reports its value.  If
% the result set was computed with ComputeUncertainty = true, then this
% function will also report the 1-sigma statistical uncertainty for the
% associated parameter.
%
% "function_handle" is the name of a Matlab function to be applied.  It
% must have the form "value = function_handle( times, data )".  The times
% can be assumed to be uniformly spaced.  Missing values are indicated by
% setting data = NaN at the corresponding time.
%
% "months" specifies the smoothing that should be applied to the times
% series before making computations.  For example, "months = 12" implies a
% 12-month moving average should be applied prior to computations.
%
% Note: The uncertainty returned by this function representes the
% statistical uncertainty in the corresponding parameter only over the
% region of the Earth that was sampled.  It DOES NOT include any
% uncertainty that might be related to fluctuations in the temperature
% field that may have occured in parts of the world where no records are
% available.

if nargin < 3
    months = 1;
end
    
[time_pts, values] = simpleMovingAverage( result_set.times_monthly, result_set.values_monthly, months );

value = function_handle( time_pts, values );

if nargout > 1
    try
        gr = result_set.statistical_uncertainty.groups;
        outer = length(gr);
        sz = size(gr{1});
        inner = sz(2);

        v_array = zeros( inner, outer );
        for k = 1:outer
            for j = 1:inner
                [~, values] = simpleMovingAverage( result_set.times_monthly, gr{k}(:,j), months );

                if all( isnan( values ) )
                    v_array(j,k) = NaN;
                else
                    v_array(j, k) = function_handle( time_pts, values );
                end
            end
        end
        
        bad_values = false;
        v_outer = zeros( outer, 1 );
        for k = 1:outer
            f = ~isnan( v_array(:, k ) );
            if ~all(f)
                bad_values = true;
            end
            v_outer(k) = std(v_array(f,k)) / sqrt(sum(f));
        end
        stat_unc = mean( v_outer );

        if bad_values
            warning( 'Uncertainty is underdetermined.  Function returned NaN for one or more test series.' );
        end
    catch
        warning( 'No statistical uncertainty available' );
        stat_unc = NaN;        
    end    
end

if nargout > 2
    try
        gr = result_set.spatial_uncertainty.unc_monthly;
        f = ~isnan( result_set.values_annual );
        f = find( f(1:end-1) & f(2:end) );
        autocorr = correlate( result_set.values_monthly(f), ...
            result_set.values_monthly(f+1) );
        
        len_t = length( result_set.times_monthly );
        reset(RandStream.getDefaultStream);
        
        samples = 1000;
        R = randn( len_t, samples );
        
        R = bsxfun( @times, R, gr );
        R( isnan(R) ) = 0;
        
        phi = (-1 + sqrt(1+4*autocorr^2))/(2*autocorr);
        R2 = R.*0;
        R2(1,:) = R(1,:)/sqrt(1/(1-phi^2));
        for k = 2:length(gr)
            R2(k,:) = R2(k-1,:)*phi + R(k,:)/sqrt(1/(1-phi^2));
        end        
        
        values = zeros( samples, 1 );
        for k = 1:samples
            [time_pts, data] = simpleMovingAverage( result_set.times_monthly, ...
                result_set.values_monthly + R2( :, k ), months );
            
            values(k) = function_handle( time_pts, data );
        end
        
        spat_unc = std( values );    
    catch
        error( 'No Spatial Error Available' );
        spat_unc = NaN;
    end
end

if nargout > 3
    tot_unc = sqrt( stat_unc.^2 + spat_unc.^2 );
end