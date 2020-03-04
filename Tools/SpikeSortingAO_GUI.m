% 1. This is for catenating *.mat files converted from alpha-omega *.mpx files (limited by 1G) together
% These .mat files were converted by Mapfile
% 2. Do sipke sorting based on these .mat files using wave_clus
% LBY 20191125

function h1 = SpikeSortingAO_GUI()

clear all;clc;
%close all;

global ori_data output monkeys;
ori_data = [];
monkeys = {'Polo';'Qiaoqiao'}; % Add or change Monkeys here

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', 403.003784179688, ...
    'taginfo', struct(...
    'figure', 2, ...
    'text', 9, ...
    'edit', 5, ...
    'pushbutton', 9, ...
    'popupmenu', 2), ...
    'override', 0, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 0, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastFilename', 'Z:\Labtools\Tools\SpikeSortingAO_GUI.fig');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
    'Units','characters',...
    'Color',[0.941176470588235 0.941176470588235 0.941176470588235],...
    'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
    'IntegerHandle','off',...
    'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
    'MenuBar','none',...
    'Name','---- Spike sorting (.mat) GUI ----',...
    'NumberTitle','off',...
    'PaperPosition',get(0,'defaultfigurePaperPosition'),...
    'Position',[-150 47.84615384615385 98.0 32.15384615384615],...
    'Resize','off',...
    'HandleVisibility','callback',...
    'UserData',[],...
    'Tag','figure1');

h2 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',12,...
    'FontWeight','bold',...
    'HorizontalAlignment','left',...
    'Position',[6.5 27.84615384615398 17.8 2.38461538461538],...
    'String','Monkey: ',...
    'Style','text',...
    'Tag','text1');

h3 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',12,...
    'FontWeight','bold',...
    'HorizontalAlignment','left',...
    'Position',[6.5 24.76923076923086 17.8 2.38461538461538],...
    'String','File name:',...
    'Style','text',...
    'Tag','text2');

hMonkey = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'FontSize',12,...
    'Position',[23.4 27.846153846153868 22 2.76923076923077],...
    'String',monkeys,...
    'Style','popupmenu',...
    'Value',1);

h22 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',12,...
    'FontWeight','bold',...
    'HorizontalAlignment','left',...
    'Position',[6.5 21.923076923076955 9.2 2.38461538461538],...
    'String','#Ch:',...
    'Style','text',...
    'Tag','text1');

hChNo = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'Position',[14.8 22.38461538461536 6.8 2.23076923076923],...
    'String','16',...
    'Style','edit',...
    'Tag','channel number');

h_fileName = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'Position',[23.4 25.230769230769265 22 2.23076923076923],...
    'String','m?c?r?',...
    'Style','edit',...
    'Tag','Filename');

% Good stuffs for change filename. Copy from HH20130831
fileNametemp = textread('Z:\Labtools\Tools\MergeAO_LastFileName.txt','%s');
fileName = fileNametemp{:};
set(h_fileName,'string',fileName);


h5 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',{@ChangeFileName,h_fileName},...
    'Position',[23.4 22.692307692307764 5 1.76923076923077],...
    'String','+c',...
    'FontWeight','bold',...
    'Tag','pushbutton1');


h6 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',{@ChangeFileName,h_fileName},...
    'Position',[29 22.692307692307764 5 1.76923076923077],...
    'String','-c',...
    'FontWeight','bold',...
    'Tag','pushbutton2');

h7 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',{@ChangeFileName,h_fileName},...
    'Position',[36.8000000000001 22.692307692307764 5 1.76923076923077],...
    'String','+r',...
    'FontWeight','bold',...
    'Tag','pushbutton3');

h8 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',{@ChangeFileName,h_fileName},...
    'Position',[42.4 22.692307692307764 5 1.76923076923077],...
    'String','-r',...
    'FontWeight','bold',...
    'Tag','pushbutton4');

h11 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',19,...
    'FontWeight','bold',...
    'ForegroundColor',[0.313725490196078 0.313725490196078 0.313725490196078],...
    'HorizontalAlignment','right',...
    'Position',[46 25.846153846153868 45 5.61538461538462],...
    'String',{'SPIKE SORTING'},...
    'Style','text',...
    'Tag','text3');

