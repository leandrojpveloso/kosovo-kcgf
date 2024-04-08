* Goal:Central Bank Data data preparation
*-------------------------------------------------------------------------------

* 1: Importing data Central Bank
{
	* 2015
	import excel using  "${path_project}/data/raw/Central Bank 2015-2018.xls" , clear firstrow sheet("_bb_loans_2015")
	gen year = 2015
	tempfile   2015
	save      `2015'
	
	* 2016
	import excel using  "${path_project}/data/raw/Central Bank 2015-2018.xls" , clear firstrow sheet("_bb_loans_2016")
	gen year = 2016
	tempfile   2016
	save      `2016'			

	forvalues year = 2017(1)2022 {
		foreach sheet in 1 2 3 4 {
			
		if `year' == 2017 | `year' == 2018 cap noi	import excel using  "${path_project}/data/raw/Central Bank 2015-2018.xls"  , clear firstrow sheet("`year'_`sheet'")
		
		if `year' >  2018 				   cap noi  import excel using  "${path_project}/data/raw/Central Bank `year'.xls" 	, clear firstrow sheet("`year'_`sheet'")
		
		gen year = `year'
		cap noi tempfile data_`year'_`sheet'
		cap noi save 	`data_`year'_`sheet''
		}				
	}
	.
}
.
	
* 2: Appending separated years
{
	clear
	append using `2015'
	append using `2016'
	forvalues year = 2017(1)2022 {
		foreach sheet in 1 2 3 4 {
			cap noi append using `data_`year'_`sheet''
		}
	}
	. 
}
.

* 3: Variable adjustments
{		
	* Converting to strings
	tostring *, replace force
	
	* Replacing by missing
	foreach var of varlist * {
		replace `var' = "" if `var' == "NULL" | `var' == "N/A" 
	}	
					
	foreach var of varlist ApprovalDate DisbursementDate MaturityDate {
		generate aux1 = date(subinstr(`var',"-","/",.), "YMD")			
		format   aux1* %td
		drop     `var'
		rename   aux1 `var'
	}
	destring *, replace
	
	keep 	if year == year(ApprovalDate)
	duplicates report	//no duplicates
	gen 	period = year(ApprovalDate)
	drop 	NewColumn year
	keep 	if period >= 2015
	drop 	if Amount == 0
	gen 	kcgf = Fundcoverage == "FKGK"
	compress
	save "${path_project}/data/inter/03-Central Bank.dta", replace

}
.
