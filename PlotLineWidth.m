function M = PlotLineWidthAll(PeakFit)

% function M = PlotLineWidthAll(PeakFit) plots output PeakFit created
% by FitPeaks or FitPeaks_WS_ON.

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

M1 = cell2mat(arrayfun(@(n)cellfun(@(x)x.c*123.2*2,PeakFit{n}.fitH20),[1:length(PeakFit)],'UniformOutput',false)');
M2 = cell2mat(arrayfun(@(n)cellfun(@(x)x.c*123.2*2,PeakFit{n}.fitNAA),[1:length(PeakFit)],'UniformOutput',false)');
M = [M1 M2]; [rows,cols] = size(M);
STYLE = {'-+','-x','->','-^','s-','-o'};
for k=[1:3,5,6]
    H = plot([1:rows],M(:,k),STYLE{k}), hold on
end
set(H,'Linewidth',2);
xlabel('scan no'), ylabel('Linewidth (Hz)'), grid on
legend('H_2O WS OFF','H_2O EDIT ON','H_2O EDIT OFF','NAA EDIT OFF','NAA DIFF')
