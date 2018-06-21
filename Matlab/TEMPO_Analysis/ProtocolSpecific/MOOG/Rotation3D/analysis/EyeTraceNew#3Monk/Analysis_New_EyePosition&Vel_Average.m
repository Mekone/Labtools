% analyze eyetrace data
clear all
% choose protocol
%
% analyze_protocol = 'rotation_ves';%Que
analyze_protocol = 'rotation_vis';%Azrael
% analyze_protocol = 'translat_ves';%Zebulon
% analyze_protocol = 'translat_vis';


if analyze_protocol == 'rotation_ves'
    aa1 = dlmread('QueEye_Rot_Vet.dat','',1,1);dim=size(aa1)  % load data
    aa2 = dlmread('QueEye_Rot_Vis.dat','',1,1);dim=size(aa2)  % load data
    aa3 = dlmread('QueEye_Tra_Vet.dat','',1,1);dim=size(aa3)  % load data
    aa4 = dlmread('QueEye_Tra_Vis.dat','',1,1);dim=size(aa4)  % load data
%     [names] = textread('Eye_rot_ves.dat','%s',2)
%     filename=names(2);
   
elseif analyze_protocol == 'rotation_vis'
    aa1 = dlmread('AzraelEye_Rot_Vet.dat','',1,1);dim=size(aa1)  % load data
    aa2 = dlmread('AzraelEye_Rot_Vis.dat','',1,1);dim=size(aa2)  % load data
    aa3 = dlmread('AzraelEye_Tra_Vet.dat','',1,1);dim=size(aa3)  % load data
    aa4 = dlmread('AzraelEye_Tra_Vis.dat','',1,1);dim=size(aa4)  % load data
% %     aa = dlmread('Eye_rot_ves.dat','',1,1);  % load data
   
elseif analyze_protocol == 'translat_ves'
    aa3 = dlmread('ZebulonEye_Tra_vet.dat','',1,1);dim=size(aa3)  % load data
    aa4 = dlmread('ZebulonEye_Tra_vis.dat','',1,1);dim=size(aa4)  % load data
    aa1 = dlmread('ZebulonEye_Rot_vet.dat','',1,1);dim=size(aa1)  % load data
    aa2 = dlmread('ZebulonEye_Rot_vis.dat','',1,1);dim=size(aa2)  % load data
%     aa = dlmread('Eye_rot_ves.dat','',1,1);  % load data
    
else
    aa = dlmread('Que_Pursuit_pursuit.dat','',1,1);  % load data 
%     aa = dlmread('Eye_rot_ves.dat','',1,1);  % load data
  
end

    title1 = 'up';
    title2 = 'down';
    title3 = 'left';
    title4 = 'right';
    
% % 1 Rotation vestibular
% aa = dlmread('Eye_rot_ves.dat','',1,1);  % load data


% mean for repeats cells...%Azuel no need
% aa3=aa3(:,1:22402);%Que 
% aa3=aa3(:,1:19202);%Zebulon or for Zebulon do not need


aa=[aa1;aa2;aa3;aa4];


repeat = aa(:,1); % 1st column is repeatition, else are the raw eye trace
dim = size(aa)

% definition for sum all cells (>300), {i}
        res_x_up_sum(1,1:400) = 0;
        res_y_up_sum(1,1:400) = 0;
        res_x_down_sum(1,1:400) = 0;
        res_y_down_sum(1,1:400)  = 0;
        res_x_left_sum(1,1:400)  = 0;
        res_y_left_sum(1,1:400)  = 0;
        res_x_right_sum(1,1:400)  = 0;
        res_y_right_sum(1,1:400)  = 0;
        
        vel_x_up_sum(1,1:399) = 0;
%         vel_x_up_sum2(1,1:400) = 0;
        vel_y_up_sum(1,1:399) = 0;
        vel_x_down_sum(1,1:399) = 0;
        vel_y_down_sum(1,1:399) = 0;
        vel_x_left_sum(1,1:399) = 0;
        vel_y_left_sum(1,1:399) = 0;
        vel_x_right_sum(1,1:399) = 0;
        vel_y_right_sum(1,1:399) = 0;
        
          vel_x_up_sum2(1,1:400) = 0;
%         vel_x_up_sum2(1,1:400) = 0;
        vel_y_up_sum2(1,1:400) = 0;
        vel_x_down_sum2(1,1:400) = 0;
        vel_y_down_sum2(1,1:400) = 0;
        vel_x_left_sum2(1,1:400) = 0;
        vel_y_left_sum2(1,1:400) = 0;
        vel_x_right_sum2(1,1:400) = 0;
        vel_y_right_sum2(1,1:400) = 0;
        
