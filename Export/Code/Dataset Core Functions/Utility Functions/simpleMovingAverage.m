function [times, values] = simpleMovingAverage( times, values, n )

times = nPointMovingAverage( times, n );
values = nPointMovingAverage( values, n );