function excel=CurveFitting_3Plane_Sti(data, SpikeChan, StartCode, StopCode, BegTrial, EndTrial, StartOffset, StopOffset, StartEventBin, StopEventBin, PATH, FILE, Protocol, OutputPath)

warning off MATLAB:divideByZero;
warning off MATLAB:singularMatrix;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all;clc
% load time_vel_acc.mat;%load('C:\MATLAB6p5\work\time_vel_acc.mat');
% load m14c136r1.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Path_Defs;
ProtocolDefs; %contains protocol specific keywords - 1/4/01 BJP

%get the column of values for azimuth and elevation and stim_type
switch Protocol
    case 100 % DIRECTION_TUNING_3D
        temp_azimuth = data.moog_params(AZIMUTH,:,MOOG);
        temp_elevation = data.moog_params(ELEVATION,:,MOOG);
        CurrentProtocol=['Translation'];
    case 112 %ROTATION_TUNING_3D
        temp_azimuth = data.moog_params(ROT_AZIMUTH,:,MOOG);
        temp_elevation = data.moog_params(ROT_ELEVATION,:,MOOG);
        CurrentProtocol=['Rotation'];
    case 104 %DIR3D_VARY_FIXATION
        temp_azimuth = data.moog_params(AZIMUTH,:,MOOG);
        temp_elevation = data.moog_params(ELEVATION,:,MOOG);
        CurrentProtocol=['DIR3D VARY FIXATION '];
end

temp_stim_type = data.moog_params(STIM_TYPE,:,MOOG);
temp_spike_data = data.spike_data(SpikeChan,:);
temp_spike_rates = data.spike_rates(SpikeChan, :);

