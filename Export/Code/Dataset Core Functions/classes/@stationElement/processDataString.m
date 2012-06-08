function se = processDataString( se, strs )

if isa( strs, 'char' )
    strs = cellstr( strs );
end

I1 = [];
I2 = [];
I3 = [];
I4 = [];
I5 = [];
I6 = [];
I7 = [];
I8 = [];
I9 = [];

for k = 1:length( strs )
    if length( strs{k} ) < 7
        continue;
    end
        
    if strcmp( strs{k}(5:7), 'DLY')
        I1(end+1) = k;
    elseif strcmp( strs{k}(5:7), 'MLY')
        I7(end+1) = k;
    elseif strcmp( strs{k}(1:4), 'SCAR')
        I5(end+1) = k;
    elseif strs{k}(7) == '-' && strs{k}(1) >= '0' && strs{k}(1) <= '9' ...
            && strs{k}(6) >= '0' && strs{k}(6) <= '9'
        I3(end+1) = k;
    elseif length(strs{k}) == 102
        I8(end+1) = k;
    elseif length(strs{k}) == 140
        I9(end+1) = k;
    elseif length(strs{k}) == 269
        I2(end+1) = k;
    elseif length(strs{k}) == 76
        if strs{k}(5) == ' '
            I6(end+1) = k;
        else
            I4(end+1) = k;
        end
    elseif length(strs{k}) == 77
        I6(end+1) = k;
    else
        error( 'Data String of Unknown Type' );
    end
end 

if ~isempty(I1)
    se = processUSSODDataString( se, strs(I1) );
end
if ~isempty(I2)
    se = processGHCNDDataString( se, strs(I2) );
end
if ~isempty(I3)
    se = processGSODDataString( se, strs(I3) );
end
if ~isempty(I4)
    se = processGHCNMDataString( se, strs(I4) );
end
if ~isempty(I5)
    se = processSCARDataString( se, strs(I5) );
end
if ~isempty(I6)
    se = processHadCRUDataString( se, strs(I6) );
end
if ~isempty(I7)
    se = processUSSOMDataString( se, strs(I7) );
end
if ~isempty(I8)
    se = processUSHCNMDataString( se, strs(I8) );
end
if ~isempty(I9)
    se = processWMSSCDataString( se, strs(I9) );
end

se = clean( se );
