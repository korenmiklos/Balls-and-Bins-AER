% SECTION IV: Exporting Firms.
%
%   Computes the expected share of exporters and their size premium.
%

clear;

%% Calibration parameters

bs=36000;               % Ball size in dollars

mu_sales=13.4;          % Log-normal parameters in dollars
sigma=2.44;   

exp_share=.139;         % Share of export revenue -- bin size

%% Log-normal distribution over number of balls

mu=mu_sales-log(bs);    % Log-normal parameters in balls

% determine upper cutoff
K = logninv(0.999,mu,sigma);

contgrid = [0.01:0.01:K];
N = length(contgrid);
% the number of balls given is rounded up
n = ceil(contgrid);

%Cumulative density function
ld_cdf = logncdf(contgrid,mu,sigma);

%Point density function
ld_pdf(1)=ld_cdf(1);
ld_pdf(2:N)=ld_cdf(2:N)-ld_cdf(1:N-1);

%Ensure probability distribution is proper
ld_pdf = ld_pdf/sum(ld_pdf);

%% Compute share and exporter premium

% Share of exporters
sh_exp=1-ld_pdf*((1-exp_share).^n)';

% Exporter size premium (in logs)
total=ld_pdf*log(bs*contgrid');
va_nonexp=(ld_pdf.*log(bs*contgrid))*((1-exp_share).^n)';
va_exp=total-va_nonexp;
ave_nonexp=va_nonexp/(1-sh_exp);
ave_exp=va_exp/sh_exp;
premium_exp=ave_exp-ave_nonexp;

%% Display output

disp(['Share of exporters : ' num2str(sh_exp)])
disp(['Exporter sized premium (logs) : ' num2str(premium_exp)])