%get indices of any NULL conditions (for measuring spontaneous activity
null_trials = logical( (temp_azimuth == data.one_time_params(NULL_VALUE)) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now, remove trials from direction and spike_rates that do not fall between BegTrial and EndTrial
trials = 1:length(temp_azimuth);		% a vector of trial indices
bad_trials = find(temp_spike_rates > 3000);   % cut off 3k frequency which definately is not cell's firing response
if ( bad_trials ~= NaN)
    select_trials= ( (trials >= BegTrial) & (trials <= EndTrial) & (trials~=bad_trials) );
else
    select_trials= ( (trials >= BegTrial) & (trials <= EndTrial) );
end

% find spontaneous trials which azimuth,elevation,stim_type=-9999
azimuth = temp_azimuth(~null_trials & select_trials);unique_azimuth = munique(azimuth');
elevation = temp_elevation(~null_trials & select_trials);unique_elevation = munique(elevation');
stim_type = temp_stim_type(~null_trials & select_trials);unique_stim_type = munique(stim_type');
spike_rates= temp_spike_rates(~null_trials & select_trials);
% spike_rates_step=temp_SpikeRates(:,~null_trials & select_trials);

condition_num = stim_type;unique_condition_num = munique(condition_num');
h_title{1}='Vestibular';h_title{2}='Visual';h_title{3}='Combined';
stim_duration = length(temp_spike_data)/length(temp_azimuth);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove null trials, bad trials, and trials outside Begtrial~Endtrial for spike_data
Discard_trials = find(null_trials==1 | trials <BegTrial | trials >EndTrial);
for i = 1 : length(Discard_trials)
    %temp_spike_data( 1, ((Discard_trials(i)-1)*stim_duration+1) :  Discard_trials(i)*stim_duration ) = 9999;
    temp_spike_data( 1, ((Discard_trials(i)-1)*stim_duration+1) :Discard_trials(i)*stim_duration ) = 99;
end
spike_data = temp_spike_data( temp_spike_data~=99 );
spike_data( find(spike_data>89) ) = 1; % something is absolutely wrong

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get the SpikeArray
trials_per_rep = (length(unique_azimuth)*length(unique_elevation)-2*(length(unique_azimuth)-1)) * length(unique_stim_type)+1;
repetitions = floor( (EndTrial-(BegTrial-1)) / trials_per_rep);

unique_azimuth0=[0:45:315]';
for k=unique_condition_num(1):unique_condition_num(end)%1: length(unique_condition_num)
    for j=1:length(unique_elevation)
        for i=1: length(unique_azimuth0)
            clear select; select = logical( (azimuth==unique_azimuth0(i)) & (elevation==unique_elevation(j)) & (condition_num==k) );
            %             clear select; select = logical( (azimuth==unique_azimuth0(i)) & (elevation==unique_elevation(j)) & (condition_num==unique_condition_num(k)) );
            act_found = find( select==1 );
            if length(act_found)>repetitions
                NumRepetition=repetitions;
            else
                NumRepetition=length(act_found);
            end
            for repeat=1:NumRepetition
                spikeTracker(repeat,:)=spike_data(1,stim_duration*(act_found(repeat)-1)+1:stim_duration*(act_found(repeat)));
            end
            SpikeArray{k,j,i}(:,:)=spikeTracker;
            SpikeHistArray{k,j,i}=mean(spikeTracker);%每一个ijk对应一个5000的行矩阵，应该是把重复的次数平均了
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Step = 100;%Step = 20;
WindowInterval=100;%WindowInterval=50;
WindowInterval_Big=400;
%AftSti=100;%
% AftSti=500;
AftSti=300;
StepEventBin1=[StartEventBin(1,1):-Step:StartEventBin(1,1)-500];
excel.excel13=StartEventBin(1,1);%起始时间
StepEventBin1=fliplr(StepEventBin1);
StepEventBin1=StepEventBin1(1:end-1);
StepEventBin2=[StartEventBin(1,1):Step:StopEventBin(1,1)+AftSti];
StepEventBin=[StepEventBin1 StepEventBin2];
x_time=[StepEventBin-StartEventBin(1,1)]*0.001;
x_stop=([StopEventBin(1,1),StopEventBin(1,1)]-StartEventBin(1,1))*0.001; %x_stop =  [2, 2];
StartIndex=find(StepEventBin==StartEventBin(1,1));%起点991在个数序列中的位置，是第六个
[min_diff,EndIndex]=min(abs(StepEventBin-StopEventBin(1,1)));
%%%给excel赋初值
excel.excel0=[[FILE(1:end-4) '_Ch' num2str(SpikeChan)]];
% excel.excel1=[FILE(1:end-4)];
% excel.excel2=[FILE(1:end-4)];
% excel.excel3=[FILE(1:end-4)];
% excel.excel4=[FILE(1:end-4)];
% excel.excel5=[FILE(1:end-4)];
% excel.excel6=[FILE(1:end-4)];
% excel.excel7=[FILE(1:end-4)];
% excel.excel8=[FILE(1:end-4)];
% excel.excel9=[FILE(1:end-4)];
% excel.excel10=[FILE(1:end-4)];
% excel.excel11=[FILE(1:end-4)];
% excel.excel12=[FILE(1:end-4)];
% excel.excel14=9999;
% excel.excel15=9999;
% excel.excel16=9999;
% excel.excel17=9999;
% excel.excel18=9999;
% excel.excel19=9999;
% excel.excel20=9999;
% excel.excel21=9999;
% excel.excel22=9999;
% excel.excel23=9999;
% excel.excel24=9999;
% excel.excel25=9999;
% excel.excel26=9999;
% excel.excel27=9999;
% excel.excel28=9999;
% excel.excel29=9999;
% excel.excel30=9999;
% excel.excel31=9999;
% excel.excel32=9999;
% excel.excel33=9999;
% excel.excel34=9999;
% excel.excel35=9999;
% excel.excel36=9999;
% excel.excel37=9999;
% excel.excel38=9999;
% excel.excel39=9999;
% excel.excel40=9999;
% excel.excel41=9999;
% excel.excel42=9999;
% excel.excel43=9999;
% excel.excel44=9999;
% excel.excel45=9999;
% excel.excel46=9999;
% excel.excel47=9999;
% excel.excel48=9999;
% excel.excel49=9999;
% excel.excel50=9999;
% excel.excel51=9999;
% excel.excel52=9999;
% excel.excel53=9999;
% excel.excel54=9999;
% excel.excel55=9999;
% excel.excel56=9999;
% excel.excel57=9999;
% excel.excel58=9999;
% excel.excel59=9999;
% excel.excel60=9999;
% excel.excel61=9999;
% excel.excel62=9999;
% excel.excel63=9999;
% excel.excel64=9999;
% excel.excel65=9999;
% excel.excel66=9999;
% excel.excel67=9999;
% excel.excel68=9999;
% excel.excel69=9999;
% excel.excel70=9999;
% excel.excel71=9999;
% excel.excel72=9999;
% excel.excel73=9999;
% excel.excel74=9999;
% excel.excel75=9999;
% excel.excel76=9999;
% excel.excel77=9999;
% excel.excel78=9999;
% excel.excel79=9999;
% excel.excel80=9999;
% excel.excel81=9999;
% excel.excel82=9999;
% excel.excel83=9999;
% excel.excel84=9999;
% excel.excel85=9999;
% excel.excel86=9999;
% excel.excel87=9999;
% excel.excel88=9999;
% excel.excel89=9999;
% excel.excel90=9999;
% excel.excel91=9999;
% excel.excel92=9999;
% excel.excel93=9999;
% excel.excel94=9999;
% excel.excel95=9999;
% excel.excel96=9999;
% excel.excel97=9999;
% excel.excel98=9999;
% excel.excel99=9999;
% excel.excel100=9999;
% excel.excel101=9999;
% excel.excel102=9999;
% excel.excel103=9999;
excel.excel1=[FILE(1:end-4)];
excel.excel2=9999;
excel.excel3=9999;
excel.excel4=9999;
excel.excel5=9999;
excel.excel6=[FILE(1:end-4)];
excel.excel7=9999;
excel.excel8=9999;
excel.excel9=9999;
excel.excel10=9999;
% excel.excel11=[FILE(1:end-4)];
% excel.excel12=9999;
% excel.excel13=9999;
% excel.excel14=9999;
% excel.excel15=9999;

%%%
for k=unique_condition_num(1):unique_condition_num(end)
    for j=1:length(unique_elevation)
        for i=1:length(unique_azimuth0)
            clear StartBinReset;StartBinReset=StepEventBin(1,1);%StartBinReset=StartEventBin(1,1)-500;
            clear Index; Index=1;
            clear tempDC; tempDC=SpikeArray{k,j,i}(:,StartEventBin(1,1)-100:StartEventBin(1,1)+300);
            clear DCMean; DCMean=sum(tempDC')*1000/400;
            
            tempPSTH=[];
            while StartBinReset<StopEventBin(1,1)+AftSti
                clear CurrentValue;CurrentValue=SpikeArray{k,j,i}(:,StartBinReset-0.5*WindowInterval+1:StartBinReset+0.5*WindowInterval);
                clear CurrentValueMean; CurrentValueMean=sum(CurrentValue')*1000/WindowInterval; %CurrentValueMean=mean(CurrentValue');
                StepMatrix{k}(j,i,Index)=mean(CurrentValueMean);
                StdMatrix{k}(j,i,Index)=std(CurrentValueMean);
                
                %                 mean(CurrentValueMean)
                %                 std(CurrentValueMean)
                
                clear CurrentValue;CurrentValue=SpikeArray{k,j,i}(:,StartBinReset-0.5*WindowInterval+1:StartBinReset+0.5*WindowInterval);
                clear CurrentSpikeCount; CurrentSpikeCount=sum(CurrentValue')*1000/WindowInterval;
                %                 SpikeCount_Trial{k,Index}(j,i,:)=CurrentSpikeCount;
                SpikeCount_Trial{k,j,i}(Index,:)=CurrentSpikeCount;
                clear CurrentValue;CurrentValue=SpikeArray{k,j,i}(:,StartBinReset-0.5*WindowInterval_Big+1:StartBinReset+0.5*WindowInterval_Big);
                clear CurrentValueMean; CurrentValueMean=sum(CurrentValue')*1000/WindowInterval;
                tempPSTH(1,Index)=mean(CurrentValueMean);
                Index=Index+1;
                StartBinReset=StartBinReset+Step;
            end
            tempPSTH(1:StartIndex+5-1)=NaN;tempPSTH(EndIndex:end)=NaN;%tempPSTH(Index:end)=NaN;
            clear MaxIndex; MaxIndex=find(tempPSTH==max(tempPSTH));
            clear PeakTimeIndex; PeakTimeIndex=StepEventBin(MaxIndex(1,1));
            clear PeakValues; PeakValues=SpikeArray{k,j,i}(:,PeakTimeIndex-0.5*WindowInterval_Big+1:PeakTimeIndex+0.5*WindowInterval_Big);
            clear PeakValueMean; PeakValueMean=sum(PeakValues')*1000/WindowInterval;
            Value_peak{k}(j,i)=mean(PeakValueMean);
            %             mean(PeakValueMean)
            Time_peak{k}(j,i)=PeakTimeIndex*Step/1000-0.5;
            TimeIndex_peak{k}(j,i)=MaxIndex(1,1);
            %             MaxIndex(1,1)
            
            [temp_p_peak(1),h_peak] = ranksum(PeakValueMean,DCMean,0.01);%clear h_peak;
            cc=[PeakValueMean,DCMean];
            clear PeakValues; PeakValues=SpikeArray{k,j,i}(:,PeakTimeIndex-0.5*WindowInterval_Big+1-Step:PeakTimeIndex+0.5*WindowInterval_Big-Step);
            clear PeakValueMean; PeakValueMean=sum(PeakValues')*1000/WindowInterval_Big;
            p_peak{k}(j,i)=max(temp_p_peak);
            %             max(temp_p_peak)
            
            clear MinIndex; MinIndex=find(tempPSTH==min(tempPSTH));
            clear TroughTimeIndex; TroughTimeIndex=StepEventBin(MinIndex(1,1));
            clear TroughValues; TroughValues=SpikeArray{k,j,i}(:,TroughTimeIndex-0.5*WindowInterval_Big+1:TroughTimeIndex+0.5*WindowInterval_Big);
            clear TroughValueMean; TroughValueMean=sum(TroughValues')*1000/WindowInterval_Big;
            Value_trough{k}(j,i)=mean(TroughValueMean);
            %             mean(TroughValueMean)
            Time_trough{k}(j,i)=TroughTimeIndex*Step/1000-0.5;
            TimeIndex_trough{k}(j,i)=MinIndex(1,1);
            %             MinIndex(1,1)
            [temp_p_trough(1),h_Trough] = ranksum(TroughValueMean,DCMean,0.01); %clear h_Trough;
            
            clear TroughValues; TroughValues=SpikeArray{k,j,i}(:,TroughTimeIndex-0.5*WindowInterval_Big+1-Step:TroughTimeIndex+0.5*WindowInterval_Big-Step);
            clear TroughValueMean; TroughValueMean=sum(TroughValues')*1000/WindowInterval_Big;
            p_trough{k}(j,i)=max(temp_p_trough);
            aa=[i,j,k];
            bb=[temp_p_peak,temp_p_trough];
            %             max(temp_p_trough)
            %            aa=[mean(PeakValueMean),MaxIndex(1,1),max(temp_p_peak),mean(TroughValueMean), MinIndex(1,1), max(temp_p_trough)];
        end
    end
end

% temp_p_peak=reshape(temp_p_peak,120,1);
% temp_p_trough=reshape(temp_p_trough,120,1);
% h_peak=reshape(h_peak,120,1);
% h_Trough=reshape(h_Trough,120,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Azi_3D=[0:45:315];Ele_3D=[-90:45:90];%[AziGrid,EleGrid]=meshgrid(UniAzi,UniEle);
%OutputPath=['Z:\Users\Aihua\'];% OutputPath=['Z:\Users\Aihua\z_tempOutputs\'];
OutputPath=['Z:\figure\Vestibular\'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if k==1
for k=1:length(unique_condition_num)
    StimulusType=unique_condition_num(k);
    if (StimulusType==1)
        %     StimulusType=1;%Vestibular: 1; Visual=2; Combined:3.
        excel.excel1=['Vestibular'];
        %%%******************************%%%
        %xy: Horizontal plane
        % Azi_hor=[0:45:315];Ele_hor=0*ones(1,8);
        % CurveFit_Hor=CurveFittingPlot(FILE,'Horizontal Plane',Azi_3D,Ele_3D,Azi_hor,Ele_hor,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
        % if ~isempty(CurveFit_Hor)
        %     excel.excel1=[FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitHor'];
        %     excel.excel2=CurveFit_Hor.excel2;
        %     excel.excel3=CurveFit_Hor.excel3;
        % else
        %     excel.excel1=[FILE(1:end-4)];
        %     excel.excel2=9999;
        %     excel.excel3=9999;
        % end
        
        %Save the figure
        % % FigureIndex=2;
        % % if ~isempty(CurveFit_Hor)
        % %     figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
        % %     saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Hor.png'],'png');close(FigureIndex);
        % %     %Save the Data
        % %     SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitHor'];
        % %     save(SaveFileName,'CurveFit_Hor'); clear SaveFileName;
        % % else
        % % end
        
        %%%******************************%%%
        %xz: Frontal plane
        Azi_Front=[0 45 90 135 180 225 270 315 0 45 90 135 180 225 270 315 0 45 90 135 180 225 270 315 0  0];
        Ele_Front=[-45 -45 -45 -45 -45 -45 -45 -45 0 0 0 0 0 0 0 0 45 45 45 45 45 45 45 45 -90 90];
        CurveFit=CurveFittingPlot(FILE,'Frontal Plane',Azi_3D,Ele_3D,Azi_Front,Ele_Front,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
        if ~isempty(CurveFit)
%             excel.excel2=CurveFit.excel2;%p
%             excel.excel3=CurveFit.excel3;%v的权重
%             excel.excel4=CurveFit.excel4;%持续时间
            excel.excel2=CurveFit.excel3;%v的权重
            excel.excel3=CurveFit.excel4;%持续时间
            excel.excel14=CurveFit.R;
            excel.excel15=CurveFit.P;
%             excel.excel15=CurveFit.excel15;
%             excel.excel15=CurveFit.excel15;
%             excel.excel14=CurveFit.excel14;
%             excel.excel15=CurveFit.excel15;
%             excel.excel16=CurveFit.excel16;
%             excel.excel17=CurveFit.excel17;
%             excel.excel18=CurveFit.excel18;
%             excel.excel19=CurveFit.excel19;
%             excel.excel20=CurveFit.excel20;
%             excel.excel21=CurveFit.excel21;
%             excel.excel22=CurveFit.excel22;
%             excel.excel23=CurveFit.excel23;
%             excel.excel24=CurveFit.excel24;
%             excel.excel25=CurveFit.excel25;
%             excel.excel26=CurveFit.excel26;
%             excel.excel27=CurveFit.excel27;
%             excel.excel28=CurveFit.excel28;
%             excel.excel29=CurveFit.excel29;
%             excel.excel30=CurveFit.excel30;
%             excel.excel31=CurveFit.excel31;
%             excel.excel32=CurveFit.excel32;
%             excel.excel33=CurveFit.excel33;
%             excel.excel34=CurveFit.excel34;
%             excel.excel35=CurveFit.excel35;
%             excel.excel36=CurveFit.excel36;
%             excel.excel37=CurveFit.excel37;
%             excel.excel38=CurveFit.excel38;
%             excel.excel39=CurveFit.excel39;%从14到39为26个方向上的PSTH
%             excel.excel40=CurveFit.excel40;%26个方向波峰所在的时间，0是初始值，为0意为没有峰
%             excel.excel41=CurveFit.excel41;%峰值大小
%             excel.excel42=CurveFit.excel42;%同上，只不过是波谷
%             excel.excel43=CurveFit.excel43;
            
        else
%             excel.excel2=9999;
%             excel.excel3=9999;
%             excel.excel4=9999;
            excel.excel2=9999;
            excel.excel3=9999;
            excel.excel4=9999;
            excel.excel5=9999;
        end
        
        if ~isempty(CurveFit)
            %Save the figure
           saveas(figure(4),strcat(FILE(1:end-4),'_Ch',num2str(SpikeChan),'Vestibular.png'),'png');close(4);
           saveas(figure(5),strcat(FILE(1:end-4),'_Ch',num2str(SpikeChan),'Vestibular_2.png'),'png');close(5);
        else
        end
        %  else
        % end
        % % if ~isempty(CurveFit_Front)
        % %     %Save the figure
        % %     figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
        % %     saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Front.png'],'png');close(FigureIndex);
        % %     %Save the Data
        % %     SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitFront'];
        % %     save(SaveFileName,'CurveFit_Front'); clear SaveFileName;
        % % else
        % % end
        
        %%%******************************%%%
        %yz: Median plane (or mid-sagital plane)
        % Azi_Med=[90 90 0 270 270 270 0 90];Ele_Med=[0 45 90 45 0 -45 -90 -45];
        % CurveFit_Med=CurveFittingPlot(FILE,'Median Plane',Azi_3D,Ele_3D,Azi_Med,Ele_Med,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
        % if ~isempty(CurveFit_Med)
        %     excel.excel7=[FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitMed'];
        %     excel.excel8=CurveFit_Med.excel2;
        %     excel.excel9=CurveFit_Med.excel3;
        % else
        %     excel.excel7=[FILE(1:end-4)];
        %     excel.excel8=9999;
        %     excel.excel9=9999;
        % end
        
        % % if ~isempty(CurveFit_Med)
        % %     %Save the figure
        % %     figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
        % %     saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Med.png'],'png');close(FigureIndex);
        % %     %Save the Data
        % %     SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitMed'];
        % %     save(SaveFileName,'CurveFit_Med'); clear SaveFileName;
        % % else
        % % end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % if k==2
        %     if k>1
        %         StimulusType=2;%Vestibular: 1; Visual=2; Combined:3.
    elseif (StimulusType==2)
        OutputPath=['Z:\figure\Visual\'];
%         excel.excel5=['Visual'];
           excel.excel6=['Visual']
        %%%******************************%%%
        %xy: Horizontal plane
        %     Azi_hor=[0:45:315];Ele_hor=0*ones(1,8);
        %     CurveFit_Hor=CurveFittingPlot(FILE,'Horizontal Plane',Azi_3D,Ele_3D,Azi_hor,Ele_hor,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
        %     if ~isempty(CurveFit_Hor)
        %         excel.excel11=[FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitHor'];
        %         excel.excel12=CurveFit_Hor.excel2;
        %         excel.excel13=CurveFit_Hor.excel3
        %     else
        %         excel.excel11=[FILE(1:end-4)];
        %         excel.excel12=9999;
        %         excel.excel13=9999;
        %     end
        %Save the figure
        % %     FigureIndex=2;
        % %     if ~isempty(CurveFit_Hor)
        % %         figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
        % %         saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Hor.png'],'png');close(FigureIndex);
        % %         %Save the Data
        % %         SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitHor'];
        % %         save(SaveFileName,'CurveFit_Hor'); clear SaveFileName;
        % %     else
        % %     end
        
        %%%******************************%%%
        %xz: Frontal plane
        Azi_Front=[0 45 90 135 180 225 270 315 0 45 90 135 180 225 270 315 0 45 90 135 180 225 270 315 0  0];
        Ele_Front=[-45 -45 -45 -45 -45 -45 -45 -45 0 0 0 0 0 0 0 0 45 45 45 45 45 45 45 45 -90 90];
        CurveFit=CurveFittingPlot(FILE,'Frontal Plane',Azi_3D,Ele_3D,Azi_Front,Ele_Front,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
        if ~isempty(CurveFit)
%             excel.excel6=CurveFit.excel2;
%             excel.excel7=CurveFit.excel3;
%             excel.excel8=CurveFit.excel4;
%             excel.excel44=CurveFit.excel14;
%             excel.excel45=CurveFit.excel15;
%             excel.excel46=CurveFit.excel16;
%             excel.excel47=CurveFit.excel17;
%             excel.excel48=CurveFit.excel18;
%             excel.excel49=CurveFit.excel19;
%             excel.excel50=CurveFit.excel20;
%             excel.excel51=CurveFit.excel21;
%             excel.excel52=CurveFit.excel22;
%             excel.excel53=CurveFit.excel23;
%             excel.excel54=CurveFit.excel24;
%             excel.excel55=CurveFit.excel25;
%             excel.excel56=CurveFit.excel26;
%             excel.excel57=CurveFit.excel27;
%             excel.excel58=CurveFit.excel28;
%             excel.excel59=CurveFit.excel29;
%             excel.excel60=CurveFit.excel30;
%             excel.excel61=CurveFit.excel31;
%             excel.excel62=CurveFit.excel32;
%             excel.excel63=CurveFit.excel33;
%             excel.excel64=CurveFit.excel34;
%             excel.excel65=CurveFit.excel35;
%             excel.excel66=CurveFit.excel36;
%             excel.excel67=CurveFit.excel37;
%             excel.excel68=CurveFit.excel38;
%             excel.excel69=CurveFit.excel39;
%             excel.excel70=CurveFit.excel40;
%             excel.excel71=CurveFit.excel41;
%             excel.excel72=CurveFit.excel42;
%             excel.excel73=CurveFit.excel43;
            excel.excel7=CurveFit.excel3;%v的权重
            excel.excel8=CurveFit.excel4;%持续时间
            excel.excel9=CurveFit.R;
            excel.excel10=CurveFit.P;
        else
%             excel.excel6=9999;
%             excel.excel7=9999;
%             excel.excel8=9999;
            excel.excel7=9999;%v的权重
            excel.excel8=9999;%持续时间
            excel.excel9=9999;
            excel.excel10=9999;
        end
        
        if ~isempty(CurveFit)
            %Save the figure
            saveas(figure(4),strcat(FILE(1:end-4),'_Ch',num2str(SpikeChan),'Visual.png'),'png');close(4);
            saveas(figure(5),strcat(FILE(1:end-4),'_Ch',num2str(SpikeChan),'Visual_2.png'),'png');close(5);
        else
        end
        
        % %     if ~isempty(CurveFit_Front)
        % %         %Save the figure
        % %         figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
        % %         saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Front.png'],'png');close(FigureIndex);
        % %         %Save the Data
        % %         SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitFront'];
        % %         save(SaveFileName,'CurveFit_Front'); clear SaveFileName;
        % %     else
        % %     end
        
        %%%******************************%%%
        %yz: Median plane (or mid-sagital plane)
        %     Azi_Med=[90 90 0 270 270 270 0 90];Ele_Med=[0 45 90 45 0 -45 -90 -45];
        %     CurveFit_Med=CurveFittingPlot(FILE,'Median Plane',Azi_3D,Ele_3D,Azi_Med,Ele_Med,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
        %      if ~isempty(CurveFit_Med)
        %         excel.excel17=[FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitMed'];
        %         excel.excel18=CurveFit_Med.excel2;
        %         excel.excel19=CurveFit_Med.excel3;
        %      else
        %         excel.excel17=[FILE(1:end-4)];;
        %         excel.excel18=9999;
        %         excel.excel19=9999;
        %      end
        % %     if ~isempty(CurveFit_Med)
        % %         %Save the figure
        % %         figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
        % %         saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Med.png'],'png');close(FigureIndex);
        % %         %Save the Data
        % %         SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitMed'];
        % %         save(SaveFileName,'CurveFit_Med'); clear SaveFileName;
        % %     else
        % %     end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % if k==3
        %     if k>2
        %         StimulusType=3;%Vestibular: 1; Visual=2; Combined:3.
%     elseif (StimulusType==3)
%         OutputPath=['Z:\figure\Combined\'];
% %         excel.excel9=['Combined'];
%          excel.excel11=['Combined'];
%         %%%******************************%%%
%         %xy: Horizontal plane
%         %     Azi_hor=[0:45:315];Ele_hor=0*ones(1,8);
%         %     CurveFit_Hor=CurveFittingPlot(FILE,'Horizontal Plane',Azi_3D,Ele_3D,Azi_hor,Ele_hor,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
%         %     if ~isempty(CurveFit_Hor)
%         %         excel.excel21=[FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitHor'];
%         %         excel.excel22=CurveFit_Hor.excel2;
%         %         excel.excel23=CurveFit_Hor.excel3
%         %     else
%         %         excel.excel21=[FILE(1:end-4)];;
%         %         excel.excel22=9999;
%         %         excel.excel23=9999;
%         %     end
%         %Save the figure
%         % %     FigureIndex=2;
%         % %     if ~isempty(CurveFit_Hor)
%         % %         figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
%         % %         saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Hor.png'],'png');close(FigureIndex);
%         % %         %Save the Data
%         % %         SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitHor'];
%         % %         save(SaveFileName,'CurveFit_Hor'); clear SaveFileName;
%         % %     else
%         % %     end
%         
%         %%%******************************%%%
%         %xz: Frontal plane
%         Azi_Front=[0 45 90 135 180 225 270 315 0 45 90 135 180 225 270 315 0 45 90 135 180 225 270 315 0  0];
%         Ele_Front=[-45 -45 -45 -45 -45 -45 -45 -45 0 0 0 0 0 0 0 0 45 45 45 45 45 45 45 45 -90 90];
%         CurveFit=CurveFittingPlot(FILE,'Frontal Plane',Azi_3D,Ele_3D,Azi_Front,Ele_Front,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
%         if ~isempty(CurveFit)
% %             excel.excel10=CurveFit.excel2;
% %             excel.excel11=CurveFit.excel3;
% %             excel.excel12=CurveFit.excel4;
% %             excel.excel74=CurveFit.excel14;
% %             excel.excel75=CurveFit.excel15;
% %             excel.excel76=CurveFit.excel16;
% %             excel.excel77=CurveFit.excel17;
% %             excel.excel78=CurveFit.excel18;
% %             excel.excel79=CurveFit.excel19;
% %             excel.excel80=CurveFit.excel20;
% %             excel.excel81=CurveFit.excel21;
% %             excel.excel82=CurveFit.excel22;
% %             excel.excel83=CurveFit.excel23;
% %             excel.excel84=CurveFit.excel24;
% %             excel.excel85=CurveFit.excel25;
% %             excel.excel86=CurveFit.excel26;
% %             excel.excel87=CurveFit.excel27;
% %             excel.excel88=CurveFit.excel28;
% %             excel.excel89=CurveFit.excel29;
% %             excel.excel90=CurveFit.excel30;
% %             excel.excel91=CurveFit.excel31;
% %             excel.excel92=CurveFit.excel32;
% %             excel.excel93=CurveFit.excel33;
% %             excel.excel94=CurveFit.excel34;
% %             excel.excel95=CurveFit.excel35;
% %             excel.excel96=CurveFit.excel36;
% %             excel.excel97=CurveFit.excel37;
% %             excel.excel98=CurveFit.excel38;
% %             excel.excel99=CurveFit.excel39;
% %             excel.excel100=CurveFit.excel40;
% %             excel.excel101=CurveFit.excel41;
% %             excel.excel102=CurveFit.excel42;
% %             excel.excel103=CurveFit.excel43;
%             excel.excel12=CurveFit.excel3;%v的权重
%             excel.excel13=CurveFit.excel4;%持续时间
%             excel.excel14=CurveFit.R;
%             excel.excel15=CurveFit.P;
%         else
%             excel.excel12=9999;%v的权重
%             excel.excel13=9999;%持续时间
%             excel.excel14=9999;
%             excel.excel15=9999       ;
%         end
%         
%         if ~isempty(CurveFit)
%             %Save the figure
%            saveas(figure(4),strcat(FILE(1:end-4),'_Ch',num2str(SpikeChan),'Combined.png'),'png');close(4);
%            saveas(figure(5),strcat(FILE(1:end-4),'_Ch',num2str(SpikeChan),'Combined_2.png'),'png');close(5);
%         else
%         end

        % %     if ~isempty(CurveFit_Front)
        % %         %Save the figure
        % %         figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
        % %         saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Front.png'],'png');close(FigureIndex);
        % %         %Save the Data
        % %         SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitFront'];
        % %         save(SaveFileName,'CurveFit_Front'); clear SaveFileName;
        % %     else
        % %     end
        
        %%%******************************%%%
        %yz: Median plane (or mid-sagital plane)
        %     Azi_Med=[90 90 0 270 270 270 0 90];Ele_Med=[0 45 90 45 0 -45 -90 -45];
        %     CurveFit_Med=CurveFittingPlot(FILE,'Median Plane',Azi_3D,Ele_3D,Azi_Med,Ele_Med,Step,x_time,x_stop,StepMatrix,StdMatrix,SpikeCount_Trial,p_peak,Value_peak,TimeIndex_peak,p_trough,Value_trough,TimeIndex_trough,StimulusType);
        %     if ~isempty(CurveFit_Med)
        %         excel.excel27=[FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitMed'];
        %         excel.excel28=CurveFit_Med.excel2;
        %         excel.excel29=CurveFit_Med.excel3;
        %      else
        %         excel.excel27=[FILE(1:end-4)];;
        %         excel.excel28=9999;
        %         excel.excel29=9999;
        %      end
        % %     if ~isempty(CurveFit_Med)
        % %         %Save the figure
        % %         figure(FigureIndex); set(gcf, 'PaperOrientation', 'portrait');
        % %         saveas(gcf,[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitting_Med.png'],'png');close(FigureIndex);
        % %         %Save the Data
        % %         SaveFileName=[OutputPath FILE(1:end-4) '_Ch' num2str(SpikeChan) '_CurveFitMed'];
        % %         save(SaveFileName,'CurveFit_Med'); clear SaveFileName;
        % %     else
        % %     end
    end
end
assignin('base','excel',excel);
result{1}=excel.excel0;%文件名

result{2}=excel.excel1;%vestibular
result{3}=num2str(excel.excel2);%权重
result{4}=num2str(excel.excel3);%持续时间
result{5}=num2str(excel.excel4);%R
result{6}=num2str(excel.excel5);%P

result{7}=excel.excel6;%visual
result{8}=num2str(excel.excel7);%权重
result{9}=num2str(excel.excel8);%持续时间
result{10}=num2str(excel.excel9);%R
result{11}=num2str(excel.excel10);%P

% result{12}=excel.excel11;%combine
% result{13}=num2str(excel.excel12);%权重
% result{14}=num2str(excel.excel13);%持续时间
% result{15}=num2str(excel.excel14);%R
% result{16}=num2str(excel.excel15);%P

% result{2}=excel.excel1;
% result{3}=num2str(excel.excel2);
% result{4}=num2str(excel.excel3);
% result{5}=num2str(excel.excel4);
% result{6}=num2str(excel.excel14);
% result{7}=num2str(excel.excel15);
% result{8}=num2str(excel.excel16);
% result{9}=num2str(excel.excel17);
% result{10}=num2str(excel.excel18);
% result{11}=num2str(excel.excel19);
% result{12}=num2str(excel.excel20);
% result{13}=num2str(excel.excel21);
% result{14}=num2str(excel.excel22);
% result{15}=num2str(excel.excel23);
% result{16}=num2str(excel.excel24);
% result{17}=num2str(excel.excel25);
% result{18}=num2str(excel.excel26);
% result{19}=num2str(excel.excel27);
% result{20}=num2str(excel.excel28);
% result{21}=num2str(excel.excel29);
% result{22}=num2str(excel.excel30);
% result{23}=num2str(excel.excel31);
% result{24}=num2str(excel.excel32);
% result{25}=num2str(excel.excel33);
% result{26}=num2str(excel.excel34);
% result{27}=num2str(excel.excel35);
% result{28}=num2str(excel.excel36);
% result{29}=num2str(excel.excel37);
% result{30}=num2str(excel.excel38);
% result{31}=num2str(excel.excel39);
% result{32}=num2str(excel.excel40);
% result{33}=num2str(excel.excel41);
% result{34}=num2str(excel.excel42);
% result{35}=num2str(excel.excel43);
% 
% result{36}=excel.excel5;
% result{37}=num2str(excel.excel6);
% result{38}=num2str(excel.excel7);
% result{39}=num2str(excel.excel8);
% result{40}=num2str(excel.excel44);
% result{41}=num2str(excel.excel45);
% result{42}=num2str(excel.excel46);
% result{43}=num2str(excel.excel47);
% result{44}=num2str(excel.excel48);
% result{45}=num2str(excel.excel49);
% result{46}=num2str(excel.excel50);
% result{47}=num2str(excel.excel51);
% result{48}=num2str(excel.excel52);
% result{49}=num2str(excel.excel53);
% result{50}=num2str(excel.excel54);
% result{51}=num2str(excel.excel55);
% result{52}=num2str(excel.excel56);
% result{53}=num2str(excel.excel57);
% result{54}=num2str(excel.excel58);
% result{55}=num2str(excel.excel59);
% result{56}=num2str(excel.excel60);
% result{57}=num2str(excel.excel61);
% result{58}=num2str(excel.excel62);
% result{59}=num2str(excel.excel63);
% result{60}=num2str(excel.excel64);
% result{61}=num2str(excel.excel65);
% result{62}=num2str(excel.excel66);
% result{63}=num2str(excel.excel67);
% result{64}=num2str(excel.excel68);
% result{65}=num2str(excel.excel69);
% result{66}=num2str(excel.excel70);
% result{67}=num2str(excel.excel71);
% result{68}=num2str(excel.excel72);
% result{69}=num2str(excel.excel73);
% 
% result{70}=excel.excel9;
% result{71}=num2str(excel.excel10);
% result{72}=num2str(excel.excel11);
% result{73}=num2str(excel.excel12);
% result{74}=num2str(excel.excel74);
% result{75}=num2str(excel.excel75);
% result{76}=num2str(excel.excel76);
% result{77}=num2str(excel.excel77);
% result{78}=num2str(excel.excel78);
% result{79}=num2str(excel.excel79);
% result{80}=num2str(excel.excel80);
% result{81}=num2str(excel.excel81);
% result{82}=num2str(excel.excel82);
% result{83}=num2str(excel.excel83);
% result{84}=num2str(excel.excel84);
% result{85}=num2str(excel.excel85);
% result{86}=num2str(excel.excel86);
% result{87}=num2str(excel.excel87);
% result{88}=num2str(excel.excel88);
% result{89}=num2str(excel.excel89);
% result{90}=num2str(excel.excel90);
% result{91}=num2str(excel.excel91);
% result{92}=num2str(excel.excel92);
% result{93}=num2str(excel.excel93);
% result{94}=num2str(excel.excel94);
% result{95}=num2str(excel.excel95);
% result{96}=num2str(excel.excel96);
% result{97}=num2str(excel.excel97);
% result{98}=num2str(excel.excel98);
% result{99}=num2str(excel.excel99);
% result{100}=num2str(excel.excel100);
% result{101}=num2str(excel.excel101);
% result{102}=num2str(excel.excel102);
% result{103}=num2str(excel.excel103);


xlswrite(strcat(FILE(1:end-4),'_Ch',num2str(SpikeChan),'.xls'),result);





