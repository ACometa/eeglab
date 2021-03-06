function [Z]=rrdivide(X,Y)
% function [Z]=rrdivide(X,Y)
% 
% Replicating division X by Y
%
% Does element by element operations on X and Y where non-same sized
% dimensions are implicity wrapped round to match the size of the larger
% to give a result matrix Z with size max(size(X),size(Y));
%
% In this case returns double array with X/Y 
%
% See also repops, rdivide, ldivide
%
% Copyright 2006- by Jason D.R. Farquhar (jdrf@zepler.org)
% Inspired by code by Douglas M. Schwarz & Aki Vehtari.
Z=repop(X,'./',Y);
