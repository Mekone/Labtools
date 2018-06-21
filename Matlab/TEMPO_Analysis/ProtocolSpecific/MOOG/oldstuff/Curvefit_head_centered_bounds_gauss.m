%-----------------------------------------------------------------------------------------------------------------------
%-- Curvefit_head_centered_bounds.m -- Create bounds for head centered model.
%-- Created - pwatkins, 4/04
%-----------------------------------------------------------------------------------------------------------------------
function R = Curvefit_head_centered_bounds(trial_data, num_gazes)

Curvefit_defines;

dyn_terms = 0;  % no define - dependent on this module anyways,
                % and computed elsewhere as: 
                % (total_terms - FIXED_PARAMS) / num_gazes
terms = CURVEFIT_NUM_FIXED_PARAMETERS_HC_7P_ASP_NG + dyn_terms*num_gazes;

% % create bounds for the fixed parameters for this model.
% % the fixed parameters are azimuth and elevation rotation angles.
% lb = [-2*pi  -2*pi   .001   0   0   -1 .001];
% ub = [ 2*pi   2*pi  pi   5e3 5e3 1 pi/2];
lb = [-2*pi  -2*pi  0   0   0.01  0.01  -1];
ub = [ 2*pi   2*pi  5e3 5e3 pi/3  pi/5   1];

% Compute a guess at the amplitude by taking the amplitude of the average
% data over all repititions.
% See DirectionTuningPlot_Curvefit for a description of the trial_data
% structure.
if length(trial_data) == 0
    amplitude = 100*rand(1,num_gazes);
else
    amplitude = (max(trial_data(:,:,1)) - min(trial_data(:,:,1)))/2;
end

% create a completely random but tightly bounded initial x0 guess.

% create initial guess for the fixed parameters for this model.
% the fixed parameters are azimuth and elevation rotation angles.
% x0 = rand(1,CURVEFIT_NUM_FIXED_PARAMETERS_HC_7P_ASP_NG).*[2*pi pi (pi/2)-.001 0 0 2 (pi/4)-.001] - [pi pi/2 -.001 -amplitude -amplitude 1 -.001];
x0 = rand(1,CURVEFIT_NUM_FIXED_PARAMETERS_HC_7P_ASP_NG).*[2*pi pi 0 0 pi/3-0.1 pi/5-0.1 2] - ...
    [pi pi/2 -amplitude -amplitude -0.1 -0.1 1];

R{CURVEFIT_BOUNDS_X0} = x0;
R{CURVEFIT_BOUNDS_LB} = lb;
R{CURVEFIT_BOUNDS_UB} = ub;
