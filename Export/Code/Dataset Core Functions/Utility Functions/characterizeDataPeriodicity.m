function [res, means, stds_high, stds_low, stds] = characterizeDataPeriodicity( x_orig, y_orig, degree )
% Worhorse function that actually computes data periodcity.

y = y_orig(:);
x = x_orig(:);

if nargin < 3
    degree = 3;
end

exit_threshold = 0.001;     %Exit if percent variation on all parameters is less than this
exclusion_threshold = 0.9;  %Exclude outliers from fit with variance scaled distance beyond this
variance_limit = 1e-3;  %Lowest allowed variance;

if length( x ) <= 2
    res.mean_constant = NaN;
    res.variance_constant_high = NaN;
    res.variance_constant_low = NaN;
    res.mean_periodicity = zeros(2*degree,1)*NaN;
    res.variance_periodicity_high = zeros(2*degree,1)*NaN;
    res.variance_periodicity_low = zeros(2*degree,1)*NaN;
    
    means(1:length(x),1) = NaN;
    stds(1:length(x),1) = NaN;
    stds_high = stds;
    stds_low = stds;
    
    return; 
end

if max(x) - min(x) < 0.75 && degree > 1
    fake_degree = degree;
    degree = 1;
elseif max(x) - min(x) < 1.5 && degree > 2
    fake_degree = degree;
    degree = 2;
else
    fake_degree = degree;
end

A = zeros( length(y), 2*degree + 1 );
Y = y;

A(:, 1) = ones(length(y),  1);

A( :, 2:degree + 1 ) = sin( 2*pi*x .* ones(length(x),1)*(1:degree) );
A( :, degree + 2 : 2*degree + 1 ) = cos( 2*pi*x .* ones(length(x),1)*(1:degree) );

try 
    rA = rank(A);
catch
    rA = 0;
end

if rA < 2*degree + 1
    res.mean_constant = mean(y);
    res.variance_constant_high = mean(y-mean(y)).^2;
    res.variance_constant_low = mean(y-mean(y)).^2;
    res.mean_periodicity = zeros(2*degree,1);
    res.variance_periodicity_high = zeros(2*degree,1);
    res.variance_periodicity_low = zeros(2*degree,1);
    
    means(1:length(x),1) = mean(y);
    stds(1:length(x),1) = std(y);
    stds_high = stds;
    stds_low = stds;
    
    return;
end

last_fit = [];
len = length(x);

S = A(:,1);

warning('off','MATLAB:rankDeficientMatrix')  %rank deficiencies
warning('off','MATLAB:nearlySingularMatrix')  %rank deficiencies
warning('off','MATLAB:singularMatrix')  %rank deficiencies

Y_adj = Y;
for iter = 1:30            
    W = 1./S;
    
    WA = (W*ones(1, 2*degree+1)).*A;
    
    M = WA \ (W.*Y_adj);
    y_exp = A*M;
    y_diff = Y - y_exp;
    
    fa = (y_diff >= 0);    
    fb = ~fa; 
    Y2 = (y_diff).^2;
    M2a = WA(fa,:) \ (W(fa).*Y2(fa));
    M2b = WA(fb,:) \ (W(fb).*Y2(fb));
    
    Sa = A*M2a;
    Sb = A*M2b;
    f = ( Sa <= variance_limit*max(Sa) );
    Sa(f) = variance_limit*max(Sa);
    f = ( Sb <= variance_limit*max(Sb) );
    Sb(f) = variance_limit*max(Sb);
    
    SM = (Sa + Sb)/2;
    
    %Defines an overlap interval based on SM for a smooth between high and low.
    part = 0.5;
    
    SM2 = sqrt(SM)/part;
    f = ( y_diff >= SM2 );
    S(f) = Sa(f);
    f = ( y_diff <= -SM2 );
    S(f) = Sb(f);    

    f = ( y_diff > -SM2 & y_diff < SM2 );
    w = y_diff(f)./SM2(f);
    S(f) = ((1+w)/2).*Sa(f) + ((1-w)/2).*Sb(f);

    dist = Y2./S;
    [dist_sort, I] = sort(dist);    
    
    if iter > 1
        test = [sum(abs(M)), sum(abs(M2a)), sum(abs(M2b))];
        if min(test) == 0 || max( abs(test - last_fit) ./ ((test + last_fit)/2) ) < exit_threshold
            break;
        end
        last_fit = test;
    else
        last_fit = [sum(abs(M)), sum(abs(M2a)), sum(abs(M2b))];
    end
        
    % Effectively crop the most egregious outliers from the fit.
    max_dist = dist_sort(round(exclusion_threshold*len));
    Y_adj = Y;

    fx = (dist > max_dist) & ( Y > y_exp );
    Y_adj(fx) = y_exp(fx) + sqrt(S(fx)).*sqrt(max_dist);
    fx = (dist > max_dist) & ( Y < y_exp );
    Y_adj(fx) = y_exp(fx) - sqrt(S(fx)).*sqrt(max_dist);
    
end

warning('on','MATLAB:rankDeficientMatrix')  %rank deficiencies
warning('on','MATLAB:nearlySingularMatrix')  %rank deficiencies
warning('on','MATLAB:singularMatrix')  %rank deficiencies

%rescale based on 95% threshold to adjust for non-normality
target = erfinv(0.95)*sqrt(2);
[~,I] = sort(dist);
fk = I(round(end*0.95));
M2a = M2a*dist(fk)/target^2;
M2b = M2b*dist(fk)/target^2;
Sa = Sa*dist(fk)/target^2;
Sb = Sb*dist(fk)/target^2;
S = S*dist(fk)/target^2;

if degree ~= fake_degree
    M_c = zeros(2*fake_degree+1,1);
    M_c(1:degree+1) = M(1:degree+1);
    M_c(fake_degree+2:fake_degree+2+degree-1) = M(degree+2:end);
    M = M_c;

    M2a_c = zeros(2*fake_degree+1,1);
    M2a_c(1:degree+1) = M2a(1:degree+1);
    M2a_c(fake_degree+2:fake_degree+2+degree-1) = M2a(degree+2:end);
    M2a = M2a_c;

    M2b_c = zeros(2*fake_degree+1,1);
    M2b_c(1:degree+1) = M2b(1:degree+1);
    M2b_c(fake_degree+2:fake_degree+2+degree-1) = M2b(degree+2:end);
    M2b = M2b_c;
end

res.mean_constant = M(1);
res.variance_constant_high = M2a(1);
res.variance_constant_low = M2b(1);
res.mean_periodicity = M(2:end);
res.variance_periodicity_high = M2a(2:end);
res.variance_periodicity_low = M2b(2:end);

means = y_exp;
stds_low = sqrt(Sb);
stds_high = sqrt(Sa);
stds = sqrt(S);    
    