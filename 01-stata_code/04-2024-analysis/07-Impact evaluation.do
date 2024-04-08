

																*IMPACT EVALUATION*
	*__________________________________________________________________________________________________________________________________________*
	**

			/*
			Treatment Group - > Firms included in KCGF up to 2021
			Comparison Group -> Firms included in KCGF only in 2022
			*/

			**
			*Checking how many firms in KCGF data we are able to find in the Tax Registry.
			*For thousands of firms, we do not find their business registration number in the Tax Registry (these might be informal firms)
			*----------------------------------------------------------------------------------------------------------------------------->>
			{
				use 	"${path_project}/data/inter/Updated KCGF Panel.dta", clear
				codebook 	businessid, detail
				local total = r(N)
				di `total'
				merge 		m:1 businessid using "${path_project}/data/inter/Tax Payer and Businessid.dta"	
				tab 		period if _merge == 1  											
				codebook	businessid if _merge == 1
				sort 		businessid
				br 			businessid if _merge == 1
				local 	p = 2794/8630
				di as red "matched unsucessful for `p'"  									//68% of the firms in KCGF data were found in Tax Registry
			}
			
			
			**
			*Merging KCGG Panel and Tax Authorities
			*----------------------------------------------------------------------------------------------------------------------------->>
			{
			
			*We will merge KCGF data and Tax Registry to have a measure of firms' turnover, employment and productivity before and after KCGF participation
			
			use  "${path_project}/data/inter/Updated KCGF Panel.dta" if size_kcgf != 4, clear
				
				tab period if loanamount != . & loanamount > 0
				
				/*
					 period |      Freq.     Percent        Cum.
				------------+-----------------------------------
					   2016 |         90        0.86        0.86
					   2017 |        737        7.06        7.93
					   2018 |      1,347       12.91       20.83
					   2019 |      1,732       16.60       37.43
					   2020 |      1,787       17.13       54.56
					   2021 |      3,126       29.96       84.51
					   2022 |      1,616       15.49      100.00
				------------+-----------------------------------
					  Total |     10,435      100.00
				*/
				
				merge 	m:1 businessid					 using "${path_project}/data/inter/Tax Payer and Businessid.dta", keep(3  ) nogen keepusing(tax_payer_no)
				merge 	1:1 tax_payer_no period 		 using "${path_project}/data/inter/Updated Tax Registry.dta"	 , keep(1 3) nogen
				bys   	firm_id: egen max_size = max(size) //if we want to include a control in the Staggered DiD proposed by Woodrigde, the control shoulc be time invariant
				
				tab period if loanamount != . & loanamount > 0			//because there are firms listed in KCGF that we do not find in the tax registry, we can see a decrease in our sample:

				/*
					 period |      Freq.     Percent        Cum.
				------------+-----------------------------------
					   2016 |          6        0.11        0.11
					   2017 |         91        1.62        1.73
					   2018 |        259        4.62        6.35
					   2019 |      1,011       18.04       24.39
					   2020 |      1,517       27.07       51.46
					   2021 |      2,720       48.54      100.00
				------------+-----------------------------------
					  Total |      5,604      100.00

				*/
				
				order 	tax_payer_no businessid period
				sort 			   	 businessid period
				

				xtset   firm_id period 
				gen 	lag_turnover 		= L.turnover
				gen 	lag_productivity 	= L.productivity 
				gen 	lag_employees 		= L.employees 

				gen 	after_treatment = period >= first_kcgf
				gen 	DT 				= after_treatment*treated_before2022

				gen 	t 				= period - first_kcgf 		if first_kcgf >  period
				replace t  				= period - first_kcgf + 1 	if first_kcgf <= period
				replace t 				= 0 						if first_kcgf == 2022

				gen 	has_turn = turnover > 0 & !missing(turnover) & period < first_kcgf //has turnover data prior to KCGF participation
				bys 	firm_id: egen has_turn_beforekcgf = max(has_turn)
				drop    has_turn
				
				gen 	has_turn = turnover > 0 & !missing(turnover) & period >= first_kcgf //has turnover after during or after kcgf participation
				bys 	firm_id: egen has_turn_duringkcgf = max(has_turn)
				drop    has_turn
				
				sort 	businessid  period
				br 		businessid period loanamount		   first_kcgf t treated_before2022 after_treatment DT turnover turnover_kcgf has_turn_beforekcgf  has_turn_duringkcgf
				save 	"${path_project}/data/inter/Updated IE dataset.dta", replace
			}	
			

		
		**
		** Conventional DiD
		*--------------------------------------------------------------------------------------------------------------------------------->>
		{
	
			/*
			Estimates of the probability of closing based on the preliminary analysis 
			We could not replicate using more recent data because the tax authority did not share the variable "death_year" in the dataset up to 2021
	
					Estimates	lower bound  upper bound
			model 1	-6.091197	-7.527215	-4.65518	
			model 2	-5.073162	-6.628808	-3.517515	
			model 3 -4.86938	-6.283798	-3.454963			I will use this one to be conservative
			model 4	-5.863317	-7.258839	-4.467795	
			*/
			
			estimates clear
			matrix results = (0,0,0,0)
			* "${path_project}/data/inter/05-impact_evaluation_dataset.dta"
			use "${path_project}/data/inter/Updated IE dataset.dta", clear
			
				drop if number_types_loans > 1	&  (prod_erp == 1 | prod_star == 1)	//means that in the same year the company took two loans and one of them was eco recovery package. 
				drop if first_kcgf ==  2016
				keep if period     >=  2016
				keep if (has_turn_beforekcgf == 1 & has_turn_duringkcgf == 1 ) | comparison == 1
				
				xtreg  ln_employees  	 DT  i.period i.size i.sectorid, fe
				matrix results = results\(1,el(r(table),1,1),el(r(table),5,1),el(r(table),6,1))
					
				xtreg  ln_turnover 	 	 DT  i.period i.size i.sectorid , fe
				matrix results = results\(2,el(r(table),1,1),el(r(table),5,1),el(r(table),6,1))

				xtreg  ln_productivity 	 DT  i.period i.size i.sectorid , fe
				matrix results = results\(3,el(r(table),1,1),el(r(table),5,1),el(r(table),6,1))
				
				matrix list results
				clear
				svmat results
				rename (results1-results4) (variable att lower upper)
				drop in 1 
				foreach var of varlist att lower upper {
					replace `var' = `var'*100
				}
				
				set obs 4
				replace variable = 4 in 4
				replace att = -4.9 in 4
				replace lower = -6.3 in 4
				replace upper = -3.5 in 4
				gen 	aux = -0.5 if inlist(variable, 1,2,3)
				replace aux = 1  if variable == 4
				
				tostring att, force gen (attstring) 
				
				replace attstring = substr(attstring,1,4)
				replace attstring = attstring + "%"
				
				gen variableaux =variable - 0.2
		
				format att %2.1fc
				twoway    bar att variable , ml(att) barw(0.4) color(cranberry),  || rcap lower upper variable, lcolor(navy) lw(thick)	|| scatter aux variableaux , mlabsize(large) msymbol(none) mlabel( attstring)	///
				xtitle("", size(medsmall)) 											  																											///
				ytitle("Increase in %", size(medium))  																																			///					
				yline(0) ///
				ylabel(-6(3)12, angle(360)) 																																					///
				xlabel(1 `" "Employees" "' 2 `" "Turnover" "' 3 `" "Productivity" "' 4 `" "Probability" "of" "closing" "', labsize(medsmall) ) 													///
				xscale(r(0.5 2.5)) 																																								///
				title(, size(medsmall) color(black)) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																		///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																				///						
				legend(order(1 "Estimate in %"  2 "95% confidence interval" ) span cols(3) pos(12) region(lstyle(none) fcolor(none)) size(medium))  											///
				ysize(4) xsize(5)  ///
				note(, color(black) fcolor(background) pos(7) size(small)) 
				graph export "$output/figures/DiD-results.pdf", as(pdf) replace			
			}			
						
											
											
		**
		** Testing parallel trends
		*--------------------------------------------------------------------------------------------------------------------------------->>
		{ 					
			use "${path_project}/data/inter/Updated IE dataset.dta" if size == 1 & period > 2015 , clear
											
				drop if number_types_loans > 1	&  (prod_erp == 1 | prod_star == 1)					//means that in the same year the company took two loans and one of them was eco recovery package. 
				
				keep if (has_turn_beforekcgf  == 1 & has_turn_duringkcgf == 1) | comparison == 1		
					
				collapse (mean) turnover productivity employees, by(period first_kcgf comparison)			
				
				replace turnover = turnover/1000
				format turnover %12.1fc
			
					
				foreach year in 2019 2020 2021 {
				    
					if `year' == 2019 local color = "ebblue"
					if `year' == 2020 local color = "emidblue"
					if `year' == 2021 local color = "navy"
				    
				tw 	///
				(line  turnover  period if first_kcgf == `year' , 	lcolor(`color') lwidth(1)   lp(solid) ms(i) ml(turnover) mlabposition(6) color(emidblue) mlabsize(3) connect(direct) recast(connected) mlabcolor(gs2))      ///  		
				(line  turnover  period if comparison==1, 			lcolor(gs12)    lwidth(0.5) lp(solid) ms(i) ml(turnover) mlabposition(12)  color(emidblue) mlabsize(3) connect(direct) recast(connected) mlabcolor(gs2)  ///  	
				ylabel(30(10)65,  labsize(medium) nogrid gmax angle(horizontal) format(%12.0fc)) xsca(r(2015.8 2021))  ///
				///
				ytitle("Turnover, thousands EUR", size(large))  ///
				///
				xtitle("`xtitle'", size(medium)) ///
				///
				xlabel(2016(1)2021, angle(360) labsize(large)) ///
				///
				title("KCGF in `year'", pos(12) size(huge) color(red)) ///
				///
				subtitle(, pos(12) size(medsmall) color(black)) ///
				///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				legend(order(1 "Treated in `year'"  2 "Comparison Group" ) span region(lwidth(none)) cols(2) size(large) position(6) bplacement(seast)) ///
				///
				ysize(2.5) xsize(3)	 ///
				///
				note("", color(black) fcolor(background) pos(7) size(small))) 
				*graph export "$output/figures/trends_treated_`year'.pdf", replace
				}
		}
		.			

					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
			/*		
					
					
											
			
		**
		** Event study design
		*--------------------------------------------------------------------------------------------------------------------------------->>
				use "${path_project}/data/inter/Updated IE dataset.dta",clear

				drop if number_types_loans > 1	&  (prod_erp == 1 | prod_star == 1)		//means that in the same year the company took two loans and one of them was eco recovery package. 
				keep if first_kcgf  >= 2019
				keep if period      >= 2016
				keep if has_turn_beforekcgf == 1 | comparison == 1
	
					gen t0 			= t ==  1
					gen tmenos2		= t == -2
					gen tmenos1		= t == -1
					gen t1			= t ==  2
					gen t2			= t ==  3
						

					xtreg  ln_turnover  tmenos2 tmenos1  t0 t1 t2 i.period, fe
					
					parmest, norestore	
					gen 	obs = _n
					keep if obs <= 5
					gen lower = estimate - (1.9604662*stderr)
					gen upper = estimate + (1.9604662*stderr)
				foreach var of varlist estimate lower upper {
				replace `var' = `var'*100
				}
				
			
						
				twoway    bar estimate obs, ml(estimate) barw(0.4) color(navy),  || rcap lower upper obs, lcolor(navy) lw(thick)		///
				yline(0,lcolor(cranberry) lp(shortdash)) ///
				xtitle("", size(medsmall)) 											  																											///
				ytitle("Increase in %", size(medium))  																						///					
				ylabel(-20(5)15) 	///
				xlabel(1 `" "2 years" "before KCGF" "' 2 `" "1 year" "before KCGF" "' 3  `" "KCGF" "approved loan" "' 4  `" "One year" "after KCGF" "'  5  `" "Two years" "after KCGF" "', labsize(medsmall) ) 									///
				xscale(r(0.5 2.5)) 																																								///
				title(, size(medsmall) color(black)) 																																			///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))		 																		///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 																				///						
				legend(order(1 "Increase in %"  2 "95% CI" ) span cols(3) pos(12) region(lstyle(none) fcolor(none)) size(medium))  																///
				ysize(4) xsize(5)  ///
				note(, color(black) fcolor(background) pos(7) size(small)) 
				*graph export "$output/figures/Event study_productivity.pdf", as(pdf) replace		
				graph export "$output/figures/Event study_turnover.pdf", as(pdf) replace		
								
			
			**
			*Testing parallel trends
			*---------------------------- ------------------------------------------------------------------------------------------------->>
			
			use "${path_project}/data/inter/Updated IE dataset.dta" if size == 1, clear
				matrix results1 = (0,0,0,0,0)
				matrix results2 = (0,0,0,0,0)
				matrix results3 = (0,0,0,0,0)

				
				
				*drop if number_types_loans > 1	&  (prod_erp == 1 | prod_star == 1)	//means that in the same year the company took two loans and one of them was eco recovery package. 
				*keep if first_kcgf >= 2019    | comparison == 1		
				*	keep if has_turn_beforekcgf  == 1 | comparison == 1		
					
					foreach group in 0 1 {
						forvalues period = 2014(1)2021 {
							ci means 	turnover if period == `period' &  comparison == `group'
							matrix 		results1 = results1 \ (`period', `group',r(mean), r(lb), r(ub))
							
							ci means 	productivity if period == `period' &  comparison == `group'
							matrix 		results2 = results2 \ (`period', `group',r(mean), r(lb), r(ub))	
							
							ci means 	employees if period == `period' &  comparison == `group'
							matrix		results3 = results3 \ (`period', `group',r(mean), r(lb), r(ub))
						}
					}
					
					
					*-------------------------------------------------------------------------------------------------------------------------*
					foreach variable in 1 2 3 {
						clear 
						svmat results`variable'
						drop in 1
						if `variable' == 1 rename (results11-results15)  (period group turnover 			lturnover  		uturnover)
						if `variable' == 2 rename (results21-results25)  (period group productivity		lproductivity 	uproductivity)
						if `variable' == 3 rename (results31-results35)  (period group employees 			lemployees 		uemployees)
						tempfile  `variable'
						save 	 ``variable'', replace
					}
					*-------------------------------------------------------------------------------------------------------------------------*
					
					**
					**
					*-------------------------------------------------------------------------------------------------------------------------*
					use `1', clear
						merge 1:1 period group using `2', nogen
						merge 1:1 period group using `3', nogen
					*-------------------------------------------------------------------------------------------------------------------------*
					
							tw 	///
							(rarea lturnover uturnover period if group == 0, fcolor(cranberry%30) lcolor(bg) fintensity(50)) ///
							(line turnover period if group == 0,   lcolor(cranberry) lwidth(0.5) lp(shortdash)) 	/// 
							(rarea lturnover uturnover period if group == 1, fcolor(gs12%30) lcolor(bg) fintensity(50)) ///
							(line turnover period if group == 1, lcolor(gs12) lwidth(0.5) lp(shortdash)  ///  			
							ylabel(, labsize(medium) nogrid gmax angle(horizontal) format(%12.0fc))  ///
							///
							ytitle("`ytitle'", size(medium))   ///
							///
							xtitle("",) ///
							///
							xlabel(2014(1)2021, angle(45) labsize(medium)) ///
							///
							title("`ytitle'", pos(12) size(medsmall) color(black)) ///
							///
							subtitle(, pos(12) size(medsmall) color(black)) ///
							///
							graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
							///
							plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
							///
							xline(2017, lp(shortdash) lcolor(red)) ///
							legend(order(1 "95% CI"  2 "Treated" 3 "95% CI" 4 "Comparison") region(lwidth(none)) cols(2) size(medium) position(12)) ///
							///
							ysize(5) xsize(6) ///
							///
							note("", color(black) fcolor(background) pos(7) size(small)))	
							graph export "$output/figures/trend_`main_dataset'_`model'_`comparison'_`var'.png", as(png) replace
					
					
					
			use "${path_project}/data/inter/Updated IE dataset.dta" if size == 1 , clear
							
				drop if number_types_loans > 1	&  (prod_erp == 1 | prod_star == 1)	//means that in the same year the company took two loans and one of them was eco recovery package. 
				keep if first_kcgf > 2018   | comparison == 1		
				keep if (has_turn_beforekcgf  == 1 & has_turn_duringkcgf == 1) | comparison == 1		
					
				collapse (mean)turnover productivity employees ln_turnover ln_productivity ln_employees, by(period first_kcgf)			
				
				replace turnover = turnover/1000
								
				tw 	///
				(line turnover  period if first_kcgf == 2022 , lcolor(black) lwidth(1) lp(solid))  ///  	
				(line  turnover  period if first_kcgf == 2019 , lcolor(orange) lwidth(0.5) lp(solid))  ///  	
				(line  turnover  period if first_kcgf == 2020 , lcolor(olive_teal) lwidth(0.5) lp(solid))  ///  	
				(line  turnover  period if first_kcgf == 2021, lcolor(cranberry) lwidth(0.5) lp(solid)  ///  	
				ylabel(20(10)60,  labsize(medium) nogrid gmax angle(horizontal) format(%12.1fc)) ysca()  ///
				///
				ytitle("Turnover", size(medium))   ///
				///
				xtitle("`xtitle'", size(medium)) ///
				///
				xlabel(2014(1)2021, angle(360) labsize(medium)) ///
				///
				title("`title'", pos(12) size(medlarge) color(black)) ///
				///
				subtitle(, pos(12) size(medsmall) color(black)) ///
				///
				graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
				///
				legend(order(1 "Comparison"  2 "2019" 3 "2020" 4 "2021" ) span region(lwidth(none)) cols(3) size(medium) position(11) bplacement(seast)) ///
				///
				ysize(5) xsize(5)	 ///
				///
				note("", color(black) fcolor(background) pos(7) size(small))) 
				

				
				
				
											
											
											
											
											
											
											
											
											
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
				/*							
											
											
													
		**
		** Staggered DiD
		*--------------------------------------------------------------------------------------------------------------------------------->>
		{		
			use "${path_project}/data/inter/Updated IE dataset.dta" if (max_size == 1 | max_size == 2) , clear
			
			tab period if loanamount > 0 & !missing(loanamount)
			
			//in the end our sample is reduced to 4 thousand observations
			
				drop if number_types_loans > 1	&  (prod_erp == 1 | prod_star == 1)		//means that in the same year the company took two loans and one of them was eco recovery package. 
				keep if first_kcgf  >= 2019
				keep if period      >= 2016
				keep if has_turn_beforekcgf == 1 | comparison == 1
				
				jwdid ln_employees, ivar(firm_id) tvar(period) gvar(first_kcgf) 
				parmest, norestore					
				gen lower = estimate - (1.9604662*stderr)
				gen upper = estimate + (1.9604662*stderr)
					
				foreach var of varlist estimate lower upper {
				replace `var' = `var'*100
				}
				drop if parm == "_cons"
				gen 	obs = _n
					
				tw  bar estimate obs , || rcap lower upper obs, lcolor(navy) lw(thick) ///
					 xlabel( ///
							 1 `" "2019" "2019" "' 2 `" "2019" "2020" "' 3 `" "2019" "2021" "'  ///
							 4 `" "2020" "2020" "' 5 `" "2020" "2021" "'  ///
							 6 `" "2021" "2021" "'  ///
					, labsize(small) ) ///
					 legend(order(1 "Increase in %"  2 "95% CI" ) span cols(3) pos(12) region(lstyle(none) fcolor(none)) size(medium))  																
						graph export "$output/figures/staggered did.pdf", as(pdf) replace			

		}
