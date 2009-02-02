classdef SampleDist < ParamFreeDist
  % Sample based representation of a pdf
  % May represent multiple distributions in pages so long as these are all
  % of he same size, e.g. the same number of samples drawn for each and each
  % of the same dimensionality. See LogregDist.predict('method','mc') for an
  % example of this usage. 
  
  properties
    samples; % rows are samples, columns are dimensions
             % multiple pdfs may be represented in a single object where the
             % sth sample for the dth dimension of the ith pdf is stored in 
             % samples(s,d,i)
    domain; 
    
    %{
    % We need to remember which dimension corresponds to which variable,
    % since when we marginalize down, we extract a subset of the variables.
    Consider this example
    X=rand(2,4);    S=sampleDist(X);
    m23 = marginal(S,[2 3]); m2 = marginal(m23, 2);
    m2Direct = marginal(S,2); assert(isequal(m2, m2Direct))
    %}
  end

  %%  Main methods
  methods
    function m = SampleDist(X, domain)
      if nargin < 1, X = []; end
      m.samples = X;
      if nargin < 2, domain = 1:size(X,2); end
      m.domain = domain;
    end
    
    function mu = mean(obj) 
    % Average samples, (if this object represents multple pdfs, do this for each
    % in parallel). mu is of size npdfs-by-d. 
      mu = squeeze(mean(obj.samples))';
    end
    
    function mu = median(obj)
    % mu is of size npdfs-by-d    
      mu = squeeze(median(obj.samples))';
    end
    
   
    
    function v = var(obj)
    % v is of size npdfs-by-d    
      v = squeeze(var(obj.samples))';
    end
    
    function C = cov(obj)
    % C is of size d-by-d-npdfs
      [n,d,npdfs] = size(obj.samples);  
      C = zeros(d,d,npdfs);
      for i=1:npdfs
         C(:,:,i) = cov(obj.samples);
      end
    end
    
    function mm = marginal(m, queryVars)    
    % mm is of size nsamples-by-numel(queryVars)-by-npdfs  
      if(isempty(m.domain))
          m.domain = 1:size(m.samples,2);
      end
      Q = lookupIndices(queryVars, m.domain);
      mm = SampleDist(m.samples(:,Q,:), m.domain(Q));
    end
    
   
    function mm = extractDist(m,ndx)
    % mm is a SampleDist object of size nsamples-by-ndimensions-by-numel(ndx)    
    % When this object represents multiple distributions, you can extract one or
    % more of them and have them returned in a new sampleDist object with this
    % method. 
        mm = SampleDist(m.samples(:,:,ndx));
    end
    
    function s = extractSample(m,sampleNDX)
    % Extract the specified sample(s)
    % s is numel(sampleNDX)-by-ndimensions-by-npdfs - a double matrix, not an
    % object. If numel(sampleNDX) = 1, the size is just ndimensions-by-npdfs
       s = squeeze(m.samples(sampleNDX,:,:));
    end
    %}
    
    function [l,u] = credibleInterval(obj, p,distNDX)
    % Obtain a credible interval for a single distribution, specified by distNDX.
    % If not specified, distNDX = 1, the first. 
      if(nargin < 3), distNDX = 1;end
      if(numel(distNDX)>1),error('distNDX must be a scalar');end
      samples = obj.samples(:,:,distNDX);
      if nargin < 2, p = 0.95; end
      q= (1-p)/2;
      [Nsamples d] = size(samples);
      l = zeros(d,1); u = zeros(d,1);
      for j=1:d
        tmp = sort(samples(:,j), 'ascend');     %#ok
        u(j) = tmp(floor((1-q)*Nsamples));
        l(j) = tmp(floor(q*Nsamples));
      end
    end
    
    
    function v = cdf(obj, x)
      [Nsamples Ndims Ndistrib] = size(obj.samples); % samples(s,d,i)
      assert(Ndistrib==1)
      for j=1:Ndims
        tmp = sort(obj.samples(:,j), 'ascend'); %#ok
        ndx = find(x <= tmp);
        ndx = ndx(1);
        v(j) = ndx/Nsamples;
      end
    end
    
    function p = pmf(obj)
      % p(j,d) = p(X=j|distrib d), j=1:nstates, d=1:ndistrib
      [Nsamples Ndims Ndistrib] = size(obj.samples); % samples(s,d,i)
      K = length(unique(obj.samples));
      assert(Ndistrib==1)
      p = zeros(K, Ndims);
      for d=1:Ndims
        p(:,d) = int_hist(obj.samples(:,d), K)'/Nsamples;
      end
    end
    
    
    function s = sample(obj,n)
      NN = size(obj.samples, 1);
      if n > NN, error('requesting too many samples'); end
      perm = randperm(NN);
      ndx = perm(1:n); % randi(NN,n,1);
      s = obj.samples(ndx,:);
    end
    
    function [h, hist_area] = plot(obj, varargin)
      [scaleFactor, useHisto,distNDX] = process_options(...
        varargin, 'scaleFactor', 1, 'useHisto', 1,'distNDX',1);
      samples = obj.samples(:,:,distNDX);
      switch ndimensions(obj)
        case 1,
          if useHisto
            [bin_counts, bin_locations] = hist(samples, 20);
            bin_width = bin_locations(2) - bin_locations(1);
            hist_area = (bin_width)*(sum(bin_counts));
            %counts = scaleFactor * normalize(counts);
            %counts = counts / hist_area;
            h=bar(bin_locations, bin_counts);
          else
            [f,xi] = ksdensity(samples(:,1));             %#ok
            plot(xi,f);
          end
        case 2, h=plot(samples(:,1), samples(:,2), '.'); %#ok
        otherwise, error('can only plot in 1d or 2d'); 
      end
    end
      
    function d = ndimensions(obj)
      % num dimensions (variables)
      %mu = mean(obj); d = length(mu);
      d = size(obj.samples,2);
    end
    
    function d = ndistrib(obj)
      d = size(obj.samples,3);
    end
  end
  
  
end