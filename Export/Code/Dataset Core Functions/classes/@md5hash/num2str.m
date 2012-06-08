function hash = num2str( md5 )
% Alternative acccessor for retrieving text hash

hash = subsref(md5, substruct('()',{':'}, '.', 'hash'));

