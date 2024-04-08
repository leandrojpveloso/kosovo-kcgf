
* 01: Tables
{
  * Open content slide
    * Open a new file called example.txt for writing, assign handle named myfile
	file open myfile using "${path_overleaf}/01-Tables/01-statnumbers.tex", write text replace
	file write myfile "% Slide 1" _n

    * Slide 02: Tax Registry information
	{
		* Period 2018
		{
		    use "${path_project}/data/02-inter\Tax Registry.dta",clear
	
			tab period	
			keep if period==2018

			local taxN: di %10.1fc `= floor(r(N)/100)/10'
			* Write a line of text to the file
			file write myfile "\newcommand\taxA{38.8}" _n
			file write myfile "\newcommand\taxperiodA{2018}" _n
			
			* 
			sum turnover if period==2018 & turnover>0, detail
			
			* Write a line of text to the file
			file write myfile "\newcommand\taxB{`=floor(r(p50)/1000)'}" _n
			
			count if inlist(turnover,0,.)
			di as white `=floor(100*r(N)/_N)'
			file write myfile "\newcommand\taxC{`=floor(100*r(N)/_N)'}" _n
			
			count if inlist(employees,1)
			di as white `=floor(100*r(N)/_N)'
			file write myfile "\newcommand\taxD{`=floor(100*r(N)/_N)'}" _n
			
			sum employees if period==2018 & employees>0, detail
			di as white `=floor(100*r(N)/_N)'
			file write myfile "\newcommand\taxE{`=floor(r(p50))'}" _n
			
			count if inlist(employees,0,.)
			di as white `=floor(100*r(N)/_N)'
			file write myfile "\newcommand\taxF{`=floor(100*r(N)/_N)'}" _n
		}
		.
		
		* Notes from full panel 
		{
			use "${path_project}/data/02-inter\Tax Registry.dta",clear
			count if inlist(operational_profit,0,.)
			di as white `=floor(100*(1-r(N)/_N))'
			file write myfile "\newcommand\taxG{`=floor(100*(1-r(N)/_N))'}" _n
			
			* Checking 
			sum period
			file write myfile "\newcommand\periodB{`=r(min)'}" _n
			file write myfile "\newcommand\periodC{`=r(max)'}" _n
		}
		
	}
	.
	
    * Slide 02: Central Bank
	{
	    use  "${path_project}/data/02-inter\Credit Registry.dta"		if period==2018			, clear
		
		* N loans
		di as white `=ceil(_N/1000)'
		file write myfile "\newcommand\credregA{`=ceil(_N/1000)'}" _n
		
		* N loans
		gunique fuid
		file write myfile "\newcommand\credregB{`=floor(r(unique)/100)/10'}" _n
		
		* Merge checking
		{
			use "${path_project}/data/02-inter\Tax Registry.dta",clear
			
			keep  fuid period
			gsort fuid -period
			by fuid: keep if _n==1
			tempfile data_check
			save `data_check'
			
			* 
			use "$data\inter\Credit Registry.dta"		if period==2018			, clear
			
			keep fuid
			duplicates drop fuid, force
			local N_credit_2018 = _N
			merge 1:1 fuid using `data_check'
			
			tab period _merge,m
			
			count if _merge==3 & period==2018
			local total_merge = `N_credit_2018'-r(N)
			di as white   `total_merge'/1000
			file write myfile "\newcommand\credregC{`=floor(`total_merge'/100)/10'}" _n
			file write myfile "\newcommand\credregD{99}" _n  _n  _n	
		}
		. 
	}
	.
	
	*  File closing
	file write myfile "% Slide 2-content" _n 

	* Close the file
	file close myfile
}
.

* 00: Setting stata
{
	* Open a new file called example.txt for writing, assign handle named myfile
	file open myfile using "${path_overleaf}/01-Tables/01-statnumbers.tex", write text append
	file write myfile "% Slide 2" _n
	
	* Close the file
	file close myfile
}

