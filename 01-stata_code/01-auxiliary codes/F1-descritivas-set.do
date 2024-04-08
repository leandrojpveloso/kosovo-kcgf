* Made by Leandro Veloso
* Set of main measures in a long format
* stat list "sum mean sd p1 p5 p25 p50 p75 p95 p99 min max"

cap program drop set_descriptives
program define set_descriptives
	syntax varlist , data_save(string) 	[ , /*
	*/ set_stats(string) by(string)  ] 

	*use "${path_project}/2_data/02_clean/01-SCR_data_clean",clear
	
	*gen normal_dist = rnormal(7.6, 42)
	*gen exp_dist    = rexponential(7.6 )
	
	*local varlist normal_dist exp_dist loan_amount_granted loan_amount_outstanding borrower_industry  D_rct_treat
	*local by fin_inst_type D_rct_treat
	*local set_stats "count"
	*local set_stats "mean sd"
	*local set_stats  "full"
	
 
	* Padrao"
	if !inlist("`set_stats'", "","count","full") { 
		local set_stats "`set_stats'"
	} 
	else if inlist("`set_stats'","", "full") { 
		local set_stats "sum mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99 min max"
	}  
	else {
	    local set_stats ""
	}
			
	di as white "`set_stats'"

	* Saving a tempdata
	di as white "1"
	tempfile   data_source
	save 	  `data_source'	
	
	* Reading data
	di as white "2"
	* Getting varlist to avoid problem with by
	if "`by'" != "" {
		keep `varlist' `by'
		drop `by'

		local list_variables ""
		foreach var of varlist * {
			local list_variables "`list_variables' `var'"
		}
	}
	else {
	   local list_variables "`varlist'" 
	}
	.
	
	* Reading data
	use   `data_source'	,clear
	keep `list_variables' `by'
	
	di as white "`list_variables'"
	di as white "`by'"
	
	* auxiliar variable to merge
	gen byte aux_variable_merge =0
	
	* Summarizing	
	{ 
		* Garantindo tamanho dos nomes
		foreach var of varlist `list_variables' {
			qui rename `var' `=substr("`var'",1,27)'
		}
		.

		* Ajuste para numero de missing e valores unicos
		foreach var of varlist `list_variables' {
 				* di as white "	`var'"
				gen double  nesimo 	= _n
				cap confirm  string var `var'
				if _rc == 0 {
					bys `var' : gen aux =  nesimo[1] if `var' !=""
				}
				else {
					bys `var' : gen aux =  nesimo[1] if `var' !=.
				}	
				
				gegen Un_`var' 	= nunique(aux) if aux!=.
				drop aux nesimo		
		}
		.

		* measures 
		foreach var of varlist `list_variables'{
			cap confirm  string var `var'
			if _rc == 0 {
				rename `var' aux_string
				gen `var' = length(aux_string)
				drop aux_string
			}
		}	
		.

		* variavel local para auxiliar no collapse
		local count		="(count) "
		local sum		="(sum)   " 
		local mean		="(mean)  " 
		local sd		="(sd)    " 
 		local p1  		="(p1)  " 
		local p5  		="(p5)  "  
		local p10  		="(p10) "
		local p25  		="(p25) "
		local p50  		="(p50) "  
		local p75 		="(p75) "
		local p90 		="(p90) "
		local p95 		="(p95) "
		local p99 		="(p99) "
		local min 		="(min) "
		local max 		="(max) "

		foreach var of varlist `list_variables' {
			local count 	"`count' N`var'=`var'"
			local sum  		"`sum'  sum`var'=`var' "
			local mean 		"`mean' mean`var'=`var' "
			local sd  		"`sd'  sd`var'=`var' "
			local p1  		"`p1'  p1`var'=`var' "
			local p5  		"`p5'  p5`var'=`var' "
			local p10 		"`p10' p10`var'=`var' "
			local p25  		"`p25' p25`var'=`var' "
			local p50  		"`p50' p50`var'=`var' "
			local p75 		"`p75' p75`var'=`var' "
			local p90 		"`p90' p90`var'=`var' "
			local p95 		"`p95' p95`var'=`var' "
			local p99 		"`p99' p99`var'=`var' "
			local min 		"`min' min`var'=`var' "
			local max 		"`max' max`var'=`var' "
		}
		.

		*des aux_variable_merge `by'
		*di as white "gcollapse `count', by(aux_variable_merge `by')"
		*gcollapse `count', by(aux_variable_merge `by')
		
		* collapsing
		foreach measures in  count `set_stats' {
  			preserve
				gcollapse ``measures'' (max)  Un_* , by(aux_variable_merge `by') freq(GNobs)
				tempfile data`measures'
				save `data`measures''
			restore
		}
		.
			
		* joing
		keep aux_variable_merge `by'
		bys aux_variable_merge `by': keep if _n==1
		foreach measures in count `set_stats' {
			merge 1:1 aux_variable_merge `by' using `data`measures'', nogen
		}
		.

		*reorders
		reshape long  N `set_stats'  Un_ , i(aux_variable_merge GNobs `by') j(variable) s
 	
		rename Un_ 		Nuniquevalue
	
		if "`set_stats'"!= "" {
			format %16.2fc `set_stats'
		}
		
		format %16.0fc N Nuniquevalue

		* Ordering
		order variable  N   Nuniquevalue `set_stats'
		rename N N_non_missing

		tempfile summary_data
		save 	`summary_data'
	}
	.	
	
	di as white "3"
	* Assing label
	{
		use  `data_source' ,clear
		

		count
		local N_obs = r(N)
		des, clear replace
		gen N = `N_obs'

		 
		* format variable
		drop format
		gen 	format = "string"  if isnumeric==0
		replace format = "numeric" if isnumeric==1				
		
		keep name format varlab N
		rename name variable
		gen original_order = _n

		merge 1:m  variable using `summary_data', nogen   keep( 2 3)
	}
	.
	
	* Saving 
	{
	    order 	variable `by'  varlab format N GNobs N_non_missing Nuniquevalue ///
			    `set_stats'

		sort original_order `by'  
		drop   original_order 
		
		if "`by'" =="" {
		    drop  GNobs
		}
		else {
		    rename  GNobs N_by_group
		}
		
		
 		drop aux_variable_merge
		
		
		qui count if  Nuniquevalue!=. 
		if r(N) ==0 drop Nuniquevalue
 
	}
	.
 
end	
.

