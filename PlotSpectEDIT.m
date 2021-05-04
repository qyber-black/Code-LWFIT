function result = PlotSpectEDIT(data,N_fft,offset)

% function result = PlotSpectEDIT(data,N_fft,offset) is the main routine
% It plots the edit on, edit off and difference spectra defined in data,
% and a close up of the 3.01 ppm GABA peak.
%
% The routine attempts to align the spectra to the 2.01 ppm NAA peak.
% Minimal vertical baseline adjustment is done by subtracting the mean of
% the real part of the spectrum for frequencies >1 ppm when the water peak
% is at 0 ppm.  If there are signals upfield of of the water signal, e.g.,
% when reference compounds are added then the noise index range needs to
% be adjusted.  In this case it is best to specify offsets manually.
%
% The routine calculates various peak areas using numerical integration.
% Spline fits for 3.01 ppm GABA and Lorentz fits for 2.01 ppm NAA peak are
% also performed but we found that restricting the shape of the peaks
% generally decreased the quantification accuracy, and given sufficiently
% high frequency resolution, performing spline fits and calculating the
% areas of the fitted peaks seems to offer little advantage.

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie G Shermer, Swansea University

% Peak integration ranges -- adjust these as necessary

if ~exist('offset','var')
   ppm_NOISE = [1 inf];
else
    switch length(offset)
       case 1
       xoffset = offset;
       ppm_NOISE = [1 inf];
       case 2
       ppm_NOISE = [offset(1) offset(2)];
       case 3
       xoffset = offset(1);
       ppm_NOISE = [offset(2) offset(3)];
       case 4
       xoffset = offset(1);
       yoffset = offset(2:4);
    end
end

ppm_GABA  = [2.9 3.12];
ppm_NAA   = [1.91 2.11];
ppm_GLX1  = [2.25 2.45];
ppm_GLX2  = [3.65 3.85];
ppm_CRE   = [2.9 3.1];
% ppm_CRE = [2.95 3.05];  % reduced range to avoid overlap with 2.8 ppm NAA doublet in E2

% default frequency resolution 4096 points
if ~exist('N_fft','var')
    N_fft = 2048*2;
end

% resample spectra at desired resolution
for n=1:3
    out(n) = GetSpectra(data(n).spec,N_fft);
    FT{n}  = real(out(n).FT);
end
f = out(1).f;  i_noise = find( (f>ppm_NOISE(1)) & (f<=ppm_NOISE(2)));

% determine frequency offset to align spectra to 2.01 NAA peak
if ~exist('xoffset','var')
    [a,b] = max(abs(FT{3}));
    xoffset = 2.01-f(b);
    if xoffset<4
        warning('alignment failed')
        result.warning1 = 'alignment failed';
        xoffset = 4.8;
    end
end
% determine y-offsets by subtracting signal average over noise range
if ~exist('yoffset','var')
    yoffset = cellfun(@(x)-mean(x(i_noise)),FT);
end

% Siemens' MEGAPRESS implementation has a problem with inverted difference
% spectra.  The largest peak in the difference spectrum which determines
% max(abs(FT)) should be the NAA peak and it should be negative. If it is
% positive then something has gone wrong;  The routine will attempt to fix
% this by inverting the difference spectrum but additional manual checks
% on the spectra should be performed in this case.

if real(out(3).FT(b))>0
    warning('spectra inverted')
    result.warning2 = 'spectra inverted';
    for n=1:3
        FT{n}  = -real(out(n).FT);
    end
end

% extract frequency and spectra
f  = f + xoffset;
FT = arrayfun(@(n)FT{n}+yoffset(n),[1:3],'UniformOutput',false);

% Set up figure and plot spectra
figure('position', [339.0000  743.0000  480.0000  768.0000]);
%figure('position', [339.0000  743.0000  750.0000  1200.0000]);
LEGEND = {'edit on','edit off','difference','difference'};
for n=1:3
    Max     = ceil(max(FT{n}));
    Min     = floor(min(FT{n}));
    PLOT(n) = subplot('position',[0.15 1-n*0.23 0.82 0.20]); hold on, box on
    PlotSpectrum(f,FT{n},'b',[1 5],[Min Max]);
    %set(gca,'XtickLabel',''),
    xlabel(''), ylabel('Re(fft)'), legend(LEGEND{n},'Location','Best')
end
PLOT(4) = subplot('position',[0.15 1-4*0.23 0.82 0.20]); hold on
PlotSpectrum(f,FT{3},'k.',[2.8 3.2],[Min Max]); ylim auto; box on, ylabel('Re(fft)')

%% Perform numerical integration

% integrate GABA 3.01 ppm peak
i_GABA = find((f>ppm_GABA(1))&(f<ppm_GABA(2)));
f_GABA = f(i_GABA);  FT_GABA = FT{3}(i_GABA);
area_GABA_trapz = -trapz(f_GABA,FT_GABA);

% integrate NAA 2.01 ppm peak
i_NAA = find((f>ppm_NAA(1))&(f<ppm_NAA(2)));
f_NAA = f(i_NAA);  FT_NAA = FT{3}(i_NAA);
area_NAA_trapz = -trapz(f_NAA,FT_NAA);

