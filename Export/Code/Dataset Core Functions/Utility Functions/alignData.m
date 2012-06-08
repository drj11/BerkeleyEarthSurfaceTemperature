function S = alignData( table )
% alignment = alignData( data )
%
% Data appear in columns, missing values indicated with NaN.

M = zeros(length(table(1,:)));
Y = M(:,1);

M2 = zeros(size(table));
Y2 = M2(:,1);
count = Y2;

for i = 1:length(table(:,1))
    f = ( ~isnan(table(i,:)) );
    if sum(f) == 0
        continue;
    end
    M2(i,f) = M2(i,f) + 1;
    count(i) = count(i) + sum(f);
    Y2(i) = Y2(i) + sum(table(i,f));
end

Y2 = Y2 ./ count;
M2 = M2 ./ (count*ones(1,length(table(1,:))));

for i = 1:length(table(:,1))
    f = ( ~isnan(table(i,:)) );
    if sum(f) == 0
        continue;
    end
    Y(f) = Y(f)' + table(i,f) - Y2(i);
    
    M(f,:) = bsxfun( @minus, M(f,:), M2(i,:) );
    
    D = diagonalIndices( length(M) );
    M(D(f)) = M(D(f)) + 1;
end

M(end+1,:) = ones(length(table(1,:)),1);
Y(end+1) = 0;

S = (M\Y)';