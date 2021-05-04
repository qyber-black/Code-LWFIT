function out = ReadSpectRaw(DATFILE,N_fft)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

twix_obj = ReadDAT(DATFILE);

prot = GetProtFromImageNew(DATFILE);
NCol = twix_obj{2}.image.NCol;
NCha = twix_obj{2}.image.NCha;
NLin = twix_obj{2}.image.NLin;
NPhs = twix_obj{2}.image.NPhs;
NAve = twix_obj{2}.image.NSet;
%dims = twix_obj{2}.image.dataSize;
%list = twix_obj{2}.image.dataDims;
%dim1 = strmatch('Lin',list);
%dim2 = strmatch('Phs',list);

transmit_freq = str2num(prot.sTXSPEC_asNucleusInfo_0__lFrequency);
sampling_freq = 1e9/str2num(prot.sRXSPEC_alDwellTime_0_);

out.prot = prot;
out.spec.Slices = 1;
out.spec.Number_of_points = NCol;
out.spec.Transmitter_frequency = transmit_freq;
out.spec.Sampling_frequency = sampling_freq;
out.spec.TE = prot.alTE_0_;
out.spec.t = [1:NCol]/sampling_freq;
if ~exist('N_fft','var')
    N_fft = 2^nextpow2(NCol);
end
% frequency in ppm (not shifted)
out.spec.f  = ([1:N_fft]-N_fft/2)/N_fft * sampling_freq*1e6/transmit_freq;
out.spec.FID = double(squeeze(twix_obj{2}.image()));
out.spec.FT  = fftshift(fft(out.spec.FID,N_fft));

keyboard
