function out = FitPeaks(WS_ON,TITLE)

% function out = FitPeaks(WS_ON) fits water peak for water suppressed
% spectra only.  Also fit NAA peak in edit-off MP spectrum using FitLorentz.

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

for k=1:length(WS_ON)
    WS_ON(k).spec = GetSpectra(WS_ON(k).spec, 2^14);
end

Figs = 2;  XLIM1 = [-0.45 0.45];  XLIM2 = [-5 0.2];

F1 = figure('position',[0 2000 500 800]);

subplot('position',[0.15 0.55 0.8 0.4]);
    [out.fitH20{2},out.gofH20{2},out.ErrH20{2}] = FitLorentz(WS_ON(1).spec.f, abs(WS_ON(1).spec.FT), -0.5,0.5,'r','northwest');
    grid on, xlim(XLIM1), set(gca,'XTickLabel','')
    ylabel('WS ON EDIT ON (abs)'), xlabel('')

subplot('position',[0.15 0.1 0.8 0.4]);
    [out.fitH20{3},out.gofH20{3},out.ErrH20{3}] = FitLorentz(WS_ON(2).spec.f, abs(WS_ON(2).spec.FT), -0.5,0.5,'r','northwest');
    grid on, xlim(XLIM1)
    ylabel('WS ON EDIT OFF (abs)')

F2 = figure('position',[500 2000 500 800]);
subplot('position',[0.15 0.7 0.8 0.25]);
    [out.fitDSS,out.gofDSS,out.ErrDSS] = FitLorentz(WS_ON(1).spec.f, real(WS_ON(1).spec.FT), -5,-4.6,'r','northeast');
    grid on, xlim(XLIM2),set(gca,'XTickLabel','')
    ylabel('WS ON EDIT ON (real)'), xlabel('')
    if exist('TITLE','var'), title(TITLE); end

subplot('position',[0.15 0.4 0.8 0.25]);
    [out.fitNAA{1},out.gofNAA{1},out.ErrNAA{1}] = FitLorentz(WS_ON(2).spec.f, real(WS_ON(2).spec.FT), -3,-2.5,'r','northeast');
    grid on, xlim(XLIM2), set(gca,'XTickLabel','')
    ylabel('WS ON EDIT OFF (real)'), xlabel('')

subplot('position',[0.15 0.1 0.8 0.25]);
    [out.fitNAA{2},out.gofNAA{2},out.ErrNAA{2}] = FitLorentz(WS_ON(3).spec.f, real(WS_ON(3).spec.FT), -3,-2.5,'r','southwest');
    grid on, xlim(XLIM2),
    ylabel('WS ON DIFF (real)')

if exist('TITLE','var')
    saveas(F1, sprintf('PeakFit1-%s',TITLE),'fig')
    saveas(F1, sprintf('PeakFit1-%s',TITLE),'png')
    saveas(F2, sprintf('PeakFit2-%s',TITLE),'fig')
    saveas(F2, sprintf('PeakFit2-%s',TITLE),'png')
end
