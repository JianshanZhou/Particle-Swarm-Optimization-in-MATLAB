function state = InitializePSO(nvars,lbMatrix,ubMatrix,objFcn,options)
% Create an initial set of particles and objective function values
% makeState needs the vector of bounds, not the expanded matrix.
lb = lbMatrix(1,:);
ub = ubMatrix(1,:);

% A variety of data used in various places
state = struct;
state.Iteration = 0; % current generation counter
state.StartTime = tic; % tic identifier
state.StopFlag = false; % OutputFcns flag to end the optimization
state.LastImprovement = 1; % generation stall counter
state.LastImprovementTime = 0; % stall time counter
state.FunEval = 0;
numParticles = options.SwarmSize;

state.Positions = lbMatrix + (ubMatrix - lbMatrix).*rand(size(lbMatrix));

% Enforce bounds
if any(any(state.Positions < lbMatrix)) || any(any(state.Positions > ubMatrix))
    state.Positions = max(lbMatrix, state.Positions);
    state.Positions = min(ubMatrix, state.Positions);

    fprintf(getString(message('globaloptim:particleswarm:shiftX0ToBnds')));

end

% Initialize velocities by randomly sampling over the smaller of 
% options.InitialSwarmSpan or ub-lb. Note that min will be
% InitialSwarmSpan if either lb or ub is not finite.
vmax = min(ub-lb, options.InitialSwarmSpan);
state.Velocities = repmat(-vmax,numParticles,1) + ...
    repmat(2*vmax,numParticles,1) .* rand(numParticles,nvars);

% Calculate the objective function for all particles.
state.Fvals = fcnvectorizer(objFcn, state.Positions);
state.FunEval = numParticles;

% Record the individual best objectives as well as the corresponding
% positions
state.IndividualBestFvals = state.Fvals;
state.IndividualBestPositions = state.Positions;
end % function makeState
