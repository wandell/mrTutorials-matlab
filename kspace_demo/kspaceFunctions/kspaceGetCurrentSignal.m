function  kspace = kspaceGetCurrentSignal(kspace, t, im, spins, params)
%  kspace = kspaceGetCurrentSignal(kspace, t, imv, spins, params)

% We can think of s.r as our 'real' or sinusoidal basis matrix and s.i as
% our 'imaginary' or cosinudoidal basis matrix. When we multiply these
% basis matrices with the image, we get the kspace measurement. So
% ksapce.vals.real is our 'real' or sinusoidal recording channel and
% kspace.vals.imag is our 'imaginary' or cosinusoidal recording channel.
% Apparently, in the early days of MRI, there were in fact two antennae in
% the coils, one for the imaginary and one for the real componennts. Now
% the signal is digitized at a very high rate and the real and imaginary
% components can be extracted later from the one high rate channel.

dx  = params.imRes;
dy  = params.imRes;
s.r = real(spins.total); 
s.i = imag(spins.total);  
imv = im.vector;

kspace.vector.real(t) = imv * s.r(:) * dx * dy;
kspace.vector.imag(t) = imv * s.i(:) * dx * dy;

return


