function timePlot(name, complete, text_mode)
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

persistent last_call

if nargin < 3
    text_mode = false;
end

if text_mode
    timePlot2( name, complete );
    return;
end

if ~isempty( last_call ) 
    if (cputime - last_call) < 0.5 && complete ~= 0 && complete ~= 1
        return;
    end
end
now_value = now;

s = get(0,'CurrentFigure');

if (complete < 0) || (complete > 1)
    error('Not acceptable completion 0-1');
end

ch = get(0,'Children');
plh =0;
for a = 1:length(ch);
    if (strcmp(get(ch(a),'Name'),['Time Remaining on ' name]))
        plh = ch(a);
    end
end

if (complete == 0)
    if (plh~=0)
        close(plh)
    end
    plh = 0;
end

if plh == 0 && complete == 1
    return;
end

if (plh == 0)
    
    mat0 = jet(250);
    
    h0 = figure('Units','points', ...
        'Color',[0.8 0.8 0.8], ...
        'Colormap',mat0, ...
        'MenuBar','none',...
        'Name',['Time Remaining on ' name], ...
        'NumberTitle','off', ...
        'Position',[255 352 400 65], ...
        'Resize','off', ...
        'Tag','Fig2',...
        'UserData',[complete, now_value-700000]);
    h1 = axes('Parent',h0, ...
        'Units','points', ...
        'CameraUpVector',[0 1 0], ...
        'Color',[1 1 1], ...
        'ColorOrder',mat0, ...
        'Position',[15 33 370 25], ...
        'Tag','TimePlotBar', ...
        'TickDirMode','manual', ...
        'XColor',[1 1 1], ...
        'XTickLabelMode','manual', ...
        'XTickMode','manual', ...
        'XTick',[],...
        'XLim',[0,1],...
        'YColor',[1 1 1], ...
        'YTickLabelMode','manual', ...
        'YTickMode','manual', ...
        'YTick',[],...
        'YLim',[0,1],...
        'ZColor',[0 0 0]);
    patch([0.02,0.02,0.98*complete,0.98*complete],[0.1,0.9,0.9,0.1],[0,0,0]);
    h1 = uicontrol('Parent',h0, ...
        'Units','points', ...
        'HorizontalAlignment','center', ...
        'Position',[15 8 370 22], ...
        'String','Time Remaining', ...
        'Style','text', ...
        'Tag','TimePlotText');
    
else
    ch = get(plh,'Children');
    d = get(plh,'UserData');
    if complete < 1 && (now_value-700000) - d(end,2) >= 0.5/(24*60*60) 
        % Minimum delay of 0.5 second for change.
        if s ~= plh
            set(0,'CurrentFigure', plh);
        end
        d = [d; complete, now_value-700000];        
        patch([0.02,0.02,0.98*complete,0.98*complete],[0.1,0.9,0.9,0.1],[0,0,0]);
     
        set(plh,'UserData',d);
        for a = 1:length(ch)        
            if strcmp(get(ch(a),'Tag'),'TimePlotBar')
                c = get(ch(a),'Children');
                set(c,'UserData',[0.02,0.02,0.98*complete,0.98*complete]);
            end
            if strcmp(get(ch(a),'Tag'),'TimePlotText')
                if length( d ) >= 3
                    M = d(2:end,1) - complete;
                    T = d(2:end,2) - d(end,2);
                    W = exp( ((-length(T):-1)+1)/20 )';
                    A = (W.*M)\(W.*T);                    
                    est = (1-complete)*A*24*60*60;                    
                    
                    hr = fix(est/3600);
                    min = fix(mod(est,3600)/60);
                    sec = fix(mod(est,60));
                    if (hr ~=0)
                        timeleft = [num2str(hr) ':'];
                    else
                        timeleft = '';
                    end
                    if min < 10
                        timeleft = [timeleft '0' num2str(min) ':'];
                    else
                        timeleft = [timeleft num2str(min) ':'];
                    end
                    if sec < 10
                        timeleft = [timeleft '0' num2str(sec)];
                    else
                        timeleft = [timeleft num2str(sec)];
                    end
                    set(ch(a),'String',[num2str(complete*100) '% Completed       Time Remaining ' timeleft]);
                end
            end
        end
        drawnow;
    elseif complete == 1
        d = [d; complete, now_value-700000];
    end        
    if (complete==1)        
        M = [d(:,1) - d(1,1)];
        T = d(:,2) - d(1,2);
        A = M\T;
        est = d(1,1)*A;

        est = est + (now_value-700000) - d(1,2);
        est = est * 24 * 60 * 60;
        if (est < 0)
            est = 0;
        end
        hr = fix(est/3600);
        min = fix(mod(est,3600)/60);
        sec = fix(mod(est,60));
        if (hr ~=0)
            timeleft = [num2str(hr) ':'];
        else
            timeleft = '';
        end
        if min < 10
            timeleft = [timeleft '0' num2str(min) ':'];
        else
            timeleft = [timeleft num2str(min) ':'];
        end
        if sec < 10
            timeleft = [timeleft '0' num2str(sec)];
        else
            timeleft = [timeleft num2str(sec)];
        end
        disp( ['Time for process ' name ': ' timeleft] );
        close(plh);
        drawnow;
    end
end

if (~isempty(s))
    if (complete ~= 1) || ((complete==1) && (s~=plh))
        try
            set(0,'CurrentFigure',s);
        catch
        end
    end
end

if complete ~= 0 && complete ~= 1 
    last_call = cputime;
else
    last_call = [];
end
