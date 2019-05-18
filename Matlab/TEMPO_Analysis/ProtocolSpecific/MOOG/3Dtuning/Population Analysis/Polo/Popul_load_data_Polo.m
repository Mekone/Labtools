% population analysis
% Protocol: 1->translation, 2-> rotation, 3->dark T, 4->dark R
% LBY 20170612
% LBY 20171123

% function popul_load_data(FnameCode, Protocol)

%% load data

tic;
% clear all;

global PSTH;

FnameCode = 2;
% Protocol: 1->translation, 2-> rotation, 3->dark T, 4->dark R
Protocol = 1;


pathname = {'Z:\Data\TEMPO\BATCH\Polo';'Z:\Data\TEMPO\BATCH\Polo';'Z:\Data\TEMPO\BATCH\Polo_Dark';'Z:\Data\TEMPO\BATCH\Polo_Dark';};

switch FnameCode
    case 1 % choose files mannully
        [filename pathname] = uigetfile('Z:\Data\TEMPO\BATCH');
        
    case 2 % load all mat files from interested folder
        switch Protocol
            case {1 3}
                cd(pathname{Protocol});
                disp('Load PSTH T data...');
                filename = dir([pathname{Protocol},'\*PSTH_T*.mat']);
                for ii = 1:length(filename)
                    % load PSTH data
                    temp = load([pathname{Protocol} '\' filename(ii).name]);
                    Polo_3DTuning_T(ii).name = str2double((filename(ii).name(4:7)));
                    Polo_3DTuning_T(ii).ch = temp.result.SpikeChan;
%                     Polo_3DTuning_T(ii).repNums = temp.result.repNums;
                    Polo_3DTuning_T(ii).stimType = temp.result.unique_stimType;
                    Polo_3DTuning_T(ii).duration = temp.result.unique_duration;
                    Polo_3DTuning_T(ii).meanSpon = temp.result.meanSpon;
                    Polo_3DTuning_T(ii).DDI = temp.result.DDI;
                    Polo_3DTuning_T(ii).nBins = temp.result.nBins;
                    Polo_3DTuning_T(ii).ANOVA = temp.result.p_anova_dire;
                    Polo_3DTuning_T(ii).preDir = temp.result.preferDire;
                    Polo_3DTuning_T(ii).responSig = temp.result.PSTH.respon_sigTrue;
                    Polo_3DTuning_T(ii).localPeak = temp.result.PSTH.localPeak;
                    Polo_3DTuning_T(ii).localTrough = temp.result.PSTH.localTrough;
                    Polo_3DTuning_T(ii).localTrough = temp.result.PSTH.localTrough;
                    Polo_3DTuning_T(ii).maxFR = temp.result.PSTH.maxSpkRealBinMean;
                    Polo_3DTuning_T(ii).minFR = temp.result.PSTH.minSpkRealBinMean;
                    Polo_3DTuning_T(ii).PSTH = temp.result.PSTH.spk_data_bin_mean_rate_aov;
                    Polo_3DTuning_T(ii).PSTH3Dmodel = temp.result.PSTH3Dmodel;
                    try
                    Polo_3DTuning_T(ii).peakDS = temp.result.PSTH.peak_DS;
                    catch
                        keyboard;
                    end
                    Polo_3DTuning_T(ii).NoDSPeaks = temp.result.PSTH.NoDSPeaks;
                    disp('T DATA LOADED!');
                end
            case {2 4}
                cd(pathname{Protocol});
                disp('Load PSTH R data...');
                filename = dir([pathname{Protocol},'\*PSTH_R*.mat']);
                for ii = 1:length(filename)
                    % load PSTH data
                    temp = load([pathname{Protocol} '\' filename(ii).name]);
                    Polo_3DTuning_R(ii).name = str2double(filename(ii).name(4:7));
                    Polo_3DTuning_R(ii).ch = temp.result.SpikeChan;
%                     Polo_3DTuning_R(ii).repNums = temp.result.repNums;
                    Polo_3DTuning_R(ii).stimType = temp.result.unique_stimType;
                    Polo_3DTuning_R(ii).duration = temp.result.unique_duration;
                    Polo_3DTuning_R(ii).meanSpon = temp.result.meanSpon;
                    Polo_3DTuning_R(ii).DDI = temp.result.DDI;
                    Polo_3DTuning_R(ii).nBins = temp.result.nBins;
                    Polo_3DTuning_R(ii).ANOVA = temp.result.p_anova_dire;
                    Polo_3DTuning_R(ii).preDir = temp.result.preferDire;
                    Polo_3DTuning_R(ii).responSig = temp.result.PSTH.respon_sigTrue;
                    Polo_3DTuning_R(ii).localPeak = temp.result.PSTH.localPeak;
                    Polo_3DTuning_R(ii).localTrough = temp.result.PSTH.localTrough;
                    Polo_3DTuning_R(ii).localTrough = temp.result.PSTH.localTrough;
                    Polo_3DTuning_R(ii).maxFR = temp.result.PSTH.maxSpkRealBinMean;
                    Polo_3DTuning_R(ii).minFR = temp.result.PSTH.minSpkRealBinMean;
                    Polo_3DTuning_R(ii).PSTH = temp.result.PSTH.spk_data_bin_mean_rate_aov;
                    Polo_3DTuning_R(ii).PSTH3Dmodel = temp.result.PSTH3Dmodel;
                    Polo_3DTuning_R(ii).peakDS = temp.result.PSTH.peak_DS;
                    Polo_3DTuning_R(ii).NoDSPeaks = temp.result.PSTH.NoDSPeaks;
                    disp('R DATA LOADED!');
                end
        end
        
        
end

% save the data

cd('Z:\Data\TEMPO\BATCH\Polo_3DTuning');
switch Protocol
    case 1
        save('PSTH_OriData.mat','Polo_3DTuning_T','-append');
% save('PSTH_OriData.mat','Polo_3DTuning_T');
    case 2
        save('PSTH_OriData.mat','Polo_3DTuning_R','-append');
% save('PSTH_OriData.mat','Polo_3DTuning_R');
    case 3
        save('PSTH_OriData_Dark.mat','Polo_3DTuning_T','-append');
% save('PSTH_OriData_Dark.mat','Polo_3DTuning_T');
        case 4
        save('PSTH_OriData_Dark.mat','Polo_3DTuning_R','-append');
%  save('PSTH_OriData_Dark.mat','Polo_3DTuning_R');
        
end
disp('DATA SAVED!');

toc;