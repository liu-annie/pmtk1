% Example from Edwards p39
S = [3.023 1.258 1.004;...
  1.258 1.709 0.842;...
  1.004 0.842 1.116];
G = zeros(3,3);
G(1,2)=1; G(2,3)=1; G = mkSymmetric(G);
precMat1 = covselPython(S, G)
precMat2 = ggmIPF(S,G)
%precMat3 = covselChordalPython(S, G);
precMat3 = covselProj(S, G)
precMat4 = gaussIPF(S, G)
precMat5 = ggmIPFR(S, G)
covMat = inv(precMat2);
precMatEdwards = [0.477 -0.351 0; -0.351 1.19 -0.703; 0 -0.703 1.426];
assert(approxeq(precMat1, precMatEdwards))
assert(approxeq(precMat2, precMatEdwards))
assert(approxeq(precMat3, precMatEdwards))
assert(approxeq(precMat4, precMatEdwards))
assert(approxeq(precMat5, precMatEdwards))


% Marks - Edwards p48
G = zeros(5,5);
me = 1; ve = 2; al= 3; an = 4; st = 5;
G([me,ve,al], [me,ve,al]) = 1;
G([al,an,st], [al,an,st]) = 1;
G = setdiag(G,0);
load marks; X = marks;
S = cov(X);
precMat1 = ggmIPF(S, G)
precMat2 = covselPython(S, G)
precMat3 = covselProj(S, G)
precMat4 = gaussIPF(S, G)
precMat5 = ggmIPFR(S, G)

pcorMatEdwards = eye(5,5);
pcorMatEdwards(2,1) = 0.332;
pcorMatEdwards(3,1:2) = [0.235 0.327];
pcorMatEdwards(4,1:3) = [0 0 0.451];
pcorMatEdwards(5,1:4) = [0 0 0.364 0.256];
pcorMatEdwards = mkSymmetric(pcorMatEdwards);

assert(approxeq(pcorMatEdwards, abs(cov2cor(precMat1))))
assert(approxeq(pcorMatEdwards, abs(cov2cor(precMat2))))
assert(approxeq(pcorMatEdwards, abs(cov2cor(precMat3))))
assert(approxeq(pcorMatEdwards, abs(cov2cor(precMat4))))
assert(approxeq(pcorMatEdwards, abs(cov2cor(precMat5))))

% Timing on random problems - full rank
d = 10;
setSeed(0);
n = d*2;
X = randn(n,d);
S = cov(X); 
G = mkSymmetric(rand(d,d)>0.8);
G = setdiag(G,0);
%S = randpd(d);
tic; precMat1 = covselPython(S, G); toc
tic; precMat2 = covselProj(S, G); toc
%tic; precMat3 = gaussIPF(S, G); toc
%tic; precMat4 = ggmIPFR(S, G); toc
assert(approxeq(precMat1, precMat2))
%assert(approxeq(precMat1, precMat3))

% Timing on random problems
d = 10;
setSeed(2);
n = ceil(d/2);
%n = d*2;
X = randn(n,d);
S = cov(X); % may not be full rank
G = mkSymmetric(rand(d,d)>0.8);
G = setdiag(G,0);
%S = randpd(d);
tic; precMat1 = covselPython(S, G); toc
tic; precMat2 = covselProj(S, G); toc
%tic; precMat3 = gaussIPF(S, G); toc
%tic; precMat3 = ggmIPFR(S, G); toc
assert(approxeq(precMat1, precMat2))
%assert(approxeq(precMat1, precMat3))

% Timing on random problems - not full rank
d = 10;
setSeed(0);
n = ceil(d/2);
X = randn(n,d);
S = cov(X);
G = mkSymmetric(rand(d,d)>0.8);
G = setdiag(G,0);
tic; precMat1 = covselPython(S, G); toc
tic; precMat2 = covselProj(S, G); toc
assert(approxeq(precMat1, precMat2))


