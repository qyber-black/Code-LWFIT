function [fl1,gof,Error] = FitLorentz(f,FT,f1,f2,Color,LOC)

% function [fl1,gof,Error] = FitLorentz(f,FT,f1,f2,Color,LOC)
%
% INPUT:
% f:    frequency range
% FT:   fourier spectrum
% f1:   left fitting limit
% f2:   right fitting limit
% Color: color choice (optional)
% LOC:  legend location (optional)
%
% OUTPUT:
% fl:    lorentizan fit
% Error: fitting error (vector)

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

% define fit type (Lorentzian) with independent variable x
% parameters to fit: a -- amplitude, c -- width, f0 centre freq
L = fittype(@(a,c,d,f0,x)a*c^2./(c^2+(x-f0).^2)+d);

% identify frequency range to fit
ind1 = find((f>=f1)&(f<=f2));

% fit normalized amplitude spectrum abs(FT(ind))/max(abs(FT(ind)))
% in frequency window defined by ind with StartPoint [1 1 -2]
% where a=1, c=1, f=-2 (guess obtained by looking at spectrum)

FT1 = FT(ind1); [Max1,i0] = max(abs(FT1));
Max1 = Max1*sign(FT1(i0)); f0 = f(ind1(i0));
%fl1 = fit(f(ind1)',FT1/Max1,L,'StartPoint',[1 1 f0])
c0 = max(1/Max1^2,1e-4);
[fl1,gof] = fit(f(ind1)',FT1,L,'StartPoint',[Max1 c0 0 f0]);

if exist('Color','var')
% plot the fitted curve and the original data
   plot(f,FT,'b'), set(gca,'XDir','reverse'); hold on
   P = plot(f,fl1(f),Color); set(P,'Color',Color,'LineWidth',2);
   xlabel('frequency (ppm), no shift'), ylabel('Spectrum (arb. units)');
   legend({'data',sprintf('L-fit \\nu_0=%0.2gppm\na=%0.2g, c=%0.2gHz',fl1.f0,fl1.a,fl1.c*123.2)},'Location',LOC);
end

% calculate the fitting error (what we are trying to minimize)
Error = feval(fl1,f(ind1))-FT1;
norm_error = norm(Error);