* 02: Graphs
{
    * Graph global setting
    {
    		global color_sme_1  "dkgreen%90"
			global color_sme_2  "dkorange%90"
			global color_sme_3  "lavender%90"
			global color_sme_4	"ebblue%90"
			global color_sme_7	"ebklue%90"
			
			global color_primary	"bluishgray%90"
			global color_secondary	"maroon%90"
			global color_tertiary	"navy%90"
			global color_quaternary	"emerald%90"		 
			
			global style_sme_1 "connect(1)  lc(${color_sme_1}) mcolor(${color_sme_1}) ms(oh)  lp(dash) " 
			global style_sme_2 "connect(1)  lc(${color_sme_2}) mcolor(${color_sme_2}) ms(oh)  lp(dash)"
			global style_sme_3 "connect(1)  lc(${color_sme_3}) mcolor(${color_sme_3}) ms(oh)  lp(dash)"
			global style_sme_4 "connect(1)  lc(${color_sme_4}) mcolor(${color_sme_4}) ms(oh)  lp(dash)"
			global style_sme_7 "connect(1)  lc(${color_sme_4}) mcolor(${color_sme_4}) ms(oh)  lp(dash)"
			
			global  pct_up_10  `"0 "0%" .025 "2.5%" .05 "5%" .075 "7.5%" 0.1 "10%""'
			global  pct_up_100 `"0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
			global  pctfrom_50_up_100  `".5 "50%" .6 "60%" .7 "70%" .8 "80%" .9 "90%" 1 "100%" "'
			 
			 * graphs configuration
			global graph_year graphregion(color(white))   ///
				xlabel(2010(1)2018, angle(90)) ytitle("") ylabel( , angle(0) nogrid)  ///
				 plotregion(margin(large))  yline(0, lp(solid) lc(black%50)  )	  xsize(10) ysize(5)		
	}	
	.
	
	
    * S3-scatter graph 
    {
		use "${path_project}/data/03-final\firm_year_level.dta" if  active == 1 & group_sme != 5 & turnover_r_all != 0, clear
		
		foreach i of numlist 1/4 {
		   gen byte D_sme_`i' = group_sme==`i'
		}
		gen byte D_sme_7 = inlist(group_sme,3,4)
		
		gcollapse (mean)  D_sme_* , by(period)

		* Writting number
		{
		* Open a new file called example.txt for writing, assign handle named myfile
			file open myfile using "${path_overleaf}/01-Tables/01-statnumbers.tex", write text append

		* Rate SME
			local loc_sme_small = `= ceil(D_sme_1[_N]*100)'
			di as white `loc_sme_small'
			file write myfile "% Slide 3" _n
			file write myfile "\newcommand\SCtaxA{`loc_sme_small'\%}" _n

		* Rate SME increate
			local loc_sme_micro_grouth =  abs(ceil((D_sme_1[_N]-D_sme_1[1])*1000)/10)
			di as white `loc_sme_micro_grouth'
			file write myfile "\newcommand\SCtaxB{`loc_sme_small_grouth'\%}" _n

		* Rate SME increate
			local loc_sme_small_grouth =  abs(ceil((D_sme_2[_N]-D_sme_2[1])*1000)/10)
			di as white `loc_sme_small_grouth'
			file write myfile "\newcommand\SCtaxC{`loc_sme_small_grouth'\%}" _n

		* Rate SME increate
			local loc_sme_medlar_grouth = abs(ceil((D_sme_7[_N]-D_sme_7[1])*1000)/10)
			di as white `loc_sme_medlar_grouth'
			file write myfile "\newcommand\SCtaxD{`loc_sme_medlar_grouth'\%}" _n

		* Close the file
			cap file close myfile
			
		}

		{
			* Graph 01: 1/N_bidders
			format %15.3fc D_sme_*

			* Graph All class	
			cap drop mlab_percent_*
			foreach var in sme_1 sme_2 sme_3 sme_4 sme_7 {
				gen mlab_percent_`var' = string(floor(D_`var'*10000)/100) + "%"
			}
			. 

			
			tw ///
				///  (scatter D_sme_1  period  , ${style_sme_1}  	) 		 ///
				|| (scatter D_sme_2  period  , ${style_sme_2} mlabc($color_sme_2) mlab(mlab_percent_sme_2) mlabsize(Huge) mlabp(1 ) ) ///
				|| (scatter D_sme_7  period  , ${style_sme_7} mlabc($color_sme_7) mlab(mlab_percent_sme_7) mlabsize(Huge) mlabp(1 ) ) /// 
				, ${graph_year}  legend(order(1 "Small" 2 "Medium/Large" ) col(2) ring(0) pos(5) ) ///
				ylab(${pct_up_10}) xtitle("Year Tax Registry")
				
			graph export "${path_overleaf}/02-Figures/S3.pdf", replace as(pdf)
		}
		.
	}
	.
	
	* S4-Bar graph: The majority of the firms are in the tertiary sector
	{ 
		* use "https://github.com/worldbank/stata-visual-library/raw/master/Library/data/bar-better.dta" , clear
		use "${path_project}/data/03-final\firm_year_level.dta" if active == 1 & inlist(period, 2018) & turnover_r_all != 0, clear
		drop if group_sme==5
		
		
		gen D_primary		= sec_activityid==1
		gen D_secondary		= sec_activityid==2
		gen D_tertiary		= sec_activityid==3
		gen D_quaternary	= sec_activityid==4
		
		* redefining sme group
			replace group_sme = 3 if group_sme == 4
			label define group_sme 1 "Micro" 2 "Small" 3 "Medium/Large", replace
			label val group_sme group_sme
	 
	   global  pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
		 
		* Graph bar
		graph  bar (mean) D_tertiary D_secondary D_quaternary D_primary    , blabel(bar , format(%15.3fc))    ///
				 over(group_sme ) $graph_opts ///
				 plotregion(margin(medlarge)) ytitle("Proportion condition to size") ///
				 legend(order(4 "Primary" 2 "Secondary" 1 "Tertiary" 3 "Quaternary") col(4) ring(0) pos(12) ) ///
				 bar(1, color(${color_tertiary}  ))  bar(2, color(${color_secondary})) ///
				 bar(3, color(${color_quaternary}))  bar(4, color(${color_primary})) ///
				 ylab(${pct}) 
		graph export "${path_overleaf}/02-Figures/S4.pdf", replace as(pdf)
	}
	.
	
	* S5-Scatter plot : Proportion size class by great industry
	{
		use 	"${path_project}/data/03-final\firm_year_level.dta" , clear
		keep if inlist(group_sme,1,2,3,4)
 
		replace group_sme = 7 if inlist(group_sme,3,4)
		
		collapse (mean) has_loan, by(period group_sme)		    
		
 
		{
			* Graph 01: 1/N_bidders
			format %15.3fc has_loan

			* Graph All class	
			cap drop mlab_percent_*
			foreach k in 1 2 3 7 {
				gen mlab_percent_sme_`k' = string(floor(has_loan*10000)/100) + "%" if group_sme==`k'
			}
			.  
			
			tw ///
				   (scatter has_loan  period  if group_sme==1, ${style_sme_1} mlabc($color_sme_1) mlab(mlab_percent_sme_1) mlabsize(Huge) mlabp(1 ) ) 		 ///
				|| (scatter has_loan  period  if group_sme==2, ${style_sme_2} mlabc($color_sme_2) mlab(mlab_percent_sme_2) mlabsize(Huge) mlabp(1 ) ) ///
				|| (scatter has_loan  period  if group_sme==7, ${style_sme_7} mlabc($color_sme_7) mlab(mlab_percent_sme_7) mlabsize(Huge) mlabp(1 ) ) /// 
				, ${graph_year}  legend(order(1 "Micro" 2 "Small" 3 "Medium/Large" ) col(3) ring(0) pos(5) ) ///
				ylab(${pct_up_100}) xtitle("Year Tax Registry") 
			graph export "${path_overleaf}/02-Figures/S5.pdf", replace as(pdf)
		}
		.
	}
	.
	
	* S6-Bar plot : Death rate 
	{
	    use "${path_project}/data/03-final\firm_year_level.dta", clear 
		
		xtset fuid period
		bys fuid (period): gen last_year=period[_N]
		bys fuid (period): gen last_year_turn_not_miss=turnover_r[_N]!=.
		
		gen has_information_2018  		=  last_year==2018
		gen has_information_2018_turn  	=  (last_year==2018) & last_year_turn_not_miss==1
		
		replace group_sme = 7 if inlist(group_sme,3,4)
		
		gcollapse (mean)  has_information_2018 , by(period group_sme)
		 
		gen mlab_has_information = string(floor(has_information_2018*10000)/100) + "%" 

		tw ///
			   (scatter has_information_2018  period  if group_sme==1, ${style_sme_1} mlabc($color_sme_1) mlab(mlab_has_information) mlabsize(Huge) mlabp(1 ) ) 		 ///
			|| (scatter has_information_2018  period  if group_sme==2, ${style_sme_2} mlabc($color_sme_2) mlab(mlab_has_information) mlabsize(Huge) mlabp(1 ) ) ///
			|| (scatter has_information_2018  period  if group_sme==7, ${style_sme_7} mlabc($color_sme_7) mlab(mlab_has_information) mlabsize(Huge) mlabp(1 ) ) /// 
			, ${graph_year}  legend(order(1 "Micro" 2 "Small" 3 "Medium/Large" ) col(3) ring(0) pos(5) ) ///
			ylab(${pctfrom_50_up_100}) xtitle("Year") ytitle("Probability of exist in 2018")  ///
			  xline(2015.25, lwidth(12) lp(solid) lc(black%10)  )	
			
		graph export "${path_overleaf}/02-Figures/S6.pdf", replace as(pdf)
	}
	.
	
	* S9*- Histogram: Anuual growth
}
.

