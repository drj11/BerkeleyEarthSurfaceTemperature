function groups = findBaselineGroups( baselines, initial_chi, baseline_adjustments, baseline_weights, df )
% This function is used to determine which baseline shifts are significant. 

numBase = length(baselines);

groups = 1:numBase;

BB = abs( bsxfun( @minus, baselines, baselines' ) );
[ki, ji] = meshgrid( 1:numBase, 1:numBase );

f = (ki == ji - 1) | (ki == ji - 2);
BB = BB(f);
ki = ki(f);
ji = ji(f);

[~, I] = sort( BB );

BB = BB(I);
ki = ki(I);
ji = ji(I);

for k = 1:length(BB)
    if groups(ki(k)) == groups(ji(k))
        continue;
    end
    f = ( groups == groups(ki(k)) | groups == groups(ji(k)) );
    new_base = sum( baseline_weights(f).*baselines(f) )/sum(baseline_weights(f));
    
    shift = baselines(f) - new_base;
    adjustment = sum( abs( baseline_adjustments(f, 1).*shift + baseline_adjustments(f, 2).*shift.^2 ) );
    
    if (initial_chi + adjustment) / (df + sum(f) - 1) < initial_chi / df
        replace = min( [groups(ki(k)), groups(ji(k))] );
        groups(f) = replace;
    end
end
    
un = unique( groups );
map = zeros( numBase, 1 );
map( un ) = 1:length(un);

groups = map( groups );


