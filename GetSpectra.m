function spec = GetSpectra(spec,N_fft)

% function out = GetSpectra(spec,fft_res)
%
% INPUT
% spec: structure created by ReadSpectIMA, ReadDPT, ReadRDA, etc with fields
%       Number_of_points:       number of samples per FID
%       Sampling_frequency:     sampling frequency per FID
%       Transmitter_frequency:  transmitter frequency
%       FID:                    FID matrix (averages & channels combined)
%       N:                      Number of points for FFT (optional)
%
% OUTPUT
% data: input structure with added/recomputed fields
%       f:      frequency sampling vector
%       FT:     fourier transform of FID data
%

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

scaling = spec.Sampling_frequency/spec.Transmitter_frequency * 1e6;
if ~exist('N_fft','var')
    N_fft = 2^nextpow2(spec.Number_of_points);
end
% frequency in ppm (not shifted)
spec.f  = -([1:N_fft]-N_fft/2)/N_fft * scaling;

% fourier transform in dimension 1, shifted in dimention 1 only
spec.FT  = fftshift(fft(spec.FID,N_fft));
