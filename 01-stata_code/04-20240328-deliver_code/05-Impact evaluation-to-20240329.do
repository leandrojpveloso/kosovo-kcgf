
* 01: Tables
{
	
}
.

* 02: Graphs
{
	
}
.

{
	 		
	global controls0_xgboost	 	import_tx 			 sectionid1 				sectionid20 			///
									sq_num_loans 		 sq_lag1_num_loans 	    	sq_lag2_num_loans 		///
									num_loans 			 sq_lag1_wages_worker_r 	sq_number_loans_up2015
									
	global controls1_xgboost	 	import_tx 			 sectionid1 				sectionid20 			///
									sq_num_loans 	 	 sq_lag1_num_loans 	    	sq_lag2_num_loans 		///
									num_loans 			 sq_lag1_wages_worker_r 	sq_number_loans_up2015
														 
	sum $controls1_xgboost		

	global control_output_lag 	L1_log_empl 	  	L1_log_turn 	L1_log_wage ///
								Dm_L1_log_empl 	  	Dm_L1_log_turn 	Dm_L1_log_wage   

	global control_adds		 	import_tx 	export_tx		 sectionid1 		sectionid20 			///
								sq_num_loans 		 sq_lag1_num_loans 	    	sq_lag2_num_loans 		///
								num_loans 		     sq_number_loans_up2015

								
								
	global controls_model_1 $control_output_lag		$controls0_xgboost							
	global controls_model_2 $control_output_lag		$control_adds
 
}
.

local size_NN_limit  "1(1)50"
 
global limit_inf_common_suport = 1/25 /// 1 para 30

* 03: Impact evaluation and policy expansion
{	
		global comparison 0
		
		{
			use "${path_project}/data/03-final\firm_year_level.dta"  , clear 
 	
			*----------------------------------------------------------------------------------------------------------------------------*
			keep 	if D_study_sample==1
			keep 	if inlist(group_sme,1,2,3) 
			keep 	if main_dataset == 1								//active firms in 2015
			  keep 	if inlist(type_firm_after2015,$comparison, 2) 							//keeping only comparison group 0 or 1 and type_firm_2015 = 2 (which means the ones that had access to KCGF)
			keep    if active == 1
			*----------------------------------------------------------------------------------------------------------------------------*
  			
			**
			*Treatment status
			*----------------------------------------------------------------------------------------------------------------------------*
			gen 	treated = 1 if type_firm_after2015 == 2	 //treated firms are the ones with KCGF
			replace treated = 0 if type_firm_after2015 != 2	 //comparison firms
			*----------------------------------------------------------------------------------------------------------------------------*	
		}
		. 
		
		* Saving data
		compress
		save "${path_project}/output/01-tempfiles/data_to_psm",replace
		keep   if period == 2015	
}	 
.

