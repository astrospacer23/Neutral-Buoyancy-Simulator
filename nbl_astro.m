clc; clear; close all;

% Constants
density_water = 1000;      % kg/m^3 (freshwater)
g = 9.81;                  % m/s^2

% Diver body (~985 kg/m^3)
mass_diver = 70;           % kg
density_body = 985;        % kg/m^3
volume_diver = mass_diver / density_body;             % m^3
buoyancy_diver = volume_diver * density_water * g;    % N

% Scuba tank (12L, 13kg)
mass_tank = 13;            % kg
volume_tank = 0.012;       % m^3
buoyancy_tank = volume_tank * density_water * g;      % N

% Wetsuit (5mm neoprene, ~500 kg/m^3)
mass_suit = 2;             % kg
density_neoprene = 200;    % kg/m^3
volume_suit = mass_suit / density_neoprene;           % m^3
buoyancy_suit = volume_suit * density_water * g;      % N

% Lead weights (6kg, negligible volume)
mass_lead = 6;             % kg
buoyancy_lead = 0;         % N

% EVA foam (~100 kg/m^3), 5 liters = 0.005 m³
volume_foam = 0.005;       % m^3
density_foam = 100;        % kg/m^3
mass_foam = volume_foam * density_foam;               % kg
buoyancy_foam = volume_foam * density_water * g;      % N

% Total mass and buoyancy
total_mass = mass_diver + mass_tank + mass_suit + mass_lead + mass_foam;  % kg
total_weight = total_mass * g;                                            % N
total_buoyancy = buoyancy_diver + buoyancy_tank + buoyancy_suit + buoyancy_foam;  % N

% Net force
net_force = total_buoyancy - total_weight;   % N

% Display results
fprintf('Diver Volume: %.4f m^3\n', volume_diver);
fprintf('Diver Buoyancy: %.2f N\n', buoyancy_diver);
fprintf('Total Weight: %.2f N\n', total_weight);
fprintf('Total Buoyancy: %.2f N\n', total_buoyancy);
fprintf('Net Force (Buoyancy - Weight): %.2f N\n', net_force);
