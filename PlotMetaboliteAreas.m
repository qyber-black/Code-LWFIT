function out = PlotMetaboliteAreas(MPFit,conc,TITLE,EditEfficiencyGABA,outliers)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

STYLE = {'o','s','>','<'};
COLOR = [0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880];
if ~exist('outliers','var')
    outliers = [];
end
ind = setdiff([1:length(MPFit)],outliers);

area.NAA  = cellfun(@(x)-x.NAA.area_t,MPFit);
area.CRE  = cellfun(@(x) x.CRE.area_t,MPFit);
area.GLX1 = cellfun(@(x) x.GLX1.area_t,MPFit);
area.GLX2 = cellfun(@(x) x.GLX2.area_t,MPFit);
area.GABA = cellfun(@(x) x.GABA.area_t,MPFit)/EditEfficiencyGABA;

ind2 = setdiff(ind,find(conc.CRE==0));

[Fit.NAA,GOF.NAA]   = fit(ind',area.NAA(ind)',  'a*x+b','StartPoint',[1 0]);
[Fit.CRE,GOF.CRE]   = fit(ind2',area.CRE(ind2)','a*x+b','StartPoint',[1 0]);
[Fit.GLX1,GOF.GLX1] = fit(ind',area.GLX1(ind)', 'a*x+b','StartPoint',[1 0]);
[Fit.GLX2,GOF.GLX2] = fit(ind',area.GLX2(ind)', 'a*x+b','StartPoint',[1 0]);
[Fit.GABA,GOF.GABA] = fit(conc.GABA(ind)',area.GABA(ind)','a*x+b','StartPoint',[1 0]);
[Fit.GABA_NAA,GOF.GABA_NAA] = fit((conc.GABA(ind)./conc.NAA(ind))',1.5*(area.GABA(ind)./area.NAA(ind))','a*x+b','StartPoint',[1 0]);

out.Area = area;
out.Fit = Fit;
out.GoF = GOF;
out.mean.NAA = mean(area.NAA(ind));
out.mean.CRE = mean(area.CRE(conc.CRE(ind)>0));
out.CRE_NAA  = 100*out.mean.CRE/out.mean.NAA;

figure('position', [500 500 480 768]);

subplot('position',[0.15 0.7 0.8 0.26])
plot(ind,area.NAA(ind),STYLE{1},'Color',COLOR(1,:), 'MarkerFaceColor',COLOR(1,:)), hold on
plot(ind,area.CRE(ind),STYLE{2},'Color',COLOR(2,:), 'MarkerFaceColor',COLOR(2,:))
plot(ind,area.GLX1(ind),STYLE{3},'Color',COLOR(3,:), 'MarkerFaceColor',COLOR(3,:))
plot(ind,area.GLX2(ind),STYLE{4},'Color',COLOR(4,:), 'MarkerFaceColor',COLOR(4,:))

ind1 = [1:length(MPFit)];
plot(ind1,Fit.NAA(ind1),'--','Color',COLOR(1,:))
plot(ind1,Fit.CRE(ind1),'--','Color',COLOR(2,:))
plot(ind1,Fit.GLX1(ind1),'--','Color',COLOR(3,:))
plot(ind1,Fit.GLX2(ind1),'--','Color',COLOR(4,:))

if ~isempty(outliers)
    plot(outliers,area.NAA(outliers),STYLE{1},'Color',COLOR(1,:)), hold on
    plot(outliers,area.CRE(outliers),STYLE{2},'Color',COLOR(2,:))
    plot(outliers,area.GLX1(outliers),STYLE{3},'Color',COLOR(3,:))
    plot(outliers,area.GLX2(outliers),STYLE{4},'Color',COLOR(4,:))
end

xlabel('scan number'), ylabel('peak areas (arb. units)'), grid on
legend({'NAA','CRE','GLX1','GLX2'},'Location','best'), title(TITLE)
xlim([1 length(MPFit)])

subplot('position',[0.15 0.38 0.8 0.26])
plot(conc.GABA(ind),area.GABA(ind),'p','Color',COLOR(5,:), 'MarkerFaceColor',COLOR(5,:)), hold on
plot(conc.GABA(ind1),Fit.GABA(conc.GABA(ind1)),'--','Color',COLOR(5,:))
if ~isempty(outliers)
    plot(conc.GABA(outliers),area.GABA(outliers),'p','Color',COLOR(5,:))
end
xlabel('conc. GABA (mM)'), ylabel('peak areas (arb. units)'), grid on
legend({'GABA',sprintf('y = %0.2f c %+0.2f\nR^2 = %0.3f', Fit.GABA.a,Fit.GABA.b,GOF.GABA.rsquare)},'Location','best')

subplot('position',[0.15 0.06 0.8 0.26])
if length(conc.NAA)==1
    conc.NAA = ones(size(conc.GABA))*conc.NAA;
end
plot(conc.GABA(ind)./conc.NAA(ind),1.5*area.GABA(ind)./area.NAA(ind),'p','Color',COLOR(5,:), 'MarkerFaceColor',COLOR(5,:)), hold on
plot(conc.GABA(ind1)./conc.NAA(ind1),Fit.GABA_NAA(conc.GABA(ind1)./conc.NAA),'--','Color',COLOR(5,:))
if ~isempty(outliers)
    plot(conc.GABA(outliers)./conc.NAA(outliers),1.5*area.GABA(outliers)./area.NAA(outliers),'p','Color',COLOR(5,:))
end
xlabel('conc. GABA/NAA'), ylabel('ratio of peak areas x 1.5'), grid on
legend({'GABA/NAA',sprintf('y = %0.2f c %+0.2f\nR^2 = %0.3f', Fit.GABA_NAA.a,Fit.GABA_NAA.b,GOF.GABA_NAA.rsquare)},'Location','best')