{
	* probit treated $controls_model  
	* probit treated $controls_model_1 
	probit treated $controls_model_2 
	predict pscore, pr

	drop if pscore	<  ${limit_inf_common_suport}
 
	gen	N_obs		=.
	gen pscore_mean =.
	gen pscore_sd 	=.
	gen pscore_min 	=.
	gen pscore_p05 	=.
	gen pscore_p25 	=.
	gen pscore_p50 	=.
	gen pscore_p75 	=.
	gen pscore_p95 	=.
	gen pscore_max 	=.


	gen group = .
	replace group = 0 if _n==1
	replace group = 1 if _n==2
	replace group = 2 if _n==3
	replace group = 3 if _n>=4
	 
	local k 0
	foreach T in 0 1 2 {
		local k = `k'+1
		qui if `T'==0 sum pscore					 , detail
		qui if `T'==1 sum pscore		if treated==1, detail
		qui if `T'==2 sum pscore		if treated==0, detail
		 
		replace	N_obs		= r(N)		if _n==`k'
		replace pscore_mean = r(mean) 	if _n==`k'
		replace pscore_sd 	= r(sd) 	if _n==`k'
		replace pscore_min 	= r(min)  	if _n==`k'
		replace pscore_p05 	= r(p5)		if _n==`k'
		replace pscore_p25 	= r(p25)	if _n==`k'
		replace pscore_p50 	= r(p50)	if _n==`k'
		replace pscore_p75 	= r(p75)	if _n==`k'
		replace pscore_p95 	= r(p95)	if _n==`k'
		replace pscore_max 	= r(max) 	if _n==`k'
	}
	.

	gen _weight= 1
	qui	pstest $controls_model_2 , treated(treated)

	gen pstest_chiprob	= r(chiprob) 	if _n==3		
	gen pstest_chiprob_nowei = .
	gen pstest_r2		= r(r2) 		if _n==3	
	gen pstest_meanbias	= r(meanbias) 	if _n==3		
	gen pstest_medbias	= r(medbias)	if _n==3		
	gen pstest_B		= r(B)			if _n==3	
	gen pstest_R		= r(R)			if _n==3	
	
	
	
	ksmirnov pscore, by(treated)  
	gen p_value_ksmisrnov= r(p)
	 
	gen N_neighbors = 0 if _n<=3
	
	* preserve
	* 	keep if pscore>=0.5 & pscore!=.
	* 	keep fuid pscore _weight D_expansion_program
	* 	gen N_neighbors = `size'
	* 	tempfile data_`size'
	* 	save	`data_`size''
	* restore	
	 
	local k = 3
	forvalues  size = `size_NN_limit' {
		
 		di as white "Running paring to size: `size'"
		local k = `k'+1
		* local size 5
		* PSM 1-10

		
		qui psmatch2 treated, pscore(pscore) neighbor(`size') /*caliper(0.01)*/
		qui replace _pscore= pscore if _pscore!=.
		 
		cap drop D_expansion_program 
		qui gen 	D_expansion_program = 1 if treated ==0 & _support==1 & _weight!=. 
		qui replace D_expansion_program = 0 if treated ==1 & _support==1 & _weight!=.
	 
		* Replacing
		replace N_neighbors = `size' if _n==`k'	
		
		{
			qui sum pscore		if D_expansion_program==1 , detail
			replace	N_obs		= r(N)		if _n==`k'
			replace pscore_mean = r(mean) 	if _n==`k'
			replace pscore_sd 	= r(sd) 	if _n==`k'
			replace pscore_min 	= r(min)  	if _n==`k'
			replace pscore_p05 	= r(p5)		if _n==`k'
			replace pscore_p25 	= r(p25)	if _n==`k'
			replace pscore_p50 	= r(p50)	if _n==`k'
			replace pscore_p75 	= r(p75)	if _n==`k'
			replace pscore_p95 	= r(p95)	if _n==`k'
			replace pscore_max 	= r(max) 	if _n==`k'
		}
		.
		
		* New group
		qui pstest $controls_model_2  

		replace pstest_chiprob	= r(chiprob) 	if _n==`k'		
		replace pstest_r2		= r(r2) 		if _n==`k'	
		replace pstest_meanbias	= r(meanbias) 	if _n==`k'		
		replace pstest_medbias	= r(medbias)	if _n==`k'		
		replace pstest_B		= r(B)			if _n==`k'	
		replace pstest_R		= r(R)			if _n==`k'
		
		* Pstest nowei
		*qui	pstest $controls_model_2  , treated(D_expansion_program) 
		
		*replace pstest_chiprob_nowei	= r(chiprob) 	if _n==`k'		
		
	 
		

		qui ksmirnov pscore, by(D_expansion_program)  
		replace p_value_ksmisrnov= r(p) if _n==`k'
		
		preserve
			keep if D_expansion_program==1
			keep fuid pscore _weight D_expansion_program
			gen N_neighbors = `size'
			tempfile data_`size'
			save	`data_`size''
		restore
		
		preserve
			keep if D_expansion_program==1
			keep fuid pscore _weight D_expansion_program
			gen N_neighbors = `size'
			tempfile data_`size'
			save	`data_`size''
		restore
	}
	.

	* Saving matching data
	preserve
		* creating data with all matching
		keep if D_expansion_program==0
		keep fuid pscore _weight D_expansion_program _n*
		forvalues  size = `size_NN_limit' {
			append using `data_`size''
		}
		.
		compress
		save "${path_project}/data/03-final/Matching_data",replace
	restore
 
	gen 		D_pscore_same_dist	= "Yes" if p_value_ksmisrnov>  0.05
	replace  	D_pscore_same_dist 	= "No"  if p_value_ksmisrnov<= 0.05

	gen 	D_controls_pair 		= "Yes" if pstest_chiprob> 0.05
	replace D_controls_pair 		= "No"  if pstest_chiprob<=0.05

	gen 	D_controls_pair_hard 	= "Yes" if pstest_chiprob> 0.05 & pstest_B<=25  
	replace D_controls_pair_hard 	= "No"  if pstest_chiprob<=0.05 | pstest_B> 25 
 
	* gen 	D_controls_pair_nowei 	= "Yes" if pstest_chiprob_nowei> 0.05
	* replace D_controls_pair_nowei 	= "No"  if pstest_chiprob_nowei<=0.05
	
	global list_out 	group 				N_neighbors N_obs D_controls_pair_hard	D_controls_pair   D_pscore_same_dist 	///
						 pscore_mean  pscore_sd pscore_min  pscore_p05 pscore_p25 ///
						 pscore_p50 pscore_p75 pscore_p95 pscore_max 	p_value_ksmisrnov	 ///
						 pstest_chiprob_nowei pstest_chiprob		pstest_r2	pstest_meanbias	pstest_medbias	pstest_B	pstest_R
	 

	order $list_out
	keep  $list_out 
	keep if N_neighbors!=.

	format %9.3fc pscore_mean	pscore_sd	pscore_max	pscore_min p_value_ksmisrnov	pstest_chiprob	pstest_r2 ///
				   pscore_p* pstest_meanbias	pstest_medbias	pstest_B	pstest_R pstest_chiprob_nowei
	 
	save  "${path_project}/data/03-final/04-data-sample_expansion", replace
	export excel using "${path_project}/output/02-tables/04_table-sample_expansion.xlsx",  ///
		sheet("01_matching_up_to_find")   sheetreplace firstrow(varlabels) 
}
.
 
* Graph expansion
{
	 
	* 0: Scatter options
	{
		use "${path_project}/data/03-final/04-data-sample_expansion" if group==3,clear	
		
		* Graph All class
		format %10.0fc N_obs
		scatter N_obs  N_neighbors if N_neighbors<=50, ///
			connect(1)  lc(navy) mcolor(navy)    ms(oh)  lp(dash)  ///
			graphregion(color(white)) xsize(10) ysize(5) 			///
			xline( 33 ,   lc(gs6) lp(dash)) ylabel(0(500)4000, angle(0)) ///
			xlabel(0(2)50, angle(0)) ///
			xtitle("Number of possible matchings by treated") ///
			ytitle("Number of matchings")
		graph export "${path_overleaf}/02-Figures/IE01-graph_out_sample.pdf", replace as(pdf)
		
 global  pct_up_25  `"0 "0%" .05 "5%" .10 "10%" .15 "15%" .20 "20%"  0.25 "25%""'
 
		* Graph All class
		format %10.0fc N_obs
		scatter pscore_mean  N_obs if N_neighbors<=50, ///
			connect(1)  lc(navy) mcolor(navy)    ms(oh)  lp(dash)  ///
			graphregion(color(white)) xsize(10) ysize(5) 			///
			xline(3320 ,   lc(gs6) lp(dash)) xlabel(0(500)4000, angle(90)) ///
			ylabel($pct_up_25, angle(0)) ///
			xtitle("Population expansion program estimation") ///
			ytitle("Average propensity score")
		graph export "${path_overleaf}/02-Figures/IE02-score.pdf", replace as(pdf)
		
	}
	.

	* Density plot
	{
		 
		use "${path_project}/data/03-final/Matching_data", clear
 
		
		tw	(kdensity pscore [aw=_weight] if D_expansion_program ==0 				  , 	color(	  navy%99  ) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==1  , 	color(dkorange%30) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==5  , 	color(dkorange%35) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==10  , 	color(dkorange%40) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==20  , 	color(dkorange%45) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==25  , 	color(dkorange%50) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==33  , 	color(dkorange%99) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==35  , 	color(dkorange%50) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==40  , 	color(dkorange%45) ) ///
		|| 	(kdensity pscore [aw=_weight] if D_expansion_program ==1 & N_neighbors==50  , 	color(dkorange%40) ) ///
 		, legend(order( 1 "Treated" 7 "Control NN-33")   ring(0) pos(3) col(1))  ///
		graphregion(color(white)) xsize(10) ysize(5) 
		
		graph export "${path_overleaf}/02-Figures/IE03-densities_treat_vs_control.pdf", replace as(pdf)
		
	}
}
.


