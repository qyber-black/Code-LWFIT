function prot = GetProtFromImageNew(SIEMENS)

% function res = GetProtFromImageNew(SIEMENS) extracts the sequence protocol
% from a Siemens IMA or DAT file.  It returns the full protocol in a basic
% and somewhat clumsy data structure prot.

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

% extract protocol from DICOM into asc file
[status,str] = system(sprintf('sed -n "/### ASCCONV BEGIN/,/### ASCCONV END ###/p" "%s" | sed -e "s,###.*###,,"',SIEMENS));
if status ~= 0 then
   error(sprintf("cannot prcoess file %s with sed",SIEMENS))
end
fs = textscan(str,'%s%s','Delimiter','=');
prot = struct;
for k = 1:numel(fs{1})
    f = matlab.lang.makeValidName(fs{1}{k});
    prot.(f) = fs{2}{k};
end
