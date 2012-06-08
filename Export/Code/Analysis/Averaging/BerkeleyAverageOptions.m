function options = BerkeleyAverageOptions( varargin )
% options = BerkeleyAverageOptions( )
% options = BerkeleyAverageOptions( keyword )
% options = BerkeleyAverageOptions( keyword, option1, values1, option2, value2, ... )
%
% This function establishes and validates a set of options for use with the
% BerkeleyAverage function.
%
% The most basic usage of this function is to rely on one of several
% "keywords" that define standard option groups.
%
%    'quick' : A simple average that does not include outlier or site
%    weighting.  No iterative reweighting is done, and the empriical
%    scalpel is disabled.  This will provide a rough idea of the associated
%    temperature series but is not considered complete enough for technical
%    work.  This is the fastest standard mode.
%
%    'weighted' : A more sophisticated average that includes outlier and
%    site weighting based on empricial estimates of record reliability.
%    This requires iterative reweighting and is ~15 times slower than the
%    'quick' mode.  The empricial scalpel is also included by default.
%
%    'local' : This is a complete averaging system with localized outlier
%    analysis and mapping functions.  By default, it also included 
%    uncertainty analysis.  This is by far the slowest of the default
%    groups, but is believed to provide the most accurate picture of
%    temperature changes.  This is the mode used for most of the analyses
%    intended for publication.  It is also the default mode.
%
% In addition to the defined keywords, one can also specify values for
% specific parameters by adding pairs to the argument list of the form
% 'option_name', option_value.
%
% For example, a call to:
%
%    options = BerkeleyAverageOptions( 'weighted', 'GridSize', 5000 );
%
% will create an option set based on the "weighted" keyword, but with
% "GridSize" set to 5000.  One can append as many option_name + value pairs
% as necessary.
%
% For a list of option names, refer to the comments within
% BerkeleyAverageOptions.  Option names are case insensitive.

temperatureGlobals;

% Initialize a blank structure.
options = struct;

% The following values are used to define the 'local' mode.  At the end 
% certain values will be overriden to specify the other processing modes.

%%%%
%%%% Basic Mapping Options
%%%%

% Whether to enable localization and mapping functions.
options.LocalMode = true;

% Number of equal area grid cells to use in describing the surface of the
% Earth.  The exact number used in the calculation may vary slightly from 
% the value specified in order to tile the surface smoothly
options.GridSize = 16000;

% For the purposes of determining spatial weighting coefficients, two
% stations are treated as having the same position provided their
% separation distance is less than this.  Larger numbers significantly 
% improves performance; however, this number should be smaller than the 
% mean distance between grid cells (e.g. 22500 km / sqrt( GridSize ) ) or
% one will start to sacrifice accuracy.
options.GridApproximationDistance = 60; %km

% Whether to mask calculation to only land areas
options.UseLandMask = true;

%%%%
%%%% Minimum Data Size Requirements
%%%%

% The minimum number of valid months a time series must have to be included
% in the analysis.
options.MinMonths = 6;

% The minimum number of stations that must be operational at the same time
% in order to report an average.  (When calculating uncertainty, the
% effective number of stations needed will be approximately
% MinStations * StatisticalUncertaintyInnerLoops. )
options.MinStations = 5;

%%%%
%%%% Correlation Function Parameterization
%%%%

% Previously computed monthly covariance information.
load new_monthly_covariance_info r_p max_d

% Parameterization of the correlation function as exp( -f( distance ) ),
% where, f( distance ) = polyval( CorrelationParameters, distance ).
options.CorrelationParameters = r_p;

% The spatial correlation function is defined to be zero for all distances
% beyond this limit.
options.CorrelationLimitDistance = max_d;

%%%%
%%%% Bad Flags
%%%% 

% Data flags associated with values that should be excluded from the analysis.
options.BadFlags = getBadFlags();

%%%% 
%%%% Site Weighting Parameters
%%%%

% Enable / disable site weighting
options.UseSiteWeighting = true;

% For the purposes of determining site reliability, data points more than
% this many standard errors from the global mean trend are ignored.  This
% should be set to a large value if localization is also used.
options.SiteWeightingGlobalCutoffMultiplier = Inf;

% For the purposes of determining site reliability, data points more than
% this many standard errors from the local mean anomaly are ignored.  This
% value is ignored if localization is disabled.
options.SiteWeightingCutoffMultiplier = 5;