h_pathName = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'FontSize',11,...
    'HorizontalAlignment','left',...
    'Position',[23.4 19.26923076923078 56.6 2.23076923076923],...
    'String','Z:\Data\MOOG\Polo\raw\LA\',...
    'Style','edit',...
    'Tag','Pathname');

hSavePath = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'FontSize',11,...
    'HorizontalAlignment','left',...
    'Position',[23.4 16.384615384615426 56.6 2.23076923076923],...
    'String','Z:\Data\MOOG\Polo\raw\LA\',...
    'Style','edit',...
    'Tag','SavePath');

hRefreshDataPath = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',11,...
    'callback',{@ChangeDataPath,hMonkey,h_fileName, h_pathName,hSavePath},...
    'HorizontalAlignment','left',...
    'Position',[6.5 19.26923076923078 15 2.38461538461538],...
    'String','Data path:',...
    'Style','pushbutton');

hRefreshSavePath = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',11,...
    'callback',{@ChangeSavePath,h_pathName,hSavePath},...
    'HorizontalAlignment','left',...
    'Position',[6.5 16.269230769230788 15 2.38461538461538],...
    'String','Save path:',...
    'Style','pushbutton');

hBrowseOpen = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',{@BrowseOpen,monkeys,hMonkey,h_fileName,h_pathName,hSavePath},...
    'Position',[82.2 19.346153846153857 10.6 2.23076923076923],...
    'String','Browse',...
    'Tag','BrowseOpen');

hBrowseSave = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',{@FileSave,hSavePath},...
    'Position',[82.2 16.44615384615386 10.6 2.23076923076923],...
    'String','Browse',...
    'Tag','BrowseSave');

hLoadData = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback','mergeAO(''load data'')',...
    'FontSize',12,...
    'FontWeight','bold',...
    'ForegroundColor',[0 0.2667 0.6863],...
    'Position',[23 8.846153846153852 20 3.23076923076923],...
    'String','Load data',...
    'Tag','LoadData');

hInfo = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback','mergeAO(''show info'')',...
    'FontSize',12,...
    'FontWeight','bold',...
    'ForegroundColor',[0 0.6902 0.3137],...
    'Position',[45 8.846153846153852 12 3.23076923076923],...
    'String','Info',...
    'Tag','info');

hInfoShowPanel = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'ForegroundColor',[0 0.6902 0.3137],...
    'Position',[57 22.84615384615385 35 5.30769230769231],...
    'String','Information of the data',...
    'Style','listbox',...
    'FontWeight','bold',...
    'Value',1,...
    'Tag','InfoShowPanel');

hMergeAO = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback','mergeAO(''merge files'')',...
    'FontSize',16,...
    'FontWeight','bold',...
    'ForeGroundColor',[0.8 0 0],...
    'Position',[59 8.846153846153852 12 3.23076923076923],...
    'String','GO!',...
    'Tag','pushbutton6');

hToMat = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@OpenMapfile,...
'FontSize',12,...
'FontWeight','bold',...
'ForegroundColor',[0.247058823529412 0.247058823529412 0.247058823529412],...
'Position',[6 8.846153846153852 15 3.23076923076923],...
'String','To .mat');

hSaveFiles = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback','mergeAO(''save files'')',...
    'FontSize',12,...
    'FontWeight','bold',...
    'ForegroundColor',[1 0.2353 0.1294],...
    'Position',[73 8.846153846153852 20 3.23076923076923],...
    'String','Save files',...
    'Tag','save files');

hRefresh = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',{@Refresh,h_fileName, h_pathName},...
'FontSize',6,...
'Position',[46.4 25.230769230769265 8 2.23076923076923],...
'String','Refresh',...
'Tag','pushbutton1');

h26 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'FontSize',12,...
'FontWeight','bold',...
'HorizontalAlignment','left',...
'Position',[6.8 12.230769230769234 33.2 2.38461538461538],...
'String','Merge AO files : ',...
'Style','text');

h27 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'FontSize',12,...
'FontWeight','bold',...
'HorizontalAlignment','left',...
'Position',[6.8 5 53.4 2.38461538461538],...
'String','Spike sorting ( Wave_clus ) : ',...
'Style','text');

h28 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',{@SpikeDetection,hSavePath},...
'FontSize',12,...
'FontWeight','bold',...
'ForegroundColor',[0.247058823529412 0.247058823529412 0.247058823529412],...
'Position',[6 1.15384615384615 17.8 3.23076923076923],...
'String','Detection',...
'Tag','detection');

