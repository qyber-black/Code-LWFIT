function out = Endian2Complex(DATA)

% function out = Endian2Complex(DATA) converts Siemens FIDs from little
% endian to complex


% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

N1 = length(DATA);
if mod(N1,4) ~= 0
    error('length of input vector not multiple of 4');
end
N = N1/4;

out = arrayfun(@(n)typecast(uint8(DATA(n:n+3)), 'single'),[1:4:N1]);

if mod(N,2)==0
    out = out(1:2:end)+1i*out(2:2:end);
end
