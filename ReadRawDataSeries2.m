function WS_ON_RAW = ReadRawDataSeries2(TOPDIR,WS_ON)

% [WS_ON_RAW,WS_OFF_RAW] = ReadRawDataSeries(TOPDIR,WS_ON)
% INPUT:
% TOPDIR  -- top level directory in which the raw data files reside
% WS_ON   -- vector of measurement IDs of data to be read
% The top directory will be scanned for all subdirectories
% OUTPUT: WS_ON list of water supressed spectra

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

PWD = pwd; cd(TOPDIR);
for k=1:length(WS_ON)
    FILE1 = dir(sprintf('meas*%i_FID*.dat',WS_ON(k)));
    if ~isempty(FILE1)
        WS_ON_RAW{k}  = ReadSpectRaw(FILE1.name);
    end
end
cd(PWD)