local size_NN_limit  "32(1)33"
foreach variable in  turnover_r  employees productivity_r closed_definitely  log_empl log_prod log_turn log_wage  {	
	forvalues  size = `size_NN_limit' {
		
		
*local variable  turnover_r
*local size 33		
		
		use fuid pscore _weight D_expansion_program  N_neighbors _nn using ///
				"${path_project}/data/03-final/Matching_data", clear

		keep if N_neighbors==`size' | D_expansion_program==0

		merge 1:m fuid using "${path_project}/output/01-tempfiles/data_to_psm", keep(3) nogen
		keep  if period >= 2015
		
		xtset fuid period

		tab period  D_expansion_program
		 
		
			xtreg 	`variable'  after_kcgf i.period  [aw = _weight] if period >= 2015 , fe cluster(fuid)
			eststo	 model 
			 
			local  ATT_`size' 		 	= el(r(table),1,1)
			local  ATT_se_`size' 		= el(r(table),2,1)
			local  lowerbound_`size' 	= el(r(table),5,1)
			local  upperbound_`size'   	= el(r(table),6,1)
			qui su 		`variable' 										if D_expansion_program == 1 & period == 2015 [aw = _weight], detail
	
	*di as white 344				
			* N firms
			qui count if D_expansion_program == 1 & period == 2015 
			local   N_obs_C_`size'  		= r(N)
			qui count if D_expansion_program == 0 & period == 2015 
			local   N_obs_T_`size'  		= r(N)

			
			qui su 		`variable' 										if D_expansion_program == 1  & period  ==  2015 [aw = _weight], detail
 			local   avg_YC_pre_`size'			= r(mean)
			qui su 		`variable' 										if D_expansion_program == 0  & period ==  2015 [aw = _weight], detail			
 			local   avg_YT_pre_`size'			= r(mean)
			
			qui su 		`variable' 										if D_expansion_program == 1 & period  >  2015 [aw = _weight], detail
 			local   avg_YC_post_`size'			= r(mean)
			qui su 		`variable' 										if D_expansion_program == 0  & period >   2015 [aw = _weight], detail			
 			local   avg_YT_post_`size'			= r(mean)
 	*di as white 346		
			local 	effect_`size'			   = `ATT_`size''/`avg_YC_pre_`size''
	*di as white 348

	}
	.
	di as white "Parte 1"
	clear 
	set obs 50
	gen variable 		= "`variable'"
	gen nn 				= _n
	gen att				= .
	gen att_se			= .
	gen att_lower		= .	
	gen att_upper		= .	
	gen N_obs			= .
	gen N_obs_T			= .
	gen N_obs_C			= .
	gen avg_YT_pre 			= .  
	gen avg_YC_pre			= .
	gen avg_YT_post			= .  
	gen avg_YC_post			= .
	gen avg_att_effect  = .

	forvalues  size = `size_NN_limit' {
		di as white `size'
		
		replace att				=  `ATT_`size'' 		if _n==`size'
		replace att_se			=  `ATT_se_`size''		if _n==`size'
		replace att_lower		=  `lowerbound_`size'' 	if _n==`size'
		replace att_upper		=  `upperbound_`size''  if _n==`size'
		replace avg_att_effect  =  `effect_`size''		if _n==`size'
		di as white 380
		replace N_obs			= `N_obs_T_`size''+`N_obs_C_`size''	if _n==`size'
		replace N_obs_T			= `N_obs_T_`size''	if _n==`size'
		replace N_obs_C			= `N_obs_C_`size''	if _n==`size'
		replace avg_YT_pre		= `avg_YT_pre_`size''	if _n==`size'
		replace avg_YC_pre		= `avg_YC_pre_`size''	if _n==`size'
		replace avg_YT_post		= `avg_YT_post_`size''	if _n==`size'
		replace avg_YC_post		= `avg_YC_post_`size''	if _n==`size'		
		
		di as white 387
	}
	.
	 
	compress
	save "${path_project}/output/01-tempfiles/nn_match_outcome-`variable'", replace
}
.


