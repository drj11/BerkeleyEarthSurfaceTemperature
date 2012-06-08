function se = partialDecompress( se )
% Decompresses key fields in memory.  Can make for faster access at the
% expense of larger storage requierments.

se.data = expand( se.data );
se.dates = expand( se.dates );
