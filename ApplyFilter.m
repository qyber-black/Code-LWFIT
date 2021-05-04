function filtered = ApplyFilter(data,fft_res,h)

% FUNCTION filtered = ApplyFilter(data,fft_res,h)
% applies a filter to the time-domain signal
%
% INPUT
% data:     structure with fields
%           t   -- vector containing time samples
%           FID -- vector containing time-domain signal
% fft_res:  desired FFT resolution
% h:        filter function, e.g., hamming filter
%           h = Hamming(1000), Hanning(1000) etc
% OUTPUT:   filtered spectrum, structure with fields
% t         vector containing time samples (identical to input)
% FID       vector containing filtered time-domain signal
% f         vector containing frequencies
% FT        vector containing frequency-domain signal (spectrum)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

L = size(data.FID,2);
N = length(h);
g = zeros(size(data.FID));
g(1:ceil(N/2),:) = h(floor(N/2)+1:N)*ones(1,L);

filtered = data;
filtered.FID = g.*data.FID;
filtered = GetSpectra(filtered,fft_res);