* Tables
{
	{
		* use 	"$data\final\firm_year_level.dta" if active == 1 & period == 2018 & main_dataset == 1, clear	
		
		use 	"${path_project}/data/03-final\firm_year_level.dta" ///
			if active == 1 & period == 2018 & main_dataset == 1 , clear	

				
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
		replace turnover_r 				= turnover_r       /1000
		replace productivity_r 			= productivity_r   /1000
		replace wages_worker_r 			= wages_worker_r   /1000

		label   var employees  				"Number employees"
		label   var turnover_r  			"Sales, in 2021 EUR (1000)"
		label   var productivity_r  		"Sales (1000)/employee"
		label   var wages_worker_r  		"Wages, in 2021 EUR (1000)"
		label   var firms_age  				"Firms' age"
		label   var has_credit_history  	"Credit history"
		
		
		tab type_firm_panel if D_study_sample==1
		
		sum has_loan employees turnover_r productivity_r wages_worker_r firms_age has_credit_history
		 
		keep D_study_sample type_firm_panel  has_loan employees turnover_r productivity_r wages_worker_r firms_age has_credit_history ///
			 avgrowth_turnover_r avgrowth_productivity_r
		
		* Saving data
		compress
		save "${path_project}/output/01-tempfiles/aux_table1",replace
	}
	.
	
	* Histograqm
	foreach var of varlist avgrowth_turnover_r avgrowth_productivity_r { 
		use  "${path_project}/output/01-tempfiles/aux_table1" if D_study_sample==1 ,clear
		* local var avgrowth_turnover_r
		if "`var'" == "avgrowth_turnover_r" 	{
			local xtitle = "Annual growth sales"
			local color olive_teal
		}
		
		if "`var'" == "avgrowth_productivity_r" {
			local xtitle = "Annual growth sales per employee"
			local color orange*0.8
		}	
		
		sum `var' if inlist(type_firm_panel,0,1)
		local bin_hist_N 	= 50
		local bin_hist_width= (r(max)-r(min))/`bin_hist_N'
		local bin_hist_start= r(min)
		
		local bin_config "width(`bin_hist_width') start(`bin_hist_start')"
		di as white  "`bin_config'"
		
		tw  (histogram `var' if type_firm_panel == 0 , `bin_config' percent color(`color') fintensity(50)) ///
			(histogram `var' if type_firm_panel == 1 , `bin_config' percent fcolor(none) lcolor(black)),   ///
		legend(order(1 "Credit constrained firms" 2 "Firms with loans approved") pos(12) size(medium) cols(1) region(lwidth(white) lcolor(white) color(white) fcolor(white) )) 		 ///
		ytitle("% firms", size(large)) ylabel(, nogrid labsize(large) format(%12.0fc)) 						 ///
		xtitle("`xtitle'", size(medium)) xlabel(,labsize(small) format(%12.0fc)) 				 	 				 ///
		title("", pos(12) size(medsmall) color(black)) 														 ///
		subtitle("", pos(12) size(medsmall) color(black)) 													 ///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	 ///
		plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	 ///
		ysize(5) xsize(6) 																					 ///
		note("", color(black) fcolor(background) pos(7) size(small)) 
		graph export "${path_overleaf}/02-Figures/S9_`var'.pdf", replace as(pdf)
	}
	.		
			
	* Table	
	{
	    
		* All
			use "${path_project}/output/01-tempfiles/aux_table1",clear
			
			set_descriptives employees turnover_r productivity_r wages_worker_r firms_age has_credit_history, ///
				data_save("XXX")
		
			* exporting to excel
				export excel using "${path_project}/output/02-tables/P04-table-01-Firms_characteristics_2018_sme.xls", ///
					sheet("01-All")  firstrow(variables) replace		
			
		* Study sample
			use "${path_project}/output/01-tempfiles/aux_table1",clear
			keep  if D_study_sample==1
			
			set_descriptives employees turnover_r productivity_r wages_worker_r firms_age has_credit_history, ///
				data_save("XXX")
		
			* exporting to excel
				export excel using "${path_project}/output/02-tables/P04-table-01-Firms_characteristics_2018_sme.xls", ///
					sheet("02-sample_study")  firstrow(variables) sheetmodify
					
		* Study sample & Firm without loan aproved in 2010-2018
			use "${path_project}/output/01-tempfiles/aux_table1",clear
			keep  if D_study_sample==1 &  type_firm_panel == 0
			
			set_descriptives employees turnover_r productivity_r wages_worker_r firms_age has_credit_history, ///
				data_save("XXX")
		
			* exporting to excel
				export excel using "${path_project}/output/02-tables/P04-table-01-Firms_characteristics_2018_sme.xls", ///
					sheet("03-without_loan_2010-2018")  firstrow(variables) sheetmodify
		
		* Study sample & Firm with    loan aproved in 2018
			use "${path_project}/output/01-tempfiles/aux_table1",clear
			keep  if  D_study_sample==1 &  (type_firm_panel == 1 & has_loan == 1)
			
			set_descriptives employees turnover_r productivity_r wages_worker_r firms_age has_credit_history, ///
				data_save("XXX")
		
			* exporting to excel
				export excel using "${path_project}/output/02-tables/P04-table-01-Firms_characteristics_2018_sme.xls", ///
					sheet("04-loan_2018")  firstrow(variables) sheetmodify
	}  
	.	
	
	* Wrtting table
	{
	    		
		* Right side
			use "${path_project}/output/01-tempfiles/aux_table1",clear
			keep  if  D_study_sample==1 &  (type_firm_panel == 1 & has_loan == 1)

			set_descriptives employees turnover_r productivity_r wages_worker_r firms_age has_credit_history, ///
			data_save("XXX")
			
			keep  N_non_missing variable mean sd p5 p50  p95
			gen correct_order =_n
			
			rename * *_1
			rename variable_1 variable
					tempfile  data_aux
			save	 `data_aux'
		
		* Left side
			use "${path_project}/output/01-tempfiles/aux_table1",clear
			keep  if D_study_sample==1 &  type_firm_panel == 0
			
			set_descriptives employees turnover_r productivity_r wages_worker_r firms_age has_credit_history, ///
				data_save("XXX")
			
			keep  N_non_missing variable varlab mean sd p5 p50 p95
						
			rename * *_0
			rename variable_0 variable
 
			merge 1:1 variable using  `data_aux'		
			
 

		* Preparing
		sort correct_order
			di as white `=mean_0[1]'
			
		rename p50* median*
		local center 	"mean"
		local disp  	"sd"
		local inf	  	"p5"
		local sup	  	"p95"
		
		* local center 	"median"
		* local disp  	"sd"
		* local inf	  	"min"
		* local sup	  	"max"
		
		 
		rename `center'*  	center*
		rename `disp'*  	disp*
		rename `inf'*	  	inf*
		rename `sup'*	  	sup*
		
		* Stat according center measure choise
		{ 
		* Open a new file called example.txt for writing, assign handle named myfile
			file open myfile using "${path_overleaf}/01-Tables/01-statnumbers.tex", write text append

		* Rate SME
			local times_sales = `= floor(center_1[3]/center_0[3]*10)/10'
			di as white `times_sales'
			file write myfile "% Slide table 01" _n
 			file write myfile "\newcommand\tabA{`times_sales'\%}" _n
			
			local percent_prod = `= floor(center_1[4]/center_0[4]*100)'
			di as white `percent_prod'
			file write myfile "\newcommand\tabB{`percent_prod'}" _n	
		
			cap file close myfile 
		}
		
		tostring center* disp* inf* sup*, replace force format(%12.1fc)
		tostring N_non_missing_*, replace force format(%12.0fc)
		
		

*rename disp*  sd*
*rename p50*  center*
*rename min*  inf*
*rename max*  sup*
 
	* Checking
	local k 1
	di "				 &   `center' 	    &  `disp' 		 &        `inf'  &        `sup'  &    `center'    &  `disp' 	   &        `inf'  &        `sup'  \\"
	di "`=varlab_0[`k']' & `=center_0[`k']' & `=disp_0[`k']' & `=inf_0[`k']' & `=sup_0[`k']' & `=disp_1[`k']' & `=disp_1[`k']' & `=inf_1[`k']' & `=sup_1[`k']' \\"

 

	* Open a new file called example.txt for writing, assign handle named myfile
	file open table using "${path_overleaf}/01-Tables/02-table-Firm_char_2018.tex", write text replace
	
	file write table	  "% Slide 2" _n
	 
	file write table "\begin{table}[h!]" _n 
	file write table "\fontsize{8}{9}\selectfont" _n
	file write table "\resizebox{\textwidth}{!}{" _n
	file write table "\begin{tabular}{lcccccccc}" _n _n
 	file write table " & \multicolumn{ 4}{c}{{\it Credit constrained firms}} & \multicolumn{ 4}{c}{Firm with loan approved in 2018} \\ "  _n _n
 	file write table " & \multicolumn{ 4}{c}{Firms without loans 2010-2018} & \multicolumn{ 4}{c}{} \\ " _n _n
 	file write table " & `center' & `disp' & `inf' & `sup' & `center' & `disp' & `inf' & `sup' \\" _n _n
	file write table "\hline"  _n
	foreach k of numlist 1/6 {
		file write table "`=varlab_0[`k']' & `=center_0[`k']' & `=disp_0[`k']' & `=inf_0[`k']' & `=sup_0[`k']' & `=center_1[`k']' & `=disp_1[`k']' & `=inf_1[`k']' & `=sup_1[`k']' \\"  _n  _n
	}
	file write table "Num. firms & `=N_non_missing_0[1]' & & & & `=N_non_missing_1[1]' & & & \\"  _n 
	file write table "\hline "  _n
	file write table "\end{tabular} "  _n
	file write table "}"  _n
 	file write table "\caption{Firms' characteristics by access to credit, micro firms (2018)} "  _n
	file write table "\end{table}"  

	* Close the file
	cap file close table 
	}
	.

}
.


