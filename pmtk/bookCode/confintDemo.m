% Larsen and Marx p332
D = [249 254 243 268 253 269 287 241 273 306 303 280 260 256 278 344 304 283 310];
N = length(D);
alpha = 0.05;

muHat = mean(D);
S2 = var(D); % unbiased
nu = N-1;
SS = sqrt(S2/N);
L = muHat + SS*tinv(alpha/2,nu);
U = muHat - SS*tinv(alpha/2,nu);
muCI = [L, U] % 263.8416  289.9478

sigma2HatMLE = var(D,1);
LL = N*sigma2HatMLE/chi2inv(1-alpha/2,nu);
UU = N*sigma2HatMLE/chi2inv(alpha/2,nu);
sigma2CI = [LL UU] % 418.75       1603.96
sigmaCI = sqrt([LL, UU])  % 20.46         40.05

% stats toolbox
[pHat, pCI] = mle(D, 'distribution', 'normal')
assert(approxeq(pHat, [muHat sqrt(sigma2HatMLE)]))
assert(approxeq(pCI, [muCI(:) sigmaCI(:)]))



