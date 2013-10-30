===================================================================
Replication data and programs for "A Balls-and-Bins Model of Trade"
===================================================================
Replication data and programs for Armenter, Roc and Miklós Koren. 2014. "A Balls-and-Bins Model of Trade." American Economic Review. 

Please cite the above paper when using these programs.

Code
----
All programs are under the folder `code`. We have included a makefile (`Makefile` for Linux and Mac OS X and `make.bat` for Windows) that calls all necessary programs in the required order.

read_gravity_data.do
~~~~~~~~~~~~~~~~~~~~
Using data from the Penn World Table, World Development Indicators, and the GeoDist data of CEPII, this Stata do-file compiles the necessary variables for a gravity equation for all the countries in the Census trade data.

It saves these gravity variables in `data/gravity/gravity_variables.dta` to be used for analysis by the Stata script below and in `data/gravity/gravity_variables.csv` to be used for analysis by Matlab.

SectionIIa_d.do
~~~~~~~~~~~~~~~
This Stata script reads 2005 U.S. export data from `data/census/export_detl.csv`, gravity variables from `data/gravity/gravity_variables.dta` (make sure to run `read_gravity_data.do` first) and replicates all the numbers, tables and figures reported in Sections II.A through II.D in the paper.

It assumes you are running Stata 12 or higher. If you have Stata 11, you may want to assign a large-enough amount of memory at the beginning. If you have Stata 10 or older, you should change the `merge` commands to the old syntax.

SectionIIe.m
~~~~~~~~~~~~
This Matlab script calculates firm-level zeroes in the model, using the trade shares calculated above and the gravity-related variables. Make sure to run `read_gravity_data.do` and `SectionIIa_d.do` first.

SectionIII.m
~~~~~~~~~~~~
This Matlab script calculates all numbers reported in Section III on multi-product and multi-country exporting firms. It takes as inputs the marginal distribution of trade shipments across countries (`data/census/countryshares.csv`) and across products (`data/census/hs10shares.csv`).

SectionIV.m
~~~~~~~~~~~
This Matlab script calculates all the number reported in Section IV on which firms export. It does not take any input: the parameters of the firm-size distribution and the share of exports in revenue are entered directly in the script.

Data
----
World Development Indicators
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
For your convenience, we have reproduced the World Development Indicators from http://databank.worldbank.org/data/download/WDI_csv.zip (downloaded on October 17, 2013). Please cite the original data as:

	World Development Indicators, The World Bank. 2013.

Penn World Table
~~~~~~~~~~~~~~~~
For your convenience, we have reproduced version 7.1 of the Penn World Table from  http://pwt.econ.upenn.edu/Downloads/pwt71/pwt71_11302012version.zip (downloaded on October 17, 2013). Please cite the original data as:

	Alan Heston, Robert Summers and Bettina Aten, Penn World Table Version 7.1, Center for International Comparisons of Production, Income and Prices at the University of Pennsylvania, Nov 2012.

U.S. Exports of Merchandise
~~~~~~~~~~~~~~~~~~~~~~~~~~~
The analysis of Section II uses the published detailed export data from the December 2005 release
U.S. Exports of Merchandise, U.S. Bureau of the Census. 

We have converted the dBase file `export_detl.dbf` in `.csv` format and saved it in `data/census/exp_detl.csv` for your convenience. Please cite the original data as:

	U.S. Exports of Merchandise DVD-ROM. December issue. U.S. Dept. of Commerce, Economics and Statistics Administration, Bureau of the Census, 2005.

Internet resources
------------------
GeoDist data from CEPII
~~~~~~~~~~~~~~~~~~~~~~~
We read the GeoDist data on geographic distance directly from the CEPII website, `http://www.cepii.fr/distance/dist_cepii.dta` (accessed October 17, 2013). Please cite the original data as:

	Mayer, T. & Zignago, S. (2011) Notes on CEPII’s distances measures : the GeoDist Database CEPII Working Paper 2011-25 - See more at: http://www.cepii.fr/CEPII/en/bdd_modele/presentation.asp?id=6#sthash.ADIwQtB6.dpuf

Schedule-C country codes of the Census
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Flat-text file read directly from `http://www.census.gov/foreign-trade/schedules/c/country.txt` (accessed on October 17, 2013).

Conversion between ISO 3166 2-digit and 3-digit country codes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ISO 3166-1 is the standard for alphanumeric country codes, see `http://www.iso.org/iso/home/standards/country_codes.htm`. We use the conversion at `http://commondatastorage.googleapis.com/ckannet-storage/2011-11-25T132653/iso_3166_2_countries.csv` (accessed October 17, 2013).
