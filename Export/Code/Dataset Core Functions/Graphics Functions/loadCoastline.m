function seg = loadCoastline( type )
% Reads GSHHS coastline files

pth = '';
switch lower(type)
    case {'c','coarse'}
        kind = 'c';
    case {'l','low'}
        kind = 'l';
    case {'h','high'}
        kind = 'h';
    case {'f','full'}
        kind = 'f';
    otherwise
        if exist( type, 'file' )
            pth = type;
        else
            disp(['Coastline Type "' type '" is Unknown.']);
            seg = [];
            return;
        end
end

temperatureGlobals;

if ~isempty( pth ) 
    fin = fopen(pth, 'r','b');
else    
    fin = fopen([temperature_data_dir 'Geographical Data\gshhs\gshhs_' kind '.b'],'r','b');
end
cnt = 1;
seg = [];

rivermode = 0;
while ~feof(fin)
    A = fread(fin,2,'int32');
    if isempty(A)
        break;
    end
    B = fread(fin,4,'char');
    A2 = fread(fin,8,'int32');
    C = fread(fin,A(2)*2,'int32');

    seg(cnt).id = A(1);
    seg(cnt).length = A(2);
    seg(cnt).level = B(4);
    seg(cnt).area = A2(5);
    seg(cnt).points = [C(1:2:end),C(2:2:end)]/1e6;
    if seg(cnt).level == 2
        if seg(cnt).area > 20000 && seg(cnt-1).area < 10000 && seg(cnt-1).level == 2
            rivermode = 1;
        end
        seg(cnt).river = rivermode;
    else
        seg(cnt).river = 0;
    end
    
    cnt = cnt + 1;
end

fclose(fin);
