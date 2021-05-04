function RewriteIMA_single(DIR)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

PWD = pwd; cd(DIR);
IMA = dir('*.IMA'); delete('*.asc');
for k=1:length(IMA)
    orig(k) = dicominfo(IMA(k).name);
    clean(k) = CleanHeader2(orig(k));
    delete(IMA(k).name);
    dicomwrite([],sprintf('%04.0f.IMA',k),clean(k),'CreateMode','copy','WritePrivate',true);
end

% only use this for S4
%for k=1:160
%    dicomwrite([],sprintf('%04.0f.IMA',2*k-1),clean(k),'CreateMode','copy','WritePrivate',true);
%    dicomwrite([],sprintf('%04.0f.IMA',2*k),clean(k+160),'CreateMode','copy','WritePrivate',true);
%end
cd(PWD)
