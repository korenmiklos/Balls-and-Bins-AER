/*
This program reproduces all the tables, figures and numbers reported in 
Section II of 

	Armenter, Roc and Miklos Koren. "A Balls-and-Bins Model of Trade." 
	American Economic Review, 2014.
	
As an input, you need the EXP_DETL.DBF file from the December 2005 release
U.S. Exports of Merchandise, U.S. Bureau of the Census. 

	http://www.census.gov/foreign-trade/reference/products/layouts/exdb.html 

We have saved this file in .csv format in data/census for your convenience.
*/

clear
set more off

* bin sizes are based on values, not the number of shipments
local binsize shipments

insheet using ../data/census/exp_detl.csv, comma case names
gen byte catchall = regexm(COMM_DESC,"(OTHER)|(PARTS)|(N.E.S.O.I.)|(NESOI)|(OTHR)|(ETC)")

drop *_DESC /* these are descriptions */

* drop reexports
keep if DOM_OR_FOR==1

ren COMMODITY product
ren CTY_CODE country
ren CARDS_YR shipments
ren ALL_VAL_YR value

keep product country shipments value catchall
destring product country , force replace

* drop chapter 98, special statistical classification 
drop if int(product/1e+8)==98

* drop non-countries
drop if country==8220 | country==8500

* aggregate over irrelevant dimension: census region
collapse (sum) shipments value, by(country product catchall)

* fill in the zeroes
fillin product country
replace shipments = 0 if _fillin
replace value = 0 if _fillin
drop _fillin
* filled in countries will have this variable missing
egen catch_all = mean(catchall), by(product)
drop catchall
ren catch_all catchall

* create aggregate classifications
gen hs6 = int(product/1e+4)
gen hs4 = int(product/1e+6)
gen hs2 = int(product/1e+8)
gen byte section = hs2
recode section 1/5=1 6/14=2 15=3 16/24=4 25/27=5 28/38=6 39/40=7 41/43=8 44/46=9 47/49=10 50/63=11 64/67=12 68/70=13 71=14 72/83=15 84/85=16 86/89=17 90/92=18 93=19 94/96=20 97=21 *=22

compress
save ../data/census/export_detail_2005, replace

/*
Save marginal distribution across countries and products for Matlab.
*/
use  ../data/census/export_detail_2005, clear
* save country shares
collapse (sum) `binsize', by(country)
gsort -`binsize'
su `binsize', d
gen share = `binsize'/r(sum)
outsheet share using ../data/census/countryshares.csv, comma nonames replace

use  ../data/census/export_detail_2005, clear
* save product shares
collapse (sum) `binsize', by(product)
gsort -`binsize'
su `binsize', d
gen share = `binsize'/r(sum)
outsheet share using ../data/census/hs10shares.csv, comma nonames replace

* save gravity variables and total number of shipments for Matlab
use  ../data/census/export_detail_2005, clear
collapse (sum) shipments, by(country)
gen census_code = country
merge m:1 census_code using ../data/gravity/gravity_variables
tab _m
keep if _m==3
drop _m
drop if missing(distance, nominal_gdp, shipments)
outsheet distance nominal_gdp shipments using ../data/gravity/gravity_variables.csv, comma nonames replace

/*
Statistics reported in text, Section II.C and II.D.
*/

* total number of shipments
use  ../data/census/export_detail_2005, clear
su shipments, d
di in green "Total number of shipments " in yellow r(sum)

* total number of products
codebook product

* total number of countries
codebook country

* number of shipments going to Canada
su shipments if country==1220, d
di in green "Total number of shipments going to Canada: " in yellow r(sum)

* number of shipments going to Equatorial Guinea
su shipments if country==7380, d
di in green "Total number of shipments going to Equatorial Guinea: " in yellow r(sum)


