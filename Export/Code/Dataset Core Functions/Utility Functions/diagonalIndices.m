function I = diagonalIndices( sz )
% I = diagonalIndices( N )
% List of the indices to the diagonal elements of a N x N matrix;

I = (0:sz-1)*sz + (1:sz);
