function t = NuclearForces(pos, neighbours, positions, radius, theta)
% NUCLEARFORCES takes in as input neighbour and position matrices and based
% on this information it calculates the new heading of a bird

% Set constants for the forces
A = 0.85;
H = 1;
S = radius/4;

% Calculate the displacement and distance of other birds
disp = positions(:,neighbours) - [pos(1)*ones(1,size(positions(neighbours),2)); ...
                                  pos(2)*ones(1,size(positions(neighbours),2))];
disp = disp(:,any(disp));
dist = sqrt(sum(disp.^2,1));
angle = atan2(disp(2,:),disp(1,:));

% Calculate the magnitude of the force
force = (A./dist.^2) - (H.*exp(-dist./S)./(dist.^2));

% Provide a correction to theta based on information
if sum(force) == 0
    t = theta;
else
    t = mod(theta + (sum(force.*angle)*pi/sum(force) - theta), 2*pi);
end

end