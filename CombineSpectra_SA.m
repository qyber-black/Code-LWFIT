function [combi_smooth, combi] = CombineSpectra_SA(data_SA,N_fft,filter)
%
% function [combi_smooth, combi] = CombineSpectra_SA(data_SA,N_fft,filter)
% combines a series of single average MegaPRESS spectra to produce combined
% spectra with a fourier resolution N_fft (default 4096).  The FIDs are
% assumed to be alternating EDIT ON, EDIT OFF.
% combi_smooth are the combined spectra with the filter (filter) applied.
% The default filter is hanning(2500) but any other filter can be used.
% combi is the combined spectra without any filter applied.
%
% INPUT:
% data_SA:  structure which must contain a substructure spec with field
%           FT a 2D array containing the edit-on/edit-off single spectra
%           as obtained from Siemens IMA files, odd columns: edit on,
%           even columns: edit off
% N_fft:    FFT resolution (default 4096)
% filter:   vector with filter function, default filder = hanning(2500)
%           default: hanning(2500)
%
% OUTPUT:
% combi_smooth:  structure containing combined spectra with filter applied
% combi:    structure containing combined edit-on/edit-off/diff spectra
%           without any filter applied

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

if ~exist('N_fft','var')
    N_fft = 2048*2;
end
if ~exist('filter','var')
    filter = hanning(2500);
end

% generate EDIT ON, EDIT OFF and DIFF Spectra
for n=1:3
    combi(n).info = data_SA.info;
    combi(n).prot = data_SA.prot;
    combi(n).spec = data_SA.spec;
end

combi(1).spec.FID = mean(data_SA.spec.FID(:,1:2:end),2);
combi(2).spec.FID = mean(data_SA.spec.FID(:,2:2:end),2);
combi(3).spec.FID = combi(1).spec.FID-combi(2).spec.FID;

for n=1:3
    combi(n).spec = GetSpectra(combi(n).spec,N_fft);
end

for n=1:3
    combi_smooth(n) = combi(n);
    combi_smooth(n).spec = ApplyFilter(combi(n).spec,N_fft,filter);
end
