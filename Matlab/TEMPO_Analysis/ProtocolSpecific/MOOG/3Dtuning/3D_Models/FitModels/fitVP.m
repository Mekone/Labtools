% fit Velocity-acceleration-pos model for 3D tuning
% time (unit: s)
% spon: spontaneous firing rate
% PSTH_data: PSTH data with sliding windows
% spatial_data: 9*5 data according to spatial
% reps: the repetition number to perform for fiiting models
% 20170603LBY

function [modelFitRespon_VP,modelFit_VP, modelFit_VP_spatial, modelFitPara_VP, BIC_VP, RSquared_VP, rss_VP, time] = fitVP(spon,PSTH_data,spatial_data, nBins,reps,stimOnBin,stimOffBin,aMax,aMin,duration)

sprintf('Fitting VP model...')

%-- initialize global using parameters

% spatial parameters
u_azi = [0 45 90 135 180 225 270 315]'*pi/180;
u_ele = [-90 -45 0 45 90]'*pi/180;
s_data = [u_ele;u_azi]; % transform to this form for fitting
% time parameters
time = (1: (stimOffBin - stimOnBin +1))' /(stimOffBin - stimOnBin +1)*duration/1000;
st_data = [u_ele;u_azi;time]; % transform to this form for fitting
% fitting initial parameters

sig = sqrt(sqrt(2))/6;
baseline = spon;
acc_max = aMax/1000; % transfer unit from ms to s
acc_min = aMin/1000; % transfer unit from ms to s
mu = (acc_max+acc_min)/2;

% PSTH data
temporal_data = squeeze(mean(mean(PSTH_data(:,:,:),1),2)); % PSTH data according to time bin
spatial_data = permute(spatial_data,[2 1]);
y_data = permute(PSTH_data, [2 1 3]); % transform to azi*ele*timebin

gauss_time = vel_func([mu sig],time);
d2_gauss_time = pos_func([mu sig],time);

u1 = gauss_time;
p = (u1'*d2_gauss_time)/(u1'*u1);
u2 = d2_gauss_time - p*u1;

t_psth = y_data - baseline;
v_s_profile = zeros([length(u_azi), length(u_ele)]);
p_s_profile = zeros([length(u_azi), length(u_ele)]);

for j=1:length(u_ele),
    for i=1:length(u_azi),
        t_profile = squeeze(t_psth(i,j,:));
        coeff = (pinv([u1 u2])*squeeze(t_profile));
        v_s_profile(i,j) = coeff(1)-coeff(2)*p;
        p_s_profile(i,j) = coeff(2);
    end
end

% normalise time and spatial profile
v_DC = (min(v_s_profile(:))+max(v_s_profile(:)))/2;
v_A = (max(v_s_profile(:))-min(v_s_profile(:)))/2;
v_space_profile = v_s_profile-v_DC;
v_space_profile = v_space_profile/v_A;

p_DC = (min(p_s_profile(:))+max(p_s_profile(:)))/2;
p_A = (max(p_s_profile(:))-min(p_s_profile(:)))/2;
p_space_profile = p_s_profile-p_DC;
p_space_profile = p_space_profile/p_A;


%optimisation parameters for profile fits
options = optimset('Display', 'off', 'MaxIter', 5000);

%% fit velocity spatial profile
%-- 1st, fit spatial profile1

LB = [0.001 0 -pi/2];
UB = [10 2*pi pi/2];

[~, max_idx] = max(v_space_profile(:));
[max_idx_a, max_idx_e] = ind2sub(size(v_space_profile), max_idx);

param = [0.01 u_azi(max_idx_a) u_ele(max_idx_e)];
recon_v = lsqcurvefit('cos_tuning', param,  s_data, ...
    v_space_profile(:), LB, UB, options);
v_n = recon_v(1);
v_a_0 = recon_v(2);
v_e_0 = recon_v(3);

%Initialise spatial tuning function error
ele_azi = cos_tuning(recon_v, s_data);
ele_azi = reshape(ele_azi, length(u_azi), length(u_ele));
v_space_profile2 = v_space_profile - ele_azi;

% normalise time and spatial profile
v_DC2 = (max(v_space_profile2(:)) + min(v_space_profile2(:)))/2;
v_s_A2 = (max(v_space_profile2(:)) - min(v_space_profile2(:)))/2;
v_space_profile2 = (v_space_profile2 - v_DC2)/v_s_A2;


%-- 2nd, fit spatial profile2
[~, max_idx] = max(v_space_profile2(:));
[max_idx_a, max_idx_e] = ind2sub(size(v_space_profile2), max_idx);
param = [0.01 u_azi(max_idx_a) u_ele(max_idx_e)];
recon_v = lsqcurvefit('cos_tuning', param,  s_data, ...
    v_space_profile2(:), LB, UB, options);
v_n2 = recon_v(1);

