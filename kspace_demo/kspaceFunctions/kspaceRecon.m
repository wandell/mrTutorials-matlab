function kspace = kspaceRecon(kspace, params)
% kspace = kspaceRecon(kspace, params)
%
% Take sequence of kspace measures and put them on a grid.
sequenceType = params.sequenceType;

v = kspace.vector;
g = kspace.grid;

switch lower(sequenceType)
    case 'epi'
        inds = kspace.inds;
        
        kr = zeros(size(g.x));
        ki = kr;
        
        kr(inds.g) = v.real(inds.v);
        ki(inds.g) = v.imag(inds.v);
        %         kr = griddata(v.x, v.y, v.real, g.x, g.y);
        %         ki = griddata(v.x, v.y, v.imag, g.x, g.y);
        
    case 'spiral'
        % Reconstruct using Voronoi weighting function (code from
        % Atsushi)
        data     = 1i*v.real + v.imag;           % k-space data
        kmax     = params.freq / params.FOV*.5;  % cycles / meter, highest resolution
        k        = (-1i*v.x+v.y)/(kmax*2);       % k-space trajectories, scaled to [-.5 .5]
        [~, r]   = cart2pol(v.x, v.y);           % convert k-space trajectory to polar coordinates
        w        = r.^0.5;                       % weighting of k-space data - don't understand this.
        %  but in atsushi test data, seems to be weighted by
        %  about the sqrt of r in kspace trajectory
        %n = round(.1*length(r)); w(1:n) = w(1:n)/2;%
        %w              = ones(size(w));
        n              = params.freq;                  % number of pixels in width (or length) of reconned image
        oversample     = 2;                            % oversampling of kspace (output image will be a*a, where a = oversample * n)
        kbwidth        = 2.5;                          % FULL width of Kaiser-Bessel Kernel (Atsushi: 2.5)
        kbbeta         = (oversample-0.5)*pi*kbwidth;  % Shape parameter (Beta) of KB kernel
        trimming       =  'y';                         %
        apodize        =  'y';                         %
        postcompensate =  'y';                         %
        
        k = grid_kb(data',k',w', n,oversample,kbwidth,kbbeta,trimming, apodize, postcompensate);
        k = fftshift(k);
        
        kr = real(k);
        ki = imag(k);
        
end

% get rid of annoying nan's (where do they come from anyway?)
kr(isnan(kr) | abs(kr) < 1e-15) = 0;
ki(isnan(ki) | abs(ki) < 1e-15) = 0;

% put data back into properly named structs for output
kspace.grid.real = kr;
kspace.grid.imag = ki;

return
