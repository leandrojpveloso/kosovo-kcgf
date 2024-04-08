* Goal: Importing raw file in the tax registry and cleaning it
*-------------------------------------------------------------------------------
* foreach var in po salaries turnover

import delim "${path_project}/data/raw/Tax Registry-2010-2018.csv",clear delim(",")
 
rename numberofemployedpersons po_old

tostring period, replace format(%04.0f)
tostring municipalityid, replace format(%02.0f)


* bro period  municipalityid  activityid  statusid turnover
gen merge_id_aux =	period 		+ ///
					municipalityid	+ ///
					activityid 		 	

cap drop turnovermerge
gen turnovermerge = string(floor(salaries/10)*10)
					
keep if !inlist(salaries,0,.)					

cap drop tag
gduplicates tag merge_id_aux turnovermerge, gen(tag)

keep if tag==0
 
tab period
keep merge_id_aux 	turnovermerge po_old	 fuid	 period		


tempfile data
save 	`data'


use "${path_project}/data/inter/Tax Registry Raw.dta", clear	
			rename  frameperiod period
			
keep period turnover  municipalityid ent_activity_code  nr numberofemployedpersons  tax_payer_no salaries



foreach var in municipalityid ent_activity_code   {
	replace `var' = ustrregexra(`var',"[^0-9]","")
}


replace municipalityid = (2-length(municipalityid))*"0" + municipalityid if length(municipalityid)<=2
 
gen merge_id_aux = 	period  + 					///
					municipalityid +			///
					ent_activity_code  
					
gen turnovermerge = string(floor(real(salaries)/10)*10) 

gduplicates tag merge_id_aux turnovermerge, gen(tag)

keep if tag==0

gunique merge_id_aux turnovermerge if !inlist(real(salaries),.,0)

keep if !inlist(real(turnover),.,0)

merge m:1 merge_id_aux turnovermerge  using `data'

sort merge_id_aux turnovermerge
tab period _merge

preserve
	keep if fuid !=. & tax_payer_no!=""

	duplicates drop fuid tax_payer_no, force

	gunique fuid 
	gunique tax_payer_no 

	bys fuid: gen N_fuid= _N
	bys tax_payer_no: gen N_tax= _N

	drop if N_fuid>=2 | N_tax>=2
	 
	keep  fuid tax_payer_no
	
	append using "${path_project}/data/inter/fuid_to_tax"
	
	duplicates drop fuid tax_payer_no, force
	
	save "${path_project}/data/inter/fuid_to_tax",replace
restore

keep if substr(merge_id_aux,1,4) == "2017"

keep period fuid tax_payer_no




drop if _merge==3

gegen var = sd(_merge) , by(merge_id_aux)

count if inlist(var,0,.)
drop if inlist(var,0,.)

bys merge_id_aux : gen count_n = _N

tab _merge
 
order _merge merge_id_aux turnovermerge period  municipalityid ent_activity_code nr turnover po numberofemployedpersons


* 1: Importing TAX REGISTRY DATASET SHARED BY THE GOVERNMENT OF KOSOVO 
foreach year of numlist 2011/2021  {
	di as white "`year'"
	import 	excel using  "${path_project}/data/raw/Tax Registry_2011-2021.xlsx", sheet(`year') clear allstring
 eeee
	*
	foreach var of varlist * {
		local var_name = `var'[1]

		if "`var_name'"=="" {
			drop `var'
		} 
		else {
			di as white "`=ustrtoname("`var_name'")'"
			label var `var' "`var_name'" 
			cap rename `var' `=lower(ustrtoname("`var_name'"))'
		}
	}
	.
	
	drop in 1
	compress
	save "${path_project}/data/01-import/03-tax_reg_`year'",replace
}
.
	
