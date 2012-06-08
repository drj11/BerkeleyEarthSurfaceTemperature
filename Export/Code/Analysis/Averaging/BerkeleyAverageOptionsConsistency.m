function BerkeleyAverageOptionsConsistency( options )
% BerkeleyAverageOptionsConsistency( options )
%
% This function runs various checks on the options created by
% BerkeleyAverageOptions to make sure they are within reasonable bounds and
% mutually consistent.
%
% This function is called automatically by BerkeleyAverageOptions and
% should not need to be called direclty by the user.

% Grid sizing
if options.GridSize < 100 && options.LocalMode
    error( 'GridSize is too small' );
end
if options.GridSize > 50000 && options.LocalMode
    warning( 'Options:GridLarge', 'Very large GridSize may provide poor performance' );
end

% Grid approximation
if options.GridApproximationDistance < 0
    error( 'GridApproximationDistance < 0' );
end
if options.GridApproximationDistance > 100
    warning( 'Options:GridApproximationDistanceLarge', ...
        'GridApproximationDistance > 100 km is not recommended' );
end
if options.GridApproximationDistance > 0.5 * 22500 / sqrt( options.GridSize )
    warning( 'Options:GridApproximationDistanceConflict', ...
        'GridApproximationDistance should not exceed half the mean distacne between grid cells' );
end

% Record lengths
if options.MinMonths < 3
    error( 'MinMonths < 3' );
end
if options.MinStations < 1
    error( 'MinStations < 1' );
end

% Site Weighting
if options.UseSiteWeighting
    if options.SiteWeightingCutoffMultiplier < 0
        error( 'SiteWeightingCutoffMultiplier < 0' );
    end
    if options.SiteWeightingGlobalCutoffMultiplier < 0
        error( 'SiteWeightingCutoffMultiplier < 0' );
    end
    if options.SiteWeightingLocalized && ~options.LocalMode
        error( 'SiteWeightingLocalized in non-local mode' );
    end
end

% Outlier Weighting
if options.UseOutlierWeighting
    if options.OutlierWeightingCutoffMultiplier < 0
        error( 'OutlierWeightingCutoffMultiplier < 0' );
    end
    if options.OutlierWeightingGlobalCutoffMultiplier < 0
        error( 'OutlierWeightingCutoffMultiplier < 0' );
    end
    if options.OutlierWeightingLocalized && ~options.LocalMode
        error( 'OutlierWeightingLocalized in non-local mode' );
    end
end

% Scalpel Methods
if options.UseScalpel
    if options.ScalpelMetadata
        if options.ScalpelGaps && options.ScalpelGapLength < 1/6
            error( 'ScalpelGapLength < 1/6' );
        end
        if options.ScalpelTOBChanges && options.ScalpelTOBPersistence < 1/6
            error( 'ScalpelTOBPersistence < 1/6' );
        end
        if options.ScalpelTOBChanges && ...
                ( options.ScalpelTOBDifference < 1 || options.ScalpelTOBDifference > 12 )
            error( 'ScalpelTOBDifference not between 1 and 12' );
        end
        if ~options.ScalpelGaps && ~options.ScalpelTOBChanges && ...
                ~options.ScalpelDeclaredMoves && ~options.ScalpelSuspectedMoves
            error( 'ScalpelMetadata is true, but all metadata segments are false.' );
        end        
    end  
    if options.ScalpelEmpirical
        if options.ScalpelEmpiricalMaxDistance < 0
            error( 'ScalpelEmpiricalMaxDistance < 0' );
        end
        if options.ScalpelEmpiricalMaxDistance < 200
            warning( 'Options:ScalpelEmpiricalMaxDistance', ...
                'ScalpelEmpiricalMaxDistance < 200 km is not recommended' );
        end
        if options.ScalpelEmpiricalMaxPairs < 1
            error( 'ScalpelEmpiricalMaxPairs < 1' );
        end
        if options.ScalpelEmpiricalMaxPairs < options.ScalpelEmpiricalBestPairs
            error( 'ScalpelEmpiricalMaxPairs < ScalpelEmpiricalBestPairs' );
        end
        if options.ScalpelEmpiricalBestPairs < 1
            error( 'ScalpelEmpiricalBestPairs < 1' );
        end
        if options.ScalpelEmpiricalBestPairs > 100
            warning( 'Options:ScalpelEmpiricalBestPairs', ...
                'ScalpelEmpiricalBestPairs > 100 is not recommended' );
        end
        if ( options.ScalpelEmpiricalCut >= 1 || ...
                options.ScalpelEmpiricalCut <= 0 )
            error( 'ScalpelEmpiricalPrimaryCut not in range 0-1' );
        end
        if ( options.ScalpelEmpiricalMaxSegment < 6 )
            error( 'ScalpelEmpiricalMaxSegment is less than 6' );
        end
        if options.ScalpelEmpiricalCut < 0.99
            warning( 'Options:ScalpelEmpiricalCut', ...
                'ScalpelEmpiricalCut < 0.99 is not recommended' );
        end
        if options.ScalpelEmpiricalMaxSegment < 5*12
            warning( 'Options:ScalpelEmpiricalMaxSegment', ...
                'ScalpelEmpiricalMaxSegment < 60 is not recommended' );
        end
    end
