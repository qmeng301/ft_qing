function [curv] = read_SUMA_curvature(fname)
%
% reads a SUMA ld10 curvature into a vector
%

fid = fopen(fname, 'r') ;
nvertices = 1002;
curv = textscan(fid, '%f\n', nvertices, 'headerlines', 12) ;

