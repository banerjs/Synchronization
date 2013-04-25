function theta = RepulseFunction(theta, neigh)
% REPULSE_FUNCTION.m is a function to determine the new heading of a
% particle based on number of neighbours ('neigh') in its immediate
% vicinity.

forces = find(neigh == max(neigh)); % Find the forcing directions

if size(forces,2) == 4
    return;
end

xmove = 0; % Set initial forcing = 0 in X direction
ymove = 0; % Set initial forcing = 0 in Y direction

if any(forces == 1)
    xmove = xmove-1;
    ymove = ymove-1;
end
if any(forces == 2)
    xmove = xmove+1;
    ymove = ymove-1;
end
if any(forces == 3)
    xmove = xmove+1;
    ymove = ymove+1;
end
if any(forces == 4)
    xmove = xmove-1;
    ymove = ymove+1;
end

theta = angle(complex(xmove,ymove));

end