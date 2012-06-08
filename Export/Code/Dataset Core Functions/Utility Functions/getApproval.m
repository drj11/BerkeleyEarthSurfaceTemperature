function tf = getApproval( question )
% Asks the user a yes or no question

tf = '';
while( ~strcmp(tf, 'y') && ~strcmp(tf, 'n') )
    tf = lower(input( [question ' (y/n)? '], 's' ));
end

disp( ' ' );
disp( '----' );
disp( ' ' );