% reconstruct into matrixs
% 2 files on 1 figure

for i = 1 : dim(1)  % How many cells?
   
        res_x_up(i,:) = aa(i, 2:401);
        res_y_up(i,:) = aa(i, 402:801);
        res_x_down(i,:)= aa(i, 802:1201);
        res_y_down(i,:)= aa(i, 1202:1601);
        res_x_left(i,:) = aa(i, 1602:2001);
        res_y_left(i,:) = aa(i, 2002:2401);
        res_x_right(i,:) = aa(i, 2402:2801);
        res_y_right(i,:) = aa(i, 2802:3201);
        
        
        % Convert to velosity
        vel_x_up(i,:) = diff(res_x_up(i,:))*1000/5;
%         vel_x_up2{i}(j,:) = fderiv(res_x_up{i}(j,:),15,200);
        vel_y_up(i,:) = diff(res_y_up(i,:))*200;
        vel_x_down(i,:) = diff(res_x_down(i,:))*200;
        vel_y_down(i,:) = diff(res_y_down(i,:))*200;
        vel_x_left(i,:) = diff(res_x_left(i,:))*200;
        vel_y_left(i,:) = diff(res_y_left(i,:))*200;
        vel_x_right(i,:) = diff(res_x_right(i,:))*200;
        vel_y_right(i,:) = diff(res_y_right(i,:))*200;
        
               % Convert to velosity 2
        vel_x_up2(i,:) = fderiv(res_x_up(i,:),15,200);
%         vel_x_up2{i}(j,:) = fderiv(res_x_up{i}(j,:),15,200);
        vel_y_up2(i,:) = fderiv(res_y_up(i,:),15,200);
        vel_x_down2(i,:) = fderiv(res_x_down(i,:),15,200);
        vel_y_down2(i,:) = fderiv(res_y_down(i,:),15,200);
        vel_x_left2(i,:) = fderiv(res_x_left(i,:),15,200);
        vel_y_left2(i,:) = fderiv(res_y_left(i,:),15,200);
        vel_x_right2(i,:) = fderiv(res_x_right(i,:),15,200);
        vel_y_right2(i,:) = fderiv(res_y_right(i,:),15,200);
      

        res_x_up_sum = res_x_up(i,:)+res_x_up_sum;
        res_y_up_sum =  res_y_up(i,:)+res_y_up_sum;
        res_x_down_sum = res_x_down(i,:)+res_x_down_sum;
        res_y_down_sum = res_y_down(i,:)+res_y_down_sum ;
        res_x_left_sum = res_x_left(i,:)+res_x_left_sum ;
        res_y_left_sum = res_y_left(i,:)+res_y_left_sum;
        res_x_right_sum = res_x_right(i,:)+res_x_right_sum ;
        res_y_right_sum =  res_y_right(i,:)+res_y_right_sum;
        
        vel_x_up_sum = vel_x_up(i,:)+vel_x_up_sum;
        vel_y_up_sum = vel_y_up(i,:)+vel_y_up_sum;
        vel_x_down_sum = vel_x_down(i,:)+vel_x_down_sum;
        vel_y_down_sum = vel_y_down(i,:)+vel_y_down_sum;
        vel_x_left_sum = vel_x_left(i,:)+vel_x_left_sum;
        vel_y_left_sum = vel_y_left(i,:)+vel_y_left_sum;
        vel_x_right_sum = vel_x_right(i,:)+vel_x_right_sum;
        vel_y_right_sum = vel_y_right(i,:)+vel_y_right_sum;
        
         vel_x_up_sum2 = vel_x_up2(i,:)+vel_x_up_sum2;
        vel_y_up_sum2 = vel_y_up2(i,:)+vel_y_up_sum2;
        vel_x_down_sum2 = vel_x_down2(i,:)+vel_x_down_sum2;
        vel_y_down_sum2 = vel_y_down2(i,:)+vel_y_down_sum2;
        vel_x_left_sum2 = vel_x_left2(i,:)+vel_x_left_sum2;
        vel_y_left_sum2 = vel_y_left2(i,:)+vel_y_left_sum2;
        vel_x_right_sum2 = vel_x_right2(i,:)+vel_x_right_sum2;
        vel_y_right_sum2 = vel_y_right2(i,:)+vel_y_right_sum2;
