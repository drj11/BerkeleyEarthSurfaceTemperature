function timePlot2(name, complete)
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

persistent last_call

if ~isempty( last_call ) 
    if (cputime - last_call) < 0.5 && complete ~= 0 && complete ~= 1
        return;
    end
end
now_value = now;

if (complete < 0) || (complete > 1)
    error('Not acceptable completion 0-1');
end

persistent time_plot_data;

plh = 0;
for a = 1:length(time_plot_data);
    if (strcmp(time_plot_data(a).name,['Time Remaining on ' name]))
        plh = a;
    end
end

if (complete == 0)
    if (plh~=0)
        time_plot_data(a) = [];
    end
    plh = 0;
end

if plh == 0 && complete == 1
    return;
end

if (plh == 0)
    plh = length(time_plot_data) + 1;
    time_plot_data(plh).name = ['Time Remaining on ' name];
    time_plot_data(plh).data = [complete, now_value-700000];
    time_plot_data(plh).last_print = -Inf;
else
    d = time_plot_data(plh).data;
    if complete < 1 && (now_value-700000) - d(end,2) >= 0.5/(24*60*60) 
        % Minimum delay of 0.5 second for change.
        d = [d; complete, now_value-700000];        

        time_plot_data(plh).data = d;
        if length( d ) >= 3 && ...
                complete > time_plot_data(plh).last_print + 0.02
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
            disp( ['Process "' name '": ' sprintf('%0.1f',complete*100) '% Completed (' timeleft ' Remaining)'] );
            time_plot_data(plh).last_print = complete;
        end
        drawnow;
    elseif complete == 1
        d = [d; complete, now_value-700000];
    end        
    if (complete==1) && length(d(:,1)) > 2       
        M = d(:,1) - d(1,1);
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
        
        time_plot_data(plh) = [];
        drawnow;
    end
end

if complete ~= 0 && complete ~= 1 
    last_call = cputime;
else
    last_call = [];
end
