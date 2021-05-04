function RewriteIMA(DIR)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

PWD = pwd; cd(DIR)
FILES = dir('*.IMA')
for k=1:length(FILES)
    %orig(k) = dicominfo(sprintf('%i.IMA',k));
    orig(k) = dicominfo(FILES(k).name);
    clean(k) = CleanHeader2(orig(k));
end
%delete('1.IMA'); delete('2.IMA'); delete('3.IMA'); delete('*.asc');
delete('*.IMA'); delete('*.asc');
if length(FILES)==3
    dicomwrite([],'MP_EDIT_ON.IMA',clean(1),'CreateMode','copy','WritePrivate',true);
    dicomwrite([],'MP_EDIT_OFF.IMA',clean(2),'CreateMode','copy','WritePrivate',true);
    dicomwrite([],'MP_EDIT_DIFF.IMA',clean(3),'CreateMode','copy','WritePrivate',true);
end

if isdir('WS_OFF')
    cd('WS_OFF');
    FILES = dir('*.IMA');
    if length(FILES)==3
        for k=1:3
            orig_ws(k) = dicominfo(FILES(k).name);
            clean_ws(k) = CleanHeader2(orig_ws(k));
        end
        delete('*.IMA'); delete('*.asc');
        dicomwrite([],'MP_EDIT_ON.IMA',clean_ws(1),'CreateMode','copy','WritePrivate',true)
        dicomwrite([],'MP_EDIT_OFF.IMA',clean_ws(2),'CreateMode','copy','WritePrivate',true)
        dicomwrite([],'MP_EDIT_DIFF.IMA',clean_ws(3),'CreateMode','copy','WritePrivate',true)
    else
        orig_ws  = dicominfo(FILES(1).name);
        clean_ws = CleanHeader2(orig_ws);
        clean_ws.ProtocolName = 'svs_se';
        delete('*.IMA'); delete('*.asc');
        dicomwrite([],'SE_WS_OFF.IMA',clean_ws(1),'CreateMode','copy','WritePrivate',true)
    end
end
cd(PWD)