clear
foreach variable in  turnover_r employees productivity_r closed_definitely  log_empl log_prod log_turn log_wage {	 	
	use   "${path_project}/output/01-tempfiles/nn_match_outcome-`variable'", clear

	set obs `=_N+1'
	replace att_upper =0 if _n==_N

	* graphs configuration
	global graph_year graphregion(color(white))   ///
				xlabel(1(1)50, angle(90)) ytitle("") ylabel( , angle(0) nogrid)  ///
				 plotregion(margin(large))  yline(0, lp(solid) lc(black%50)  )	  xsize(10) ysize(5)	

	tw  (rspike att_upper att_lower nn, msize(tiny) color(gs10)) ///
		(scatter att nn			, msize(tiny) color(gs4)) /// 
		, /// 
		$graph_year legend( ring(0) pos(1) )
	graph export "${path_overleaf}/02-Figures/Sample_expansion-`variable'.pdf", replace as(pdf)
}
.


clear
foreach var in   turnover_r  employees productivity_r log_wage {
	append using   "${path_project}/output/01-tempfiles/nn_match_outcome-`var'"
}
.
keep if nn==33
 
keep  variable N_obs 	att	att_se nn N_obs_T	N_obs_C avg_YC_pre avg_att_effect
order  N_obs 	att	att_se nn N_obs_T	N_obs_C avg_YC_pre avg_att_effect 
 