end         
        res_x_up_cellmean = res_x_up_sum/dim(1);% dim(1)= how many cells are there?
        res_y_up_cellmean =  res_y_up_sum/dim(1);
        res_x_down_cellmean = res_x_down_sum/dim(1);
        res_y_down_cellmean = res_y_down_sum/dim(1) ;
        res_x_left_cellmean = res_x_left_sum/dim(1) ;
        res_y_left_cellmean = res_y_left_sum/dim(1);
        res_x_right_cellmean = res_x_right_sum/dim(1) ;
        res_y_right_cellmean =  res_y_right_sum/dim(1);
        
        vel_x_up_cellmean = vel_x_up_sum/dim(1);
%         vel_x_up_cellmean2 = vel_x_up_sum2/dim(1);
        vel_y_up_cellmean = vel_y_up_sum/dim(1);
        vel_x_down_cellmean = vel_x_down_sum/dim(1);
        vel_y_down_cellmean = vel_y_down_sum/dim(1);
        vel_x_left_cellmean = vel_x_left_sum/dim(1);
        vel_y_left_cellmean = vel_y_left_sum/dim(1);
        vel_x_right_cellmean = vel_x_right_sum/dim(1);
        vel_y_right_cellmean = vel_y_right_sum/dim(1);
        
        vel_x_up_cellmean2 = vel_x_up_sum2/dim(1);
%         vel_x_up_cellmean2 = vel_x_up_sum2/dim(1);
        vel_y_up_cellmean2 = vel_y_up_sum2/dim(1);
        vel_x_down_cellmean2 = vel_x_down_sum2/dim(1);
        vel_y_down_cellmean2 = vel_y_down_sum2/dim(1);
        vel_x_left_cellmean2 = vel_x_left_sum2/dim(1);
        vel_y_left_cellmean2 = vel_y_left_sum2/dim(1);
        vel_x_right_cellmean2 = vel_x_right_sum2/dim(1);
        vel_y_right_cellmean2 = vel_y_right_sum2/dim(1);


% % Furthermore, mean and get each direction's eye movement depth (use only
% % midline 1sec)>>>>>1-400 coloum  (0-2sec) ===>> take 100-300 (0.5-1.5sec)
% for i=1:2
%   m_res_x_up(i) = mean(res_x_up_cellmean(201-(100*i):199+(100*i)));
%   m_res_y_up(i) = mean(res_y_up_cellmean(201-(100*i):199+(100*i)));
%   m_res_x_down(i) = mean(res_x_down_cellmean(201-(100*i):199+(100*i)));
%   m_res_y_down(i) = mean(res_y_down_cellmean(201-(100*i):199+(100*i)));
%   m_res_x_left(i) = mean(res_x_left_cellmean(201-(100*i):199+(100*i)));
%   m_res_y_left(i) = mean(res_y_left_cellmean(201-(100*i):199+(100*i)));
%   m_res_x_right(i) = mean(res_x_right_cellmean(201-(100*i):199+(100*i)));
%   m_res_y_right(i) = mean(res_y_right_cellmean(201-(100*i):199+(100*i)));
%   
%   m_vel_x_up(i) = mean(vel_x_up_cellmean(201-(100*i):199+(100*i)));
% %   mean(vel_x_up_cellmean2(100:300))
%   m_vel_y_up(i) = mean(vel_y_up_cellmean(201-(100*i):199+(100*i)));
%   m_vel_x_down(i) = mean(vel_x_down_cellmean(201-(100*i):199+(100*i)));
%   m_vel_y_down(i) = mean(vel_y_down_cellmean(201-(100*i):199+(100*i)));
%   m_vel_x_left(i) = mean(vel_x_left_cellmean(201-(100*i):199+(100*i)));
%   m_vel_y_left(i) = mean(vel_y_left_cellmean(201-(100*i):199+(100*i)));
%   m_vel_x_right(i) = mean(vel_x_right_cellmean(201-(100*i):199+(100*i)));
%   m_vel_y_right(i) = mean(vel_y_right_cellmean(201-(100*i):199+(100*i)));
% end
       
% figure(4)
% plot(vel_x_up_cellmean2,'b.');
%     hold on;
%     xlim( [1, 400] );
%     set(gca, 'XTickMode','manual');
%     set(gca, 'xtick',[1,100,200,300,400]);
%     set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-0.1, 0.1]);
%     ylabel('(deg)');        
        
       


%%%%%%%%%%%%%%%plot data%%%%%%%%%%%%%%%%%%%%%%
figure(2)

