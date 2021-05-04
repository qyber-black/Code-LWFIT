function [COMBI,res] = GetRefData(IN_WS_ON,IN_WS_OFF)

% function [COMBI,res] = GetRefData(IN_WS_ON,IN_WS_OFF) extracts info
% from sequence protocol stores with Siemens IMA files and does various
% consistency check
%
% INPUT:        IN_WS_ON, IN_WS_OFF:  list of spectra with WS ON and OFF
% inputs should structures created by ReadSpectIMA2(DIR_NAME) or lists of
% such structures, e.g., IN{k} = ReadSpectIMA2(DIR(k).name);
%
% OUTPUT:
% COMBI, res:   data structures with info about frequency, gradients,
%               transmitter voltages and changes over time.

% SPDX-License-Identifier: AGPL-3.0-or-later
%
% Copyright (C) 2021, Sophie M Shermer, Swansea University

WS_ON  = GetData(IN_WS_ON);
FIELDS = fields(WS_ON);

if exist('IN_WS_OFF','var')
   WS_OFF = GetData(IN_WS_OFF);
   for n=1:length(FIELDS)
      COMBI.(FIELDS{n}) = [WS_OFF.(FIELDS{n}),WS_ON.(FIELDS{n})];
   end
else
    for n=1:length(FIELDS)
      COMBI.(FIELDS{n}) = WS_ON.(FIELDS{n});
    end
end

% Consistency checks
res.check_tol0 = structfun(@(x)find(abs(diff(x'))>0),    COMBI,'UniformOutput',false);
res.check_tol1 = structfun(@(x)find(abs(diff(x'))>1e-10),COMBI,'UniformOutput',false);
if any(cell2mat(struct2cell(res.check_tol0))), warning('Strict checking found inconsistency'); end
if any(cell2mat(struct2cell(res.check_tol1))), warning('Inconsistency at 1e-10 tol level'); end

% Drift plots
Figs = 2;
figure('position',[0 2000 500 800])
subplot('position',[0.15 0.7 0.8 0.25])
plot(COMBI.F-123.2e6,'k'),
set(gca,'XTickLabel','')
tix=get(gca,'ytick')'; set(gca,'yticklabel',num2str(tix,'%4.0f'))
ylabel('frequency (Hz) -123.2MHz'), grid on,

subplot('position',[0.15 0.4 0.8 0.25])
TX.med = median(COMBI.TX_ref,2);
TX.min = min(COMBI.TX_ref,[],2);
TX.max = max(COMBI.TX_ref,[],2);
errorbar([1:length(TX.med)],TX.med,TX.max-TX.med,TX.med-TX.min)
set(gca,'XTickLabel',''), ylabel('TX Reference Voltage (V)'), grid on

subplot('position',[0.15 0.1 0.8 0.25])
plot(COMBI.TX5(:,end-2,end),'b'), hold on
plot(COMBI.TX6(:,end-2,end),'r'),
plot(COMBI.TX7(:,end-2,end),'g'),
xlabel('Scan No.'), ylabel('RF WS ON (V)'), grid on

figure('position',[500 2000 500 800]), clf
subplot('position',[0.15 0.7 0.8 0.25])
plot(COMBI.GX,'k'), set(gca,'XTickLabel',''),
tix=get(gca,'ytick')'; set(gca,'yticklabel',num2str(tix,'%4.0f')), ylabel('X-gradient offset'), grid on

subplot('position',[0.15 0.4 0.8 0.25])
plot(COMBI.GY,'k'), set(gca,'XTickLabel',''),
tix=get(gca,'ytick')'; set(gca,'yticklabel',num2str(tix,'%4.0f')), ylabel('Y-gradient offset'), grid on

subplot('position',[0.15 0.1 0.8 0.25])
plot(COMBI.GZ,'k'), xlabel('Scan No.'),
tix=get(gca,'ytick')'; set(gca,'yticklabel',num2str(tix,'%4.0f')), ylabel('Z-gradient offset'), grid on

%figure(6), clf, plot(COMBI.TX0,'k'), xlabel('Scan No.'), ylabel('RF dummy exc (V)'), grid on
%figure(7), clf, plot(COMBI.TX1,'k'), xlabel('Scan No.'), ylabel('RF excitation (V)'), grid on
%figure(8), clf, plot(COMBI.TX2,'k'), xlabel('Scan No.'), ylabel('RF dummy (V)'), grid on
%figure(9), clf, plot(COMBI.TX3,'k'), xlabel('Scan No.'), ylabel('RF pi sl (V)'), grid on
%figure(10), clf, plot(COMBI.TX4,'k'), xlabel('Scan No.'), ylabel('RF pi ph (V)'), grid on

%if isfield(COMBI,'TX8')
%    Figs=15;
%    figure(14), clf, plot(COMBI.TX8,'k'), xlabel('Scan No.'), ylabel('RF edit (V)'), grid on
%    figure(15), clf, plot(COMBI.TX9,'k'), xlabel('Scan No.'), ylabel('RF offset (V)'), grid on
%end

for k=1:Figs
    saveas(k,sprintf('Drift-plot-%i',k),'fig');
    saveas(k,sprintf('Drift-plot-%i',k),'png');
end

% Analysis & Correlations
res.change_abs = structfun(@(x)(max(x(:,1))-min(x(:,1))),COMBI);
res.change_rel = structfun(@(x)(max(x(:,1))-min(x(:,1)))/median(x(:,1)),COMBI);
res.corr.TX = structfun(@(x)corr(x(:,1),COMBI.TX0(:,1)),COMBI);

%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = GetData(IN)
%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 1:length(IN)  % number of experiments
M = length(IN{1}) % number of spectra per experiment
for k=L, out.F(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_asNucleusInfo_0__lFrequency),[1:M]); end
for k=L, out.GX(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sGRADSPEC_lOffsetX),[1:M]); end
for k=L, out.GY(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sGRADSPEC_lOffsetY),[1:M]); end
for k=L, out.GZ(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sGRADSPEC_lOffsetZ),[1:M]); end
for k=L, out.TX_ref(k,:) =  arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_asNucleusInfo_0__flReferenceAmplitude),[1:M]); end
for k=L, out.TX0(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_0__flAmplitude),[1:M]); end % ss_rf_dummy_ex
for k=L, out.TX1(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_1__flAmplitude),[1:M]); end % ss_rf_exc
for k=L, out.TX2(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_2__flAmplitude),[1:M]); end % ss_rf_dummy
for k=L, out.TX3(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_3__flAmplitude),[1:M]); end % ss_rf_pi_sl
for k=L, out.TX4(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_4__flAmplitude),[1:M]); end % ss_rf_pi_ph
for k=L, out.TX5(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_5__flAmplitude),[1:M]); end % ss_rf_ws1
for k=L, out.TX6(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_6__flAmplitude),[1:M]); end % ss_rf_ws2
for k=L, out.TX7(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_7__flAmplitude),[1:M]); end % ss_rf_ws3
if isfield(IN{1}(1).prot,'sTXSPEC_aRFPULSE_8__flAmplitude')
    for k=L, out.TX8(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_8__flAmplitude),[1:M]); end % RF_Edit
    for k=L, out.TX9(k,:) = arrayfun(@(n)str2num(IN{k}(n).prot.sTXSPEC_aRFPULSE_9__flAmplitude),[1:M]); end % RF_Offset
end