h29 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',{@SpikeClustering,hSavePath},...
'FontSize',12,...
'FontWeight','bold',...
'ForegroundColor',[0.247058823529412 0.247058823529412 0.247058823529412],...
'Position',[26 1.15384615384615 14 3.23076923076923],...
'String','Cluster',...
'Tag','cluster');

h30 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@SpikeSorting,...
'FontSize',16,...
'FontWeight','bold',...
'ForegroundColor',[0.8 0 0],...
'Position',[42.6 1.15384615384615 17.8 3.23076923076923],...
'String','Sorting',...
'Tag','SpikeSorting');

h31 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@OpenWaveclus,...
'FontSize',12,...
'FontWeight','bold',...
'ForegroundColor',[0.247058823529412 0.247058823529412 0.247058823529412],...
'Position',[63.8 1.15384615384615 29.4 3.23076923076923],...
'String','Open wave_clus');

saveas(h1,'Z:\Labtools\Tools\SpikeSortingAO_GUI.fig');

%%%%%%%%%%%%% Functions

function ChangeFileName(src, ~, h_fileName)
fileName = get(h_fileName,'String');
c_pos = find(fileName == 'c', 1);
r_pos = find(fileName == 'r',1);
dot_pos = find(fileName=='.',1);

if ~isempty(dot_pos)
    fileName = fileName(1:dot_pos-1);
end

if ~isempty(c_pos) && ~isempty(r_pos)
    switch get(src,'string')
        case '+c'
            value = str2double(fileName(c_pos+1:r_pos-1)) + 1;
            fileName = [fileName(1:c_pos) num2str(value) 'r1'];
        case '-c'
            value = str2double(fileName(c_pos+1:r_pos-1));
            value = value - 1 * (value~=1);
            fileName = [fileName(1:c_pos) num2str(value) 'r1'];
        case '+r'
            value = str2double(fileName(r_pos+1:end)) + 1;
            fileName = [fileName(1:r_pos) num2str(value)];
        case '-r'
            value = str2double(fileName(r_pos+1:end));
            value = value - 1 * (value~=1);
            fileName = [fileName(1:r_pos) num2str(value)];
    end
    
    if ~isempty(dot_pos) fileName = [fileName '.htb']; end
    set(h_fileName,'String',fileName);
    
end

function BrowseOpen(src,~,monkeys,hMonkey,h_fileName,h_pathName,hSavePath)

filename = get(h_fileName,'string');
pathname = ['Z:\Data\MOOG\',monkeys{get(hMonkey,'value')},'\raw\LA\',filename,'\'];
% PATH = get(h_pathName, 'String');
fname = uigetdir(pathname,'Select the directory');
if (fname ~= 0)
    set(h_pathName, 'String', fname);
    set(hSavePath, 'String', fname); % Set save path the same as the file open path
end

function FileSave(src,~,hSavePath)

PATH = get(hSavePath, 'String');
fname = uigetdir(PATH,'Select the directory you want to save the files');
if (fname ~= 0)
    set(hSavePath, 'String', fname); % Set the new save path
end

function ChangeDataPath(src,~,hMonkey,h_fileName, h_pathName,hSavePath)
global monkeys;
fileNametemp = get(h_fileName,'string');
set(h_pathName,'string',['Z:\Data\MOOG\',monkeys{get(hMonkey,'value')},'\raw\LA\',fileNametemp]);
filePath = get(h_pathName,'string');
set(hSavePath,'string',filePath);

function ChangeSavePath(src,~,h_pathName,hSavePath)

filePath = get(h_pathName,'string');
set(hSavePath,'string',filePath);

function Refresh(src,~,h_fileName, h_pathName)

filePathName = get(h_pathName,'string');
fileNameTemp = filePathName(end-8:end);
set(h_fileName,'string',fileNameTemp);

function OpenMapfile(src,~)

winopen('E:\Converter\Mapfile.exe')

function SpikeDetection(src,~,hSavePath)

cd(get(hSavePath,'string'));
Get_spikes('detection.txt');


function SpikeClustering(src,~,hSavePath)

cd(get(hSavePath,'string'));
Do_clustering('cluster.txt');

function SpikeSorting(src,~,hSavePath)

cd(get(hSavePath,'string'));
Get_spikes('detection.txt');
Do_clustering('cluster.txt');

function OpenWaveclus(src,~)

wave_clus; 