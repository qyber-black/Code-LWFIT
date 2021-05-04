function out = ReadSpectIMA_SA(DIR)
%
% function out = ReadSpectIMA_SA(DIR,N_fft) reads all the IMA files in
% directory DIR assuming they are single averages acquired with the
% same protocol.  It returns a data structure out with fields info
% containing the dicominfo, prot containing the Siemens protocol and
% spec containing the FIDs.

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

HOME = pwd; cd(DIR);
FILE = dir('*.IMA');

% get dicom info and protocol from 1st file
out.info = dicominfo(FILE(1).name);
out.prot = GetProtFromImageNew(FILE(1).name);

% create substructure spec containing some basis info (transmitter
% and sampling frequency, number of points, echo time,

out.spec.Transmitter_frequency = str2num(out.prot.sTXSPEC_asNucleusInfo_0__lFrequency);
out.spec.Sampling_frequency = 1e9/(2*str2num(out.prot.sRXSPEC_alDwellTime_0_));
out.spec.TE = str2num(out.prot.alTE_0_);
Nt = length(out.info(1).Private_7fe1_1010)/8;
out.spec.Number_of_points = Nt;

% a time vector t and a matrix FID whose columns are single FIDs
out.spec.t = [1:Nt]/(out.spec.Sampling_frequency);
for k=1:length(FILE)
    Info = dicominfo(FILE(k).name);
    out.spec.FID(:,k) = double(Endian2Complex(Info.Private_7fe1_1010)).';
end
cd(HOME)
