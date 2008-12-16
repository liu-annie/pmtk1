classdef Binom_BetaDist < CompoundDist
 % p(X,theta|a,b,N) = Binom(X|N,theta) Beta(theta|a,b) 
  
 properties
   muDist;
   N;
 end
 
  %% Main methods
  methods 
    function obj =  Binom_BetaDist(N,muDist)
      % Binom_Betadist(N,muDist) where muDist is of type BetaDist
      obj.N = N;
      obj.muDist = muDist;
    end

    function d = ndistrib(obj)
      d = length(obj.N);
    end
    
    function m = marginal(obj)
      a = obj.muDist.a; b = obj.muDist.b;
      m =  BetaBinomDist(obj.N, a, b);
    end

     function SS = mkSuffStat(obj,X) %#ok
        % We require sum(X(i,:)) = N
       SS.counts = sum(X,1);
       SS.N = sum(X(:));
      end

     function obj = fit(obj, varargin)
       % m = fit(model, 'name1', val1, 'name2', val2, ...)
       % Arguments are
       % data - X(i,1) is number of successes, X(i,2) is number of failures
       % suffStat - SS.counts(j), SS.N = total amount of data
       [X, SS] = process_options(varargin,...
           'data'       , [],...
           'suffStat'   , []);
       if isempty(SS), SS = mkSuffStat(obj,X); end
       a = obj.muDist.a; b = obj.muDist.b;
       obj.muDist = BetaDist(a + SS.counts(1), b + SS.counts(2));
     end
           
  end 
 
end