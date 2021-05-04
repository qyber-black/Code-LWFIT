function [combi_smooth, combi] = CombineSpectra_RAW(data_in,N_fft,filter)
%
% function [combi_smooth, combi] = CombineSpectra_RAW(data_in,N_fft,filter)
% combines raw MegaPRESS data (data_in) to produce three combined spectra
% with a fourier resolution N_fft (default 4096).  Channels are aligned to
% the **2.01 ppm NAA peak** in the **difference** spectrum.  No other phase
% corrections are performed.  For the purpose of averaging the FIDs are
% assumed to be alternating EDIT ON, EDIT OFF.
%
% combi_smooth are the combined spectra with the filter (filter) applied.
% The default filter is hanning(2500) but any other filter can be used.
% combi is the combined spectra without any filter applied.
%
% INPUT:
% data_in:  structure which must contain a substructure spec with field
%           FT a 4D array containing the edit-on/edit-off raw spectra
% N_fft:    FFT resolution
% filter:   vector with filter function, default filder = hanning(2500)
%
% OUTPUT:
% combi_smooth:  structure containing combined spectra with filter applied
% combi:    structure containing combined edit-on/edit-off/diff spectra
%           without any filter applied
%
% This function has some peculiarities to keep it compatible with other
% routines, caution is advised.

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

if ~exist('N_fft','var')
    N_fft = 4096;
end
if ~exist('filter','var')
    filter = hanning(2500);
end

spec_in = data_in.spec;
% take mean over averages and difference between edit on/off spectra
FID   = diff(mean(spec_in.FID,3),[],4);
FT    = fftshift(fft(FID));
[a,b] = max(abs(FT));
phi   = arrayfun(@(n)exp(1i*phase(FT(b(n),n))),[1:4]);
f     = -spec_in.f;     % inversion of frequency axis
foff  = 2.01+f(b(1));

FT_ON  = mean(spec_in.FT(:,:,:,2),3)*(phi')*N_fft;
FT_OFF = mean(spec_in.FT(:,:,:,1),3)*(phi')*N_fft;

combi(1) = data_in;
combi(1).spec.f = f;
combi(1).spec.foff = foff;
combi(1).spec.FT  = FT_ON;
% conjugate required due to frequency axis inversion
combi(1).spec.FID = conj(ifft(ifftshift(combi(1).spec.FT)))*2^15;

combi(2) = data_in;
combi(2).spec.f = f;
combi(2).spec.foff = foff;
combi(2).spec.FT  = FT_OFF;
% conjugate required due to frequency axis inversion
combi(2).spec.FID = conj(ifft(ifftshift(combi(2).spec.FT)))*2^15;

combi(3) = data_in;
combi(3).spec.f = f;
combi(3).spec.foff = foff;
combi(3).spec.FID = combi(1).spec.FID-combi(2).spec.FID;
combi(3).spec.FT  = combi(1).spec.FT -combi(2).spec.FT;

for k=1:3
    combi_smooth(k) = combi(k);
    combi_smooth(k).spec = ApplyFilter(combi(k).spec,N_fft,filter);
end