end

% Weighted mode
if options.UseIterativeReweighting
    if options.PrecisionTarget < 0
        error( 'PrecisionTarget < 0' );
    end
    if options.PrecisionTarget < 0.0001
        warning( 'Options:PrecisionTargetLow', ...
            'PrecisionTarget < 0.0001 is not recommended' );
    end
    if options.PrecisionTarget > 0.01
        warning( 'Options:PrecisionTargetHigh', ...
            'PrecisionTarget > 0.01 is not recommended' );
    end
    if options.MaxIterations < 3
        error( 'MaxIterations < 3' );
    end
    if options.MaxIterations > 100
        warning( 'Options:MaxIterations', ...
            'MaxIterations > 100 is not recommended' );
    end
    if options.PrecisionTargetMinStations < 1
        error( 'PrecisionTargetMinStations < 1' );
    end
    if options.PrecisionTargetMinStations < 20
        warning( 'Options:PrecisionTargetMinStations', ...
            'PrecisionTargetMinStations < 20 is not recommended' );
    end    
end

% Local mode
if options.LocalMode
    if options.SpatialMapsEmptyCellCut < 0 || options.SpatialMapsEmptyCellCut > 1
        error( 'SpatialMapsEmptyCellCut not in range 0-1' );
    end
    if options.SpatialMapsEmptyCellCut > 0.05
        warning( 'Options:SpatialMapsEmptyCellCut', ...
            'SpatialMapsEmptyCellCut > 0.05 is not recommended' );
    end    
    if options.SpatialMapsTrivialMaxCut < 0 || options.SpatialMapsTrivialMaxCut > 1
        error( 'SpatialMapsTrivialMaxCut not in range 0-1' );
    end
    if options.SpatialMapsTrivialMaxCut > 0.1
        warning( 'Options:SpatialMapsTrivialMaxCut', ...
            'SpatialMapsTrivialMaxCut > 0.1 is not recommended' );
    end    
    if options.SpatialMapsTrivialSumCut < 0 || options.SpatialMapsTrivialSumCut > 1
        error( 'SpatialMapsTrivialSumCut not in range 0-1' );
    end
    if options.SpatialMapsTrivialSumCut > 0.05
        warning( 'Options:SpatialMapsTrivialSumCut', ...
            'SpatialMapsTrivialSumCut > 0.05 is not recommended' );
    end    
end

% Empricial region determination
if options.LimitEmpiricalFitRegion
    if options.EmpiricalFitRegionCutoff < 0 || options.EmpiricalFitRegionCutoff > 1
        error( 'EmpiricalFitRegionCutoff not in range 0-1' );
    end
end
if options.LimitEmpiricalBaselineRegion
    if options.EmpiricalBaselineRegionCutoff < 0 || options.EmpiricalBaselineRegionCutoff > 1
        error( 'EmpiricalBaselineRegionCutoff not in range 0-1' );
    end
end
if options.LimitEmpiricalBaselineRegion && options.LimitEmpiricalFitRegion
    if options.EmpiricalBaselineRegionCutoff < options.EmpiricalFitRegionCutoff
        warning( 'Options:CutoffComparison', ...
            'EmpiricalBaselineRegionCutoff < EmpiricalFitRegionCutoff is not recommended' );
    end    
end

