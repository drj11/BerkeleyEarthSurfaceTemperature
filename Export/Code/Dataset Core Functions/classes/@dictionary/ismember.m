function res = ismember( ind, dd )

pos = quickSearch( ind, dd.keys );
res = ~isnan(pos);