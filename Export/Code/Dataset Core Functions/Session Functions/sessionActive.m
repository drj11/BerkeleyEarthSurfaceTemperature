function result = sessionActive()
% Returns true is a session is ongoing, false otherwise.

sessionParallelCheck;

global SESSION_DATA

result = ~isempty( SESSION_DATA );