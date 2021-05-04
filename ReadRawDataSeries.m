function [WS_ON_RAW,WS_OFF_RAW] = ReadRawDataSeries(TOPDIR,WS_ON,WS_OFF)

% [WS_ON_RAW,WS_OFF_RAW] = ReadRawDataSeries(TOPDIR,WS_ON,WS_OFF)
% INPUT:
% TOPDIR        -- top level directory in which the raw data files reside
% WS_ON, WS_OFF -- vectors of measurement IDs of data to be read
% The top directory will be scanned for all subdirectories
% OUTPUT: WS_ON, WS_OFF list of water supressed and unsuppressed spectra

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

PWD = pwd; cd(TOPDIR);
DIR = dir('G*');
for k=1:length(DIR)
    cd(DIR(k).name);
    FILE1 = dir(sprintf('meas*%i_FID*.dat',WS_ON(k)));
    if ~isempty(FILE1)
        WS_ON_RAW{k}  = ReadSpectRaw(FILE1.name);
    end
    if exist('WS_OFF','var')
      FILE2 = dir(sprintf('meas*%i_FID*.dat',WS_OFF(k)));
      if ~isempty(FILE2)
        WS_OFF_RAW{k} = ReadSpectRaw(FILE2.name);
      end
    else
        WS_OFF = [];
    end
    cd ..
end
cd(PWD)
