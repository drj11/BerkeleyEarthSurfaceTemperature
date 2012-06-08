function [p1, max_d] = fitCorrelationCurve( dist_monthly, corr_monthly )
% Function used to determine the parameterization of the correlation versus
% distance function from a previous generate set of correlation pairs.

if nargin >= 2
    load monthly_covariance_info
    dist = dist_monthly;
    corr = corr_monthly;
end

% figure
% plot(dist, corr, '.');

f = ( ~isnan(dist) & ~isnan(corr) );
dist2 = dist(f);
corr2 = corr(f);
[~,I] = sort(dist2);
dist2 = dist2(I);
corr2 = corr2(I);

distx = zeros( length(dist)/25, 1 );
corrx = distx;

block_size = 25;
cnt = 1;
for k = 1:block_size:length(dist2)
    timePlot( 'loop', k / length(dist2) )
    max_block = min( length(dist2), k+block_size-1 );
    I = k:max_block;
    distx(cnt) = median( dist2(I) );
    corrx(cnt) = median( corr2(I) );
    cnt = cnt + 1;
end
timePlot('loop', 1)

distx( cnt+1:end ) = [];
corrx( cnt+1:end ) = [];

f = ( dist >= 5000 );
c_late = mean(corr(f));

hold on
plot( distx, corrx, 'r.');

fx = find( distx > 0.1 & ~isnan(distx) & ~isnan(corrx) );
p0 = polyfit( distx(fx), log(abs(corrx(fx))), 4);

f = @(p) scoreCorrelationCurve( p, distx(fx), corrx(fx) );

options = optimset;
options = optimset( options, 'display', 'iter', 'tolfun', 1e-6);
p1 = fminsearch( f, p0, options );

dist = 1:5000;
o = polyval(p1, dist);
plot( dist, exp(o)*(1-c_late)+c_late, 'k', 'linewidth', 3)
set(gca, 'tickdir', 'out')
setxmax(5000);

fx = find( exp(o) < 1e-7 );
max_d = dist(fx(1));



function sc = scoreCorrelationCurve( p, dist, corr )
% Quality of fit helper function.

f = find( dist >= 5000 );

corr = ( corr - mean(corr(f)) ) / ( 1 - mean(corr(f)) );

o = exp( polyval( p, dist ) );

dd = diff([0; dist]);

%sc = sum(1./dist.*(corr-o).^2) / sum( 1./dist );
sc = sum( dd.*(corr-o).^2) / sum( dd );

o2 = exp( polyval( p, 1:5000 ) );
sc = sc + 0.00001*sum( diff(o2) > 0 ) + 100*(o2(5000));