% Determine site reliability by comparing the time series to the expected 
% values at the same location (rather than to the global trend).  This
% option required that LocalMode = true;
options.SiteWeightingLocalized = true;

% When making a comparison to the local expectation, compute the local mean
% field without the site itself being included.  This calculation is
% approximate.
options.SiteWeightingRemoveSelf = true;

%%%%
%%%% Outlier Weighting Parameters
%%%%

% Enable / disable outlier detection and downweighting
options.UseOutlierWeighting = true;

% A point is considered to be an outlier if it is this many standard errors
% from the value expected from the global mean trend.  This value should be
% set large if localization is also being used.
options.OutlierWeightingGlobalCutoffMultiplier = 4;

% A point is considered to be an outlier if it is this many standard errors
% from the value expected from the local mean anomaly field.  Outlier
% points are downweighted in proportion to their distance beyond the cutoff
% threshold.
options.OutlierWeightingCutoffMultiplier = 2.5;

% Determine outlier points by comparing the time series to the expected 
% values at the same location (rather than to the global trend).  This
% option required that LocalMode = true;
options.OutlierWeightingLocalized = true;

% When making a comparison to the local expectation, compute the local mean
% field without the site itself being included.  This calculation is
% approximate.
options.OutlierWeightingRemoveSelf = false;

%%%%
%%%% Scalpel Related Options
%%%%

% Enable / disable use of the scalpel procedure entirely
options.UseScalpel = true;

% Enable / disable use of scalpel for matadata-based issues
options.ScalpelMetadata = true;

% Enable / disable use of the scalpel procedure for gaps in record
% continuity
options.ScalpelGaps = true;

% The minimum length of a gap in time series continuity required for a cut 
% to be made
options.ScalpelGapLength = 1; % years

% Enable / disable use of the scalpel procedure for declared changes in
% station location.
options.ScalpelDeclaredMoves = true;

% Enable / disable use of the scalpel procedure for suspected changes in
% station location.  "Suspected" changes are based in changes in the
% station's reported location that are inconsistent with a mere change in
% reporting precision.
options.ScalpelSuspectedMoves = true;

% Enable / disable use of the scalpel procedure for declared changes in
% the time of observation used to define the local climatological day at
% the site.
options.ScalpelTOBChanges = true;

% Length of time that a time of observation change must persist before
% declaring a break.  The actual break point occurs at the date of the
% first change, but persistence is required to avoid extraneous breaks due
% to reporting errors or other temporary conditions.
options.ScalpelTOBPersistence = 0.5; %years

% Number of hours in TOB shift required for a cut
options.ScalpelTOBDifference = 4; %hours

% Enable / disable the use of the empirical scalpel
options.ScalpelEmpirical = true;

% Max distance between stations pairs to be considered for the empirical
% scalpel process.
options.ScalpelEmpiricalMaxDistance = 2500; %km

% Max pairs to consider
options.ScalpelEmpiricalMaxPairs = 300;

% Max pairs to use in constructing expected temperature series, after
% identifying the most highly correlated records from all considered pairs.
options.ScalpelEmpiricalBestPairs = 25;

% Statistical threshold for change point detection.  For a value of 0.9999, 
% we would expect 1 false positive cut every 10000 months.  However, this
% calculation is based on a Gaussian expectation.  Since the actual data 
% series tends to have far longer tails than a Gaussian distribution, the
% actual frequency of cuts will be increased.
options.ScalpelEmpiricalCut = 0.9999;

% The empirical cut process searches progressively smaller segment lengths
% looking for change points.  This defines the maximum size of a segment 
% that could be considered intact without needing further searching.
options.ScalpelEmpiricalMaxSegment = 10*12; %months

% Empirically determine whether a station break's existence improves the 
% quality of the fit sufficiently to justify its existence.  If not, remove
% the associated break.
options.RemoveInsignificantBreaks = false;

%%%%
%%%% Iterative Reweighting Options
%%%%

% Enable / disable iterative reweighting process
options.UseIterativeReweighting = true;

% Precision target.  The average temperature must change less than this 
% between iterations during every month in the target window for the
% iterative process to exit normally
options.PrecisionTarget = 0.001;

% The precision target is applied to all months where at least this many
% stations were active.
options.PrecisionTargetMinStations = 50; 

% Upper limit on the number of iterations to attempt.  If this limit is
% reached, the process will exit even if the precision target has not been
% reached.
options.MaxIterations = 30;

