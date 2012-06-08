function [times, values] = simpleAnnualMovingAverage( times, values )

[times, values] = simpleMovingAverage( times, values, 12 );