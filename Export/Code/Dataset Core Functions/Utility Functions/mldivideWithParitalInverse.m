function X = mldivideWithParitalInverse( M, T, f, Ai )
% X = mldivideWithParitalInverse( M, T, indices, Ai )
%
% Computes X = M \ T where M is square and M( indices, indices )^-1 = Ai
%
% This function can be very efficient if the partial matrix comprises most
% of M;

%T = full(T);

sz = size(M);
if sz(1) ~= sz(2)
    error( 'Requires that M be square' );
end

if ~islogical(f)
    t = false( sz(1), 1 );
    t(f) = true;
    f = t;
end

if all(f) 
    X = Ai*T;
    return;
end

if ~any(f)
    X = M \ T;
    return;
end

B = M( f, ~f );
C = M( ~f, f );
D = M( ~f, ~f );

T1 = T(f,:);
T2 = T(~f,:);

Y = Ai*T1;

X2 = (D - C*Ai*B)\(T2 - C*Y);

szA = size(Ai);
sz2 = size(X2);

if szA(1) > sz2(2)
    X1 = Y - Ai*(B*X2);
else
    X1 = Y - (Ai*B)*X2;
end    

szM = size(M);
szT = size(T);

X = zeros(szM(1), szT(2));
X(f,:) = X1;
X(~f,:) = X2;