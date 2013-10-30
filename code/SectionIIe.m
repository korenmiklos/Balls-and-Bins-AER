% SECTION II.E Firm-level zeros
%
%   Computes expected number of firm-level zeros and gravity pattern.
%

clear;

%% Calibration parameters

sigma_x=2.99;           % Log-normal parameters in dollars

K_firms = 167217;       % Number of firms

%% Load data for bin sizes in products and gravity regression

% Bin sizes for products
s=csvread('../data/census/hs10shares.csv');
K_prod=length(s); % number of categories
if sum(s)~=1
    s=s/sum(s);
elseif min(s)<0
    error('Probabilities should be non-negative')
end
s_prod=s;

% Data for gravity regression
G = csvread('../data/gravity/gravity_variables.csv');
% variables: distance, GDP, number of shipments
dist = log(G(:,1));
gdp = log(G(:,2));
balls = G(:,3);
T = length(balls);

%% Compute firm's bin sizes

p = (1:K_firms)'/K_firms;
Lorenz = normcdf(norminv(p,0,1)-sigma_x,0,1);
s_firm = [Lorenz(1);diff(Lorenz)];


%% Expected number of firm-level zeros

firms = zeros(T,1);
products = zeros(T,1);
for k=1:T
    firms(k) = sum(1-(1-s_firm).^balls(k));
    products(k) = sum(1-(1-s_prod).^balls(k));
end

firm_zeros=1-mean(firms)/K_firms;
product_zeros=1-mean(products)/K_prod;

%% Gravity (cross-country) pattern for zeros

Y = [log(firms)];

X = [ones(T,1) gdp dist];

[B,BINT,R,RINT,STATS] = regress(Y,X);

%% Output display

disp(['Share of firm-level zeros:' num2str(firm_zeros)])
disp(['GDP OLS coefficient: ' num2str(B(2))])
disp(['Distance OLS coefficient: ' num2str(B(3))])