function b0noise = kspaceGetB0Noise(params, xygrid)
% create a map of B0 field inhomogeneities in units of Tesla
% (realistic scale is approx 1 part in 10^6 or 10^7 of B0)
%
% b0noise = kspaceGetB0Noise(params, xygrid);

% define some variables to make our equations more readable
B0          = params.B0;
freq        = params.imFreq;
noiseType   = params.noiseType;
noiseScale  = params.noiseScale;
sz          = params.imSize;
x           = xygrid.x;
y           = xygrid.y;

% Make the spatial pattern of B0 noise, assuming an amplitude of 1
switch lower(noiseType)
    case 'none'
        b0noise = zeros(freq);
    case {'random' 'random offset'}
        b0noise = randn(freq);
        b0noise  = b0noise / max(b0noise(:));      
    case 'random lowpass'
        b0noise = randn(freq) ;
        f = fspecial('gaussian',freq,freq/16);
        b0noise  = imfilter(b0noise, f, 'same');
        b0noise  = b0noise / max(b0noise(:));
    case {'dc offset' 'constant' 'uniform'}
        b0noise = ones(freq);
    case {'local' 'local offset'}
        noiseCenter = [.25 .25]*sz; % todo: make this a variable
        noiseRadius = .01 * sz;
        inds = sqrt((x-noiseCenter(1)).^2 + (y-noiseCenter(1)).^2) < noiseRadius;
        b0noise = zeros(freq);
        b0noise(inds)  = 1;
        f = fspecial('gaussian',freq,freq/16);
        b0noise  = imfilter(b0noise, f, 'same');
        b0noise  = b0noise / max(b0noise(:));
    case 'map'
        tmp = load('b0Lucas.mat');
        b0noise = tmp.b0 * 2 * pi/ params.gamma; % convert from Hz to Tesla
        b0noise = imresize(b0noise, [freq freq]);
        return; % make sure to skip the last step where we scale the noise, 
                % as we have a real quanititative b0 map
    otherwise
        b0noise = zeros(freq);
end

% Scale the amplitude of the B0 noise image as requested
b0noise = b0noise * noiseScale*B0;