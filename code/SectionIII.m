% SECTION III Firm-level export patterns
%

clear;

%% Calibration parameters

bs=36000;               % Ball size in dollars

sigma_x=3;             % Log-normal parameters in dollars
mu_x=11;

%% Load data for bin sizes in products and countries

% Bin sizes for products
s=csvread('../data/census/hs10shares.csv');
K_prod=length(s); % number of categories
if sum(s)~=1
    s=s/sum(s);
elseif min(s)<0
    error('Probabilities should be non-negative')
end
s_prod=s;

% Bin sizes for destinations
s=csvread('../data/census/countryshares.csv');
K_dest=length(s); % number of categories
if sum(s)~=1
    s=s/sum(s);
elseif min(s)<0
    error('Probabilities should be non-negative')
end
s_dest=s;


%% Log-normal distribution over number of balls

mu=mu_x-log(bs);    % Log-normal parameters in balls
sigma=sigma_x;

%Truncation Parameter - in balls
N=8000;

%Cumulative density function
ld_cdf = logncdf(1:N,mu,sigma);

%Point density function
ld_pdf(1)=ld_cdf(1);
ld_pdf(2:N)=ld_cdf(2:N)-ld_cdf(1:N-1);

%Ensure probability distribution is proper
ld_pdf = ld_pdf/sum(ld_pdf);

%% Extensive-Margin Functions
% For a given number of balls, how many products/destinations?

% initialize
emf=zeros(3,N);

for in=1:N
    n=in;
    emf(1,in)=sum(s_prod.^n); % probability of a single product firm if its size n
    emf(2,in)=sum(s_dest.^n); % probability of a single country firm if it is size n
    emf(3,in)=emf(1,in)*emf(2,in); % probability of a single variety firm if it is size n
    % conditional on n, # products and # countries are independent, so the
    % probability is just the product
end

%% Compute share of singles and relative market shares

share = 100*sum(repmat(ld_pdf,3,1).*emf,2);
values = 100*sum(repmat(ld_pdf,3,1).*emf.*repmat((1:N),3,1),2)/exp(mu+0.5*sigma^2);

%% Display output

disp('Share (%) of single product/country/product-country exporters: ')
   disp(num2str(share))
   
disp('Share (%) of single product/country/product-country export revenue: ')
   disp(num2str(values))
  