% Baseline Smooth
if options.FullBaselineMapping
    if min( options.FullBaselineTargetLats ) < 0
        error( 'min( FullBaselineTargetLats ) < 0' );
    end
    if max( options.FullBaselineTargetLats ) < 0
        error( 'max( FullBaselineTargetLats ) > 1' );
    end
    if isempty( options.FullBaselineTargetLats )
        error( 'FullBaselineTargetLats is empty' );
    end
    if length( options.FullBaselineTargetLats ) < 10
        warning( 'Options:FullBaselineTargetLats', ...
            'length( FullBaselineTargetLats ) < 10 not recommended' );
    end
    if options.FullBaselineAltitudeDegree < 1 
        error( 'FullBaselineAltitudeDegree < 1' );
    end
    if options.FullBaselineAltitudeDegree ~= floor( options.FullBaselineAltitudeDegree ) 
        error( 'FullBaselineAltitudeDegree is not an integer' );
    end
    if options.FullBaselineAltitudeDegree > 4 
        warning( 'Options:FullBaselineAltitudeDegree', ...
            'FullBaselineAltitudeDegree > 4 not recommended' );
    end
end

% Uncertainty options 
if options.ComputeUncertainty
    if options.ComputeStatisticalUncertainty
        if options.StatisticalUncertaintyLocal && ~options.LocalMode
            error( 'StatisticalUncertaintyLocal true but LocalMode is false' );
        end
        if options.StatisticalUncertaintyInnerLoops < 2
            error( 'StatisticalUncertaintyInnerLoops < 2' );
        end
        if options.StatisticalUncertaintyInnerLoops > 10
            warning( 'Options:StatisticalUncertaintyInnerLoops', ...
                'StatisticalUncertaintyInnerLoops > 10 is not recommended' );
        end
        if options.StatisticalUncertaintyOuterLoops < 1
            error( 'StatisticalUncertaintyOuterLoops < 1' );
        end
        if options.StatisticalUncertaintyOuterLoops > 5
            warning( 'Options:StatisticalUncertaintyOuterLoops', ...
                'StatisticalUncertaintyOuterLoops > 5 is not recommended' );
        end
        if options.StatisticalUncertaintyMinRepeats > options.StatisticalUncertaintyInnerLoops
            error( 'StatisticalUncertaintyMinRepeats > StatisticalUncertaintyInnerLoops' );
        end
        if options.StatisticalUncertaintyMinRepeats < 2
            error( 'StatisticalUncertaintyMinRepeats < 2' );
        end
        if options.StatisticalUncertaintyMinRepeats < 3
            warning( 'Options:StatisticalUncertaintyMinRepeats', ...
                'StatisticalUncertaintyMinRepeats < 3 is not recommended' );
        end
        if options.StatisticalUncertaintyBenchmarkMinDate >= options.StatisticalUncertaintyBenchmarkMaxDate
            error( 'StatisticalUncertaintyBenchmarkMinDate >= StatisticalUncertaintyBenchmarkMaxDate' );
        end
        if options.StatisticalUncertaintyBenchmarkMaxDate - options.StatisticalUncertaintyBenchmarkMinDate < 20
            warning( 'Options:StatisticalUncertaintyMinRepeats', ...
                'StatisticalUncertaintyBenchmarkMaxDate minus StatisticalUncertaintyBenchmarkMinDate is less than 20 years' );
        end
    end
    if ( options.ComputeEmpiricalSpatialUncertainty || options.ComputeAnalyticSpatialUncertainty ) && ~options.LocalMode
        error( 'Can''t generate spatial uncertainties without localization' );
    end

    if options.ComputeEmpiricalSpatialUncertainty
        if options.SpatialUncertaintyBenchmarkMinDate >= options.SpatialUncertaintyBenchmarkMaxDate
            error( 'SpatialUncertaintyBenchmarkMinDate >= SpatialUncertaintyBenchmarkMaxDate' );
        end
        if options.SpatialUncertaintyBenchmarkMaxDate - options.SpatialUncertaintyBenchmarkMinDate < 20
            warning( 'Options:StatisticalUncertaintyMinRepeats', ...
                'SpatialUncertaintyBenchmarkMaxDate minus SpatialUncertaintyBenchmarkMinDate is less than 20 years' );
        end
        if ~options.SupplementEmpiricalSpatialWithAnalytic 
            warning( 'Options:SupplementEmpiricalSpatialWithAnalytic', ...
                'Use of SupplementEmpiricalSpatialWithAnalytic is highly recommended' );
        end
        if options.SupplementEmpiricalSpatialWithAnalytic && ~options.ComputeAnalyticSpatialUncertainty
            error( 'SupplementEmpiricalSpatialWithAnalytic is true but ComputeAnalyticSpatialUncertainty is false' );
        end
    end
end
if options.RenderMovie && isempty( options.MovieName )
    error( 'Movie File Name Not Specified' );
end

