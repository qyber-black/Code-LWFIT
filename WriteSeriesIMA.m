function WriteSeriesIMA(data,Info,DIR,DOWNSAMPLE)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

K = length(data);
FNAME = {'MP_EDIT_ON','MP_EDIT_OFF','MP_EDIT_DIFF'}

for k=1:K
    if ~exist(DIR(k).name)
        mkdir(DIR(k).name);
    end
    cd(DIR(k).name);
    for n=1:3
        if DOWNSAMPLE
           WriteSpecIMA(data{k}(n).spec.FID(1:2:end),Info{k}(n).info,FNAME{n});
        else
           WriteSpecIMA(data{k}(n).spec.FID,Info{k}(n).info,FNAME{n});
        end
    end
    cd ..
end
