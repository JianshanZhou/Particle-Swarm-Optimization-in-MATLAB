function [x, fval, exitFlag, output] = ...
    PSOalg(objFun, objFcnArgs, nvars, lb, ub, options, plotFlag)
exitFlag=[];
output = struct;
output.PStrajectory = cell(3,1);
output.PSvelocity = cell(3, 1);
% Create an anonymous function for the objective function
% objFun is a function handle to the objective function which
% has two main parts of input arguments
if isempty(objFcnArgs)
    objfcn = objFun;
else
    objfcn = @(x)objFun(x, objFcnArgs);
end

% Check lb and ub whether they are rwo vectors
lbRow = lb(:)';
ubRow = ub(:)';

% Get algorithmic options
numParticles = options.SwarmSize;
cSelf = options.SelfAdjustment;
cSocial = options.SocialAdjustment;
minNeighborhoodSize = max(2,floor(numParticles*options.MinFractionNeighbors));
minInertia = options.InertiaRange(1);
maxInertia = options.InertiaRange(2);
lbMatrix = repmat(lbRow, numParticles, 1);
ubMatrix = repmat(ubRow, numParticles, 1);

% Initialize particle swarm
state = InitializePSO(nvars, lbMatrix, ubMatrix, objfcn, options);
bestFvals = min(state.Fvals);
% Create a vector to store the last StallIterLimit bestFvals.
% bestFvalsWindow is a circular buffer, so that the value from the i'th
% iteration is stored in element with index mod(i-1,StallIterLimit)+1.
 bestFvalsWindow = nan(options.StallIterLimit, 1);
 
% Record historical data for animation
if plotFlag
    output.PStrajectory{1} = state.Positions(:,1);
    output.PStrajectory{2} = state.Positions(:,2);
end

% Initialize adaptive parameters:
%   initial inertia = maximum *magnitude* inertia
%   initial neighborhood size = minimum neighborhood size
adaptiveInertiaCounter = 0;
if all(options.InertiaRange >= 0)
    adaptiveInertia = maxInertia;
elseif all(options.InertiaRange <= 0)
    adaptiveInertia = minInertia;
else
    % checkfield should prevent InertiaRange from having positive and
    % negative vlaues.
    assert(false, 'globaloptim:particleswarm:invalidInertiaRange', ...
        'The InertiaRange option should not contain both positive and negative numbers.');
end
adaptiveNeighborhoodSize = minNeighborhoodSize;

% printInfo(state);

% Run the main loop until some exit condition becomes true
while isempty(exitFlag)
        state.Iteration = state.Iteration + 1;

        % Generate a random neighborhood for each particle that includes
        % the particle itself
        neighborIndex = zeros(numParticles, adaptiveNeighborhoodSize);
        neighborIndex(:, 1) = 1:numParticles; % First neighbor is self
        for i = 1:numParticles
            % Determine random neighbors that exclude the particle itself,
            % which is (numParticles-1) particles
            neighbors = randperm(numParticles-1, adaptiveNeighborhoodSize-1);
            % Add 1 to indicies that are >= current particle index
            iShift = neighbors >= i;
            neighbors(iShift) = neighbors(iShift) + 1;
            neighborIndex(i,2:end) = neighbors;
        end
        % Identify the best neighbor
        [~, bestRowIndex] = min(state.IndividualBestFvals(neighborIndex), [], 2);
        % Create the linear index into neighborIndex
        bestLinearIndex = (bestRowIndex.'-1).*numParticles + (1:numParticles);
        bestNeighborIndex = neighborIndex(bestLinearIndex);
        randSelf = rand(numParticles, nvars);
        randSocial = rand(numParticles, nvars);

        % Note that velocities and positions can become infinite if the
        % inertia range is too large or if the objective function is badly
        % behaved.

        % Update the velocities
        newVelocities = adaptiveInertia*state.Velocities + ...
            cSelf*randSelf.*(state.IndividualBestPositions-state.Positions) + ...
            cSocial*randSocial.*(state.IndividualBestPositions(bestNeighborIndex, :)-state.Positions);
        tfValid = all(isfinite(newVelocities), 2);
        state.Velocities(tfValid,:) = newVelocities(tfValid,:);
        % Update the positions
        newPopulation = state.Positions + state.Velocities;
        
        tfInvalid = ~isfinite(newPopulation);
        newPopulation(tfInvalid) = state.Positions(tfInvalid);
        % Enforce bounds, setting the corresponding velocity component to
        % zero if a particle encounters a lower/upper bound
        tfInvalid = newPopulation < lbMatrix;
        if any(tfInvalid(:))
            newPopulation(tfInvalid) = lbMatrix(tfInvalid);
            state.Velocities(tfInvalid) = 0;
        end
        tfInvalid = newPopulation > ubMatrix;
        if any(tfInvalid(:))
            newPopulation(tfInvalid) = ubMatrix(tfInvalid);
            state.Velocities(tfInvalid) = 0;
        end 
        state.Positions = newPopulation;
                
        state.Fvals = fcnvectorizer(objfcn, state.Positions);
        state.FunEval = state.FunEval + numParticles;
        
        if plotFlag
            output.PStrajectory{1} = [output.PStrajectory{1},state.Positions(:,1)];
            output.PStrajectory{2} = [output.PStrajectory{2},state.Positions(:,2)];
        end

        % Remember the best fvals and positions
        tfImproved = state.Fvals < state.IndividualBestFvals;
        state.IndividualBestFvals(tfImproved) = state.Fvals(tfImproved);
        state.IndividualBestPositions(tfImproved, :) = state.Positions(tfImproved, :);
        bestFvalsWindow(1+mod(state.Iteration-1,options.StallIterLimit)) = min(state.IndividualBestFvals);
        
        % Keep track of improvement in bestFvals and update the adaptive
        % parameters according to the approach described in S. Iadevaia et
        % al. Cancer Res 2010;70:6704-6714 and M. Liu, D. Shin, and H. I.
        % Kang. International Conference on Information, Communications and
        % Signal Processing 2009:1-5.

        newBest = min(state.IndividualBestFvals);
        if isfinite(newBest) && newBest < bestFvals
            bestFvals = newBest;
            state.LastImprovement = state.Iteration;
            state.LastImprovementTime = toc(state.StartTime);
            adaptiveInertiaCounter = max(0, adaptiveInertiaCounter-1);
            adaptiveNeighborhoodSize = minNeighborhoodSize;
        else
            adaptiveInertiaCounter = adaptiveInertiaCounter+1;
            adaptiveNeighborhoodSize = min(numParticles, adaptiveNeighborhoodSize+minNeighborhoodSize);
        end
        
        % Update the inertia coefficient, enforcing limits (Since inertia
        % can be negative, enforcing both upper *and* lower bounds after
        % multiplying.)
        if adaptiveInertiaCounter < 2
            adaptiveInertia = max(minInertia, min(maxInertia, 2*adaptiveInertia));
        elseif adaptiveInertiaCounter > 5
            adaptiveInertia = max(minInertia, min(maxInertia, 0.5*adaptiveInertia));
        end

        % check to see if any stopping criteria have been met
        [exitFlag, output.message] = stopPSO(options, state, bestFvalsWindow);
end % End while loop

% Find and return the best solution
[fval,indexBestFval] = min(state.IndividualBestFvals);
x = state.IndividualBestPositions(indexBestFval,:);

% Update output structure
output.iterations = state.Iteration;
output.funccount   = state.FunEval;

end