* Table 2: The incidence of zeroes under different classifications - data
foreach classification of any product hs6 hs4 hs2 section {
    use ../data/census/export_detail_2005, clear
    collapse (sum) shipments, by(`classification' country)
    gen byte zero = (shipments==0)
    su zero, meanonly
    di in green "Fraction of zeroes in the data for `classification' = " in yellow r(mean)
}

* Table 3: The incidence of zeroes under different classifications - model
foreach classification of any product hs6 hs4 hs2 section {
    use ../data/census/export_detail_2005, clear
    collapse (sum) value shipments, by(`classification' country)
    egen country_shipments = sum(shipments), by(country)
    egen product_shipments = sum(`binsize'), by(`classification')
    qui su `binsize', d
    gen product_share = product_shipments/r(sum)

    * equation (5) gives the probability of zeroes conditionl on country shipments
    gen probzero = (1-product_share)^country_shipments
    su probzero, meanonly
    di in green "Fraction of zeroes in the model for `classification' = " in yellow r(mean)
}

* reproduce figure 3
use ../data/census/export_detail_2005, clear
    gen byte zero = (shipments==0)
    egen country_shipments = sum(shipments), by(country)
    egen product_shipments = sum(`binsize'), by(product)
    qui su `binsize', d
    gen product_share = product_shipments/r(sum)

    * equation (5) gives the probability of zeroes conditionl on country shipments
    gen probzero = (1-product_share)^country_shipments
collapse (sum) empty=zero pred_empty = probzero country_shipments = shipments, by(country)

gen ln_products = ln(8867-empty)
gen ln_nonempty_bins = ln(8867-pred_empty)
gen ln_country_shipments = ln(country_shipments)

label var ln_products "Number of exported products"
label var ln_nonempty_bins "Number of nonempty bins"
label var ln_country_shipments "Total number of shipments (log)"
tw (scatter ln_products ln_country_shipments) (line ln_nonempty_bins ln_country_shipments, sort), ytitle(Number of bins and products (log)) graphregion(color(white)) scheme(s2mono) legend(region(lstyle(none)))
graph export ../../AER-MS-20101454-figure-3.pdf, replace

* Merge gravity variables
use ../data/census/export_detail_2005, clear
gen census_code = country
merge m:1 census_code using ../data/gravity/gravity_variables
tab _m
drop _m

gen byte zero = (shipments==0)
egen country_shipments = sum(shipments), by(country)
egen product_shipments = sum(`binsize'), by(product)
su `binsize', d
gen product_share = product_shipments/r(sum)

* equation (5) gives the probability of zeroes conditionl on country shipments
gen probzero = (1-product_share)^country_shipments

* Table 4: Non-zero flows and gravity
gen nonzero_data = 1-zero
gen nonzero_model = 1-probzero
reg nonzero_data ln_real_gdp  ln_real_gdp_per_capita dist_1 dist_2 dist_4 dist_5, cluster(country)
reg nonzero_model ln_real_gdp ln_real_gdp_per_capita dist_1 dist_2 dist_4 dist_5, cluster(country)

/* Alternative calibrations for the product shares. */

* share of zeroes with symmetric prodoucts
use ../data/census/export_detail_2005, clear
egen count_products = group(product)
su count_products
scalar number_of_products = r(max)

egen country_shipments = sum(shipments), by(country)
gen product_share = 1/number_of_products
gen probzero = (1-product_share)^country_shipments
su probzero, meanonly
di in green "Fraction of zeroes for symmetric products = " in yellow r(mean)

* Which are the biggest and smallest products?
use ../data/census/export_detail_2005, clear
collapse (sum) `binsize', by(product catchall)
egen biggest = rank(-`binsize'), unique
egen smallest = rank(`binsize'), unique

* 100 biggest categories, 72 are catch all
tab catchall if biggest<=100
* 100 smallest categories, 13 are catch all
tab catchall if smallest<=100

* Use exports to Canada and Mexico to calibrate product shares
use ../data/census/export_detail_2005, clear
gen byte CANMEX = (country==1220)|(country==2010)
egen product_shipments = sum(CANMEX*`binsize'), by(product)
su product_shipments if country==1220, d
gen product_share = product_shipments/r(sum)

egen country_shipments = sum(shipments), by(country)
gen probzero = (1-product_share)^country_shipments
su probzero, meanonly
di in green "Fraction of zeroes for product shares calibrated to Canada and Mexico = " in yellow r(mean)

* average shipment value $36,000
use ../data/census/export_detail_2005, clear
su value, d
scalar total_export_value = r(sum)
su shipments, d
scalar total_shipments = r(sum)
scalar shipment_size = total_export_value/total_shipments
di in green "Average size of shipments " in yellow shipment_size

/* Alternative calibrations for the number of shipments per country */

* use values/36000 for shipments
use ../data/census/export_detail_2005, clear
egen country_trade = sum(value), by(country)
gen country_shipments = floor(country_trade/shipment_size)
* flows predicted by gravity, 0.66
gen census_code = country
merge m:1 census_code using ../data/gravity/gravity_variables
tab _m
drop _m

egen country_tag = tag(country)
count if country_tag 
scalar countries = r(N)

gen ln_country_trade = ln(country_trade)

egen product_shipments = sum(`binsize'), by(product)
qui su `binsize', d
gen product_share = product_shipments/r(sum)

gen probzero = (1-product_share)^country_shipments
su probzero, meanonly
di in green "Fraction of zeroes based on country trade volume only = " in yellow r(mean)

* estimate gravity equation with distance to predict number of shipments
reg ln_country_trade ln_nominal_gdp ln_distance if country_tag
predict pred_trade_with_distance
gen pred_shipments_with_distance = floor(exp(pred_trade_with_distance)/shipment_size)

* estimate gravity equation without distance to predict number of shipments
reg ln_country_trade ln_nominal_gdp if country_tag
predict pred_trade_wo_distance
gen pred_shipments_wo_distance = floor(exp(pred_trade_wo_distance)/shipment_size)

gen probzero_with_distance = (1-product_share)^pred_shipments_with_distance
su probzero_with_distance, meanonly
di in green "Fraction of zeroes based on gravity = " in yellow r(mean)

gen probzero_wo_distance = (1-product_share)^pred_shipments_wo_distance
su probzero_wo_distance, meanonly
di in green "Fraction of zeroes based on country size only = " in yellow r(mean)

gen probzero_with_sym_countries = (1-product_share)^(total_shipments/countries)
su probzero_with_sym_countries, meanonly
di in green "Fraction of zeroes with symmetric countries = " in yellow r(mean)

