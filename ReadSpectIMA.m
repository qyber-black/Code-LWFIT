function out = ReadSpectIMA(DIR,MP,OF,N_fft)

% function out = ReadSpectIMA(DIR,MP,N_fft) reads spectra in IMA
% format in diretory DIR.  If MP~=0, it is assumed that there are
% 3 spectra MP_EDIT_ON.IMA, MP_EDIT_OFF.IMA and MP_EDIT_DIFF.IMA
% otherwise the routine simply reads all .IMA files it finds.
% OF is an optional oversampling factor (default OS=2).  Set to 1
% for no oversampling.
% N_fft is an optional argument specifying the fourier resolution
% (default N_fft=2048).
%

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

if ~exist('OF','var')
    % Siemens spectra are oversampled by factor of 2 by default
    OF = 2;
end

if ~exist('N_fft','var')
    N_fft = 2048;
end

HOME = pwd; cd(DIR);
if MP % Assume megapress
    FILE(1) = dir('MP_EDIT_ON.IMA');
    FILE(2) = dir('MP_EDIT_OFF.IMA');
    FILE(3) = dir('MP_EDIT_DIFF.IMA');
else
    FILE = dir('*.IMA');
end
for k=1:length(FILE)
    out(k).info = dicominfo(FILE(k).name);
    out(k).prot = GetProtFromImageNew(FILE(k).name);

    out(k).spec.Number_of_points = length(out(k).info.Private_7fe1_1010)/8;
    out(k).spec.Transmitter_frequency = str2num(out(k).prot.sTXSPEC_asNucleusInfo_0__lFrequency);
    out(k).spec.Sampling_frequency = 1e9/(OF*str2num(out(k).prot.sRXSPEC_alDwellTime_0_));
    out(k).spec.TE = out(k).prot.alTE_0_;

    Nt = out(k).spec.Number_of_points;
    out(k).spec.t = [1:Nt]/(out(k).spec.Sampling_frequency);
    out(k).spec.FID = double(Endian2Complex(out(k).info.Private_7fe1_1010)).';
    out(k).spec = GetSpectra(out(k).spec,N_fft);
end
cd(HOME)
end
