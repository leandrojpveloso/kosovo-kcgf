* Goal: This is a set of data that will be useful to data preparation
*-------------------------------------------------------------------------------

* 01: Recovering business id data
{
	import 		excel using "${path_project}/data/raw/Tax-payer & Business Numbers.xlsx", sheet("TaxPayer x BR") clear allstring firstrow			//correspondency between tax payer number and business registration number.
	
	rename tax_payer_no id_tax
	rename businessid 	id_firm
	
	* Removing everything that is not number
	replace id_tax = ustrregexra(id_tax,"[^0-9]","")
	replace id_firm   = ustrregexra(id_firm,"[^0-9]","")
	compress
	
	* Removing duplications
	bys id_tax id_firm: keep if _n==1
	keep 		if	id_tax != "" & id_firm != ""
	 
	replace  	id_firm = trim(id_firm)
	gen id_length = length(id_firm)
	tab id_length

	cap drop N_L*
	local id_check id_firm
	foreach val of numlist 1/3 {
		*di as white `val'
		gen N_L_`val' = real(substr(`id_check',`val',1))
		tab N_L_`val' id_length ,m
	}
	.				
	cap drop N_L*
 
		
	* 
	* replace id_firm = "0"*(9-length(id_firm)) + id_firm if length(id_firm)<=8
	
	bys id_tax: gen D_dup_tax = _N>=2
		tab D_dup_tax
	
	bys id_firm	: gen D_bus_id  = _N>=2
		tab D_bus_id
		
	duplicates drop id_firm, force
	
	sort  	id_firm
	keep id_firm id_tax
 	rename id_firm id_firm_merge
	
 	save 		"${path_project}/data/inter/01-Tax Payer and id_firm.dta", replace	
	 
	gduplicates drop id_tax, force
	
	save 		"${path_project}/data/inter/01-Tax Payer and id_firm-tax_payer.dta", replace	
}
.

* 02: Deflator dataset
{
	clear
	set obs 100
	gen period = 1990 +_n-1
	
	* deflator base 2022 by division
		gen ppi_deflator = .
	replace ppi_deflator = 100   /100   if period ==2022
	replace ppi_deflator = 89.6  /100   if period ==2021
	replace ppi_deflator = 86.7  /100   if period ==2020
	replace ppi_deflator = 86.52 /100   if period ==2019
	replace ppi_deflator = 84.27 /100   if period ==2018
	replace ppi_deflator = 83.39 /100   if period ==2017
	replace ppi_deflator = 82.17 /100   if period ==2016
	replace ppi_deflator = 81.94 /100   if period ==2015
	replace ppi_deflator = 82.39 /100   if period ==2014
	replace ppi_deflator = 82.04 /100   if period ==2013 
	replace ppi_deflator = 80.61 /100   if period ==2012
	replace ppi_deflator = 78.66 /100   if period ==2011
	replace ppi_deflator = 73.28 /100   if period ==2010
	
	
	keep if ppi_deflator != .
	
	*  saving
	label data "Kosovo deflator year base 2022"
	
	compress
	save 		"${path_project}/data/inter/01-deflator_ppi_2022.dta", replace	
} 
.

