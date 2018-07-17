
hidden_unit_outputs = hidden_outputs(:,2:4,:,:);
hidden_unit_gaze_angles_r = unique_gaze_angles_xr(2:4);
hidden_unit_num_gaze_angles = length(hidden_unit_gaze_angles);

hidden_unit_amplitude = zeros(num_stim_types,hidden_unit_num_gaze_angles,...
    num_hidden_units);
hidden_unit_pref_dir_az = zeros(num_stim_types,hidden_unit_num_gaze_angles,...
    num_hidden_units);
hidden_unit_pref_dir_el = zeros(num_stim_types,hidden_unit_num_gaze_angles,...
    num_hidden_units);

for m=1:num_stim_types
    for j=1:hidden_unit_num_gaze_angles
        for i=1:num_hidden_units

            tmp_out(1:num_unique_points) = hidden_unit_outputs(m,j,:,i);
            tmp_out = tmp_out - min(tmp_out);
            
            hidden_unit_amplitude(m,j,i) = max(tmp_out);

            [x y z] = sph2cart(unique_point_azimuth_r, unique_point_elevation_r, tmp_out);
            x = sum(x); y = sum(y); z = sum(z);
            [hidden_unit_pref_dir_az(m,j,i) hidden_unit_pref_dir_el(m,j,i) r] = cart2sph(x,y,z);
        end
    end
end

save('-v6','network_data.mat',...
    'hidden_unit_outputs',...
    'hidden_unit_amplitude',...
    'hidden_unit_pref_dir_az',...
    'hidden_unit_pref_dir_el',...
    'hidden_unit_gaze_angles_r',...
    'hidden_unit_num_gaze_angles',...
    'num_stim_types',...
    'num_hidden_units',...
    'unique_point_azimuth_r',...
    'unique_point_elevation_r',...
    'num_unique_points'...
);