subplot(4,1,1)
plot(res_x_up_cellmean,'r.');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-0.5, 0.5]);
    ylabel('(deg)');
    title(['Eye Position /  ',title1]);

    plot(res_y_up_cellmean,'b.');
    hold off;


subplot(4,1,2)
plot(res_x_down_cellmean,'r.');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-0.5, 0.5]);
    ylabel('(deg)');
    title(['Eye Position /  ',title2]);

    plot(res_y_down_cellmean,'b.');
    hold off;

subplot(4,1,3)
plot(res_x_left_cellmean,'r.');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-0.5, 0.5]);
    ylabel('(deg)');
    title(['Eye Position /  ',title3]);

    plot(res_y_left_cellmean,'b.');
    hold off;
    
subplot(4,1,4)
plot(res_x_right_cellmean,'r.');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-0.5, 0.5]);
    ylabel('(deg)');
    title(['Eye Position /  ',title4]);

    plot(res_y_right_cellmean,'b.');
    hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(3)

subplot(4,1,1)
plot(vel_x_up_cellmean,'r');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-50, 50]);
    ylabel('(deg/sec)');
    title(['Velocity /  ',title1]);

    plot(vel_y_up_cellmean,'b');
    hold off;


subplot(4,1,2)
plot(vel_x_down_cellmean,'r');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-50, 50]);
    ylabel('(deg/sec)');
    title(['Velocity /  ',title2]);

    plot(vel_y_down_cellmean,'b');
    hold off;

subplot(4,1,3)
plot(vel_x_left_cellmean,'r');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-50, 50]);
    ylabel('(deg/sec)');
    title(['Velocity /  ',title3]);

    plot(vel_y_left_cellmean,'b');
    hold off;
    
subplot(4,1,4)
plot(vel_x_right_cellmean,'r');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-50, 50]);
    ylabel('(deg/sec)');
    title(['Velocity /  ',title4]);

    plot(vel_y_right_cellmean,'b');
    hold off;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)

subplot(4,1,1)
plot(vel_x_up_cellmean2,'r');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-50, 50]);
    ylabel('(deg/sec)');
    title(['Velocity /  ',title1]);

    plot(vel_y_up_cellmean2,'b');
    hold off;


subplot(4,1,2)
plot(vel_x_down_cellmean2,'r');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-50, 50]);
    ylabel('(deg/sec)');
    title(['Velocity /  ',title2]);

    plot(vel_y_down_cellmean2,'b');
    hold off;

subplot(4,1,3)
plot(vel_x_left_cellmean2,'r');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-50, 50]);
    ylabel('(deg/sec)');
    title(['Velocity /  ',title3]);

    plot(vel_y_left_cellmean2,'b');
    hold off;
    
subplot(4,1,4)
plot(vel_x_right_cellmean2,'r');
    hold on;
    xlim( [1, 400] );
    set(gca, 'XTickMode','manual');
    set(gca, 'xtick',[1,100,200,300,400]);
    set(gca, 'xticklabel','0|0.5|1|1.5|2'); 
%     ylim([-50, 50]);
    ylabel('(deg/sec)');
    title(['Velocity /  ',title4]);

    plot(vel_y_right_cellmean2,'b');
    hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% middle 1 sec 101-299
% all 2 sec 1 - 399
%


