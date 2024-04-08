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