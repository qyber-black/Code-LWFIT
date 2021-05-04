function WriteSpec(Spec,Info,fname)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

SpecI = zeros(1,2*length(Spec));
SpecI(1:2:end) = real(Spec); SpecI(2:2:end) = imag(Spec);
Info.Private_7fe1_1010 = typecast(single(SpecI),'uint8');
dicomwrite([],sprintf('%s.IMA',fname),Info,'CreateMode','copy','WritePrivate',true)