for i=1:2
    if i==1
  mix_position_101_299 = [res_x_up_cellmean(201-(100*i):199+(100*i));...
  res_y_up_cellmean(201-(100*i):199+(100*i));...
  res_x_down_cellmean(201-(100*i):199+(100*i));...
  res_y_down_cellmean(201-(100*i):199+(100*i));...
  res_x_left_cellmean(201-(100*i):199+(100*i));...
  res_y_left_cellmean(201-(100*i):199+(100*i));...
  res_x_right_cellmean(201-(100*i):199+(100*i));...
  res_y_right_cellmean(201-(100*i):199+(100*i))];
  
  mix_velocity_101_299 = [vel_x_up_cellmean(201-(100*i):199+(100*i));...
  vel_y_up_cellmean(201-(100*i):199+(100*i));...
  vel_x_down_cellmean(201-(100*i):199+(100*i));...
  vel_y_down_cellmean(201-(100*i):199+(100*i));...
  vel_x_left_cellmean(201-(100*i):199+(100*i));...
  vel_y_left_cellmean(201-(100*i):199+(100*i));...
  vel_x_right_cellmean(201-(100*i):199+(100*i));...
  vel_y_right_cellmean(201-(100*i):199+(100*i))];

    mix_velocity2_101_299 = [vel_x_up_cellmean(201-(100*i):199+(100*i));...
  vel_y_up_cellmean2(201-(100*i):199+(100*i));...
  vel_x_down_cellmean2(201-(100*i):199+(100*i));...
  vel_y_down_cellmean2(201-(100*i):199+(100*i));...
  vel_x_left_cellmean2(201-(100*i):199+(100*i));...
  vel_y_left_cellmean2(201-(100*i):199+(100*i));...
  vel_x_right_cellmean2(201-(100*i):199+(100*i));...
  vel_y_right_cellmean2(201-(100*i):199+(100*i))];

    elseif i==2
   mix_position_1_399 = [res_x_up_cellmean(201-(100*i):199+(100*i));...
  res_y_up_cellmean(201-(100*i):199+(100*i));...
  res_x_down_cellmean(201-(100*i):199+(100*i));...
  res_y_down_cellmean(201-(100*i):199+(100*i));...
  res_x_left_cellmean(201-(100*i):199+(100*i));...
  res_y_left_cellmean(201-(100*i):199+(100*i));...
  res_x_right_cellmean(201-(100*i):199+(100*i));...
  res_y_right_cellmean(201-(100*i):199+(100*i))];
  
  mix_velocity_1_399 = [vel_x_up_cellmean(201-(100*i):199+(100*i));...
  vel_y_up_cellmean(201-(100*i):199+(100*i));...
  vel_x_down_cellmean(201-(100*i):199+(100*i));...
  vel_y_down_cellmean(201-(100*i):199+(100*i));...
  vel_x_left_cellmean(201-(100*i):199+(100*i));...
  vel_y_left_cellmean(201-(100*i):199+(100*i));...
  vel_x_right_cellmean(201-(100*i):199+(100*i));...
  vel_y_right_cellmean(201-(100*i):199+(100*i))];

  mix_velocity2_1_399 = [vel_x_up_cellmean(201-(100*i):199+(100*i));...
  vel_y_up_cellmean2(201-(100*i):199+(100*i));...
  vel_x_down_cellmean2(201-(100*i):199+(100*i));...
  vel_y_down_cellmean2(201-(100*i):199+(100*i));...
  vel_x_left_cellmean2(201-(100*i):199+(100*i));...
  vel_y_left_cellmean2(201-(100*i):199+(100*i));...
  vel_x_right_cellmean2(201-(100*i):199+(100*i));...
  vel_y_right_cellmean2(201-(100*i):199+(100*i))];  

    end
    
end
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5        output files  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

    m_pos_101_299=mean(mean(mix_position_101_299));
    s_pos_101_299=std(std(mix_position_101_299));
    m_vel_101_299=mean(mean(mix_velocity_101_299));
    s_vel_101_299=std(std(mix_velocity_101_299));
    m_vel2_101_299=mean(mean(mix_velocity2_101_299));
    s_vel2_101_299=std(std(mix_velocity2_101_299));

    space=[0];
    
    summary_101_299=[m_pos_101_299 s_pos_101_299 space m_vel_101_299 s_vel_101_299 m_vel2_101_299 s_vel2_101_299]
    csvwrite('summary_101_299.dat',summary_101_299);
    
% 	csvwrite('m_pos_101_299.dat',m_pos_101_299);
%     csvwrite('m_vel_101_299.dat',m_vel_101_299);
%     csvwrite('s_pos_101_299.dat',s_pos_101_299);
%     csvwrite('s_vel_101_299.dat',s_vel_101_299);
    
    m_pos_1_399=mean(mean(mix_position_1_399));
    s_pos_1_399=std(std(mix_position_1_399));
    m_vel_1_399=mean(mean(mix_velocity_1_399));
    s_vel_1_399=std(std(mix_velocity_1_399));
    m_vel2_1_399=mean(mean(mix_velocity2_1_399));
    s_vel2_1_399=std(std(mix_velocity2_1_399));
    
    summary_1_399=[m_pos_1_399 s_pos_1_399 space m_vel_1_399 s_vel_1_399 m_vel2_1_399 s_vel2_1_399]
    csvwrite('summary_1_399.dat',summary_1_399);

%       csvwrite('m_pos_1_399.dat',m_pos_1_399);
%       csvwrite('m_vel_1_399.dat',m_vel_1_399);
%       csvwrite('s_pos_1_399.dat',s_pos_1_399);
%       csvwrite('s_vel_1_399.dat',s_vel_1_399);
