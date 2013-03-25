function simulated = flashsim(gridsize, num, connectivity, threshold, time)
%FLASHSIM Script to create a simulator of nodes.
%   GRIDSIZE is the size of the grid that the nodes are restricted to. NUM
%   is the number of nodes in the simulator.

% Initialization of the simulator
XPosition = randi(gridsize, 1, num);
YPosition = randi(gridsize, 1, num);
for i = 1:num
    Nodes(i) = makeNode(i);
    Related(i,:) = randperm(num, connectivity);
end

% Simulation of simulator
for j = 0:time
    plot(0,0);
    axis([-10 gridsize+10 -10 gridsize+10]);
    drawnow;
    pause(0.3);
    posx = [];
    posy = [];
    sx = 0;
    sy = 0;
    for i = 1:num
        if Nodes(i).state >= threshold
            sx = sx+1; sy = sy+1;
            posx(sx) = XPosition(i);
            posy(sy) = YPosition(i);
            for n = Related(Nodes(i).index,:)
                Nodes(n).state = neighbourState(Nodes(n).state, Nodes(i).state);
            end
            Nodes(i).state = 0;
        end
        Nodes(i).state = changeState(Nodes(i).state);
    end
    plot(posx, posy, 'o');
    axis([-10 gridsize+10 -10 gridsize+10]);
    drawnow;
    pause(0.3);
end

% Displaying contents and analyzing results
simulated = 0;

% Function declarations
    function node = makeNode(index)
        node.index = index;
        node.state = randi(threshold-1, 1);
        node.func = @changeState;
    end

    function nstate = changeState(state)
        nstate = state+state.^2;
    end

    function nstate = neighbourState(sstate, bstate)
        nstate = sstate + abs(sin(bstate));
    end
end