* 2: Harmonize data
{
	local year 2011
	import 	excel using  "${path_project}/data/raw/Tax Registry_2011-2021.xlsx", sheet(`year') clear allstring

	
	
	use "${path_project}/data/01-import/03-tax_reg_`year'",clear
	
	
	* Reading raw file
	use "${path_project}/data/inter/Tax Registry Raw.dta", clear	
	
	rename  frameperiod period
	
	merge m:1 tax_payer_no  using "${path_project}/data/inter/fuid_to_tax"
	
	destring Turnover, replace
	tab period _merge if !inlist(turnover,0,.)
	
	* Reading raw file
	use "${path_project}/data/inter/Tax Registry Raw.dta", clear	
	
	foreach var of varlist * {
		rename `var' `=lower("`var'")'
	}
	
	
	* time variable
	{
		rename  frameperiod period
		
		* variable adjusts
		tab 	period
		
		* from 2011 to 2015 all information for employees is missing
		tab 	period if numberofemployedpersons == ""
		
		* Converting to numeric
		destring vat_11 numberofemployedpersons cd_74 vat_31  vat_33  vat_35  vat_37 borth_year period municipalityid salaries turnover, replace
	 
		* Renaming
		rename vat_11					exports_amount
		rename numberofemployedpersons	employees
		rename cd_74					operational_profit
				
		* firm purchases that are imported -guess does not include investment (Matias Belacin comment)	
		gegen 	imports_amount = rowtotal(vat_31  vat_33  vat_35  vat_37), missing 				
		
		* identifying firms that do not report turnover
		gen 	declared0turnover   =       turnover == 0  				 
		replace turnover 	  		= . if  turnover == 0
		replace employees 			= . if employees == 0

		* before 2015, the variable number of employees is missing
		replace employees 			= 1 if missing(employees) & y == "INDIVIDUAL" 
		
		egen 	 sectorid = group(description_sectory)
		destring ent_activity_no, replace
	}
	.
	
	tab period  
	tab period y if employees==. & turnover!=.
 
	* Size estat: Based N employees 
	{
		gen		size 			= .
		replace size 			= 1 if employees <  10 
		replace size 			= 2 if employees >= 10  & employees 		< 50
		replace size 			= 3 if employees >= 50  & employees 		< 250
		replace size 			= 4 if employees >= 250 & !missing(employees)
		replace size			= 5 if missing(employees)
		label 	define size 1 "Micro (0-9)" 2 "Small (10-49)" 3 "Medium (50-249)" 4 "Large (250+)" 5 "No info"
		label 	values size size
	}
	.
	
	* Import or export firm 
	{
		gen 	export_tx 		= exports_amount > 0 & exports_amount != .
		gen 	import_tx 		= imports_amount > 0 & imports_amount != .
		label 	define export_tx 1 "Export firm" 0 "No export firm"
		label 	define import_tx 1 "Import firm" 0 "No import firm"
		label	val export_tx export_tx
		label 	val import_tx import_tx
	}
	.
	 
	* Firms age
	{
		gen 	error = borth_year > period								//firms birth year > period, it does not make sense. 
		bys 	tax_payer_no period: egen firstyearpanel = min(period)		
		replace borth_year = firstyearpanel 			if error == 1		//for when the previous error happens, lets consider the birth year the first year of the firm in the panel. 
		gen 	firms_age = period - borth_year
		drop	firstyearpanel error
	}
	.

	*Serbian maiority
	{
		gen 		 ethnicity = 0 
		foreach 	 munid in 12 14 23 28 29 34 35 36 37 3 {
			replace  ethnicity = 1 if municipalityid == `munid'
		}
		label define ethnicity 0 "Non-Serbian majority" 1 "Serbian majority"
		label values ethnicity ethnicity		
	}
	.
			 	
	* Variables production
	{
		gen   productivity     = turnover/employees
				
		gen 	ln_turnover 		= ln(turnover)
		gen 	ln_productivity		= ln(productivity)
		gen 	ln_employees		= ln(employees)
	}
	.
		
	* Outliers identification
	{
		sort 	 tax_payer_no period
		
		cap drop *_pct_?5
		gegen turnover_pct_05 = pctile(turnover) , p(5)   by(period size)
		gegen turnover_pct_95 = pctile(turnover) , p(95)  by(period size)
		
		* Filter turnover
		gen D_filter_trim_turnover = inrange(turnover ,turnover_pct_05,turnover_pct_95)
		
		* productivity: sales divided by number of employees
		cap drop *_pct_?5
		gegen prod_pct_05 = pctile(productivity) , p(5)   by(period size)
		gegen prod_pct_95 = pctile(productivity) , p(95)  by(period size)
		
		* Filter turnover
		gen D_filter_trim_prod =  inrange(productivity ,prod_pct_05,prod_pct_95)
		
		* Dropping aux vars
		cap drop *_pct_?5
	}	
	.
	
	* Real values: Applying defaltor		
	{	
		merge m:1 period using "${path_project}/data/inter/01-deflator_ppi_2022.dta", nogen keep(3)
		
		* checking
		tabstat ppi_deflator, by(period) stat(mean sd)
	 
		* Deflating                                                                                                   
		foreach var of varlist turnover salaries exports_amount imports_amount operational_profit productivity {
			 gen 	`var'_r = `var'/ppi_deflator 
		}	
	}
	.	

	* saving data
	{		
		format *amount*  salaries* turnover* ln* *_r productivity* *profit* %15.2fc
		rename tax_payer_no	 id_tax	
		order 		id_tax period municipalityid nr y ent_activity_no ent_activity_code ent_activity_desc description_sectory sectorid ethnicity size
		
		gduplicates  report id_tax period
		
		* Dropping extra variables
		drop vat_* cd_* pd_* qs_* is_*
			 
		* Labeling data
		label data "Clean tax registry from 2011 to 2021"
		
		gen byte active=1
		
		compress
		save 	"${path_project}/data/inter/03-Tax Registry.dta", replace			//this dataset only has tax payer id. 	
	}
	.
}
.

* Notes
 
/*

To merge Tax Registry with KCGF data, we need to recover the business registration numbers. 
KCGF data only has business registration and the tax registry we just treated above only has tax payer number. 
The tax authority shared with me the correspondency between tax payer and business registration numbers. It is important to point out that:
	- The same tax payer can have several business registrations numbers (the same tax payer can have more than one business)
	- when applying for loans, as far as we understood, firms share their business registration number.

*/
		