[x0, y0, z0] = sph2cart(v_a_0, v_e_0, 1);
[x1, y1, z1] = sph2cart(recon_v(2), recon_v(3), 1);
v1 = [1 0 0] - [x0 y0 z0];
v2 = [x1 y1 z1] - [x0 y0 z0];
ang = acos(v1*v2'/(norm(v1)*norm(v2)));

elim = pi/3;
if ang < elim,
    ang = elim;
end
if ang > 2*pi-elim,
    ang = 2*pi-elim;
end
v_a2_0 = ang;
v_e2_0 = recon_v(3)-v_e_0;


%-- 3rd, fit total spatial profile

% initialize fitting
% Inital fits
param = [v_n, ...   %1
    v_a_0, ... %2
    v_e_0, ... %3
    v_n2, ...  %4
    v_a2_0, ...%5
    v_e2_0, ...%6
    v_s_A2, ...%7
    v_DC2];    %8

LB = [0.001 0 -pi/2 0.001 0 elim 0 -2];
UB = [10 2*pi pi/2  10 pi 2*pi-elim 1 2];

recon_v = lsqcurvefit('d_cos_tuning', param, s_data, ...
    v_space_profile(:), LB, UB, options);

v_n    = recon_v(1);
v_a_0  = recon_v(2);
v_e_0  = recon_v(3);
v_n2   = recon_v(4);
v_a2_0 = recon_v(5);
v_e2_0 = recon_v(6);
v_s_A2 = recon_v(7);
v_DC2  = recon_v(8);


%% fit pos spatial profile
LB = [0.001 0 -pi/2];
UB = [10 2*pi pi/2];

[~, max_idx] = max(p_space_profile(:));
[max_idx_a, max_idx_e] = ind2sub(size(p_space_profile), max_idx);

param = [0.01 u_azi(max_idx_a) u_ele(max_idx_e)];
recon_v = lsqcurvefit('cos_tuning', param,  s_data, ...
    p_space_profile(:), LB, UB, options);
p_n = recon_v(1);
p_a_0 = recon_v(2);
p_e_0 = recon_v(3);

%Initialise spatial tuning function error
ele_azi = cos_tuning(recon_v, s_data);
ele_azi = reshape(ele_azi, length(u_azi), length(u_ele));
p_space_profile2 = p_space_profile - ele_azi;

% normalise time and spatial profile
p_DC2 = (max(p_space_profile2(:)) + min(p_space_profile2(:)))/2;
p_s_A2 = (max(p_space_profile2(:)) - min(p_space_profile2(:)))/2;
p_space_profile2 = (p_space_profile2 - p_DC2)/p_s_A2;


% 2nd, fit spatial profile2
[~, max_idx] = max(p_space_profile2(:));
[max_idx_a, max_idx_e] = ind2sub(size(p_space_profile2), max_idx);
param = [0.01 u_azi(max_idx_a) u_ele(max_idx_e)];
recon_v = lsqcurvefit('cos_tuning', param,  s_data, ...
    p_space_profile2(:), LB, UB, options);
p_n2 = recon_v(1);

[x0, y0, z0] = sph2cart(p_a_0, p_e_0, 1);
[x1, y1, z1] = sph2cart(recon_v(2), recon_v(3), 1);
v1 = [1 0 0] - [x0 y0 z0];
v2 = [x1 y1 z1] - [x0 y0 z0];
ang = acos(v1*v2'/(norm(v1)*norm(v2)));

elim = pi/3;
if ang < elim,
    ang = elim;
end
if ang > 2*pi-elim,
    ang = 2*pi-elim;
end
p_a2_0 = ang;
p_e2_0 = recon_v(3)-p_e_0;


% 3rd, fit total spatial profile

% initialize fitting
% Inital fits
param = [p_n, ...   %1
    p_a_0, ... %2
    p_e_0, ... %3
    p_n2, ...  %4
    p_a2_0, ...%5
    p_e2_0, ...%6
    p_s_A2, ...%7
    p_DC2];    %8

LB = [0.001 0 -pi/2 0.001 0 elim 0 -2];
UB = [10 2*pi pi/2  10 pi 2*pi-elim 1 2];

recon_v = lsqcurvefit('d_cos_tuning', param, s_data, ...
    p_space_profile(:), LB, UB, options);

p_n    = recon_v(1);
p_a_0  = recon_v(2);
p_e_0  = recon_v(3);
p_n2   = recon_v(4);
p_a2_0 = recon_v(5);
p_e2_0 = recon_v(6);
p_s_A2 = recon_v(7);
p_DC2  = recon_v(8);
%%

v_DC = v_DC/v_A;
p_DC = p_DC/p_A;

%Fit linear parameters
A = v_A+p_A;
R_0 = baseline;
w_v = v_A/A;
%% fit VP model
mu_t = mu;
sig_t = sig;

%Inital fits
param = [A, ...       %1
    R_0, ...     %2
    mu_t, ...    %3
    sig_t, ...   %4
    v_n, ...       %5
    v_a_0, ...     %6
    v_e_0, ...     %7
    v_n2, ...      %8
    v_a2_0, ...    %9
    v_e2_0, ...    %10
    v_s_A2, ...    %11
    v_DC+v_DC2,... %12
    p_n, ...           %13
    p_a_0, ...         %14
    p_e_0, ...         %15
    p_n2, ...          %16
    p_a2_0, ...        %17
    p_e2_0, ...        %18
    p_s_A2, ...        %19
    p_DC2+p_DC, ...%20
    w_v];            %29

init_param = zeros(reps+1, length(param));
init_param(1,:) = param;

LB = [0.25*A, ...`  %1  A
    0, ...          %2  R_0
    mu-0.1, ...       %3  mu_t
    0.5*sig, ...    %4  sig_t
    0.001, ...      %5  n
    0, ...          %6  a_0
    -pi/2, ...      %7  e_0
    0.001, ...      %8  n2
    0, ...          %9  a2_0
    elim, ...       %10 e2_0
    0, ...          %11 s_A2
    -2,...          %12 v_DC
    0.001, ...      %13 p_n
    0, ...          %14 p_a_0
    -pi/2, ...      %15 p_e_0
    0.001, ...      %16 p_n2
    0, ...          %17 p_a2_0
    elim, ...       %18 p_e2_0
    0, ...          %19 p_s_A2
    -2, ...         %20 p_DC
    0];             %21   w_v

UB = [4*A, ...      %1  A
    300, ...        %2  R_0
    mu+0.1, ...      %3  mu_t
    2*sig, ...      %4  sig_t
    10, ...         %5  n
    2*pi, ...       %6  a_0
    pi/2, ...       %7  e_0
    10, ...         %8  n2
    pi, ...         %9  a2_0
    2*pi-elim, ...  %10 e2_0
    1, ...          %11 s_A2
    2,...          %12 v_DC
    10, ...        %13 p_n
    2*pi, ...      %14 p_a_0
    pi/2, ...      %15 p_e_0
    10, ...        %16 p_n2
    pi, ...        %17 p_a2_0
    2*pi-elim, ... %18 p_e2_0
    1, ...         %19 p_s_A2
    2, ...         %20 p_DC
    1];            %21    w_v


rand_rss = zeros(reps+1,1);
rand_param = zeros(reps+1, length(param));
rand_jac = zeros(reps+1, length(param), length(param));

[rand_param(1,:),rand_rss(1),~,~,~,~,temp_jac] = lsqcurvefit('VP_Model', ...
    init_param(1,:), st_data, y_data, LB, UB, options);
rand_jac(1,:,:) = full(temp_jac)'*full(temp_jac);
min_param = rand_param(1,:);
min_rss = rand_rss(1);
err_range =  0.1*(UB - LB);

% fitting the models
for ii = 2:(reps + 1)
    
    init_param(ii,:) = min_param;
    UB_param = min_param+err_range;
    LB_param = min_param-err_range;
    UB_param(UB < UB_param) = UB(UB < UB_param);
    LB_param(LB > LB_param) = LB(LB > LB_param);
    seed_param  = unifrnd(LB_param, UB_param);
    
    [rand_param(ii,:),rand_rss(ii),~,~,~,~,temp_jac] = lsqcurvefit('VP_Model', ...
        seed_param, st_data, y_data, LB, UB, options);
    rand_jac(ii,:,:) = full(temp_jac)'*full(temp_jac);
    
    if rand_rss(ii) < min_rss
        min_rss = rand_rss(ii);
        min_param = rand_param(ii,:);
    end
    
    
end

% find the best fit parameters according to rss
[~,min_inx] = min(rand_rss);
modelFitPara_VP = rand_param(min_inx,:);
rss_VP = rand_rss(min_inx);
jac_VP = rand_jac(min_inx,:,:);

% calculate the final model fitting values
respon = VP_Model(modelFitPara_VP,st_data);
modelFitRespon_VP = respon;

modelFit_VP.V = VP_V_Com(modelFitPara_VP([1:12,21]),st_data);
modelFit_VP.P = VP_P_Com(modelFitPara_VP([1:4,13:20,21]),st_data);

% model fit spatial tuning
modelFit_VP_spatial.V = d_cos_tuning(modelFitPara_VP(5:12),st_data(1:13));
modelFit_VP_spatial.P = d_cos_tuning(modelFitPara_VP(13:20),st_data(1:13));
%% analysis
data_num = 26*nBins;
para_num = 10;
BIC_VP = BIC_fit(data_num,rss_VP,para_num);
TSS = sum((PSTH_data(:) - mean(PSTH_data(:))).^2);
RSquared_VP = 1 - rss_VP/TSS;

end
