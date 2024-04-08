	
	
										 	*DESCRIPTIVE STATISTICS USED IN THE ANALYSIS OF KCGF*
	
	*__________________________________________________________________________________________________________________________________________*
	**

		
	*--------------------------------------------------------->>>
	**
	**
	*Descriptives shown in the note
	*__________________________________________________________________________________________________________________________________________*
	{
	    
		use "$data\inter\Updated KCGF.dta" 			if period > 2015, clear
			codebook firm_id
			tab      size_kcgf 
			tab 	 BusinessLegalForm				if size_kcgf == 1
			codebook businessid
			codebook businessid 					if period == 2021
			codebook businessid 					if period == 2021 & Product == "Economic Recovery Window"
			codebook businessid 					if period == 2021 & Product == "Regular Window"
		
		
		use "$data\inter\Updated KCGF Panel.dta" 	if period > 2015, clear
			tab size_kcgf
			
			
		use "$data\inter\Updated KCGF Panel.dta" 	if period == 2021, clear
			codebook businessid 					if prod_erp == 1 | prod_reg == 1
			codebook businessid 					if prod_erp == 1 & prod_reg == 0
			codebook businessid 					if prod_erp == 0 & prod_reg == 1
			codebook businessid			    		if prod_erp == 1 & prod_reg == 1
			
		use "$data\inter\Updated KCGF.dta" 			if period == 2021 & Product == "Economic Recovery Window", clear
		gen id = 1
		collapse (sum) id, by(ApprovedMonthYear)
		
	
		use "$data\inter\Updated Central Bank.dta" 	if period > 2015 & kcgf == 0, clear
		tab Companysize if Companysize != "NA"
		
	}
	
	
	
	*--------------------------------------------------------->>>
	**
	**
	*Firms by size in KCGF loans and in other loans
	*__________________________________________________________________________________________________________________________________________*
	{
	
		use "$data\inter\Updated KCGF.dta" 			if period > 2015 , clear
			gen id = 1
			collapse (sum)id, by(size_kcgf)
			drop if size_kcgf == 4
			rename size_kcgf Companysize
			gen kcgf = 1
			tostring Companysize, force replace
			tempfile aux
			save `aux'

		use "$data\inter\Updated Central Bank.dta" if period > 2015 & kcgf ==0 , clear
			gen id = 1
			replace Companysize = "" if Companysize == "NA"
			collapse (sum)id, by(Companysize kcgf)
			
		
			append using `aux'
			replace Companysize = "XS" if Companysize == "1"
			replace Companysize = "S"  if Companysize == "2"
			replace Companysize = "M"  if Companysize == "3"
			replace Companysize = "L"  if Companysize == "4"
			replace Companysize = "Not-defined"  if Companysize == ""	| Companysize == "."
			
			replace kcgf = 2 if kcgf == 0
			
			label define 	kcgf 1 "KCGF" 2 "Other loans"
			label val 		kcgf kcgf
			
			egen 	group = group(Companysize)
			recode  group (2 = 4) (4 = 2)
			
			graph pie id, over(group) by(kcgf, iscale(1.3) note("") legend(off) graphregion(color(white)) cols(2))   								///
			legend(order(1 "New" 2 "Existing") cols(2) size(large) region(lwidth(none) color(none)) pos(12)) 										///			
			pie(1, explode  color(cranberry*0.6))  	 																								///
			pie(2, explode  color(erose))  																											///
			pie(3, explode  color(gs12))  																											///
			pie(4, explode  color(emidblue*0.5))  																									///
			pie(5, explode  color(emidblue))  																										///
			plabel(1 "Large",   						 gap(-0)   format(%2.0fc) size(medsmall)) 													///
			plabel(2 "Small",   						 gap(5)   format(%2.0fc) size(medsmall)) 													///
			plabel(3 "Not-defined",   					 gap(-10)   format(%2.0fc) size(medsmall)) 													///
			plabel(4 "Medium",   						 gap(5)   format(%2.0fc) size(medsmall)) 													///
			plabel(5 " Micro",   						 gap(5)   format(%2.0fc) size(medsmall)) 													///
			plabel(_all percent,   						 gap(22) format(%2.0fc) size(tiny)) 														///
			legend(off) 																															///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 				///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 				///
			note("", span color(black) fcolor(background) pos(7) size(small))																		///
			ysize(4) xsize(6) 	
			graph export "$output/figures/loans_size.pdf", as(pdf) replace				
	}	
	
	
	
	*--------------------------------------------------------->>>
	**
	**
	*KCGF contracts by semester
	*__________________________________________________________________________________________________________________________________________*
	{	
	    
		
		use "$data\inter\Updated Central Bank.dta" 				if  inlist(Companysize, "XS","S","M") & kcgf == 0 & period > 2016, clear	//not including large companies & kcgf loans
	
			foreach var in Amount  {
				foreach Companysize in XS S M {
				su 		`var'	  if  Companysize  == "`Companysize'", detail
				replace `var' = . if  Companysize  == "`Companysize'" & (`var' <= r(p1) | `var'>= r(p99))
				}
			}
			
			collapse (sum) Amount 				//TOTAL AMOUNT
			format Amount %20.2fc
			
		
		use "$data\inter\Updated KCGF.dta" if period > 2016, clear

			gen id = 1
			
			preserve
			collapse (sum)loanamount					//TOTAL AMOUNT										
			restore 
			
			preserve
			collapse (sum)id disbursedamount_r, by(period)
			restore
			
			collapse (sum)id  disbursedamount_r, by(semester_year c_product)
			replace  disbursedamount_r = disbursedamount_r/1000000
			su  			  disbursedamount_r, detail	
			drop  disbursedamount_r
			reshape wide id, i(semester_year) j(c_product) 
			
			graph bar (asis)id1 id2 id3,  bar(1, lwidth(0.2) fcolor(orange*0.5)) bar(2,lwidth(0.2) fcolor(emidblue)) bar(3,lwidth(0.2) fcolor(gs12))     	///
			over(semester_year, sort() relabel( 1  `" "2nd" "sem" "2016" "' 	///
											   2  `" "1st" "sem" "2017" ""'  3  `" "2nd" "sem" "2017" "' 	/// 
											   4  `" "1st" "sem" "2018" ""'  5  `" "2nd" "sem" "2018" "' 	/// 
											   6  `" "1st" "sem" "2019" ""'  7  `" "2nd" "sem" "2019" "' 	/// 
											   8  `" "1st" "sem" "2020" ""'  9 `" "2nd" "sem" "2020" "' 	/// 
											   10 `" "1st" "sem" "2021" ""'  11 `" "2nd" "sem" "2021" "' 	/// 
											   12 `" "1st" "sem" "2022" ""'  13 `" "2nd" "sem" "2022" "' )	/// 		
			label(labsize(small) ) ) stack																															///
			blabel(total, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.0fc))   									 				///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   												///
			yscale(off) ///
			legend(order(1 "Agro" 2 "Economic Recovery" 3 "Regular") cols(3) size(medium) region(lwidth(none) color(none)) pos(12))  								/// 		
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 							///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 							///
			ysize(4) xsize(5.5) 																						
			graph export "$output/figures/kcgf_by_semester.pdf", as(pdf) replace		
	}
	

	
	*--------------------------------------------------------->>>
	**
	**
	*KCGF median loan amount and interest rate
	*__________________________________________________________________________________________________________________________________________*
	{
		use "$data\inter\Updated KCGF.dta" 				if  inlist(size_kcgf, 1,2,3), clear	//not including large companies
	
		foreach var in loanamount   {
			foreach size_kcgf in 1 2 3 {
			su 		`var'	  if size_kcgf == `size_kcgf', detail
			replace `var' = . if size_kcgf == `size_kcgf' & (`var' <= r(p1) | `var'>= r(p91))
			}
		}
	
		preserve
			collapse (median)loanamount irate_nominal
		restore
		
		expand 2, gen (REP)
		replace period = 2023 if REP == 1
		
		clonevar average_loan = loanamount

		collapse (median)loanamount irate_nominal EffectiveInterestRate (mean)average_loan , by(period)
		format  irate_nominal %12.1fc
		replace loanamount = loanamount/1000

		twoway ///
		(bar loanamount  period, barw(.5)  lcolor(emidblue) lwidth(0.2) fcolor(emidblue) fintensity(inten80) yaxis(2) ) 												///
		|| (scatter loanamount  period, mlabcolor(black) mlabposition(12) symbol(none) mlabel(loanamount) yaxis(2))														///
		|| (scatter irate_nominal   period , symbol(O) color(cranberry) msize(medlarge) ml( irate_nominal ) mlabcolor(black) mlabposition(12) mlabsize(3) yaxis(1) 		///
		ysca(axis(1) r(-10 12))  ylab(1(2)10,  nogrid angle(horizontal) labsize(medium) format(%4.0f) axis(1)) 					 										///
		ysca(axis(2) r(0 50))  ylab(10(10)65, nogrid   angle(horizontal) labsize(medium) format(%4.0fc) axis(2))					 									///
		xline(2022.5,  lp(shortdash) lcolor(red)) text(-12 2023   "TOTAL") 																								///
		legend(order(1 "Median loan amount" 2 "" 3 "Median nominal interest rate") cols(2) size(medium) region(lwidth(none) color(none)) pos(12))  						/// 		
		title("", pos(12) size(medsmall) color(black)) 																													///     
		ytitle("Nominal interest rates, %", axis(1) size(medium) color(black))																							/// 
		ytitle("Loan amount, thousand EUR", axis(2) size(medium) color(black)) 																							///
		xtitle("") xlab(2016(1)2022,  nogrid angle(horizontal) labsize(small) format(%4.0f) axis(1)) 																																						///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))																///
		plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																///
		ysize(5) xsize(7))							 													
		graph export "$output/figures/kcgf_windows_amount_interestrates0.pdf", as(pdf) replace	
	}

	
	
	*--------------------------------------------------------->>>
	**
	**
	*Other loans median loan amount and interest rate
	*__________________________________________________________________________________________________________________________________________*
	{
		use "$data\inter\Updated Central Bank.dta" 				if  inlist(Companysize, "XS","S","M"), clear	//MS
	
		foreach var in Amount  {
			foreach Companysize in XS S M {
			su 		`var'	  if  Companysize  == "`Companysize'", detail
			replace `var' = . if  Companysize  == "`Companysize'" & (`var' < r(p5) | `var'> r(p95))
			}
		}

		expand 2, gen (REP)
		replace period = 2023 if REP == 1
		
		clonevar average_loan = Amount
		collapse (median)Amount NominalInterestRate (mean)average_loan, by(period)
		
		format  NominalInterestRate %12.1fc
		replace Amount = Amount/1000

		twoway ///
		(bar Amount  period, barw(.5)  lcolor(emidblue) lwidth(0.2) fcolor(emidblue) fintensity(inten80) yaxis(2) ) 																///
		|| (scatter Amount  period, mlabcolor(black) mlabposition(12) symbol(none) mlabel(Amount) yaxis(2))																			///
		|| (scatter NominalInterestRate   period , symbol(O) color(cranberry) msize(medlarge) ml( NominalInterestRate ) mlabcolor(black) mlabposition(12) mlabsize(3) yaxis(1) 		///
		ysca(axis(1) r(-10 12))  ylab(1(2)10,  nogrid angle(horizontal) labsize(medium) format(%4.0f) axis(1)) 					 										///
		ysca(axis(2) r(0 50))  ylab(10(10)65, nogrid   angle(horizontal) labsize(medium) format(%4.0fc) axis(2))					 									///
		xline(2022.5,  lp(shortdash) lcolor(red)) text(-12 2023   "TOTAL") 																								///
		legend(order(1 "Median loan amount, 2022 thousand EUR" 2 "" 3 "Median nominal interest rate") cols(2) size(medium) region(lwidth(none) color(none)) pos(12))  	/// 		
		title("", pos(12) size(medsmall) color(black)) 																													///     
		ytitle("Nominal interest rates, %", axis(1) size(medium) color(black))																							/// 
		ytitle("Loan amount, 2021 thousand EUR", axis(2) size(medium) color(black)) 																					///
		xtitle("") xlab(2016(1)2022,  nogrid angle(horizontal) labsize(small) format(%4.0f) axis(1)) 																																						///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))																///
		plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																///
		ysize(5) xsize(7))							 													
	}
	
	

	*--------------------------------------------------------->>>
	**
	**
	*Windows and new clients
	*__________________________________________________________________________________________________________________________________________*
	{
		use "$data\inter\Updated KCGF.dta" 				 if inlist(size_kcgf, 1,2,3), clear	//not including large companies
			bys period: 		su duration
			bys TypeofClient: 	su loanamount_r , detail
			bys TypeofClient: 	su irate_nominal, detail
			bys Product: 		su duration		, detail			//duration by type of window
			
			gen time = period != 2021
			gen new = TypeofClient == "New"
			gen old = TypeofClient == "Existing"
			
			gen id = 1

			label define time  0 "2021" 1 "2016-2020 and 2022"
			label val time  time 
			
			**
			graph pie id, by(time, note("") iscale(1.3)  graphregion(color(white)) cols(2)) over(Product)  														///
			legend(order(1 "Agro" 2 "Economic Recovery" 3 "Regular" 4 "Start up") cols(2) size(medsmall) region(lwidth(none) color(none)) pos(12)) 	///			
			pie(1, explode  color(orange*0.5))  	 																								///
			pie(2, explode  color(emidblue))  																										///
			pie(3, explode  color(gs12))  																											///
			pie(4, explode  color(erose*1.2))  																									///
			plabel(_all percent,   						 gap(10) format(%2.0fc) size(small)) 													///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(5) 	
			graph export "$output/figures/kcgf_windows.pdf", as(pdf) replace	
		
			**
			keep if inlist(Product, "Regular Window", "Economic Recovery Window") & period == 2021
			graph pie new old, by(Product, note("") iscale(1.3) legend(off) graphregion(color(white)) cols(2))   											///
			legend(order(1 "New" 2 "Existing") cols(2) size(large) region(lwidth(none) color(none)) pos(12)) 									///			
			pie(1, explode  color(emidblue*0.8))  	 																							///
			pie(2, explode  color(gs12))  																										///
			pie(3, explode  color(orange*0.5))  																								///
			pie(4, explode  color(erose*1.2))  																									///
			plabel(1 "New",   						 	 gap(5)   format(%2.0fc) size(medium)) 													///
			plabel(2 "Existing",   						 gap(5)   format(%2.0fc) size(medium)) 													///
			plabel(_all percent,   						 gap(-25) format(%2.0fc) size(small)) 													///
			legend(off) 																														///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(6) 	
			graph export "$output/figures/newclients.pdf", as(pdf) replace			
		}
	
	
	
	*--------------------------------------------------------->>>
	**
	**
	*Purpose of the loans
	*__________________________________________________________________________________________________________________________________________*
			
	{
		use "$data\inter\KCGF.dta" 				if period > 2015 & inlist(size_kcgf, 1,2,3), clear	//not including large companies

			gen id = 1
					
			graph pie id,    																														///
			over(purpose) ///
			pie(1, explode  color(emidblue*0.8))  	 																								///
			pie(2, explode  color(cranberry*0.6))  																									///
			pie(3, explode  color(olive_teal))  																									///
			pie(4, explode  color(gs12))  																											///
			plabel(1 "Equipments/capital",   						 	gap(5)   format(%2.0fc) size(medlarge)) 									///
			plabel(2 "Construction/renovation",   			gap(5)   format(%2.0fc) size(medlarge)) 												///
			plabel(3 "Inventory",   						gap(2)   format(%2.0fc) size(large)) 													///
			plabel(4 "Other",   			gap(-2)   format(%2.0fc) size(large)) 																	///
			plabel(_all percent,   						 gap(-20) format(%2.0fc) size(medsmall)) 													///
			legend(off) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 				///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 				///
			note("", span color(black) fcolor(background) pos(7) size(small))																		///
			ysize(4) xsize(6) 	
			graph export "$output/figures/purpose_loans_kcgf.pdf", as(pdf) replace	
	}
	

	
	*--------------------------------------------------------->>>
	**
	**
	*Firms with KCGF loans that also got other loans
	*__________________________________________________________________________________________________________________________________________*
	{
	
		use "$data\inter\Updated Central Bank.dta" if inlist(Companysize, "XS", "S", "M") & period > 2016 & IdNumber != "", clear			//MSMEs
			gen 	size = 1 if Companysize == "XS"
			replace size = 2 if Companysize == "S"
			replace size = 3 if Companysize == "M"
			
			/*
			foreach var in Amount  {
				foreach Companysize in XS S M {
				su 		`var'	  if  Companysize   == "`Companysize'", detail
				replace `var' = . if  Companysize   == "`Companysize'" & (`var' < r(p5) | `var'> r(p95))										//outliers in terms of loan amount
				*drop 			   if  Companysize  == "`Companysize'" & (`var' < r(p5) | `var'> r(p95))	
				}
			}
			*/
			
			gen 	 kcgf_loan 			= 			kcgf == 1
			gen 	 other_loan 		=			kcgf == 0
			gen 	 amount_kcgf 		= Amount if kcgf == 1
			gen	 	 amount_other_loan 	= Amount if kcgf == 0

			collapse (sum) kcgf_loan other_loan (sum) amount_kcgf amount_other_loan (max)size, by(IdNumber period)
			sort 	 IdNumber period
			
			gen 	 has_other_loan = other_loan > 0
			replace  amount_other_loan = .			 if amount_other_loan == 0
			
			
			**
			*
			*------------------------------------------------------->>
			*------------------------------------------------------->>
			keep 	if kcgf_loan != 0
			*------------------------------------------------------->>
			
			
			**
			*Percentage of firms with KCGF loans that also had other loan approved
			*------------------------------------------------------->>
			*------------------------------------------------------->>
			su 		has_other_loan, detail										//52%
			su 		amount_other_loan, detail									//median loan amount 12 thousand
			
			gen 	time = period == 2022
			ttest 	has_other_loan, by(time)
			ttest   amount_other_loan, by(time)
			
						su 		has_other_loan if time ==1, detail										//52%
						su 		has_other_loan if time ==0, detail										//52%

			collapse (mean)has_other_loan (median)amount_other_loan amount_kcgf, by(period)
			
			
			ttest has_other_loan if size == 1, by(time)
			ttest has_other_loan if size == 2, by(time)
			ttest has_other_loan if size == 3, by(time)

			
			iebaltab has_other_loan amount_other_loan, groupvar(time) savexls("$output/tables/Share of non-covered loans.xlsx") 	rowvarlabels replace //in 2022, there is a higher percentage of firms included in the kcgf that had loans not-covered by the fund approved as well.
	
	}
	
	

			
			
			

	
	*--------------------------------------------------------->>>
	**
	**
	*How much firms underestimate their turnover
	*__________________________________________________________________________________________________________________________________________*
	{	
		
		use 	"$data\inter\Updated IE dataset.dta", clear
		
		gen		turnover_application = turnover_kcgf if period == first_kcgf						//turnover at the loan application
		gen 	turnover_tax		 = turnover		 if period == first_kcgf - 1					//turnover in the year before the loan application
		
		sort 	businessid period	
		br 		businessid period turnover turnover_kcgf first_kcgf turnover_* 
				
		collapse (mean) turnover_application turnover_tax, by(first_kcgf businessid)
				
				
			gen 	underestimate = (turnover_application -turnover_tax)/turnover_application 
			gen 	nodata = underestimate == .
			su 		underestimate, detail
			replace underestimate = . if underestimate <= r(p1) | underestimate >= r(p99)	
	
			gen 	time = first_kcgf == 2022															//firms whose loans were approved in 2022 versus the other group of firms
			iebaltab nodata underestimate,groupvar(time) savexls("$output/tables/Share turnover underestimate.xlsx") 	rowvarlabels replace 
	}		
		
	

	*--------------------------------------------------------->>>
	**
	**
	*Share of kcgf loans among all loans in the country
	*__________________________________________________________________________________________________________________________________________*
	{
	
		use "$data\inter\Updated Central Bank.dta" if kcgf == 0 & inlist(Companysize,"XS", "S", "M"), clear

		gen id = 1
		
		collapse (sum)id, by(period kcgf)
		
		tempfile  aux
		save 	 `aux'
	
		use "$data\inter\Updated KCGF.dta" 		   if  inlist(size_kcgf, 1,2,3), clear	//not including large companies
	
		gen id = 1
		
		collapse (sum)id, by(period)
	
		gen kcgf = 1
		
		append using `aux'
	
		reshape wide id, i(period) j (kcgf)
		
		gen total_loans  = id0+id1
		
		gen share = id1/total_loans
	
		su share if period >= 2018 & period != 2021
		}
	
	
		
	*--------------------------------------------------------->>>
	**
	**
	*Comparing economic recovery package and regular window in 2021
	*________________________________________________________________________________________________________________________________*
	{
		use "$data\inter\Updated KCGF.dta" 				 if inlist(size_kcgf, 1,2,3) & period == 2021 & ///
													inlist(Product, "Regular Window", "Economic Recovery Window"), clear	//not including large companies
		foreach var in loanamount_r   {
			foreach size_kcgf in 1 2 3 {
				su 		`var'	  if size_kcgf == `size_kcgf', detail
				replace `var' = . if size_kcgf == `size_kcgf' & (`var' <= r(p1) | `var' >= r(p99))
			}
		}
		collapse (median)loanamount irate_nominal duration GuaranteePercentageRequested turnover employees productivity (mean) zero_collateral individual_business , by(Product)
		
		
		use "$data\inter\Updated IE dataset.dta"	 	if inlist(size, 1,2,3) & period == 2021 & (prod_reg == 1 | prod_erp == 1) , clear 
		
		gen		Product =  "Regular Window" 			if prod_reg == 1
		replace Product =  "Economic Recovery Window"   if prod_erp == 1
		collapse (median)lag_turnover lag_employees lag_productivity, by(Product)
	}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/*
		
				use "$data\inter\IE dataset.dta" if loanamount_r != 0 & loanamount_r !=. & size_kcgf == 1, clear
		gen number_firms = 1
			
			collapse (sum) number_firms (median) turnover_r turnover_r_kcgf employees employees_kcgf
			
	
	
		use "$data\inter\KCGF.dta" if period == 2021 & inlist(size_kcgf,1), clear
		
		
		tw (histogram turnover if Product == "Economic Recovery Window",  percent color(emidblue) fintensity(50))  (histogram turnover if Product == "Regular Window" ,  percent fcolor(none) lcolor(black)),   ///
			legend(order(1 "Tax Registry" 2 "KCGF Dataset") pos(12) size(medium) cols(2) region(lwidth(white) lcolor(white) color(white) fcolor(white))) 		 ///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(large) format(%12.0fc)) 						 ///
			xtitle("", size(medium)) xlabel(,labsize(small) format(%12.0fc)) 				 	 				 ///
			title("", pos(12) size(medsmall) color(black)) 														 ///
			subtitle("", pos(12) size(medsmall) color(black)) 													 ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	 ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 ///
			ysize(5) xsize(6) 																					 ///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output/figures/turnover_TaxRegistry_KCGF.pdf", as (pdf) replace

		
		
		

	
	

		
		
		use "$data\inter\KCGF.dta" 				if  LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
		gen id = 1
		gen micro = size_kcgf == 1
		clonevar amount = loanamount_r
		collapse (sum) id loanamount_r (median)amount (mean)micro , by(period)
				
				
		use "$data\inter\KCGF.dta" 				if  LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies

		gen micro = size_kcgf == 1
		replace micro = . if size_kcgf == .
		bys period: su micro
		
		
		

		
		
		use "$data\inter\KCGF.dta" 				if  LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
			
			gen new = TypeofClient == "New"
			
			bys Product: su new, detail 
	
	
			**
		use "$data\inter\Updated KCGF.dta" 				if  LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
	
		drop if inlist(FinancialInstitution,"Kreditimi Rural i Kosoves","KEP Trust")
	
		**
		collapse (median)loanamount_r irate_nominal, by(time Product)
		egen cod_prod = group(Product)
			
		**
		format irate_nominal 	%12.2fc	
		format loanamount_r 	%12.0fc
		
		
		*keep if time == 0 | (time == 1 & inlist(Product, "Regular Window", "Agro Window"))
		*replace collateralamount = . if collateralamount == 0
		
		collapse (median) loanamount irate_nominal, by(time Product)
		
		**
		twoway ///
		(bar loanamount_r  cod_prod, barw(.5)  lcolor(emidblue) lwidth(0.2) fcolor(emidblue) fintensity(inten80) 					       yaxis(2)) 					///
		|| (scatter loanamount_r  cod_prod, mlabcolor(black) mlabposition(12) symbol(none) mlabel(loanamount_r) yaxis(2))												///
		|| (scatter irate_nominal cod_prod , symbol(O) color(cranberry) msize(medlarge) ml( irate_nominal ) mlabcolor(black) mlabposition(12) mlabsize(3) yaxis(1) 	///
		ysca(axis(1) r(-10 12))  ylab(1(2)10,  nogrid angle(horizontal) labsize(small) format(%4.0f) axis(1)) 					 										///
		ysca(axis(2) r(10000 50000))  ylab(10000(10000)50000, nogrid   angle(horizontal) labsize(small) format(%4.0fc) axis(2))					 						///
		legend(order(1 "Median loan amount, 2021 EUR" 2 "" 3 "Nominal interest rate") cols(3) size(medsmall) region(lwidth(none) color(none)) pos(12))  			 	/// 		
		xlabel(1 "Agro" 2 "Eco. Rec. Package" 3 "Regular" 4 "Start up") 																								///
		title("", pos(12) size(medsmall) color(black)) 																													///     
		ytitle("Nominal interest rates, %", axis(1) size(medsmall) color(black))																						/// 
		ytitle("Median loan amount, 2021 EUR", axis(2) size(medsmall) color(black)) 																					///
		xtitle("") 																																						///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))																///
		plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																///
		ysize(5) xsize(7))							 													
		graph export "$output/figures/kcgf_windows_amount_interestrates0.pdf", as(pdf) replace		
		restore
		
		preserve
		keep if time == 1
		replace cod_prod = 2 if Product == "Regular Window"
		**
		twoway ///
		(bar loanamount_r  cod_prod, barw(.5)  lcolor(emidblue) lwidth(0.2) fcolor(emidblue) fintensity(inten80) 					       yaxis(2)) 					///
		|| (scatter loanamount_r  cod_prod, mlabcolor(black) mlabposition(12) symbol(none) mlabel(loanamount_r) yaxis(2))												///
		|| (scatter irate_nominal cod_prod , symbol(O) color(cranberry) msize(medlarge) ml( irate_nominal ) mlabcolor(black) mlabposition(12) mlabsize(3) yaxis(1) 	///
		ysca(axis(1) r(-10 12))  ylab(1(2)10,  nogrid angle(horizontal) labsize(medium) format(%4.0f) axis(1)) 					 										///
		ysca(axis(2) r(10000 50000))  ylab(10000(10000)50000, nogrid   angle(horizontal) labsize(medium) format(%4.0fc) axis(2))					 						///
		legend(order(1 "Median loan amount, 2021 EUR" 2 "" 3 "Nominal interest rate") cols(3) size(medium) region(lwidth(none) color(none)) pos(12))  			 	/// 		
		xlabel(1 "Agro" 2 "Regular" ) 																								///
		title("", pos(12) size(medsmall) color(black)) 																													///     
		ytitle("Nominal interest rates, %", axis(1) size(medium) color(black))																						/// 
		ytitle("Median loan amount, 2021 EUR", axis(2) size(medium) color(black)) 																					///
		xtitle("") 																																						///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))																///
		plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																///
		ysize(5) xsize(5))							 													
		graph export "$output/figures/kcgf_windows_amount_interestrates1.pdf", as(pdf) replace		
		restore
	

		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" 					if period > 2015 & LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
		*----------------------------------------------------------------------------------------------------------------------------*
			su loanamount_r, detail
			replace 	loanamount_r = . 			if loanamount_r >= r(p95)
			gen 		fund = 1
			tempfile 	kcgf
			save 	   `kcgf'
		
		
		
				**
				*Distribution of loan amounts by fund
				twoway  (kdensity loanamount_r  			if size_kcgf == 1,   lcolor(cranberry) lwidth( thick ) )  													///	
						(kdensity loanamount_r 				if size_kcgf ==2,   lcolor(red) lwidth( thin)    															///
				title("", pos(12) size(medium) color(black))																										///
				subtitle("" , pos(12) size(medsmall) color(black))  																								///
				ylabel(, labsize(small) nogrid) xlabel(, format (%12.0fc) labsize(small) gmax angle(horizontal)) 													///
				yscale(alt) 																																		///
				xtitle("Loan amount, in 2021 EUR", size(medsmall) color(black)) ytitle("Density")  																	///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 													///
				ysize(5) xsize(7) 																																	///
				text(0.00002 120000   "10% of loans not covered by KCGF to MSME are > 54k EUR", size(medsmall)) ///
				fcolor(none) lcolor(black)), legend(order(1 "KCGF" 2 "Not covered by KCGF") region(lwidth(none) color(white) fcolor(none)) cols(4) size(large) position(12)) ///
				note(, span color(black) fcolor(background) pos(7) size(small)) 
				graph export "$output/figures/loanamount_2016-2019.pdf", as(pdf) replace			

	
	
			*--------------------------------------------------------------------------------------------------------------------------------*
		*--------------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" 				if period > 2015 & LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
		*--------------------------------------------------------------------------------------------------------------------------------*

			**
			*Interest rates and duration of KCGF loans by period of time
			foreach var of varlist irate_nominal duration 	{
				foreach group_period in 1 2 3 				{
					di as red "`var'" "`group_period'"
					su 		   `var'	  	if group_period == `group_period', detail
				}
			}
		
					
			**
			clonevar 	average_loan_r  		= loanamount_r
			replace 	loanamount_r			= loanamount_r/1000000 //I just did this to present the total amount of KCGF loans as it is in the excel they shared with us.		
			
			**
			*Creating total category
			expand 2, gen(REP)
			replace Product = "Total" if REP == 1
			
			
			**
			**Descriptives of KCGF loans
			gen 		id   = 1
			collapse (sum) id loanamount_r (median) turnover_r average_loan_r collateralvalue_r shareloan_turnover duration irate_nominal (mean) economic_recovery, by(period)
			
			**
			replace economic_recovery = economic_recovery*100
						
			**
			order   period  loanamount_r id  average_loan_r irate_nominal total_interest collateralvalue_r duration shareloan_turnover economic_recovery
			br		period  loanamount_r id  average_loan_r irate_nominal total_interest collateralvalue_r duration shareloan_turnover economic_recovery turnover_r					if Product == "Total"
			
			**
			br		period  loanamount_r id  average_loan_r irate_nominal total_interest collateralvalue_r duration shareloan_turnover economic_recovery				    		if Product != "Total" & period == 2021
		


	
	
	
	
	
	
	
	
	
	/*
				
		use "$data\inter\Updated KCGF.dta" 				if  inlist(size_kcgf, 1,2,3) & period > 201, clear	//not including large companies
		foreach var in loanamount   {
			foreach size_kcgf in 1 2 3 {
			su 		`var'	  if size_kcgf == `size_kcgf', detail
			replace `var' = . if size_kcgf == `size_kcgf' & (`var' <= r(p1) | `var'>= r(p91))
			}
		}
		recode period (2017 2018 2019 = 1) (2020 2021 2022 =2)
		collapse (median)loanamount irate_nominal , by(period)
		
		gen kcgf = 1
		tempfile aux
		save    `aux'
		
		
		use "$data\inter\Updated Central Bank.dta" 				if  inlist(Companysize, "XS","S","M") & period > 2016, clear	//not including large companies
		foreach var in Amount  {
			foreach Companysize in XS S M {
			su 		`var'	  if  Companysize  == "`Companysize'", detail
			replace `var' = . if  Companysize  == "`Companysize'" & (`var' <= r(p1) | `var'>= r(p91))
			}
		}
		replace NominalInterestRate = . if NominalInterestRate == 0

		recode period (2017 2018 2019 = 1) (2020 2021 2022 =2)

		collapse (median)Amount NominalInterestRate , by(period)
		rename (Amount NominalInterestRate) (loanamount irate_nominal)
		gen kcgf = 2
		append using `aux'
		
		format irate_nominal %12.1fc
		replace loanamount = loanamount/1000
		
		reshape wide loanamount irate_nominal, i(period) j(kcgf)
		
		graph bar (asis)loanamount1 loanamount2,  bar(1, lwidth(0.2) fcolor(orange*0.5)) bar(2,lwidth(0.2) fcolor(emidblue)) bar(3,lwidth(0.2) fcolor(gs12))     	///
			over(period, sort() ///
			label(labsize(small) ) ) 																														///
			blabel(total, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.0fc))   									 				///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   												///
			yscale(off) ///
			legend(order(1 "Agro" 2 "Economic Recovery" 3 "Regular") cols(3) size(medium) region(lwidth(none) color(none)) pos(12))  								/// 		
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 							///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 							///
			ysize(4) xsize(5.5) 																						

		
			
	
	
	
	