foreach var in att att_se avg_YC_pre {
	replace `var'=`var'/1000 if inlist(variable, "turnover_r", "productivity_r")
}
.

format %10.0fc N_obs	nn	N_obs_T	N_obs_C	
format %10.2fc att	att_se	avg_YC_pre	avg_att_effect

rename att att_avg
reshape long  att_, i(variable N_obs  nn N_obs_T	N_obs_C avg_YC_pre avg_att_effect) j(ATT) s
rename att_ att
order ATT variable N_obs  N_obs   att	att	  nn N_obs_T	N_obs_C avg_YC_pre avg_att_effect 

tostring N_obs	nn	N_obs_T	N_obs_C	 	   ,replace format(%10.0fc) force
tostring att	avg_YC_pre	avg_att_effect ,replace format(%10.2fc) force


tostring N_obs	att	nn	N_obs_T	N_obs_C	avg_YC_pre	avg_att_effect ,replace

foreach var of varlist * {
	di as white "`var'"
	replace `var' = "" if ATT=="se" & !inlist("`var'","att","ATT")
}

replace att= "(" +att + ")" if ATT=="se" 
replace ATT= "" if ATT=="se" 
 
 
	* Checking
gen label_var= ""
replace label_var= "Sales, in 2021 EUR (1000)"  		if variable =="turnover_r"     
replace label_var= "Number employees"  					if variable =="employees"
replace label_var= "Sales, in 2021 EUR (1000)/employee" if variable =="productivity_r"
replace label_var= "Log(Wages, in 2021 EUR (1000))"   	if variable =="log_wage"       

	local k=1 
	di " `=label_var[`k']' & `=N_obs[`k']' & `=att[`k']'   & `=N_obs_T[`k']' & `=N_obs_C[`k']' & `=avg_YC_pre[`k']' & `=avg_att_effect[`k']' \\"
	di " &                 &               & `=att[`k'+1]' & & & &    \\"

	* Open a new file called example.txt for writing, assign handle named myfile
	file open table using "${path_overleaf}/01-Tables/03-robust.tex", write text replace
		 
	file write table "\begin{table}[h!]" _n 
	file write table "\fontsize{8}{9}\selectfont" _n
	file write table "\resizebox{\textwidth}{!}{" _n
	file write table "\begin{tabular}{lcccccccc}" _n _n
  	file write table " & N obs & ATT & N Treat & N control & avg control pre & avg att effect  \\ " _n _n
	file write table "& & & & & & & \\"  _n 
 	file write table "\hline"  _n
	file write table "& & & & & & & \\"  _n 
	forvalues k = 1(2)7{
		di as white "`k'"
 		file write table " `=label_var[`k']' & `=N_obs[`k']' & `=att[`k']'   & `=N_obs_T[`k']' & `=N_obs_C[`k']' & `=avg_YC_pre[`k']' & `=avg_att_effect[`k']' \\"  _n
		file write table  "                  &               & `=att[`k'+1]' & & & &    \\" _n	
	}
	file write table "& & & & & & & \\"  _n 
	file write table "\hline "  _n
	file write table "\end{tabular} "  _n
	file write table "}"  _n
 	file write table "\caption{Robustness test - DiD with PSM `=nn[1]'} "  _n
	file write table "\end{table}"  

	* Close the file
	cap file close table 
	}
	.
  