% integrate GLX1 peak
i_GLX1 = find((f>ppm_GLX1(1))&(f<ppm_GLX1(2)));
f_GLX1 = f(i_GLX1);  FT_GLX1 = FT{3}(i_GLX1);
area_GLX1_trapz = -trapz(f_GLX1,FT_GLX1);

% integrate GLX2 peak
i_GLX2 = find((f>ppm_GLX2(1))&(f<ppm_GLX2(2)));
f_GLX2 = f(i_GLX2);  FT_GLX2 = FT{3}(i_GLX2);
area_GLX2_trapz = -trapz(f_GLX2,FT_GLX2);

% integrate CRE peak in edit-on and edit-off spectrum
i_CRE = find((f>ppm_CRE(1))&(f<ppm_CRE(2)));
f_CRE = f(i_CRE);  FT1_CRE = FT{1}(i_CRE); FT2_CRE = FT{2}(i_CRE);
area_CRE1_trapz = -trapz(f_CRE,FT1_CRE);
area_CRE2_trapz = -trapz(f_CRE,FT2_CRE);

%% Alternative GABA / NAA area calculations

% Split fit GABA peak
fit_GABA = spline(f_GABA,FT_GABA);
x_GABA   = linspace(ppm_GABA(1),ppm_GABA(2));
y_GABA   = ppval(fit_GABA,x_GABA);
area_GABA_spline = sum(ppval(fit_GABA,x_GABA))*mean(diff(x_GABA));

% Lorentz fit of NAA peak
% fit normalized amplitude spectrum real(FT(ind))/min(real(FT(ind)))
% in frequency window defined by ind with StartPoint [1 1 -2]
% where a=1, c=1, f=-2 (guess obtained by looking at spectrum)
Lorentz = fittype(@(a,c,f0,x)a*c^2./(c^2+(x-f0).^2));
[Min1,i0] = min(FT_NAA); f0 = f(i_NAA(i0));
fit_NAA = fit(f_NAA',FT_NAA/Min1,Lorentz,'StartPoint',[-1 1 f0]);
x_NAA   = linspace(ppm_NAA(1),ppm_NAA(2));
y_NAA   = fit_NAA(x_NAA)*Min1;
area_NAA_lorentz = sum(fit_NAA(x_NAA))*Min1*mean(diff(x_NAA));

%% Area Plots
AREA_SCALING = 1;
area(f_CRE,FT1_CRE,'Parent',PLOT(1),'FaceAlpha',0.5)
legend(PLOT(1),{'edit on',sprintf('CRE+GABA = %0.3f',area_CRE1_trapz*AREA_SCALING)},'Location','best');

area(f_CRE,FT2_CRE,'Parent',PLOT(2),'FaceAlpha',0.5)
legend(PLOT(2),{'edit off',sprintf('CRE+GABA = %0.3f',area_CRE2_trapz*AREA_SCALING)},'Location','best');

area(f_NAA,FT_NAA,'Parent',PLOT(3),'FaceAlpha',0.5)
%T1 = text(2,min(FT_NAA),sprintf('area NAA = %0.3f',area_NAA_trapz));
%set(T1,'HorizontalAlignment','center','VerticalAlignment','top')
area(f_GLX1,FT_GLX1,'Parent',PLOT(3),'FaceAlpha',0.5)
area(f_GLX2,FT_GLX2,'Parent',PLOT(3),'FaceAlpha',0.5)
legend(PLOT(3),{'diff',sprintf('NAA = %0.3f',area_NAA_trapz*AREA_SCALING), ...
sprintf('GLX1 = %0.3f',area_GLX1_trapz*AREA_SCALING), ...
sprintf('GLX2 = %0.3f',area_GLX2_trapz*AREA_SCALING)} ,'Location','best');

area(f_GABA,FT_GABA,'Parent',PLOT(4),'FaceAlpha',0.5)
legend(PLOT(4),{'diff',sprintf('GABA = %0.3f',area_GABA_trapz*AREA_SCALING)},'Location','best');
%T2 = text(3.0,max(FT_GABA),sprintf('area GABA = %0.3f',area_GABA_trapz));
%set(T2,'HorizontalAlignment','center','VerticalAlignment','bottom')

%% Generate result output structure
result.f           = f;
result.FT          = FT;
result.offset      = [xoffset yoffset];
result.GABA.fit    = fit_GABA;
result.GABA.i      = i_GABA;
result.GABA.x      = x_GABA;
result.GABA.y      = y_GABA;
result.GABA.area_t = area_GABA_trapz;
result.GABA.area_s = area_GABA_spline;

result.NAA.fit     = fit_NAA;
result.NAA.f_lim   = f_NAA;
result.NAA.i       = i_NAA;
result.NAA.x       = x_NAA;
result.NAA.y       = y_NAA;
result.NAA.scale   = Min1;
result.NAA.area_l  = area_NAA_lorentz;
result.NAA.area_t  = area_NAA_trapz;

result.CRE.f_lim   = f_CRE;
result.CRE.i       = i_CRE;
result.CRE.area_t  = area_CRE2_trapz;
result.CRE.area_ON_t  = area_CRE1_trapz;

result.GLX1.f_lim  = f_GLX1;
result.GLX1.i      = i_GLX1;
result.GLX1.area_t = area_GLX1_trapz;

result.GLX2.f_lim  = f_GLX1;
result.GLX2.i      = i_GLX1;
result.GLX2.area_t = area_GLX2_trapz;
