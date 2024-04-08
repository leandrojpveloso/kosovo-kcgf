* Goal: KCGF data preparation
*-------------------------------------------------------------------------------

* 1: importing data KCGF
{
	* reading and keeping vars
	{ 
		import excel using "${path_project}/data/raw/KCGF-2016-2022.xlsx", allstring clear firstrow
		
		foreach var of varlist * {
			local label_var: var label `var'
			if "`label_var'" == "" drop `var'
		}
 
			
		* Renaming
		rename  NoOfEmployees 				employees
		rename  BusinessAnnualTurnover 		turnover
		rename	Maturity					duration
		rename	NominalInterestrate			irate_nominal
		rename	BusinessRegistrationNumber	businessid
		rename	ApprovedAmount				loanamount
		rename	DisbursementAmount			disbursedamount	
		rename  TotalCollateralValue 		collateralvalue
		 
		local destring_list disbursedamount				 ///
							loanamount	                 /// 
							GuaranteePercentageRequested ///
							GuaranteeAmount	             /// 
							OutstandingBalance	         /// 
							OutstandingBalanceGuaranteed ///
							irate_nominal	             /// 
							EffectiveInterestRate	     /// 
							duration	                 /// 
							GracePeriod	                 /// 
							PaymentAmount	             /// 
							collateralvalue	             /// 
							TotalEstimatedMarketValue	 /// 
							CollateralSecurityTake	     /// 
							employees	                 /// 
							ProjectedNoOfEmployees	     /// 
							TotalAssetsofBusiness	     /// 
							ProjectedAnnualTurnover	     /// 
							turnover					 ///'
							PrepaymentAmount
  
		destring `destring_list', replace
	}
	.

	* Zero to missing
	replace employees = . 	if employees  		== 0
	replace turnover  = . 	if turnover   		== 0

	* 
	gen 	zero_collateral 	   				 = collateralvalue   == 0
	gen 	individual_business 				 = BusinessLegalForm == "IndividualBusiness"
	
	* Dates
	{		
		foreach var of varlist *Date* MonthofAcceptance  BI	CreatedAt	UpdatedAt {
			generate aux`var' = date(word(`var',1), "DMY")
			format   aux`var' %td
			drop 		`var'
			rename   aux`var' `var'
 
			if "`var'" == "ApprovedDate" 	 gen 	year_month_aproved 	  	 = mofd(`var')  
			if "`var'" == "DisbursementDate" gen 	year_month_disbursement  = mofd(`var')  
				format year_month* %tm
		}
		.
 
		rename ApprovedDate 	 	date_loan_approved
		rename DisbursementDate 	date_loan_disbursement 
		rename MonthofAcceptance    date_loan_acceptance 
		rename FirstPaymentDueDate	date_loan_first_payment
		rename MaturityDate 		date_loan_maturity
		
		
		rename  BI			date_bi 
		rename  CreatedAt	date_create_at 
		rename  UpdatedAt   date_update_at 

		
		* removing same vars
		drop date_bi

		global list_orderdate ///
			  date_loan_approved date_loan_disbursement ///
			  date_create_at date_loan_acceptance ///
			  date_loan_first_payment date_loan_maturity  date_update_at
  
 		* dates I know the order
		foreach date in $list_orderdate {	
			qui count if `date' !=.
			di as white "`date' : `=r(N)'"   
			foreach date_comp in $list_orderdate {
				qui count if  `date_comp'  <  `date' & `date' !=.
				local before 	= r(N)
				qui count if  `date_comp'  == `date' & `date' !=.
				local same_date = r(N)
				qui count if  `date_comp'  >  `date' & `date' !=.
				local after_date = r(N)
				di as white "	Before:# `before' | Same :# `same_date' | After :# `after_date'  [`date_comp']"  
			} 
		}
   
		* year
		gen 	period = year(date_loan_approved)
		
		gen year_semester = yh(year(date_loan_approved),halfyear(date_loan_approved))
		format %th year_semester
		
		* Orderind date variables 
		order KCGFLoanNumber KCGFLoanStatus period year_month_aproved year_month_disbursement $list_orderdate	
 	}	
	.  
  
	*Product and purpose of the credit		
 	{
		gen 	group_period = 1 					if period <= 2019
		replace group_period = 2 					if period >= 2020 & Product != "Economic Recovery Window"
		replace group_period = 3 					if period >= 2020 & Product == "Economic Recovery Window"
		gen 	economic_recovery = 								    Product == "Economic Recovery Window"	//identifying if a loan is Economic Recovery Window. 

		replace Product = "Agro Window" 			if Product == "Agro Window 2022"
		replace Product = "Agro Window"				if Product == "GROW Window"
		replace Product = "Regular Window"			if Product == "Standard Window"
		
		replace BusinessLegalForm = "Other" 		if inlist(BusinessLegalForm,"0", "13","6", "9", "GeneralPartnership", "JointStockCompany", "LimitedPartnership")

		gen 	purpose = 1 						if  inlist(PurposeofCredit,"Automobiles","ComercialVehicles","CommercialVehicles")
		replace purpose = 1 						if  inlist(PurposeofCredit,"OfficeComputerEquipment", "OtherEquipment","ProductionOrFarmingEquipment")
		replace purpose = 1						 	if  inlist(PurposeofCredit,"OtherWorkingCapitalExpenses", "IntangibleInvestments", "WorkingCapital" )
		replace purpose = 2 						if  inlist(PurposeofCredit,"Construction","ConstructionOrRenovation", "ExteriorRenovation","InteriorRenovation", "LandAndBuildings", "Renovation", "VariousConstructionsAndGreenhouses" )
		replace purpose = 3	 						if  inlist(PurposeofCredit,"Inventory")
		replace purpose = 4 						if  inlist(PurposeofCredit,"Other", "Consumables","FixedAssets","InputsRawMaterialsCrops")
		
		egen 	c_product = group(Product)
		gen 	prod_agro = c_product == 1
		gen 	prod_erp  = c_product == 2
		gen 	prod_reg  = c_product == 3
		gen 	prod_star = c_product == 4
		
		label 	define c_product  1 "Agro" 				 2 "Economic Recovery Package" 3 "Regular Window" 4 "Start Up Window"
		label 	define purpose	  1 "Equipments/capital" 2 "Construction/renovation"   3 "Inventory"      4 "Other"
		label 	val    purpose purpose 	
		label 	val    c_product   c_product
	}		
	.
	
	* Size
	{		
		gen		size 			= .
		replace size 			= 1 if employees <  10 
		replace size 			= 2 if employees >= 10  & employees 		< 50
		replace size 			= 3 if employees >= 50  & employees 		< 250
		replace size 			= 4 if employees >= 250 & !missing(employees)
		label 	define size 1 "Micro (0-9)" 2 "Small (10-49)" 3 "Medium (50-249)" 4 "Large (250+)"
		label 	values size size
		rename  size   size_kcgf
		
		* Checking
		tabstat employees, by(size_kcgf) stat(count mean min max)
		
		* sales divided by number of employees
		gen   productivity     = turnover/employees 
		tabstat productivity, by(size_kcgf) stat(count mean min max)
	}
	.

	* Amounts in EUR 2022, see inflation in % in the master do file
	{		
		gen ppi_deflator = .
		replace ppi_deflator = 100      if period ==2022
		replace ppi_deflator = 89.6     if period ==2021
		replace ppi_deflator = 86.7     if period ==2020
		replace ppi_deflator = 86.52    if period ==2019
		replace ppi_deflator = 84.27    if period ==2018
		replace ppi_deflator = 83.39    if period ==2017
		replace ppi_deflator = 82.17    if period ==2016
		replace ppi_deflator = 81.94    if period ==2015
		replace ppi_deflator = 82.39    if period ==2014
		replace ppi_deflator = 82.04    if period ==2013 
		replace ppi_deflator = 80.61    if period ==2012
		replace ppi_deflator = 78.66    if period ==2011
		replace ppi_deflator = 73.28    if period ==2010
		
		* checking
		tabstat ppi_deflator, by(period) stat(mean sd)
		

		* Deflating     
		keep if 	period >= 2016
		foreach var of varlist loanamount disbursedamount turnover collateralvalue productivity {
			 gen 	`var'_r = `var'/(ppi_deflator/100)
		}	
	}	
	.
	
	* Loan amount as % of turnover
	{	 
		cap drop *_pct_*
		gegen aux_pct_01 = pctile(loanamount_r) , p(1)   by(size_kcgf)
		gegen aux_pct_05 = pctile(loanamount_r) , p(5)   by(size_kcgf)
		gegen aux_pct_95 = pctile(loanamount_r) , p(95)  by(size_kcgf)
		gegen aux_pct_99 = pctile(loanamount_r) , p(99)  by(size_kcgf)
 
		gen 		shareloan_turnover 		= (loanamount_r/turnover_r)*100 if inrange(loanamount_r,aux_pct_01,aux_pct_99)
		cap drop *_pct_*
 	}		
	.	
	
	*Outliers in terms of turnover and productivity
	cap drop D_outlier_*_trim_*
	foreach var  in irate_nominal  duration  turnover productivity  {
		cap drop *_pct_*
		gegen aux_pct_01 		= pctile(`var') , p(1)   by(period size_kcgf)
		gegen aux_pct_05 		= pctile(`var') , p(5)   by(period size_kcgf)
		gegen aux_pct_95 		= pctile(`var') , p(95)  by(period size_kcgf)
		gegen aux_pct_99 		= pctile(`var') , p(99)  by(period size_kcgf)

		gen byte D_outlier_`var'_trim_1	= !inrange(`var' ,aux_pct_01,aux_pct_99)
		gen byte D_outlier_`var'_trim_5	= !inrange(`var' ,aux_pct_05,aux_pct_95)
		
		cap drop *_pct_*
	}
	.		
 
	* Data filters
 	{	
		cap drop D_filter
		gen 	D_filter = 0
		replace D_filter = 1  if loanamount 		== 0
		replace D_filter = 2  if LoanStatus 		== "Canceled"
		replace D_filter = 3  if date_loan_approved == .
		replace D_filter = 4  if D_outlier_irate_nominal_trim_1 	==1
		replace D_filter = 5  if D_outlier_duration_trim_1 	 		==1	
		replace D_filter = 6  if D_outlier_turnover_trim_1 	 		==1	
		replace D_filter = 7  if D_outlier_productivity_trim_1  	==1
		
		label var D_filter "Filters applied in the data"
		
		label def lab_filter 0 "00-data_selection"			 		///
							 1 "01-loan amount zero" 				///
							 2 "02-loan status canceled"			///
							 3 "03-no approved date"				///
							 4 "04-trimmed 1% nominal rate" 		///
							 5 "05-trimmed 1% duration"				///
							 6 "06-trimmed 1% turnover"				///
							 7 "07-trimmed 1% productivity" 		///
 							 ,replace
		
		label val D_filter  lab_filter
					
		tab  D_filter period
	}
	.	
	
	 
	
	rename FrequencyofPaymen 			loan_pay_freq
	rename BusinessLegalForm 			business_legal_form
	rename NIFNr			 			id_nif
	rename FICoreCreditIdentificationNu id_fic
	rename PurposeofCredit 				purpose_loan
	rename ClientMunicipality			client_munic
	rename Region						client_region
	rename KCGFLoanNumber				id_kcgf
	rename businessid					id_firm
	
	label var id_nif  "the Fiscal number (Numri fiskal)"
	 
	* Orderind date variables 
	order  id_*     period year_semester size_kcgf ///
		 employees turnover  productivity ///
		 TypeofClient Product c_product ///
		year_month_aproved year_month_disbursement $list_orderdate ///
		duration loanamount irate_nominal disbursedamount_r EffectiveInterestRate ///
		GuaranteePercentageRequested ///
		zero_collateral D_filter D_outlier_* ///
		loan_pay_freq			///					
		business_legal_form		///	 
		purpose_loan			///			
		client_munic			///			
		client_region			
		
		
	*Formating
 	{	
			format 	*Amount* *amount* turnover* productivity* shareloan_turnover ProjectedAnnualTurnover %15.2fc
			cap drop 	temp
			replace TypeofClient = "" if TypeofClient == "2"
			replace id_firm	 =  ustrregexra(id_firm,"[^0-9]","")
			replace id_nif	 =  ustrregexra(id_nif,"[^0-9]","")
			* egen 	firm_id 	 = group(businessid)			
			sort 	id_firm period
	}
	.		
	
	
	* Cheking ids formats
	{
		replace id_nif	= id_firm if length(id_firm) ==7
		
				
		replace id_firm	= id_nif if length(id_nif) ==9
			
 
		gen D_wrong_firm_id = !inlist(substr(id_firm,1,1),"","7","8") | ///
							  !inlist(substr(id_firm,2,1),"","0","1")
	
		gen D_wrong_nif_id  = !inlist(substr(id_nif,1,1),"1" )			 | ///
							  !inlist(substr(id_nif,2,1),"","0","1")	
							  
							  
							  
		replace id_firm	= "" if !inlist(length(id_firm),8,9) | D_wrong_firm_id==1
		replace id_nif	= "" if inlist(length(id_nif),7) 	 | D_wrong_nif_id==1	
							  
		

		gen 	 type_id = "01-FIRM_id" if  D_wrong_firm_id	==0 & id_firm!=""
		replace  type_id = "02-NIF_id"  if  D_wrong_nif_id	==0 & id_nif!=""
		tab type_id
		
		tab type_id  business_legal_form
		
		cap drop N_L*
		local id_check id_kcgf
		foreach val of numlist 1/24 {
			*di as white `val'
			*gen N_L_`val' = real(substr(`id_check',`val',1))
			*tab N_L_`val'  type_id,m
		}
		.				
		cap drop N_L*
		
		* global also_check  business_legal_form  LoanStatus KCGFLoanStatus loan_pay_freq	AssetClassification		 purpose_loan Section Comments
		* local id_check id_nif
		* sort `id_check'  
		* bro *id* ${also_check} if !inlist(substr(`id_check',2,1),"","0","1")
		* bro *id* ${also_check}  if !inlist(N_L_2,.,1)
		 
		
		cap drop length_*
		gen length_business_id_kcgf = length(id_firm)
			tab length_business_id_kcgf, m
			
			
		gen length_nif_id_kcgf		= length(id_nif)
			tab length_nif_id_kcgf, m
			
		gen length_fic_id			= length(id_fic)
			tab length_fic_id period, m
		cap drop length_*
		
	}
 
	* Including businessid
	{
 		di as white %10.0fc "KCGF has `=_N' obs"
		 
		* replace id_firm = "0"*(9-length(id_firm)) + id_firm if length(id_firm)<=8
		 
		codebook 	id_firm, detail
		di as white %10.0fc "KCGF has `=_N' obs"
		
		gen     id_firm_merge = id_firm if id_firm!=""  
		
		merge 		m:1 id_firm_merge using "${path_project}/data/inter/01-Tax Payer and id_firm.dta", keep(1 3)
		gen D_no_business_id_recover = _merge==1
		drop _merge   id_firm_merge
		 
		* No match to 8 digits business id
		tab period D_no_business_id_recover
		   
 	}
	
	* Temporary	
	keep if !inlist(D_filter,1,2,3) & year_semester!=.
	
	keep if id_firm != "" 
	drop if D_wrong_firm_id==1
	drop D_wrong*
	
	
	compress
	save "${path_project}/data/inter/02-KCGF.dta", replace	
}
.
  
* 2: KCGF PANEL each row is one firm and one year
{
	use  "${path_project}/data/inter/02-KCGF.dta",clear
	 
	*Collapsing one observation per firm per year
	{	
		gen 			number_loans = 1
		collapse (sum)  number_loans loanamount loanamount_r disbursedamount disbursedamount_r ///
				 (mean) GuaranteePercentageRequested  duration irate_nominal turnover turnover_r productivity productivity_r ///
				 (max)  employees size_kcgf prod_*, by(id_firm id_tax period)
		
		rename 	turnover_r     turnover_r_kcgf
		rename 	turnover       turnover_kcgf
		rename 	employees      employees_kcgf
		rename  productivity   productivity_kcgf
		rename  productivity_r productivity_r_kcgf
		duplicates report id_firm period  //no duplicates okkk
		egen 	number_types_loans = rowtotal(prod_*)			//to check if the firm has a regular and a economic recovery package for example. 
	
	}
	
	*Creating a balanced panel
	{
		set obs `=_N+1'
		replace period = 2014 if  _N==_n
		*set obs `=_N+1'
		*replace period = 2022 if  _N==_n
		
		egen id_firm_num = group(id_firm)
		tsset 	id_firm_num  period
		tsfill, full
		 
		* Filling constant vars
		foreach var of varlist id_firm id_tax {
			gsort id_firm_num -`var'
			by id_firm_num: replace  `var'= `var'[1]
		}
		.
		
		* drop auxiliar data
		drop if id_firm==""
	}
	.
	
	* Identifying the first KCGF loan
	{	
		bys 	id_firm: egen f_kcgf 	= min(period) if loanamount != 0 & loanamount!= .		//first kcgf the firm got it
		bys 	id_firm: egen first_kcgf = max(f_kcgf)
		gen 	comparison = first_kcgf > 2021														//lets treat as comparison group the firms that only got the loan in 2022
		sort 	id_firm period
		* br 		id_firm id_firm period loanamount f_kcgf first_kcgf
		drop 	f_kcgf
		order 	id_firm id_firm period
		
		gen 	t = loanamount != . & loanamount > 0
		bys 	id_firm		  : egen treated_kcgf 		= max(t)
		drop 	t
		
		gen 	t = loanamount !=. & loanamount > 0 & first_kcgf < 2022
		bys 	id_firm		  : egen treated_before2022 = max(t)
		drop    t
		* br 		id_firm id_firm period loanamount first_kcgf treated_kcgf treated_before2022
			
		//Treatment Group - > Firms included in KCGF up to 2021
		//Comparison Group -> Firms included in KCGF only in 2022
		
	}
	
	compress
	save "${path_project}/data/inter/02-KCGF-panel.dta", replace	
}	
.


* Notes


													*KCGF AND CENTRAL BANK*
*__________________________________________________________________________________________________________________________________________*
**

	
	/*
	Dataset shared by KCGF	 -> I replaced the following variables by missing if they are in the bottom 1% or top 1%
								
									- duration
									- interest rates 
									- turnover 
									- productivity 
									
									
	The data has the business registration number which allow us to merge it with the Tax Registry
	
	
	Dataset shared by the Central Bank ->
	
		All business registration numbers are masked. We can only show descriptive statistics. 
	*/
	
	
			
	**
	** KCGF each row is a loan ID for firm i, in year t, the same firm can have several KCGF loans in the same year
	*--------------------------------------------------------------------------------------------------------------------------------->>	
	
/*


**
** Central Bank Data Collaterals
*--------------------------------------------------------------------------------------------------------------------------------->>
	forvalues year = 2010(1)2022 {
		import excel using  "$data\raw\New Central Bank Data-2010-2017.xls" , clear firstrow sheet("_bb_collaterals_`year'") 	
		local yeart = `year' - 1
		if `year' > 2010 append using ``yeart'', force
		tempfile `year'
		save    ``year''
	}
	duplicates drop
	sort  LoanNo period
	order LoanNo period
	rename 	(LoanNo-Priority) (loanid institution collateral collateralvalue ispledge pledgedate priority )
	replace  	collateral = "1"  if collateral == "Ndërtesë"
	replace  	collateral = "2"  if collateral == "Tokë"
	destring 	collateral, replace
	collapse 	(sum) collateralvalue, by (loanid institution collateral)	
	reshape 	wide collateralvalue, i(loanid institution) j(collateral) 
	rename 	  (collateralvalue1 collateralvalue2) (collateral_property collateral_land)
	save "$data\inter\Collaterals.dta", replace


import excel using  "$data\raw\New Central Bank Data-2018-2022.xlsx", clear firstrow sheet("classification") 
save "$data\inter\Classification.dta", replace


	

