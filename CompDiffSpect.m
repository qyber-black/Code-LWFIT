function MP_out = CompDiffSpect(MP_in)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

MP_out(1) = MP_in(2);
MP_out(2) = MP_in(1);
MP_out(3) = MP_in(1);
MP_out(3).spec.FID = MP_out(1).spec.FID - MP_out(2).spec.FID;
MP_out(3).spec.FT  = MP_out(1).spec.FT  - MP_out(2).spec.FT;
