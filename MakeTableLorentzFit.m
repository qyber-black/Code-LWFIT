function MakeTableLorentzFit(LFit)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

% frequency offsets in ppm
Freq = [cell2mat(cellfun(@(y)cellfun(@(x)x.f0,y.fitH20),LFit,'UniformOutput',false)'), cellfun(@(x)x.fitNAA.f0,LFit)', 2.01-cellfun(@(x)x.fitNAA.f0, LFit)']

% Linewidth in Hz
LWidth = [cell2mat(cellfun(@(y)cellfun(@(x)x.c*2*123.2, y.fitH20), LFit,'UniformOutput',false)'), cellfun(@(x)x.fitNAA.c*123.2*2, LFit)']

% Amplitude
Ampl1 = cell2mat(cellfun(@(y)cellfun(@(x)x.a, y.fitH20), LFit,'UniformOutput',false)');
Ampl1 = [Ampl1 Ampl1(:,1)./Ampl1(:,3)];
Ampl1 = round([Ampl1 cellfun(@(x)x.fitNAA.a, LFit)'])

% Vert Offset (baseline)
Voff = [cell2mat(cellfun(@(y)cellfun(@(x)x.d/x.a, y.fitH20), LFit,'UniformOutput',false)'), cellfun(@(x)x.fitNAA.d/x.fitNAA.a, LFit)']

% Goodness of Fit (rsquare)
Rsqr = [cell2mat(cellfun(@(y)cellfun(@(x)x.rsquare, y.gofH20), LFit,'UniformOutput',false)'), cellfun(@(x)x.gofNAA.rsquare, LFit)']
