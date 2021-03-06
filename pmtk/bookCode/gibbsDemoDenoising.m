% gibbsDemoDenoising
% Denoising of letter A using Gibbs sampling
% with an Ising Prior and a Gaussian likelihood
% Based on code originally written by Brani Vidakovic

doPrint = 0;
seed = 3;
randn('state',seed)
rand ('state',seed)

sigma = 2; % noise level

% input matrix consisting of letter A. The body of letter
% A is made of 1's while the background is made of -1's.
img = imread('lettera.bmp'); 
[M,N] = size(img);
img = double(img);
m = mean(img(:));
img2 = +1*(img>m) + -1*(img<m); % -1 or +1

figure(1);clf; imagesc(img2); 
colormap gray; axis square; axis off
if doPrintPmtk, printPmtkFigures('gibbsDemoDenoisingNoNoise'); end;
y = img2 + sigma*randn(size(img2)); %y = noise signal

figure(1);clf
imagesc(y);colormap gray; axis square; axis off
title(sprintf('sigma=%2.1f', sigma))
fname = sprintf('figures/gibbsDemoDenoisingOrigS%2.1f.eps', sigma);
if doPrint, print(gcf, '-depsc', fname); end
fname = strrep(sprintf('gibbsDemoDenoisingOrigS%2.1f', sigma), '.', '-');
if doPrintPmtk, printPmtkFigures(fname); end;


% observation model
offState = 1; onState = 2;
mus = zeros(1,2);
mus(offState) = -1; mus(onState) = +1;
sigmas = [sigma sigma];
Npixels = M*N;
localEvidence = zeros(Npixels, 2);
for k=1:2
  localEvidence(:,k) = normpdf(y(:), mus(k), sigmas(k));
end

[junk, guess] = max(localEvidence, [], 2);  % start with best local guess
X = ones(M, N);
X(find(guess==offState)) = -1;
X(find(guess==onState)) = +1;
Xinit = X;



figure(2);clf
imagesc(Xinit);colormap gray; axis square; axis off
title('initial guess')
fname = sprintf('figures/gibbsDemoDenoisingInitS%2.1f.eps', sigma);
if doPrint, print(gcf, '-depsc', fname); end
fname = strrep(sprintf('gibbsDemoDenoisingInitS%2.1f', sigma), '.', '-');
if doPrintPmtk, printPmtkFigures(fname); end;

fig = figure(3); clf

J = 1;
avgX = zeros(M,N);
X = Xinit;
maxIter = 100000;
burnIn = 50000;
for iter =1:maxIter
  % select a pixel at random
  ix = ceil( N * rand(1) ); iy = ceil( M * rand(1) );
  pos = iy + M*(ix-1);
  neighborhood = pos + [-1,1,-M,M];  
  neighborhood(find([iy==1,iy==M,ix==1,ix==N])) = [];
  % compute local conditional
  wi = sum( X(neighborhood) );
  p1  = exp(J*wi) * localEvidence(pos,onState);
  p0  = exp(-J*wi) * localEvidence(pos,offState);
  prob = p1/(p0+p1);
  if rand < prob
    X(pos) = +1;
  else
    X(pos) = -1;
  end
  if iter > burnIn
    avgX = avgX+X;
  end
  % plotting
  if rem(iter,10000) == 0,
    figure(fig);
    imagesc(X);  axis('square'); colormap gray; axis off;
    title(sprintf('sample %d', iter));
    drawnow
    if (doPrint || doPrintPmtk) % iter==10000 | iter==50000 | iter==100000
      figure;
      imagesc(X);colormap gray; axis square; axis off
      title(sprintf('sample %d', iter))
      fname = sprintf('figures/gibbsDemoDenoisingIter%dJ%3.2fS%2.1f.eps', iter, J, sigma);
      if doPrint, print(gcf, '-depsc', fname); end;
      fname = strrep(sprintf('gibbsDemoDenoisingIter%dJ%3.2fS%2.1f', iter, J, sigma), '.', '-');
      if doPrintPmtk, printPmtkFigures(fname); end;
    end
  end
end
nSamples = (maxIter-burnIn);
avgX = avgX/nSamples;

figure(4);clf
imagesc(avgX);colormap gray; axis square; axis off
title(sprintf('posterior mean of last %d samples', nSamples))
fname = sprintf('figures/gibbsDemoDenoisingMean%dJ%3.2fS%2.1f.eps', iter, J, sigma);
if doPrint, print(gcf, '-depsc', fname); end
if doPrintPmtk, printPmtkFigures('gibbsDemoDenoisingAvg'); end;