% Use a modified Broyden method to accelerate convergence.  If false, a
% fixed point iteration method is used that is slower in most cases.
options.UseBroydenMethod = true;

% Use a seed temperature solution to accelerate convergence
options.UseSeed = false;
options.SeedMonthlyTimes = [];
options.SeedMonthlyValues = [];

%%%% 
%%%% Spatial Map Approximation Parameters
%%%%

% These values only apply if LocalMode = true

% Grid cells where the total explained variance is less than this threshold
% will be dropped.  This approximation helps reduce the memory and CPU
% overhead associated with localization.
options.SpatialMapsEmptyCellCut = 0.02;

% The contribution of the i-th station to the j-th grid cell is dropped
% (set to zero to conserve memory and CPU power) when its weight is less
% than the lower of SpatialMapsTrivialMaxCut * (the max station weight in
% the grid cell) or SpatialMapsTrivialSumCut * (sum of all station weights 
% in the grid cell) or SpatialMapsTrivialAbsCut.
options.SpatialMapsTrivialMaxCut = 0.025;
options.SpatialMapsTrivialSumCut = 0.005;

%%%%
%%%% Empirical Region Determination Parameters
%%%%

% Enable / disable empirical determination of the study region.  This
% option is recommended when the sites being studied comprise a
% geographically limited region.  If the sites are geographically extensive
% (i.e. most or all of the Earth's land areas are represented), then it may
% be beneficial to disable this option.
options.LimitEmpiricalFitRegion = true;

% Cutoff to be used with empricial region determination.  Corresponds to
% the fraction of field variance that would be explained if all stations
% were active simultaneously.
options.EmpiricalFitRegionCutoff = 0.8;

% Enable / disable empirical determination of the study region for the 
% purpose of baseline determination only.  This option is recommended in
% most cases as it leads to greater accuracy when converting temperaturs to
% an absolute scale.
options.LimitEmpiricalBaselineRegion = true;
 
% Cutoff to be used with empricial baseline determination.  Corresponds to
% the fraction of field variance that would be explained if all stations
% were active simultaneously.
options.EmpiricalBaselineRegionCutoff = 0.8;

%%%%
%%%% Baseline Mapping Options
%%%%

% Use latitude and altitude fitting in determination of global baseline
% map.
options.FullBaselineMapping = true;

% Target values for sin( latitude ) in determining latitude based fitting 
% function.
options.FullBaselineTargetLats = 0:1/15:1;

% Degree of polynomial used in altitude fit
options.FullBaselineAltitudeDegree = 2;

%%%%
%%%% Uncertainty Computation Options
%%%%

% Perform uncertainty calculations at all
options.ComputeUncertainty = true;

% Perform statistical uncertainty calculation.  "Statistical uncertainty"
% in the specific context of this project refers to uncertainty arising out
% of noise, errors, and biases in the temperature data.
options.ComputeStatisticalUncertainty = true;

% Use localization features when computing statistical uncertainty.  This
% makes the process exceedingly slow, and so is not recommend unless truly
% needed.
options.StatisticalUncertaintyLocal = false;

% Whether to use jack-knife or bootstrap process in the computation of
% statistical uncertainties.  Jack knife is more accurate, but much slower.
% By constrast, the boostrap process tends to be systematically low.
options.UseJackKnife = true;

% Number of subsamples of the station network to use
options.StatisticalUncertaintyInnerLoops = 8;

% Number of times to repeat the process.
options.StatisticalUncertaintyOuterLoops = 1;

% Minimum number of subsamples that must report a value for it to be
% included in the statistical determination.
options.StatisticalUncertaintyMinRepeats = 3;

% Benchmark years used for determining the record alignment in the
% statistical analysis.
options.StatisticalUncertaintyBenchmarkMinDate = 1960;
options.StatisticalUncertaintyBenchmarkMaxDate = 2000;

% Perform standard (i.e. empirical) spatial uncertainty calculation.  In
% the context of this project, "spatial uncertainty" refers to the
% uncertainty arising from incomplete spatial sampling of the globe.
options.ComputeEmpiricalSpatialUncertainty = true;

% Use analytic estimates for undersampled regions where empirical
% determinations are not available.
options.SupplementEmpiricalSpatialWithAnalytic = true;

% Benchmark years used for determining the record alignment in the
% statistical analysis.
options.SpatialUncertaintyBenchmarkMinDate = 1960;
options.SpatialUncertaintyBenchmarkMaxDate = 2000;

% Perform alternate (i.e. pure analyticic) spatial uncertainty calculation.
% This is only used if both ComputeEmpiricalSpatialUncertainty is false.
% Otherwise, the full analytic process will already run if
% SupplementEmpiricalSpatialWithAnalytic is true.
options.ComputeAnalyticSpatialUncertainty = true;

%%%%
%%%% Graphical Animation Options
%%%%

% Presently these don't work.  Expect this section to change.

options.RenderMovie = false;
options.MovieName = '';

%%%%
%%%% Results Saving Options
%%%%

options.SaveResults = true;
options.OutputDirectory = [temperature_data_dir ...
    'Berkeley Average Results'];
options.OutputPrefix = '';

%%%%
%%%% Cluster Options
%%%%

options.ClusterMode = (matlabPoolSize() > 8);

%%%%
%%%% End of Options 
%%%%



% The following is the part of the code that handles the assingment of
% default sets and user-specified overrides.

narg = nargin;
varg = varargin;

% No input, treat the same as the default.
if narg == 0 
    return;
end

if strcmpi( varg{1}, 'quick' )
    
    % A simple quick average
    % No outlier / site weighting, no iteration, no empirical scalpel.
    options.LocalMode = false;
    options.UseSiteWeighting = false;
    options.UseOutlierWeighting = false;
    options.UseIterativeReweighting = false;
    options.ComputeUncertainty = false;
    options.ScalpelEmpirical = false;

    options.ComputeEmpiricalSpatialUncertainty = false;
    options.SupplementEmpiricalSpatialWithAnalytic = false;
    options.ComputeAnalyticSpatialUncertainty = false;
    
    options.ClusterMode = false;
    
    varg(1) = [];
    narg = narg - 1;        
    
elseif strcmpi( varg{1}, 'weighted' )
    
    % An average with outlier and site weighting, handled iteratively, but
    % does not perform the localization and mapping functions.
    options.LocalMode = false;
    options.ComputeUncertainty = false;    
    options.OutlierWeightingLocalized = false;
    options.SiteWeightingLocalized = false;
    options.SiteWeightingGlobalCutoffMultiplier = 5;
    options.OutlierWeightingGlobalCutoffMultiplier = 2.5;

    options.ComputeEmpiricalSpatialUncertainty = false;
    options.SupplementEmpiricalSpatialWithAnalytic = false;
    options.ComputeAnalyticSpatialUncertainty = false;

    options.ClusterMode = false;
    
    varg(1) = [];
    narg = narg - 1;        
    
elseif strcmpi( varg{1}, 'local' )
    
    % Localized mapping with uncertainty, this is the default set.
    % Nothing to do, this is the default set.
    varg(1) = [];
    narg = narg - 1;        
    
elseif strcmpi( varg{1}, 'complete' )
    
    % Same as local but with localized statistical uncertainty.  
    % This is really slow.
    options.StatisticalUncertaintyLocal = true;
    varg(1) = [];
    narg = narg - 1;        
    
end

flist = fieldnames( options );
% Argument list can't end on an option name.
if mod( narg, 2 ) ~= 0 
    error( 'Argument list appears incomplete, number of options does not match number of values' );
end

for k = 1:2:narg
    % Find option name in list, case insensitive.
    A = strcmpi( varg{k}, flist );
    
    % User attempts to specify an option name that is  not supported.
    if ~any(A)
        error( ['Argument "' varg{k} '" not found'] );
    end
    
    if sum(A) > 1
        % This should never occur.
        error( 'Too many matches ?!?!' );
    end
    
    % Check that the requested value has the same datatype as what it is
    % replacing.
    if ~strcmp( class( varg{k+1} ), class( options.(flist{A}) ) )
        % Special case of "logical" values.  Allow numbers to stgand in for
        % true / false according to the standard Matlab convention.
        if islogical( options.(flist{A}) ) && isnumeric( varg{k+1} ) && ...
                length( varg{k+1} ) == 1
            varg{k+1} = logical(varg{k+1});
        else
            error( ['Value "' varg{k+1} '" for argument "' varg{k} '" has wrong type'] );
        end
    end    
    
    % Assign updated value.
    options.(flist{A}) = varg{k+1};
end

  
% Test the option set for consistency and display any errors / warnings to
% the user.
BerkeleyAverageOptionsConsistency( options );




