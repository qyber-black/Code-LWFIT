function [combi_smooth, combi] = CombineSpectra_RAW_EJA(data_in,N_fft,filter)

% function [combi_smooth,combi] = CombineSpectra_RAW_EJA(data_in,N_fft,filter)
% is version of CombineSpectra_RAW modified to work with raw data generated
% by the EJA MEGAPRESS sequence
%
% WORK IN PROGRESS

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

if ~exist('N_fft','var')
    N_fft = 4096;
end
if ~exist('filter','var')
    filter = hanning(2500);
end

spec_in = data_in.spec;
% take mean over averages and difference between edit on/off spectra
tmp = squeeze(twix_obj{2}.image());
phs = (twix_obj{2}.phasecor())

FID_ON  = sum(conj(phs).*mean(tmp(:,:,2,:),4),2);
FID_OFF = sum(conj(phs).*mean(tmp(:,:,1,:),4),2);
f       = -spec_in.f;     % inversion of frequency axis

combi(1) = data_in;
combi(1).spec.FID = FID_ON;
combi(1).spec.f   = f;
combi(1).spec.FT  = fftshift(fft(FID_ON))*N_fft;

combi(2) = data_in;
combi(2).spec.f   = f;
combi(2).spec.FT  = FT_OFF;
combi(1).spec.FT  = fftshift(fft(FID_OFF))*N_fft;

combi(3) = data_in;
combi(3).spec.f = f;
combi(3).spec.FID = combi(1).spec.FID-combi(2).spec.FID;
combi(3).spec.FT  = combi(1).spec.FT -combi(2).spec.FT;

for k=1:3
    combi_smooth(k) = combi(k);
    combi_smooth(k).spec = ApplyFilter(combi(k).spec,N_fft,filter);
end
