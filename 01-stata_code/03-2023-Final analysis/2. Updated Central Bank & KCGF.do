

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
		{
		    
			
			*Importing and renaming
			*----------------------------------------------------------------------------------------------------------------------------->>
			{
			import excel using "$data\raw\KCGF-2016-2022.xlsx", allstring clear firstrow
				drop C D BI
				
					keep	///
					FinancialInstitution Municipality  ClientMunicipality Product TypeofClient 									///
					ApprovedAmount ApprovedDate DisbursementAmount DisbursementDate GuaranteePercentageRequested 				///
					NominalInterestrate EffectiveInterestRate Maturity GracePeriod 												///
					Region Section Division 																					///
					TotalAssetsofBusiness NoOfEmployees ProjectedNoOfEmployees BusinessAnnualTurnover ProjectedAnnualTurnover	///
					KCGFLoanStatus LoanStatus TotalCollateralValue																///
					AssetClassification  BusinessLegalForm BusinessRegistrationNumber FrequencyofPayment GuaranteeAmount 		///
					KCGFLoanNumber OutstandingBalanceGuaranteed OutstandingBalance PaymentAmount Prepayed PurposeofCredit 		///
					Subproduct PrepaymentAmount MaturityDate GuaranteeFee FirstPaymentDueDate KCGFLoanNumber AnnualFee		
						
					destring, replace
					rename  NoOfEmployees employees
					rename  BusinessAnnualTurnover turnover
					rename (Maturity NominalInterestrate BusinessRegistrationNumber ApprovedAmount DisbursementAmount TotalCollateralValue) (duration irate_nominal businessid loanamount disbursedamount collateralvalue)
					
					**
					*Error
					replace employees = . 	if employees  		== 0
					replace turnover  = . 	if turnover   		== 0

					**
					*
					gen 	zero_collateral 	   				 = collateralvalue   == 0
					gen 	individual_business 				 = BusinessLegalForm == "IndividualBusiness"
			}	

			*Removing when loan amount = 0 or when status == Canceled
			*----------------------------------------------------------------------------------------------------------------------------->>
			{
				drop 					if loanamount 		== 0
				drop					if LoanStatus 		== "Canceled"
			}
			
			
			*Dates
			*----------------------------------------------------------------------------------------------------------------------------->>
			{		
					foreach var of varlist *Date* {
					    generate aux`var' = date(`var', "DMY")
						format   aux`var' %td
						drop 		`var'
						rename   aux`var' `var'
						
						if "`var'" == "ApprovedDate" 	 gen 	ApprovedMonthYear 	  = mofd(`var')  
						if "`var'" == "DisbursementDate" gen 	DisbursementMonthYear = mofd(`var')  
							format  *MonthYear %tm
					}
					
					gen 	period = year(ApprovedDate)
					drop	 		   if ApprovedDate == .	//one observation
			}	
					
				
			*Product and purpose of the credit		
			*----------------------------------------------------------------------------------------------------------------------------->>
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
			
			
			*Size
			*----------------------------------------------------------------------------------------------------------------------------->>
			{		
					gen		size 			= .
					replace size 			= 1 if employees <  10 
					replace size 			= 2 if employees >= 10  & employees 		< 50
					replace size 			= 3 if employees >= 50  & employees 		< 250
					replace size 			= 4 if employees >= 250 & !missing(employees)
					label 	define size 1 "Micro (0-9)" 2 "Small (10-49)" 3 "Medium (50-249)" 4 "Large (250+)"
					label 	values size size
					rename  size   size_kcgf
			}	
					
			
			*Outliers in terms of interest rates and duration according to firms' size
			*----------------------------------------------------------------------------------------------------------------------------->>
			{		
				forvalues period 	  = 2011(1)2011 {
					foreach size_kcgf  in 1 2 3 4 {
						di as red "size `size_kcgf'"
						su 		irate_nominal 			if size_kcgf == `size_kcgf' & period == `period', detail
						replace	irate_nominal = . 		if size_kcgf == `size_kcgf' & period == `period' & (irate_nominal <= r(p1) | irate_nominal >= r(p99)) & r(N) > 10
						su 		duration 				if size_kcgf == `size_kcgf' & period == `period', detail
						replace duration 	  = . 		if size_kcgf == `size_kcgf' & period == `period' & (duration 	  <= r(p1) | duration	   >= r(p99)) & r(N) > 10			
					}
				}
			}
					
					
			*Outliers in terms of turnover and productivity
			*----------------------------------------------------------------------------------------------------------------------------->>
			{
				forvalues period 	  = 2011(1)2011 {
					foreach size in 1 2 3 4  	    {
						di as red "period " `period' " and " " `size'" 
						su 		turnover			if size_kcgf == `size' & period == `period', detail
						replace turnover	 = . 	if size_kcgf == `size' & period == `period' & (turnover 		 <= r(p1) | turnover 	  >= r(p99))
					}
				}
				gen   productivity     = turnover/employees	//sales divided by number of employees
				forvalues period 	  = 2011(1)2021 {
					foreach size in 1 2 3 4 	    {
					su 		productivity			if size_kcgf == `size' & period == `period', detail
					replace productivity   = . 		if size_kcgf == `size' & period == `period' & (productivity      <= r(p1) | productivity  >= r(p99))
					}
				}
			}	
			
			
			*Amounts in EUR 2022, see inflation in % in the master do file
			*----------------------------------------------------------------------------------------------------------------------------->>
			{		
					local ppi2022 100
					local ppi2021 89.6
					local ppi2020 86.7
					local ppi2019 86.52
					local ppi2018 84.27
					local ppi2017 83.39
					local ppi2016 82.17
					local ppi2015 81.94
					local ppi2014 82.39
					local ppi2013 82.04 
					local ppi2012 80.61
					local ppi2011 78.66
					local ppi2010 73.28

					keep if 	period >= 2016
					forvalues 	period  = 2016(1)2022 {
						foreach var of varlist loanamount disbursedamount turnover collateralvalue productivity {
							if `period' == 2016 gen 	`var'_r = `var'/(`ppi`period''/100) if period == `period'
							if `period' != 2016 replace `var'_r = `var'/(`ppi`period''/100) if period == `period'
						}
					}
			}		
					
				
			**
			*Loan amount as % of turnover
			*----------------------------------------------------------------------------------------------------------------------------->>
			{	
				clonevar temp = loanamount_r
					foreach size_kcgf in 1 2 3 4 5		  {
					    di as red "size `size_kcgf'"
						su 		 temp							if size_kcgf == `size_kcgf', detail
						replace  temp = . 						if size_kcgf == `size_kcgf' & (  temp      			<= r(p1) |  temp              >= r(p99))
					}
					gen 		shareloan_turnover 		= (temp/turnover_r)*100
					su			shareloan_turnover		, detail
					replace 	shareloan_turnover 		= . 	if 								shareloan_turnover  <= r(p1) | shareloan_turnover >= r(p91)
			}		
					
					
			**
			*Formating
			*----------------------------------------------------------------------------------------------------------------------------->>
			{	
					format 	*Amount* *amount* turnover* productivity* shareloan_turnover ProjectedAnnualTurnover %15.2fc
					drop 	temp
					replace TypeofClient = "" if TypeofClient == "2"
					replace businessid	 = trim(businessid)
					egen 	firm_id 	= group(businessid)			
					sort 	businessid period
			}
			compress
			
				
			gen 	semester_year = 1  if month(ApprovedDate) <= 6 & period == 2016
			replace semester_year = 2  if month(ApprovedDate) >  6 & period == 2016
			replace semester_year = 3  if month(ApprovedDate) <= 6 & period == 2017
			replace semester_year = 4  if month(ApprovedDate) >  6 & period == 2017
			replace semester_year = 5  if month(ApprovedDate) <= 6 & period == 2018
			replace semester_year = 6  if month(ApprovedDate) >  6 & period == 2018
			replace semester_year = 7  if month(ApprovedDate) <= 6 & period == 2019
			replace semester_year = 8  if month(ApprovedDate) >  6 & period == 2019
			replace semester_year = 9  if month(ApprovedDate) <= 6 & period == 2020
			replace semester_year = 10 if month(ApprovedDate) >  6 & period == 2020
			replace semester_year = 11 if month(ApprovedDate) <= 6 & period == 2021
			replace semester_year = 12 if month(ApprovedDate) >  6 & period == 2021
			replace semester_year = 13 if month(ApprovedDate) <= 6 & period == 2022
			replace semester_year = 14 if month(ApprovedDate) >  6 & period == 2022

			save "$data\inter\Updated KCGF.dta", replace	
		}
	
	
		**
		** KCGF PANEL each row is one firm and one year
		*--------------------------------------------------------------------------------------------------------------------------------->>
		{
			use "$data\inter\Updated KCGF.dta" if businessid != "", clear    				//238  loans without business id
		
			*Checking firms with more than one loan per year.
			*----------------------------------------------------------------------------------------------------------------------------->>
			{
				sort businessid period
				*br   businessid period KCGFLoanNumber ApprovedMonthYear ApprovedDate
				*duplicates report businessid period KCGFLoanNumber					//no duplicates, ok!
				*duplicates tag    businessid period, gen(newvar)
				*br 				  businessid period KCGFLoanNumber ApprovedMonthYear turnover employees  loanamount if newvar > 0
			}	
			
			
			*Collapsing one observation per firm per year
			*----------------------------------------------------------------------------------------------------------------------------->>
			{	
				gen 			number_loans = 1
				collapse (sum)  number_loans loanamount loanamount_r disbursedamount disbursedamount_r (mean)GuaranteePercentageRequested  duration irate_nominal turnover turnover_r productivity productivity_r  (max)employees size_kcgf prod_*, by(businessid period firm_id)
				
				rename 	turnover_r     turnover_r_kcgf
				rename 	turnover       turnover_kcgf
				rename 	employees      employees_kcgf
				rename  productivity   productivity_kcgf
				rename  productivity_r productivity_r_kcgf
				duplicates report businessid period  //no duplicates okkk
				egen 	number_types_loans = rowtotal(prod_*)			//to check if the firm has a regular and a economic recovery package for example. 
			
			}
			
		
			*Creating a balanced panel
			*----------------------------------------------------------------------------------------------------------------------------->>
			{
				preserve
				duplicates drop firm_id businessid, force	
				keep			firm_id businessid
				tempfile 	businessid
				save 	   `businessid'
				restore
			
				tsset 	firm_id  period
				tsfill, full
				drop 	businessid
				merge 	m:1 firm_id using `businessid', nogen
				
				

				expand 2 if period == 2016, gen(REP)
				replace     period =  2015 if REP == 1
				expand 2 if period == 2016, gen(REP2)
				replace     period =  2014 if REP2 == 1
				
				foreach var of varlist number_loans-number_types_loans {
					replace `var' = . if period == 2014 | period == 2015
				}
				drop REP REP2
			}
		
		
			*Identifying the first KCGF loan
			*----------------------------------------------------------------------------------------------------------------------------->>
			{	
				bys 	businessid: egen f_kcgf 	= min(period) if loanamount != 0 & loanamount!= .		//first kcgf the firm got it
				bys 	businessid: egen first_kcgf = max(f_kcgf)
				gen 	comparison = first_kcgf > 2021														//lets treat as comparison group the firms that only got the loan in 2022
				sort 	firm_id period
				br 		firm_id businessid period loanamount f_kcgf first_kcgf
				drop 	f_kcgf
				order 	firm_id businessid period
				
				gen 	t = loanamount != . & loanamount > 0
				bys 	businessid		  : egen treated_kcgf 		= max(t)
				drop 	t
				
				gen 	t = loanamount !=. & loanamount > 0 & first_kcgf < 2022
				bys 	businessid		  : egen treated_before2022 = max(t)
				drop    t
				br 		firm_id businessid period loanamount first_kcgf treated_kcgf treated_before2022
					
				//Treatment Group - > Firms included in KCGF up to 2021
				//Comparison Group -> Firms included in KCGF only in 2022
				
			}
			save 	"$data\inter\Updated KCGF Panel.dta", replace //the variable size_kcgf is only available in this dataset for the years the firm got a loan
		}	
		
		
		**
		** Central Bank Data
		*--------------------------------------------------------------------------------------------------------------------------------->>
		{
			
			import excel using  "$data\raw\Central Bank 2015-2018.xls" , clear firstrow sheet("_bb_loans_2015")
			gen year = 2015
			tempfile   2015
			save      `2015'
			
			import excel using  "$data\raw\Central Bank 2015-2018.xls" , clear firstrow sheet("_bb_loans_2016")
			gen year = 2016
			tempfile   2016
			save      `2016'			

			forvalues year = 2017(1)2022 {
				foreach sheet in 1 2 3 4 {
					
				if `year' == 2017 | `year' == 2018 cap noi	import excel using  "$data\raw\Central Bank 2015-2018.xls"  , clear firstrow sheet("`year'_`sheet'")
				
				if `year' >  2018 				   cap noi  import excel using  "$data\raw\Central Bank `year'.xls" 	, clear firstrow sheet("`year'_`sheet'")
				
				gen year = `year'
				cap noi tempfile `year'_`sheet'
				cap noi save 	``year'_`sheet''
				}				
			}
			
			clear
			append using `2015'
			append using `2016'
				forvalues year = 2017(1)2022 {
					foreach sheet in 1 2 3 4 {
						cap noi append using ``year'_`sheet''
					}
				}
				
			tostring *, replace force
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
			save "$data\inter\Updated Central Bank.dta", replace

		}
			

			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
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


	

