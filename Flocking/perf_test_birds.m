%%PERF_TEST_BIRDS.m
% Due to the commonality in the code between the various simulations of
% birds, we can have a common wrapper to do performance testing on the
% birds.

clear all; clc;

% Set the variable to disable lower-level animations
STAT_COLLECTING = 1;

% Set the parameters for simulation
NOISE = 0; % There should be no noise in the model <- It's USELESS
FIELD = 50; % The field of the model
CONFINE = 0; % Confine the model? 0->No, 1->Toroidal, 2->Reflective
REPULSE = 0; % Repulsion type? 0->None, 1->Linear, 2->Non-linear
REPULSE_RADIUS = 2; % Radius for repulsion to set in
REPULSE_FORCE = 0.2; % On a range from 0 to 1

% Tests to perform - vary population and radii
NUM_TRIALS = 10; % Number of trials to run for each simulation
poptests = [100, 200, 300, 400, 500]; % Tests to run on the population
radtests = [1, 5, 10, 20, 30, 40]; % Tests to run for RADII
buckets = zeros(size(poptests,2), size(radtests,2)); % Collect results here
% DISCLAIMER: This may not be able to test confined birds, repulsed/
% attracted birds...

% Perform the tests
disp('Beginning performance testing');
for POPULATION = poptests
    fprintf('Initializing population to %d\n', POPULATION);
    pindex = find(POPULATION == poptests, 1, 'first');
    
    for RADIUS = radtests
        fprintf('Initializing radius to %d\n', RADIUS);
        rindex = find(RADIUS == radtests, 1, 'first');
        
        for m = 1:NUM_TRIALS
            disp({'On trial ',num2str(m),' for radius ',num2str(RADIUS), ' and population ', num2str(POPULATION)});
            
            if CONFINE == 0 && REPULSE == 0 % Clean Vicsek model
                simulate_vicsek_birds; % Perform the simulation
            end

            buckets(pindex, rindex) = buckets(pindex, rindex) + i;
        end
        buckets(pindex,rindex) = buckets(pindex,rindex)/NUM_TRIALS;
    end
end
disp('End of performance test');