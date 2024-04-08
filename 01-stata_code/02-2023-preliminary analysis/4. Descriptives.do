

	*__________________________________________________________________________________________________________________________________________*
	**

	*DESCRIPTIVE STATISTICS USED IN THE ANALYSIS OF KCGF.
	
	
	
	*--------------------------------------------------------->>>
	**
	*Statistics for blogpost
	{
	    
		use "$data\final\firm_year_level.dta" 	if period == 2018 & active == 1, clear
		tab sme has_credit_history, mis
	
	
		**
		*Share of small firms, 2015
		use "$data\final\firm_year_level.dta" 	if period == 2015 & active == 1, clear	//2015, prior to the launch of KCGF
		count
		tab sme, mis
		tab sme,
		
		**
		*Share of small firms, 2018
		use "$data\final\firm_year_level.dta" 	if period == 2018 & active == 1, clear	
		count
		tab sme, mis
		tab sme if (turnover_r_all >= 0 & turnover_r_all != .) | formal == 0, mis
		
		
		**
		*% of firms with access to credit
		bys sme: su has_loan															//% of loans by firms size.								
		su  		has_loan 					if inlist(sme, "c.50-249", "d.250+")	//medium and large firms with loans
		
		
		**
		*Productivity 
		bys sme: su productivity_r,detail
		
		
		**
		*Percentage of these active firms that ended up stopping their operations after 2015
		use "$data\final\firm_year_level.dta" 	if period == 2015 & active == 1, clear	
		bys sme: su willclose_after2015 
		su  		willclose_after2015  		if inlist(sme, "c.50-249", "d.250+"), detail
		
		
		bys sme: su has_credit_history if has_loan == 1
		
		
		**
		*For firms with no loans in 2015, what is the percentage of them that had access to the lending market between 2010 and 2014?
		su 			had_loan_up2015				if has_loan == 0 			
		
		
		**
		*Loan Interast rates according to firms' size
		bys size: su irate_nominal 				,detail
		su 			 irate_nominal 				if inlist(sme, "c.50-249", "d.250+"),detail
		
		
		**
		*Loan duration according to firms size. 
		bys size: su duration 					,detail
		su 			 duration 					if inlist(sme, "c.50-249", "d.250+"),detail
	}
	*__________________________________________________________________________________________________________________________________________*
		
		
		
	*--------------------------------------------------------->>>
	**
	*Descriptive statistics
	{	
		
		
		**
		*Percentage of firms with turnover that report profit 
		use 	"$data\final\firm_year_level.dta" if active == 1, clear
			keep 	if turnover_r_all != 0
			gen 	report_profit =  profit_r != .
			collapse (mean) report_profit, by(period)
		
		
		**
		*Average turnover, number of employees and firms that do not report the number of employees. 
		use "$data\final\firm_year_level.dta" if active == 1, clear
			tab period formal
			bys period: su turnover_r,detail
			bys period: su employees,detail
			
			tab period if formal == 1
			tab period if formal == 1 & employees ==.
			di 9327/38821  //24% did not report this information in 2018.
			
			
		**
		*Number of loan operations in 2018 and number of firms. operations> number of firms because there are firms with more than one loan. 
		use "$data\inter\Credit Registry.dta", clear
		count
		codebook fuid if period == 2018
		
			
		**
		*46% of the small firms in 2018 were created after 2010.
		use "$data\final\firm_year_level.dta" 	if  active == 1 & period == 2018 & group_sme == 2 &turnover_r_all != 0, clear
			tab birthyear	
		
		
		**
		*For firms with loans approved in 2018, what is the percentage of them with credit history.
		use 	"$data\final\firm_year_level.dta" if active == 1 & period == 2018, clear	
		tab group_sme has_credit_history if has_loan == 1
		di 1907/7724
		di 245/1906
		tab has_loan if group_sme == 1 & has_credit_history==0
		tab group_sme has_credit_history
		
		
		**
		*Percentage of loans by economic sector of activity.
		use 	"$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2018) & sec_activityid != . & group_sme!= 5, clear	
		replace group_sme = 3 if group_sme == 4
		collapse (mean) has_loan, by(sec_activityid group_sme)
				

		**
		*Comparing micro-firms and small/medium/large firms controlling for sector of activity. 
		use 	"$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2018) & !missing(sectionid), clear
		iebaltab turnover_r  productivity_r nocredit_history avgrowth_productivity_r avgrowth_employees avgrowth_turnover_r,  cov(sectionid) format(%12.0fc %12.2fc) grpvar(group_sme) ///
																									savexls("$output/tables/Comparing micro-firms with larger firms_2018.xls") 	rowvarlabels replace 
		}
	*__________________________________________________________________________________________________________________________________________*
		
		
		
	*--------------------------------------------------------->>>
	**
	*Firms' characteristics by size 2015
	{
		use "$data\final\firm_year_level.dta" if period == 2015 & active == 1, clear
						
			**
			replace willclose_after2015 = willclose_after2015*100
			replace had_loan_up2015     = had_loan_up2015*100
			replace nocredit_history    = nocredit_history*100
			replace turnover_r 			= turnover_r/1000							//outliers already replaced by missing in the do file 3. Setting up the IE Data. 
			replace productivity_r 		= productivity_r/1000
			label var turnover_r  		"Sales, thousands 2021 EUR" 
			label var productivity_r  	"Productivity, thousands 2021 EUR" 
			
			**
			tab 	sme
			
			drop if group_sme == 5 | sectionid == .
			iebaltab turnover_r employees productivity_r willclose_after2015 nocredit_history, cov(sectionid)  format(%12.0fc %12.2fc) grpvar(group_sme) savexlsxlsx("$output/tables/Firms' characteristics by size_2015.xls") 	rowvarlabels replace 

			**
			/*
			sumstats ///
			(turnover_r employees productivity_r willclose_after2015 nocredit_history duration irate_nominal  if group_sme == 1) ///
			(turnover_r employees productivity_r willclose_after2015 nocredit_history duration irate_nominal  if group_sme == 2) ///
			using "test.xlsx", replace stats(mean sd n)
			
			tabform  turnover_r employees productivity_r willclose_after2015 nocredit_history duration irate_nominal ///
			using "$output\tables\Firms' characteristics by size_2015.xls", by(sme) sd sdbracket vertical
			*/
	}
	*__________________________________________________________________________________________________________________________________________*
		

		
	
	*--------------------------------------------------------->>>
	**
	*Data inconsistence. Comparing the turnover that:
	
		*The firms report to the private banks at the moment of the loan application
		*versus 
		*the one they report to the Tax Registry
		
	*--------------------------------------------------------->>>
	{	//we only have turnover reported to the banks in the KCGF dataset, so we restrict this analysis for these firms. 
		
		**
		**
		use 	"$data\final\firm_year_level.dta" if period == 2018 & has_kcgf == 1, clear
			keep 	has_loan period turnover_r type_firm_after2015 employees productivity_r irate_nominal group_sme
			gen 	base = 1
			
		**
		**
		append  using "$data\inter\KCGF.dta" 	 , keep(turnover_r loanamount_r period size_kcgf employees productivity_r irate_nominal)
			replace base = 2 if base ==.
			keep if period == 2018
			bys 	base: su turnover_r
			bys 	base: su irate_nominal
		
			tw (histogram turnover_r if base == 1 & inlist(group_sme, 1),  percent color(emidblue) fintensity(50))  (histogram turnover_r  if base == 2  & size_kcgf == 1 ,  percent fcolor(none) lcolor(black)),   ///
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
			
			replace size_kcgf = group_sme if size_kcgf == . 
			iebaltab turnover_r employees productivity_r irate_nominal if size_kcgf == 1,  format(%12.0fc %12.2fc) grpvar(base) ///
			savexls("$output/tables/Balance Test Tax Registry KCGF_micro_firms.xls") 	rowvarlabels replace 
			iebaltab turnover_r employees productivity_r irate_nominal if size_kcgf == 2,  format(%12.0fc %12.2fc) grpvar(base) /// 
			savexls("$output/tables/Balance Test Tax Registry KCGF_small_firms.xls") 	rowvarlabels replace 
	}
	*__________________________________________________________________________________________________________________________________________*

	
	
	*--------------------------------------------------------->>>
	**
	*Economic sector of activity by size. 
	{
	use 	"$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2018) & turnover_r_all != 0, clear
		gen id = 1
		replace group_sme = 3 if group_sme == 4
		keep if inrange(sec_activityid,1,4)
		label drop group_sme
		label define group_sme 1 "Micro" 2 "Small" 3 "Medium/Large" 
		label val group_sme group_sme
		collapse (sum)id,by(sec_activityid period group_sme )
		reshape wide id, i(period group_sme ) j(sec_activityid)
			**
			graph pie id1 id2 id3 id4, by(group_sme,  note("") graphregion(color(white)) cols(3))    ///
			pie(1, explode  color(navy*0.9)) pie(2, explode  color(cranberry*0.6))  pie(3, explode  color(gs12))  pie(4, explode  color(olive_teal*0.5)) pie(5, explode color(gs12)) pie(6, explode color(cranberry*0.6)) ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 												///
			legend(order(1 "Primary" 2 "Secondary" 3 "Tertiary" 4 "Quaternary") cols(4) pos(12) region(lstyle(none) fcolor(none)) size(large)) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(8) 	
			graph export "$output/figures/sector_activity.pdf", as(pdf) replace	
			graph export "$output/figures/sector_activity.emf", as(emf) replace	
	}
	*__________________________________________________________________________________________________________________________________________*

	
	
	*--------------------------------------------------------->>>
	**
	*% of firms with Loans over the years.
	{
		use 	"$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2014, 2010, 2018), clear	
		collapse (mean)has_loan, by(period group_sme)	
		replace has_loan = has_loan*100
		reshape wide has_loan, i(period) j(group_sme)

				graph bar (asis)has_loan1 has_loan2 has_loan3 has_loan4, bargap(-30) bar(1, color(olive_teal*0.8)) bar(2, color(orange*0.5) ) bar(3, color(emidblue) ) bar(4, color(gs12) ) 	///
				over(period, sort() label(labsize(medium) ) ) 																											///
				blabel(bar, position(outside) orientation(horizontal) size(medium) color(black) format (%4.0fc))   									 					///
				ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   												///
				yscale(off) ///
				legend(order(1  "Micro"  2 "Small" 3 "Medium"  4 "Large") region(lwidth(none) color(white) fcolor(none)) cols(4) size(medlarge) position(12)) 			///	
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 							///
				plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 							///
				ysize(4) xsize(4) 																						
			local nb =`.Graph.plotregion1.barlabels.arrnels'
			di `nb'
			forval i = 1/`nb' {
			  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
			  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
			}
			.Graph.drawgraph
			graph export "$output\figures\loan-year.pdf", as(pdf) replace	
	}	
	*__________________________________________________________________________________________________________________________________________*

	
	
	*--------------------------------------------------------->>>
	**
	**Percentage of firms by size within the years - only firms with a non-zero turnover.
	{
	use "$data\final\firm_year_level.dta" if  active == 1 & group_sme != 5 & turnover_r_all != 0, clear
		gen 	id = 1
		replace group_sme = 3 if group_sme == 4
		collapse (sum)id, by(group_sme period)
		bys		period: egen total = sum(id)
		gen 	share = (id/total)*100
		format  share %12.1fc
		keep if inlist(period,2010,2012,2014,2016,2018)
		keep 	share period group_sme
		reshape wide share, i(period) j(group_sme)

		graph bar (asis)share1 share2 share3, bargap(-30) bar(1, color(olive_teal*0.8)) bar(2, color(orange*0.5) ) bar(3, color(emidblue) ) 	///
		over(period, sort() label(labsize(medium) ) ) 																							///
		blabel(bar, position(outside) orientation(horizontal) size(medium) color(black) format (%4.1fc))   								 		///
		ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   								///
		yscale(off) ///
		legend(order(1  "Micro"  2 "Small" 3 "Medium/Large"  ) region(lwidth(none) color(white) fcolor(none)) cols(3) size(medlarge) position(12)) 		///	
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 					///
		plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 					///
		ysize(4) xsize(4) 																						
		local nb =`.Graph.plotregion1.barlabels.arrnels'
		di `nb'
		forval i = 1/`nb' {
		  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
		  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
		}
		.Graph.drawgraph
		graph export "$output\figures\micro-year.pdf", as(pdf) replace	
	}
	*__________________________________________________________________________________________________________________________________________*
	
	
	
	*--------------------------------------------------------->>>
	**
	*
	*We observe a decrease in the percentage of micro firms over the years. Are these micro-firms turning into small firms?
	{
	use "$data\final\firm_year_level.dta" 	if  active == 1 & group_sme == 1 & period == 2010 & turnover_r_all != 0, clear //micro firms in 2010 with a non-zero turnover. 
		keep 	fuid
		tempfile temp
		savexls 	`temp'
	
	
	*--------------------------------------------------------->>>
	**
	*
	use 	"$data\final\firm_year_level.dta" , clear
		merge 	m:1 fuid using `temp', keep(3) nogen
		gen 	fechou = 1 if deathyear != . & period == 2010
		keep if period == 2018 | period == 2010
		sort 	fuid period
		gen 	aumentou_tamanho = .
		replace	aumentou_tamanho = 1 if period == 2010 & fechou !=1 & group_sme[_n+1] > 1 & group_sme != 5 & fuid[_n] == fuid[_n+1]
		gen		 continuou_micro = 1 if fechou == . & aumentou_tamanho == .
		keep 	if period == 2010
		gen 	id= 1
		collapse (sum) aumentou_tamanho fechou continuou_micro id, by(period)		//what happen to these micro firms that we identified in 2010?
	}
	*__________________________________________________________________________________________________________________________________________*
	
		
		
	*--------------------------------------------------------->>>
	**
	*Exit rate by size. 
	{
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 & inlist(sme, "a.1-9", "b.10-49", "c.50-249"), clear
			graph pie notclose_after2015 willclose_after2015 , by(group_sme,    iscale(1.5)     note("") legend(off) graphregion(color(white)) cols(3))  		///
			pie(2, explode  color(emidblue*0.8)) pie(1, explode color(gs12))  ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 											///
			plabel(2 "Close",   						 gap(2)   format(%2.0fc) size(medsmall)) 											///
			plabel(1 "Remain open",    						 gap(2)   format(%2.0fc) size(medsmall)) 										///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 		///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 		///
			note("", span color(black) fcolor(background) pos(7) size(small))																///
			ysize(4) xsize(10) 	
			graph export "$output/figures/exit_by_size.pdf", as(pdf) replace	
	}
	*__________________________________________________________________________________________________________________________________________*


		
	*--------------------------------------------------------->>>
	**
	*Credit history 
	{
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 & inlist(sme, "a.1-9", "b.10-49", "c.50-249"), clear
			graph pie has_credit_history  nocredit_history, by(group_sme,   iscale(1.5)     note("") legend(off) graphregion(color(white)) cols(3))  		///
			pie(1, explode  color(gs12)) pie(2, explode color(olive_teal))  ///
			plabel(_all percent,   						 gap(10) format(%2.0fc) size(medsmall)) 												///
			plabel(1 "With credit history",   						 gap(-5)   format(%2.0fc) size(medsmall)) 									///
			plabel(2 "No credit history",    						 gap(-5)   format(%2.0fc) size(medsmall)) 									///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 		///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 		///
			note("", span color(black) fcolor(background) pos(7) size(small))																///
			ysize(4) xsize(10) 	
			graph export "$output/figures/credit_history_by_size.pdf", as(pdf) replace	
	}
	*__________________________________________________________________________________________________________________________________________*

	
		
	*--------------------------------------------------------->>>
	**
	**
	*% loans by number of employees
	*__________________________________________________________________________________________________________________________________________*
	{	//the bigger the firm, the higher the % with loans
		**
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2015) & group_sme != 5 , clear
		*----------------------------------------------------------------------------------------------------------------------------*
			
			**
			gen 		id = 1 

			**
			collapse (sum) has_loan  id, by(group_sme)
			egen total = sum(id)
			gen 		p2 = (has_loan/id)*100
			gen 		p1 = (id/total)*100
			keep 	group_sme p1 p2
			reshape long p, i(group_sme) j(type)
			gen 	p2 = p if type == 2
			replace p   =. if type == 2
			
			label define type 1 "% of firms" 2 "% firms with approved loans"
			label val    type type

			
			graph bar (asis) p p2,  by(type, iscale(1) note("")) bar(1, color(emidblue)) 	bar(2, color(cranberry)) 														///
			 over(group_sme, sort()  label(labsize(medsmall)) ) 																											///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   															///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   														///
			yscale(off ) 		///
			legend(order(1  "% firms by size"  2 "% firms with approved loans"  ) region(lwidth(none) color(white) fcolor(none)) cols(3) size(medium) position(12)) 		///	
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 									///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 									///
			ysize(6) xsize(9) 
			graph export "$output/Figures/firms_size_approved_loans.pdf", as(pdf) replace	

	}
	
	
	
	*--------------------------------------------------------->>>
	**
	**
	*% of KCGF and other loans by number of employees
	*__________________________________________________________________________________________________________________________________________*
	{	
	    //the bigger the firm, the higher the % with loans
		**
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if active == 1 & inlist(period, 2017, 2018) , clear
		*----------------------------------------------------------------------------------------------------------------------------*
			
			**
			gen 		id = 1 
			gen 		has_otherloan 	= 1   	if has_kcgf == 0     & has_loan  == 1
			
			**
			replace 	employees 		= 20  	if  employees >  20  & employees < 50 
			replace 	employees 		= 21  	if (employees >= 50  & employees < 250) | sme == "c.50-249"
			replace 	employees 		= 22  	if (employees > 250  & employees != . ) | sme == "d.250+"
			label 		define employees 0 "0 or N/A" 20 "20-49" 21 "50-249" 22 "250+" 
			label 		val employees employees
			
			**
			collapse (sum) has_kcgf  id has_otherloan, by(employees group_sme)
			gen 		share_kcgf  = (has_kcgf/id)*100
			gen 		share_loans = (has_otherloan/ id)*100
			
			**
			*Average between 2017-2018
			graph bar (asis)share_kcgf share_loans,  bar(1, color(navy) fintensity(inten30)) bar(2, color(cranberry) fintensity(inten30)) 		///
			 over(employees, sort() label(labsize(medium) angle(45)) ) stack 																	///
			blabel(bar, position(outside) orientation(horizontal) size(large) color(black) format (%4.0fc))   								 	///
			ytitle("% firms with loans", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc))   					///
			yscale(line ) ///
			legend(order(1  "KCGF"  2 "Other loans"  ) region(lwidth(none) color(white) fcolor(none)) cols(3) size(large) position(12)) 		///	
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 		///
			ysize(6) xsize(10) 																						
			graph export "$output\figures\share with loans by employees_2017-2018.pdf", as(pdf) replace	
	}		

		
	
	
	*--------------------------------------------------------->>>
	**
	*Which are the firms' characteristics that increase their probability of having a loan approved? 
	
	/*
	Machine learning results according to Simon Valerio estimates.
	Simon used firm_year_level dataset to assess the probability of a firm having a loan approved in 2018
	He savexlsd the file potential_borrowers_top10_vars in datawork\data\final\machine-learning*/ 
	
	{
		
		**
		**
		*Probability of having a loan according to the Machine Learning model run by Simon Valerio
		import 		delimited using "$data\final\machine-learning\potential_borrowers_top10_vars.csv", clear
		cap noi quantiles lag1_avgrowth_turnover_r 	 ,  n(10) gencatvar(qua_turnover)
		cap noi quantiles lag1_productivity_r 		 ,  n(10) gencatvar(qua_productivity)

		**
		*Average probability (and CI) of loan according to firms' characteristics
		matrix results = (0,0,0,0,0)
		local xvar = 1
		foreach variable in lag1_employees qua_productivity qua_turnover number_loans_up_t_minus1 {
			preserve
			if "`variable'" == "lag1_employees" 			keep if lag1_employees 			  < 30
			if "`variable'" == "number_loans_up_t_minus1"  keep if number_loans_up_t_minus1  < 15
			levelsof `variable', local(`variable'_list) 
			foreach code in ``variable'_list' {
				ci means probability if `variable' == `code'
				matrix results = results\(`xvar', `code', r(mean), r(lb), r(ub))
			}
			local xvar = `xvar' + 1
			restore
		}
		
		**	
		*Probability of loan, CI, and variables under analysis and its values (employees, productivity, credit history)
		clear 
		svmat results
		drop in 1
		rename (results1-results5) (variable code xb lower upper)	

		**
		*Figures
		foreach variable in 4  {
			     
				if `variable' == 1   local xtitle = "Number  of employees in 2017"
				
				if `variable' == 2   local xtitle = "Deciles of sales per employee in 2017"

				if `variable' == 3   local xtitle = "Deciles of turnover growth in 2017" 	

				if `variable' == 4   local xtitle = "Credit history (num. loans previously approved)"		

				
				tw 	///
				(rarea lower upper 	code if variable == `variable' , fcolor(gs12%30) lcolor(bg) fintensity(50)) ///
				(line  xb 			code if variable == `variable' , lcolor(cranberry) lwidth(0.5) lp(shortdash)  ///  			
				ylabel(,  labsize(medium) nogrid gmax angle(horizontal) format(%12.1fc)) ysca()  ///
				///
				ytitle("Probability", size(medium))   ///
				///
				xtitle("`xtitle'", size(medium)) ///
				///
				xlabel(, angle(360) labsize(medium)) ///
				///
				title("`title'", pos(12) size(medlarge) color(black)) ///
				///
				subtitle(, pos(12) size(medsmall) color(black)) ///
				///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				legend(order(1 "95% CI"  2 "Probability of having an approved loan" ) span region(lwidth(none)) cols(1) size(medium) position(11) bplacement(seast)) ///
				///
				ysize(5) xsize(5)	 ///
				///
				note("", color(black) fcolor(background) pos(7) size(small))) 
				graph export "$output/figures/ML_probability_`variable'.emf", as(emf) replace
				graph export "$output/figures/ML_probability_`variable'.pdf", as(pdf) replace
				}
		}
	*__________________________________________________________________________________________________________________________________________*
		

		
	*--------------------------------------------------------->>>
	**
	*Distribution in the probability of having a loan 
	{
		
		*
		*A*
		*Machine Learning results
		*Probability of loan according to the model Simon Valerio run in python using machine learning techniques
		*----------------------------------------------------------------------------------------------------------------------------*
			import delimited using "$data\final\machine-learning\potential_borrowers_top10_vars.csv", clear

			**
			gen 	group1 = 1 if probability >= 0.8 & !missing(probability)
			gen 	group2 = 1 if probability >= 0.6 & probability < 0.8
			gen 	group3 = 1 if probability >= 0.4 & probability < 0.6
			gen 	group4 = 1 if probability <  0.4
					
			**
			label define has_loan 0 "Credit-constrained firms" 1 "Loan approved in 2018" 
			label val 	 has_loan has_loan
			
			**
			graph pie group1 group2 group3 group4,  by(has_loan,  note("") graphregion(color(white)) cols(3))   ///
			pie(1, explode  color(navy*0.9)) pie(2, explode  color(navy*0.6))  pie(3, explode  color(emidblue))  pie(4, explode  color(emidblue*0.7)) pie(5, explode color(gs12)) pie(6, explode color(cranberry*0.6)) ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 												///
			legend(order(1 "Prob > 80%" 2 "Prob > 80% & < 60%" 3 "Prob > 40% & < 60%" 4 "Prob < 40%") cols(2) pos(12) region(lstyle(none) fcolor(none)) size(medsmall)) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(6) 	
			graph export "$output/figures/ML_probability_loan.pdf", as(pdf) replace	
			graph export "$output/figures/ML_probability_loan.emf", as(emf) replace	
			
			
			**
			merge 1:1 fuid period using "$data\final\firm_year_level.dta", keep(1 3) keepusing(sme) nogen

			**
			tw kdensity probability if has_loan == 1 ,  lw(1.5) lp(dash) color(cranberry) 						///
			///
			|| kdensity probability if has_loan == 0 ,  lw(thick) lp(dash) color(gs12) 							///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
			ylabel(, labsize(small) nogrid angle(horizontal) format(%2.1fc)) 									///
			xlabel(, labsize(small) gmax angle(horizontal)) 													///
			ytitle("Number of firms", size(medsmall))			 												///
			xtitle("Probability of an approved loan in 2018", size(medsmall)) 									///
			title("", pos(12) size(medsmall)) 																	///
			subtitle(, pos(12) size(medsmall)) 																	///
			ysize(5) xsize(7) 																					///
			legend(order(1 "Firms with loans approved in 2018" 2 "Credit-constrained firms") pos(12) region(lstyle(none) fcolor(none)) size(medsmall))  	///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output/figures/ML_distribution_probability_loan.emf", as(emf) replace

		*
		*B* 
		*PSmatch
		*Probability of loan according to psmatch
		*----------------------------------------------------------------------------------------------------------------------------*
			use 	"$data\final\firm_year_level.dta" if active == 1, clear
					
			**
			keep if inlist(sme, "a.1-9") 
			
			**
			keep if type_firm_panel == 0 | (type_firm_panel == 1 & has_loan == 1)
			
			**
			sort 	fuid period
			replace avgrowth_productivity_r  = l1.avgrowth_productivity_r 	if period == 2018
			replace avgrowth_employees 		 = l1.avgrowth_employees		if period == 2018
			
			**
			keep if period == 2018

			**
			psmatch2 has_loan    i.municipalityid i.lag1_employees sq_lag1_employees number_loans_up_t_minus1  		 ///
								 sq_lag1_productivity_r lag1_productivity_r  lag1_turnover_r 	sq_lag1_turnover_r 	 	 ///
								 firms_age i.sectionid ///
			, n(5) common ties	
			
			keep 		if _support == 1	& _weight  != .	

			tab _treated

			**
			
			
			gen 		   _weight2  = _pscore/(1-_pscore) 	if  _treated == 0
			replace 	   _weight2  = 1 					if 	_treated == 1

			
			**
			gen 	group1 = 1 if _pscore >= 0.9 & !missing(_pscore)
			gen 	group2 = 1 if _pscore >= 0.8 & _pscore < 0.9
			gen 	group3 = 1 if _pscore >= 0.7 & _pscore < 0.8
			gen 	group4 = 1 if _pscore >= 0.6 & _pscore < 0.7
			gen 	group5 = 1 if _pscore >= 0.5 & _pscore < 0.6
			gen 	group6 = 1 if _pscore <  0.5
								
			label define has_loan 0 "Credit-constrained firms" 1 "Loan approved in 2018" 
			label val 	 has_loan has_loan
			
			graph pie group1 group2 group3 group4 group5 group6,  by(has_loan,  note("") graphregion(color(white)) cols(3))   ///
			pie(1, explode  color(navy*0.9)) pie(2, explode  color(navy*0.6))  pie(3, explode  color(emidblue))  pie(4, explode  color(emidblue*0.7)) pie(5, explode color(gs12)) pie(6, explode color(cranberry*0.6)) ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 												///
			legend(order(1 "Prob > 90%" 2 "Prob > 80% & < 90%" 3 "Prob > 70% & < 80%" 4  "Prob > 60% & < 70%" 5 "Prob > 50% & < 60%" 6 "Prob < 50%") cols(3) pos(12) region(lstyle(none) fcolor(none)) size(medsmall)) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(6) 	
			graph export "$output/figures/psmatch_probability_loan.pdf", as(pdf) replace	
			graph export "$output/figures/psmatch_probability_loan.emf", as(emf) replace	
			

			**
			*Kernel Density
			tw kdensity _pscore if has_loan == 1  [aw = _weight],  lw(1.5) lp(dash) color(cranberry) 			///
			///
			|| kdensity _pscore if has_loan == 0  [aw = _weight],  lw(thick) lp(dash) color(gs12) 				///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
			ylabel(, labsize(small) nogrid angle(horizontal) format(%2.1fc)) 									///
			xlabel(, labsize(small) gmax angle(horizontal)) 													///
			ytitle("Number of firms", size(medsmall))			 												///
			xtitle("Probability of an approved loan in 2018", size(medsmall)) 									///
			title("", pos(12) size(medsmall)) 																	///
			subtitle(, pos(12) size(medsmall)) 																	///
			ysize(5) xsize(7) 																					///
			legend(order(1 "Firms with loans approved in 2018" 2 "Credit-constrained firms") pos(12) region(lstyle(none) fcolor(none)) size(medsmall))  	///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output/figures/psmatch_distribution_probability_loan.pdf", as(pdf) replace
			graph export "$output/figures/psmatch_distribution_probability_loan.emf", as(emf) replace
	}
		
		
		
	*--------------------------------------------------------->>>
	**
	*Credit creditworthiness -> Results of the machine learning models Simon run in Python
	{
		import 		delimited using "$data\final\machine-learning\potential_borrowers_top10_vars.csv", clear
			rename probability prob_model2
			keep if period == 2018
			tempfile	 top10
			savexls 		`top10'
		
		import 		delimited using "$data\final\machine-learning\potential_borrowers.csv", clear
		rename probability prob_model1
			merge 1:1 fuid using `top10'

			gsort 				has_loan -prob_model1
			keep 		fuid 	has_loan prob*
			order 		fuid 	has_loan prob_model1 prob_model2 
			
			format prob* %12.2fc
			label var prob_model1 "Probability Loan - Model 1, inputing median values for missing data"
			label var prob_model2 "Probability Loan - Model 2, not inputing data"
			label var has_loan 	  "Loan approved in 2018"
			label define has_loan 0 "No" 1 "Yes"
			label val has_loan has_loan
		
			export excel using "$output\tables\ML Probability of Loan.xlsx", sheet("ML Results") firstrow(varlabels) replace
	}
		
		
		
	*--------------------------------------------------------->>>
	**
	*Balance test between:
	
		*1) firms with with loans approved in 2018 and
		
		*2) firms with no loans approved between 2010-2018
	{
		use 	"$data\final\firm_year_level.dta" if active == 1 & period == 2018 & main_dataset == 1, clear	
		
		**
		tab sme if type_firm_panel == 0				//more than 98% of the firms that did not have access to credit between 2010-2018 are micro-firms. 
		
		**
		keep 	if inlist(sme, "a.1-9") 			//micro-firms
		
		**
		keep 	if type_firm_panel == 0 | (type_firm_panel == 1 & has_loan == 1)	//firms without loans in the whole period and firms with credit history and one loan approved in 2018
		
		**
		replace export_tx 				= export_tx*100
		replace import_tx 				= import_tx*100
		replace has_credit_history 		= has_credit_history*100
		replace turnover_r 				= turnover_r/1000
		replace productivity_r 			= productivity_r/1000
		replace wages_worker_r 			= wages_worker_r/1000
		
		label   var turnover_r  		"Sales, thousands 2021 EUR" 
		label   var productivity_r  	"Productivity, thousands 2021 EUR" 
		label   var wages_worker_r  	"Average wage, thousands 2021 EUR" 

		**
		eststo clear
		*keep if sec_activityid == 3
		bys  type_firm_panel: eststo:  estpost sum employees turnover_r productivity_r wages_worker_r firms_age has_credit_history
		esttab using "$output/tables/ Firms’ characteristics by access to credit_2018.csv", replace  cells("mean sd min max") nodepvar    
		
		**
		*Distribution in the average growth rate in total sales and sales per employee
		foreach var of varlist avgrowth_turnover_r avgrowth_productivity_r { 
			
			if "`var'" == "avgrowth_turnover_r" 	{
				local xtitle = "Annual growth sales"
				local color olive_teal
			}
			
			if "`var'" == "avgrowth_productivity_r" {
				local xtitle = "Annual growth sales per employee"
				local color orange*0.8
			}	
				
			tw (histogram `var' if type_firm_panel == 0 ,  percent color(`color') fintensity(50))  (histogram `var'  if type_firm_panel == 1 ,  percent fcolor(none) lcolor(black)),   ///
			legend(order(1 "Credit constrained firms" 2 "Firms with loans approved") pos(12) size(medium) cols(1) region(lwidth(white) lcolor(white) color(white) fcolor(white) )) 		 ///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(large) format(%12.0fc)) 						 ///
			xtitle("`xtitle'", size(medium)) xlabel(,labsize(small) format(%12.0fc)) 				 	 				 ///
			title("", pos(12) size(medsmall) color(black)) 														 ///
			subtitle("", pos(12) size(medsmall) color(black)) 													 ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	 ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 ///
			ysize(5) xsize(6) 																					 ///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output/figures/av_`var'.pdf", as (pdf) replace
		}
				
		
		
		
		
	}
	*__________________________________________________________________________________________________________________________________________*
		
		

	
	*--------------------------------------------------------->>>
	**
	*Firms' characteristics prior to KCGF according to their access to credit between 2016-2018
	{
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 & inlist(sme, "a.1-9", "b.10-49"), clear
			
			**
			gen micro =  sme == "a.1-9" 
			gen small =  sme == "b.10-49"
			
			**
			gen productivity_micro 	= productivity_r/1000 	if micro == 1
			gen turnover_micro 		= turnover_r/1000  		if micro == 1
			gen productivity_small 	= productivity_r/1000  	if small == 1
			gen turnover_small		= turnover_r/1000  		if small == 1
			
			**
			replace wages_worker_r = wages_worker_r/1000
			replace willclose_after2015 = willclose_after2015*100
			replace had_loan_up2015     = had_loan_up2015*100
			replace irate_nominal 		= .   if irate_nominal 		== 0
			replace duration 	  		= .   if duration 	    	== 0
			replace employees 			= .   if employees 			== 0
			replace nocredit_history 	= nocredit_history*100
			replace turnover_r 			= turnover_r/1000
			replace productivity_r 		= productivity_r/1000
			replace import_tx 			= import_tx*100
			replace export_tx 			= export_tx*100
			replace micro 				= micro*100
			
			**
			label var micro 				"Micro-firm, %"
			label var turnover_micro 		"Sales micro-firms, thousands EUR 2021"
			label var turnover_small		"Sales small-firms, thousands EUR 2021"
			label var productivity_micro 	"Productivity micro-firms, thousands EUR 2021"
			label var productivity_small	"Productivity small-firms, thousands EUR 2021"
			label var  wages_worker_r		"Average wage, thousands EUR 2021"
				
			keep if sectionid !=.
			iebaltab firms_age employees micro turnover_micro turnover_small productivity_micro productivity_small wages_worker_r import_tx export_tx had_loan_up2015 willclose_after2015 avgrowth*,  cov(sectionid) control(2) format(%12.0fc %12.2fc) grpvar(type_firm_after2015) ///
			savexlsxlsx("$output/tables/Firms' characteristics prior to KCGF according to their access to credit between 2016-2018.xls") 	rowvarlabels replace 
			
			
			*tabform  firms_age employees micro turnover_micro turnover_small productivity_micro productivity_small wages_worker_r import_tx export_tx had_loan_up2015 willclose_after2015 avgrowth* ///
			*using "$output\tables\Firms' characteristics prior to KCGF according to their access to credit between 2016-2018.xls", vertical by(type_firm_after2015) sd sdbracket nototal	
	}
	*__________________________________________________________________________________________________________________________________________*
		
	
		
	*--------------------------------------------------------->>>
	**
	**
	*Firms size according to Tax Registry. Lots of missings, undereporting might be a problem
	{	
		
		**
		**
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 		"$data\final\firm_year_level.dta" if inlist(period, 2018,2017) & active == 1, clear
		*----------------------------------------------------------------------------------------------------------------------------*
		**
		**
		gen 		id = 1
		replace 	size = 5 if size == .
		graph pie id, over(size) plabel(_all percent, gap(-10) format(%2.1fc) size(medsmall)) 		//% of firms by size (micro, small, medium ad large)									

		**
		**
		replace 	employees = 20  if employees >  20  & employees < 50 
		replace 	employees = 21  if employees >= 50  & employees < 250
		replace 	employees = 22  if employees > 250  & employees != .
		replace 	employees = 23  if employees == .
		label 		define employees 20 "20-49" 21 "50-249" 22 "250+" 23 "N/A"
		label 		val employees employees
	
		**
		**
		collapse 	(sum)id, by(employees)
		egen 		total 	= sum(id)
		gen 		share 	= (id/total)*100
		gen 		shareNA = share 			if employees == 23
		replace 	share 	= .  				if employees == 23

		**
		**
		graph bar (asis)share shareNA ,  bar(1, color(navy) fintensity(inten50)) bar(2, color(gs18) fintensity(inten70)) 				///
		over(employees, sort() label(labsize(medium) angle(90))) stack 																		///
			blabel(bar, position(outside) orientation(horizontal) size(medsmall) color(black) format (%4.1fc))   						///
			ytitle("% firms", size(large)) ylabel(, nogrid labsize(small) gmax angle(horizontal) format (%4.0fc) )  					///
			yscale(line ) 																												///
			legend(order(1  "With number of employees in Tax Registry"  2 "Missing"  ) region(lwidth(none) color(white) fcolor(none)) cols(3) size(large) position(12)) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 ///
			plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 							 ///
			text(10 50  "70% micro, 6.8% small, 1% medium, 0.2% large, 22% N/A", size(medsmall)) ///
			ysize(6) xsize(10) 																					
			graph export "$output\figures\share firms by employees.pdf", as(pdf) replace				
	}
					
	
	
	*--------------------------------------------------------->>>
	**
	**
	*Distribution of the number of employees among firms with access to credit, only micro and small firms
	{	
		**
		**
		*KCGF Updated Dataset	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\inter\KCGF.dta"  if LoanStatus != "Canceled" & inlist(size_kcgf, 1,2), clear
		*----------------------------------------------------------------------------------------------------------------------------*
			gen 	 has_kcgf = 1
			keep 	 has_kcgf size_kcgf employees group_period period turnover
			tab 	 group_period	//1 from 2016-2019, 2 from 2020-2022, 3 Economic Recovery Package
			tempfile kcgf 
			savexls    `kcgf'
			
		
		**
		**
		*Tax Registry excluding KCGF (because it is not updated) and we used KCGF data (temp dataset above)
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\final\firm_year_level.dta" if active == 1  & inlist(sme, "a.1-9", "b.10-49") , clear		
		*----------------------------------------------------------------------------------------------------------------------------*
		
			**
			gen 	group_period = 4 if has_loan == 1	& has_kcgf == 0	//firms with loans
			replace group_period = 5 if has_loan == 0					//firms without loans
			append  using `kcgf'
			
			**
			*Average number of employees by type of firm
			bys 	group_period: su employees , detail

			**
			keep  	if inlist(period,2016,2018) //comparing firms size of firms with loans -> KCGF and other loans
			
			**
			tw (histogram employees if group_period == 1, bin(15) percent color(emidblue) fintensity(50))  (histogram employees if group_period == 4 , bin(15) percent fcolor(none) lcolor(black)),   ///
			legend(order(1 "KCGF" 2 "Other loans") pos(12) size(large) cols(3) region(lwidth(white) lcolor(white) color(white) fcolor(white) )) 		 ///
			ytitle("%", size(large)) ylabel(, nogrid labsize(large) format(%12.0fc)) 						 	 ///
			xtitle("Number employees", size(medium)) xlabel(,labsize(small) format(%12.0fc)) 				 	 ///
			title("", pos(12) size(medsmall) color(black)) 														 ///
			subtitle("", pos(12) size(medsmall) color(black)) 													 ///
			text(10 28 "* Micro and small enterprises", size(small))		 			 ///
			text(35 28 "Median KCGF: 2 employees. 80% firms between 1 and 10", size(medium))		 			 ///
			text(25 28 "Median other loans: 3 employees. 80% firms between 1 and 16", size(medium)) 			 ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	 ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 ///
			ysize(5) xsize(7) 																					 ///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output\figures\distribution of employees according to access to credit.pdf", as(pdf) replace		
	}	
	
	
	
	*--------------------------------------------------------->>>
	**
	**
	*Distribution in the number of employees of KCGF and non kcgf loans
	{
	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\final\firm_year_level.dta" if active == 1  & inlist(sme, "a.1-9", "b.10-49") & period == 2015 & employees<=30, clear		
		*----------------------------------------------------------------------------------------------------------------------------*
		
			*Average number of employees by type of firm
			bys 	type_firm_after2015: su employees , detail

			
			**
			tw (histogram employees if type_firm_after2015 == 2, bin(15) percent color(emidblue) fintensity(50))  (histogram employees if type_firm_after2015 == 1, bin(15) percent fcolor(none) lcolor(black)),   ///
			legend(order(1 "KCGF" 2 "Other loans") pos(12) size(large) cols(3) region(lwidth(white) lcolor(white) color(white) fcolor(white) )) 		 ///
			ytitle("%", size(large)) ylabel(0(20)80, nogrid labsize(large) format(%12.0fc)) 						 	 ///
			xtitle("Number employees", size(medium)) xlabel(,labsize(small) format(%12.0fc)) 				 	 ///
			title("", pos(12) size(medsmall) color(black)) 														 ///
			subtitle("", pos(12) size(medsmall) color(black)) 													 ///
			text(45 18 "Median KCGF: 3 employees. 80% firms between 1 and 9", size(medium))		 			 ///
			text(35 17 "Median other loans: 3 employees. 80% firms between 1 and 12", size(medium)) 			 ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	 ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 ///
			ysize(5) xsize(7) 																					 ///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output\figures\distribution of employees according to access to credit_1.pdf", as(pdf) replace		
				
			
			**
			tw (histogram employees if type_firm_after2015 == 2, bin(15) percent color(emidblue) fintensity(50))  (histogram employees if type_firm_after2015 == 0, bin(15) percent fcolor(none) lcolor(red)),   ///
			legend(order(1 "KCGF" 2 "No loans") pos(12) size(large) cols(3) region(lwidth(white) lcolor(white) color(white) fcolor(white) )) 		 ///
			ytitle("%", size(large)) ylabel(0(20)80, nogrid labsize(large) format(%12.0fc)) 						 	 ///
			xtitle("Number employees", size(medium)) xlabel(,labsize(small) format(%12.0fc)) 				 	 ///
			title("", pos(12) size(medsmall) color(black)) 														 ///
			subtitle("", pos(12) size(medsmall) color(black)) 													 ///
			text(45 17 "Median KCGF: 3 employees. 80% firms between 1 and 9", size(medium))		 			 ///
			text(35 17 "Median no loans: 1 employee. 80% firms between 1 and 5", size(medium)) 			 ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	 ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 ///
			ysize(5) xsize(7) 																					 ///
			note("", color(black) fcolor(background) pos(7) size(small)) 
			graph export "$output\figures\distribution of employees according to access to credit_2.pdf", as(pdf) replace		
	}
	
	
	*--------------------------------------------------------->>>
	**
	**
	*KCGF disbursement amount and number of contracts
	{	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" if period > 2015 & LoanStatus != "Canceled", clear
		*----------------------------------------------------------------------------------------------------------------------------*

			gen id = 1
			
			collapse (sum)id  	disbursedamount_r, by(DisbursementMonthYear)
			su  				disbursedamount_r, detail
			
			replace  disbursedamount_r = disbursedamount_r/1000000
					
					twoway ///
					(bar disbursedamount_r DisbursementMonthYear, barw(.5)  mlab() mlabpos(12) mlabcolor(black) lcolor(navy) lwidth(0.2) fcolor(gs14) fintensity(inten60) yaxis(2)) 			 ///
				|| (scatter id DisbursementMonthYear , symbol(O) color(cranberry*0.8) msize(medsmall) ml() mlabcolor(black) mlabposition(3) mlabsize(2) yaxis(1) 	 ///
					ysca(axis(1) r(0(50)150) line)   ylab(, nogrid	  angle(horizontal) labsize(small) format(%4.0f) axis(1)) 					 					 ///
					ysca(axis(2) r()  line)  ylab(,  nogrid   angle(horizontal) labsize(small) format(%4.0f) axis(2))	///
					xline()	///
					xsca() 	///
					legend(order(1 "Disbursement" 2 "N. of KCGF loans"  ) cols(2) size(medium) region(lwidth(none) color(none)) pos(6))  /// 		
					title("", pos(12) size(medsmall) color(black)) 														///     
					ytitle("N. of KCGF loans", axis(1) size(medium) color(black))										/// 
					ytitle("Disbursements, million 2021 EUR", axis(2) size(medium) color(black)) 						///
					xtitle("", size(small))  																			///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	///
					plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
					ysize(5) xsize(7)							 														///
					note("", span color(black) fcolor(background) pos(7) size(vsmall)))
					graph export "$output/figures/numberKcgfloans.pdf", as(pdf) replace	
	}

	
	
	*--------------------------------------------------------->>>
	**
	**
	*Distribution of the amount of kcgf and non-kcgf loans. Average loan, only MSME
	{	
		
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" 					if period > 2015 & LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
		*----------------------------------------------------------------------------------------------------------------------------*
			su loanamount_r, detail
			replace 	loanamount_r = . 			if loanamount_r >= r(p95)
			gen 		fund = 1
			tempfile 	kcgf
			savexls 	   `kcgf'
		
		
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\inter\Credit Registry.dta" 	if period > 2015 & fund != 1, clear														//non kcgf loans. Each row in this dataset is one contract. same firm can have several in the same year. 
		replace fund = 2 if fund == 3
		*----------------------------------------------------------------------------------------------------------------------------*
				
				**
				**Checking the firm sales to see if the approved amount is much more than the total sales (which indicates that something might be wrong)
				merge 	m:1 fuid period using "$data\final\firm_year_level.dta", keep (1 3) keepusing (turnover_r size sme) nogen
				
				**
				keep 	if (inlist(sme, "a.1-9", "b.10-49", "c.50-249") & period < 2019) | (period == 2019 & inlist(size_creditdata, 1,2,3)) //only MSME
				
				**
				*Ouliers in terms of approved amount divided by turnover. -> it does not make sense the company get a loan that might be more than 10 times their total sales 
				gen 	p = loanamount_r/turnover_r
				su  	p 										, detail //only for the non-covered loans, lets see the total amount of KCGF without excluding anything
				gen 	outlier = 1 							if p > r(p95) & p != .		   //excluding the percentile 95
				replace loanamount_r = . 						if outlier == 1
	
				**
				**Outliers in terms of amount
				su 		loanamount_r 							if outlier != 1, detail
				replace loanamount_r = . 						if outlier != 1 & (loanamount_r < r(p5) | loanamount_r >= r(p95))

				**
				**
				append using `kcgf'
				
				**
				**
				keep if period < 2019
				
				**
				**
				su loanamount_r if fund == 2, detail
				su loanamount_r if fund == 1, detail
				
				**
				*Distribution of loan amounts by fund
				twoway  (kdensity loanamount_r  			if fund == 1,   lcolor(cranberry) lwidth( thick ) )  													///	
						(kdensity loanamount_r 				if fund == 2,   lcolor(red) lwidth( thin)    															///
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
	}		

	
	
	*--------------------------------------------------------->>>
	**
	**
	*Descriptive statistics of KCGF loans
	{
	
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
			collapse (sum) id loanamount_r (median) turnover_r average_loan_r collateralvalue_r shareloan_turnover duration irate_nominal total_interest (mean) economic_recovery, by(period Product)
			
			**
			replace economic_recovery = economic_recovery*100
						
			**
			order   period  loanamount_r id  average_loan_r irate_nominal total_interest collateralvalue_r duration shareloan_turnover economic_recovery
			br		period  loanamount_r id  average_loan_r irate_nominal total_interest collateralvalue_r duration shareloan_turnover economic_recovery turnover_r					if Product == "Total"
			
			**
			br		period  loanamount_r id  average_loan_r irate_nominal total_interest collateralvalue_r duration shareloan_turnover economic_recovery				    		if Product != "Total" & period == 2021
		
	}	
			
		
		
	*--------------------------------------------------------->>>
	**
	**
	*Descriptive statistics of non-KCGF loans
	{
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use 	"$data\inter\Credit Registry.dta" 	if period > 2015, clear							//each row is one contract. same firm can have several in the same year. 
		replace fund = 2 if fund == 3
		*----------------------------------------------------------------------------------------------------------------------------*
		
				**
				*Checking the firm sales to see if the approved amount is much more than the total sales (which indicates that something might be wrong)
				merge m:1 fuid period using "$data\final\firm_year_level.dta", keep (1 3) keepusing (turnover_r size sme group_sme) nogen
				
				**
				*Only MSME
				keep 	if (inlist(sme, "a.1-9", "b.10-49", "c.50-249") & period < 2019) | (period == 2019 & inlist(size_creditdata, 1,2,3))
				
				**
				*Interest rates and duration of other loans
				foreach var of varlist irate_nominal duration {
						su `var', detail
				}
		
				**
				*Ouliers in terms of approved amount divided by turnover. -> it does not make sense the company get a loan that might be more than 10 times their total sales
				gen 		p = loanamount_r/turnover_r
				su  		p 										, detail //only for the non-covered loans, lets see the total amount of KCGF without excluding anything
				gen 		outlier = 1 							if p > r(p95) & p != .		   //excluding the percentile 95				
				replace 	loanamount_r = . 						if outlier == 1

				
				**
				**Outliers in terms of amount
				foreach fund in 1 2 {
				su 			loanamount_r 							if outlier != 1 & fund == `fund', detail
				replace 	loanamount_r   = . 						if outlier != 1 & fund == `fund' & (loanamount_r 	 < r(p5) | loanamount_r 	   >= r(p95))
				replace 	total_interest = .						if outlier != 1 & fund == `fund' & (loanamount_r 	 < r(p5) | loanamount_r 	   >= r(p95))
				}
				
				**
				*Loan amount as % of turnover
				gen 		shareloan_turnover 		= (loanamount_r /turnover_r)*100
				su			shareloan_turnover		, detail
				replace 	shareloan_turnover 		= . 			if 								  shareloan_turnover < r(p5) | shareloan_turnover 	>  r(p95)

				**
				**Average loan
				clonevar  	average_loan_r =	loanamount_r
							
				**
				*Firm id
				egen 		id = tag(fuid period)					//firm indicator
				
				**
				replace classA = classA*100
				
				**
				*Total loan amount
				collapse (sum) loanamount_r id (median)average_loan_r collateralvalue_r duration irate_nominal total_interest  shareloan_turnover (mean) classA, by(period fund)
				format  *amount* %15.1fc				
				replace  loanamount_r =  loanamount_r/1000000
				order 	 period id ave*		//other loans, total, contracts and average amount
				br		 period  loanamount_r id  average_loan_r irate_nominal total_interest  collateralvalue_r duration shareloan_turnover classA		if fund == 2
				br		 period  loanamount_r id  average_loan_r irate_nominal total_interest  collateralvalue_r duration shareloan_turnover classA 	if fund == 1
	}

				
	
	*--------------------------------------------------------->>>
	**
	**
	*Balance test according to type of firm by access to credit between 2016-2018
	{
	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" 		if period == 2015 & main_dataset == 1 & active == 1 & inlist(sme, "a.1-9", "b.10-49"), clear
		
		**
		gen micro =  sme == "a.1-9" 
		gen small =  sme == "b.10-49"
		
		**
		gen productivity_micro 	= productivity_r 	if micro == 1
		gen turnover_micro 		= turnover_r 		if micro == 1
		gen productivity_small 	= productivity_r 	if small == 1
		gen turnover_small		= turnover_r 		if small == 1
		
		keep if sectionid != .
		**
		iebaltab firms_age employees micro turnover_micro turnover_small productivity_micro productivity_small wages_worker_r import_tx had_loan_up2015 willclose_after2015, cov(sectionid) stdev  format(%12.0fc %12.2fc) grpvar(type_firm_after2015) ///
		savexlsxlsx("$output/tables/Balance test by access to credit_2016-2018.xls") 	rowvarlabels replace 
	}
	*__________________________________________________________________________________________________________________________________________*

	
	
	*--------------------------------------------------------->>>
	**
	**
	*Credit history according to type of firm by access to credit between 2016-2018
	{
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 &  inlist(sme, "a.1-9", "b.10-49", "c.50-249"), clear
		*----------------------------------------------------------------------------------------------------------------------------*

			graph pie had_loan_up2015 didnothave_loan_up2015, by(type_firm_after2015,  note("") legend(off) graphregion(color(white)) cols(3))  ///
			pie(1, explode  color(emidblue*0.8)) pie(2, explode color(gs12))  ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 												///
			plabel(2 "No credit",   						 gap(2)   format(%2.0fc) size(large)) 												///
			plabel(1 "With loans",    						 gap(2)   format(%2.0fc) size(large)) 												///
			legend(order(1 "Access to credit before 2016" 2 "Without access to credit before 2016") ) 											///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(10) 	
			graph export "$output/figures/had_loan_up2015_subgroup.pdf", as(pdf) replace	
	}
	*__________________________________________________________________________________________________________________________________________*

	
	
	*--------------------------------------------------------->>>
	**
	**
	*Exit rates according to type of firm by access to credit between 2016-2018
	{
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\final\firm_year_level.dta" if period == 2015 & main_dataset == 1 & active == 1 &  inlist(sme, "a.1-9", "b.10-49", "c.50-249"), clear
		*----------------------------------------------------------------------------------------------------------------------------*

			graph pie notclose_after2015 willclose_after2015 , by(type_firm_after2015,   note("") legend(off) graphregion(color(white)) cols(3))  ///
			pie(1, explode  color(gs14)) pie(2, explode color(red))  ///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 											///
			plabel(2 "Close",   						 gap(2)   format(%2.0fc) size(large)) 												///
			plabel(1 "Remain open",    						 gap(2)   format(%2.0fc) size(large)) 											///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 		///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 		///
			note("", span color(black) fcolor(background) pos(7) size(small))																///
			ysize(4) xsize(10) 	
			graph export "$output/figures/exit_by_subgroup.pdf", as(pdf) replace	
	}
	*__________________________________________________________________________________________________________________________________________*
	
	

	*--------------------------------------------------------->>>
	**
	**
	*Balance test between Regular KCCF window and Economic Recovery Package
	{
	
		use "$data\inter\KCGF.dta" if period == 2021, clear
			
			**
			keep if inlist(Product, "Economic Recovery Window", "Regular Window")
			
			**
			gen 	micro 	= (size_kcgf == 1)*100
			gen 	small 	= (size_kcgf == 2)*100
			gen 	medium 	= (size_kcgf == 3)*100
			*replace micro 	= . if size_kcgf != 1
			*replace small  = . if size_kcgf != 2
			*replace medium = . if size_kcgf != 3

			rename GuaranteePercentageRequested guarantee

			foreach var of varlist turnover_r productivity_r  collateralvalue_r guarantee irate_nominal duration employees {
				**
				if "`var'" == "turnover_r" | "`var'" == "productivity_r" | "`var'" == "collateralvalue_r" {
				replace `var' = `var'/1000
				}
				**
				gen 	`var'_micro  = `var'	if micro  == 100
				gen 	`var'_small  = `var'	if small  == 100
				gen 	`var'_medium = `var'	if medium == 100
			}
			
			**
			foreach size_kcgf in 1 2 3  {
				foreach var of varlist  turnover_r*  productivity_r* collateralvalue_r* employees*  {
					su		 `var'			if size_kcgf == `size_kcgf', detail
					replace  `var' = .		if size_kcgf == `size_kcgf' & (`var' <= r(p5) |`var' >= r(p95))
				}
			}
				
			keep if Section != ""
			
			**	
			iebaltab   *micro *small *medium, cov(format(%12.2fc) grpvar(Product) savexls("$output/tables/Balance test between KCGF Regular and Economic Recovery Package Windows.xlsx") 	rowvarlabels replace 
	}
	*__________________________________________________________________________________________________________________________________________*
	
	
	
	*--------------------------------------------------------->>>
	**
	**
	*% loans by KCGF window 2021
	{
	
		*----------------------------------------------------------------------------------------------------------------------------*
		*----------------------------------------------------------------------------------------------------------------------------*
		use "$data\inter\KCGF.dta" 				if period == 2021 & LoanStatus != "Canceled" & inlist(size_kcgf, 1,2,3), clear	//not including large companies
		*----------------------------------------------------------------------------------------------------------------------------*
		
		**
		bys Product: su duration, detail			//duration by type of window
		
		**
		gen id = 1
		
		**
			graph pie id, over(Product)  																										///
			pie(1, explode  color(emidblue*0.8))  	 																							///
			pie(2, explode  color(gs12))  																										///
			pie(3, explode  color(orange*0.5))  																								///
			pie(4, explode  color(erose*1.2))  																									///
			plabel(_all percent,   						 gap(-10) format(%2.0fc) size(medsmall)) 												///
			plabel(4 "Start up",   						 gap(1)   format(%2.0fc) size(large)) 													///
			plabel(3 "Regular",   						 gap(2)   format(%2.0fc) size(large)) 													///
			plabel(2 "Eco Rev Package",   				 gap(4)   format(%2.0fc) size(large)) 													///
			plabel(1 "Agro",    						 gap(7)   format(%2.0fc) size(large)) 													///
			legend(off) 											///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 					 			///
			plotregion(color(white)  fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 						 			///
			note("", span color(black) fcolor(background) pos(7) size(small))																	///
			ysize(4) xsize(5) 	
			graph export "$output/figures/kcgf_windows.pdf", as(pdf) replace	
	}
	*__________________________________________________________________________________________________________________________________________*
	
