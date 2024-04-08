

										*TAX REGISTRY DATASET SHARED BY THE GOVERNMENT OF KOSOVO - > FORMAL FIRMS
	*__________________________________________________________________________________________________________________________________________*
	**
		

		*Importing Tax Registry
		*------------------------------------------------------------------------------------------------------------------------------------->>
		{
			/*
			**
			*
			import 	excel using "$data\raw\Tax Registry_2011-2021.xlsx", sheet(2018) clear allstring //Checking the consistence of 2018 data because the data came organized differently 
			drop in 1
				rename (B-IV) ( ///
				FISCAL_NO		TAX_PAYER_NO	NR	Y	MUNICIPALITYID	ENT_ACTIVITY_NO	ENT_ACTIVITY_CODE	ENT_ACTIVITY_DESC	DESCRIPTION_SECTORY	BORTH_YEAR	FramePeriod	TAX_PAYER_NO2	VITI	NumberOfEmployedPersons	TAX_PAYER_NO3	FORM_NO3	TPER_YEAR3	Salaries	TAX_PAYER_NO4	TPER_YEAR4	Turnover	TAX_PAYER_NO5	FORM_NO5	TPER_YEAR5	VAT_9	VAT_10	VAT_11	VAT_12	VAT_13	VAT_14	VAT_15	VAT_16	VAT_17	VAT_18	VAT_19	VAT_20	VAT_21	VAT_22	VAT_23	VAT_24	VAT_25	VAT_26	VAT_27	VAT_28	VAT_29	VAT_30	VAT_31	VAT_32	VAT_33	VAT_34	VAT_35	VAT_36	VAT_37	VAT_38	VAT_39	VAT_40	VAT_41	VAT_42	VAT_43	VAT_44	VAT_45	VAT_46	VAT_47	VAT_48	VAT_49	VAT_50	VAT_51	VAT_52	VAT_53	VAT_54	VAT_55	VAT_56	VAT_57	VAT_58	VAT_59	VAT_60	VAT_61	VAT_62	VAT_63	VAT_64	VAT_65	VAT_66	VAT_67	VAT_68	VAT_69	VAT_70	VAT_71	VAT_72	VAT_73	TAX_PAYER_NO6	FORM_NO6	TPER_YEAR6	PD_8	PD_9	PD_10	PD_11	PD_12	PD_13	PD_14	PD_15	PD_16	PD_17	PD_18	PD_19	PD_20	PD_21	PD_22	PD_23	PD_24	PD_25	PD_26	PD_27	PD_28	PD_29	PD_30	PD_31	PD_32	PD_33	PD_34	PD_35	PD_36	PD_37	PD_38	PD_39	PD_40	PD_41	PD_42	PD_43	PD_44	PD_45	PD_46	PD_47	PD_48	PD_49	PD_50	PD_51	PD_52	PD_53	PD_54	PD_55	PD_56	PD_57	PD_58	PD_59	PD_60	PD_61	PD_62	PD_63	PD_64	PD_65	PD_66	PD_67	PD_68	PD_69	PD_70	PD_71	PD_72	PD_73	PD_74	PD_75	PD_76	PD_77	PD_78	TAX_PAYER_NO7	FORM_NO7	TPER_YEAR7	CD_10	CD_11	CD_12	CD_13	CD_14	CD_15	CD_16	CD_17	CD_18	CD_19	CD_20	CD_21	CD_22	CD_23	CD_24	CD_25	CD_26	CD_27	CD_28	CD_29	CD_30	CD_31	CD_32	CD_33	CD_34	CD_35	CD_36	CD_37	CD_38	CD_39	CD_40	CD_41	CD_42	CD_43	CD_44	CD_45	CD_46	CD_47	CD_48	CD_49	CD_50	CD_51	CD_52	CD_53	CD_54	CD_55	CD_56	CD_57	CD_58	CD_59	CD_60	CD_61	CD_62	CD_63	CD_64	CD_65	CD_66	CD_67	CD_68	CD_69	CD_70	CD_71	CD_72	CD_73	CD_74	CD_75	CD_76	CD_77	CD_78	TAX_PAYER_NO8	FORM_NO8	TPER_YEAR8	IS_9	IS_10	IS_11	IS_12	TAX_PAYER_NO9	FORM_NO9	TPER_YEAR9	QS_8	QS_9	QS_10	QS_11	QS_12	QS_13	QS_14	QS_15	QS_16	QS_17) 
					
				drop 	TAX_PAYER_NO2   TAX_PAYER_NO3  TAX_PAYER_NO4  	TAX_PAYER_NO5  	TAX_PAYER_NO6   TAX_PAYER_NO7   TAX_PAYER_NO8  TAX_PAYER_NO9 				///
										FORM_NO3 						FORM_NO5 		FORM_NO6 		FORM_NO7 		FORM_NO8 	    FORM_NO9 					///
										TPER_YEAR3 	   TPER_YEAR4 		TPER_YEAR5 		TPER_YEAR6 		TPER_YEAR7 		TPER_YEAR8 		TPER_YEAR9  VITI FISCAL_NO A
				
			tempfile 2018
			save    `2018' 
			
			**
			*
			foreach year in 2011 2012 2013 2014 2015 2016 2017 2019 2020 2021  {
				import 	excel using "$data\raw\Tax Registry_2011-2021.xlsx", sheet(`year') clear allstring
				drop in 1
					if `year' < 2019 {
						rename  (B-ID) ///
								(TAX_PAYER_NO	NR	Y	MUNICIPALITYID	ENT_ACTIVITY_NO	ENT_ACTIVITY_CODE	ENT_ACTIVITY_DESC	DESCRIPTION_SECTORY BORTH_YEAR FramePeriod							NumberOfEmployedPersons	 										Turnover	 							Salaries	TPER_YEAR_vat							VAT_9	VAT_10	VAT_11	VAT_12	VAT_13	VAT_14	VAT_15	VAT_16	VAT_17	VAT_18	VAT_19	VAT_20	VAT_21	VAT_22	VAT_23	VAT_24	VAT_25	VAT_26	VAT_27	VAT_28	VAT_29	VAT_30	VAT_31	VAT_32	VAT_33	VAT_34	VAT_35	VAT_36	VAT_37	VAT_38	VAT_39	VAT_40	VAT_41	VAT_42	VAT_43	VAT_44	VAT_45	VAT_46	VAT_47	VAT_48	VAT_49	VAT_50	VAT_51	VAT_52	VAT_53	VAT_54	VAT_55	VAT_56	VAT_57	VAT_58	VAT_59	VAT_60	VAT_61	VAT_62	VAT_63	VAT_64	VAT_65	VAT_66	VAT_67	VAT_68	VAT_69	VAT_70	VAT_71	VAT_72	VAT_73	TPER_YEAR_PD							PD_8	PD_9	PD_10	PD_11	PD_12	PD_13	PD_14	PD_15	PD_16	PD_17	PD_18	PD_19	PD_20	PD_21	PD_22	PD_23	PD_24	PD_25	PD_26	PD_27	PD_28	PD_29	PD_30	PD_31	PD_32	PD_33	PD_34	PD_35	PD_36	PD_37	PD_38	PD_39	PD_40	PD_41	PD_42	PD_43	PD_44	PD_45	PD_46	PD_47	PD_48	PD_49	PD_50	PD_51	PD_52	PD_53	PD_54	PD_55	PD_56	PD_57	PD_58	PD_59	PD_60	PD_61	PD_62	PD_63	PD_64	PD_65	PD_66	PD_67	PD_68	PD_69	PD_70	PD_71	PD_72	PD_73	PD_74	PD_75	PD_76	PD_77	PD_78	TPER_YEAR_CD							CD_10	CD_11	CD_12	CD_13	CD_14	CD_15	CD_16	CD_17	CD_18	CD_19	CD_20	CD_21	CD_22	CD_23	CD_24	CD_25	CD_26	CD_27	CD_28	CD_29	CD_30	CD_31	CD_32	CD_33	CD_34	CD_35	CD_36	CD_37	CD_38	CD_39	CD_40	CD_41	CD_42	CD_43	CD_44	CD_45	CD_46	CD_47	CD_48	CD_49	CD_50	CD_51	CD_52	CD_53	CD_54	CD_55	CD_56	CD_57	CD_58	CD_59	CD_60	CD_61	CD_62	CD_63	CD_64	CD_65	CD_66	CD_67	CD_68	CD_69	CD_70	CD_71	CD_72	CD_73	CD_74	CD_75	CD_76	CD_77	CD_78	TPER_YEAR_IS							IS_9	IS_10	IS_11	IS_12	TPER_YEAR_QS							QS_8	QS_9	QS_10	QS_11	QS_12	QS_13	QS_14	QS_15	QS_16	QS_17) 
					}
								
					if `year'> 2017 {
						rename  (B-IC)  ///
								(TAX_PAYER_NO	NR	Y	MUNICIPALITYID	ENT_ACTIVITY_NO	ENT_ACTIVITY_CODE	ENT_ACTIVITY_DESC	DESCRIPTION_SECTORY BORTH_YEAR FramePeriod 							NumberOfEmployedPersons	 										Salaries 	 							Turnover 											VAT_9	VAT_10	VAT_11	VAT_12	VAT_13	VAT_14	VAT_15	VAT_16	VAT_17	VAT_18	VAT_19	VAT_20	VAT_21	VAT_22	VAT_23	VAT_24	VAT_25	VAT_26	VAT_27	VAT_28	VAT_29	VAT_30	VAT_31	VAT_32	VAT_33	VAT_34	VAT_35	VAT_36	VAT_37	VAT_38	VAT_39	VAT_40	VAT_41	VAT_42	VAT_43	VAT_44	VAT_45	VAT_46	VAT_47	VAT_48	VAT_49	VAT_50	VAT_51	VAT_52	VAT_53	VAT_54	VAT_55	VAT_56	VAT_57	VAT_58	VAT_59	VAT_60	VAT_61	VAT_62	VAT_63	VAT_64	VAT_65	VAT_66	VAT_67	VAT_68	VAT_69	VAT_70	VAT_71	VAT_72	VAT_73	TPER_YEAR_PD							PD_8	PD_9	PD_10	PD_11	PD_12	PD_13	PD_14	PD_15	PD_16	PD_17	PD_18	PD_19	PD_20	PD_21	PD_22	PD_23	PD_24	PD_25	PD_26	PD_27	PD_28	PD_29	PD_30	PD_31	PD_32	PD_33	PD_34	PD_35	PD_36	PD_37	PD_38	PD_39	PD_40	PD_41	PD_42	PD_43	PD_44	PD_45	PD_46	PD_47	PD_48	PD_49	PD_50	PD_51	PD_52	PD_53	PD_54	PD_55	PD_56	PD_57	PD_58	PD_59	PD_60	PD_61	PD_62	PD_63	PD_64	PD_65	PD_66	PD_67	PD_68	PD_69	PD_70	PD_71	PD_72	PD_73	PD_74	PD_75	PD_76	PD_77	PD_78	TPER_YEAR_CD							CD_10	CD_11	CD_12	CD_13	CD_14	CD_15	CD_16	CD_17	CD_18	CD_19	CD_20	CD_21	CD_22	CD_23	CD_24	CD_25	CD_26	CD_27	CD_28	CD_29	CD_30	CD_31	CD_32	CD_33	CD_34	CD_35	CD_36	CD_37	CD_38	CD_39	CD_40	CD_41	CD_42	CD_43	CD_44	CD_45	CD_46	CD_47	CD_48	CD_49	CD_50	CD_51	CD_52	CD_53	CD_54	CD_55	CD_56	CD_57	CD_58	CD_59	CD_60	CD_61	CD_62	CD_63	CD_64	CD_65	CD_66	CD_67	CD_68	CD_69	CD_70	CD_71	CD_72	CD_73	CD_74	CD_75	CD_76	CD_77	CD_78	TPER_YEAR_IS							IS_9	IS_10	IS_11	IS_12	TPER_YEAR_QS							QS_8	QS_9	QS_10	QS_11	QS_12	QS_13	QS_14	QS_15	QS_16	QS_17) 
					}
				drop TPER_YEAR* A	
				local yeart = `year' - 1
				local yeart2= `year' - 2
				if `year' >  2011 & `year' != 2019	append using ``yeart''
				if `year' == 2019 				    append using ``yeart2''
				tempfile `year'
				save    ``year''
			}
			append using `2018'
			save "$data\inter\Tax Registry Raw.dta", replace
			*/
		}
	
	
		
		*Cleaning
		*------------------------------------------------------------------------------------------------------------------------------------->>
		{
		use "$data\inter\Tax Registry Raw.dta", clear

		
			**
			*Renaming, & variables that assume value equal to 0
			*---------------------------------------------------------------------------------------------------------------------------------->>
			{
			foreach var of varlist * {
				rename `var' `=strlower("`var'")'
			}
			tab 	frameperiod
			tab 	frameperiod if numberofemployedpersons == ""	//from 2011 to 2015 all information for employees is missing
						
			destring vat_11 numberofemployedpersons cd_74 vat_31  vat_33  vat_35  vat_37 borth_year frameperiod municipalityid salaries turnover, replace
			
			
			rename 	(vat_11 		numberofemployedpersons cd_74			   ) ///
					(exports_amount	employees				operational_profit ) 
			
			egen 	imports_amount = rowtotal(vat_31  vat_33  vat_35  vat_37), missing 				//firm purchases that are imported -guess does not include investment (Matias Belacin comment)
			
			gen 	declared0turnover   =       turnover == 0  										//identifying firms that do not report turnover
			replace turnover 	  		= . if  turnover == 0
			replace employees 			= . if employees == 0
			
			*---------------------------------------------------------------------->>
			*-------------------------------------->>
			replace employees 			= 1 if missing(employees) & y == "INDIVIDUAL"				//before 2015, the variable number of employees is missing
			*-------------------------------------->>
			
			egen 	 sectorid = group(description_sectory)
			destring ent_activity_no, replace
			}
			
			
			**
			*Size, in terms of number of employees 
			*---------------------------------------------------------------------------------------------------------------------------------->>
			{
			gen		size 			= .
			replace size 			= 1 if employees <  10 
			replace size 			= 2 if employees >= 10  & employees 		< 50
			replace size 			= 3 if employees >= 50  & employees 		< 250
			replace size 			= 4 if employees >= 250 & !missing(employees)
			replace size			= 5 if missing(employees)
			label 	define size 1 "Micro (0-9)" 2 "Small (10-49)" 3 "Medium (50-249)" 4 "Large (250+)" 5 "No info"
			label 	values size size
			}
			
			
			**
			*Import or export firm 
			*---------------------------------------------------------------------------------------------------------------------------------->>
			{
			gen 	export_tx 		= exports_amount > 0 & exports_amount != .
			gen 	import_tx 		= imports_amount > 0 & imports_amount != .
			label 	define export_tx 1 "Export firm" 0 "No export firm"
			label 	define import_tx 1 "Import firm" 0 "No import firm"
			label	val export_tx export_tx
			label 	val import_tx import_tx
			rename  frameperiod period
			}
			
			
			**
			*Firms age
			*---------------------------------------------------------------------------------------------------------------------------------->>
			{
			gen 	error = borth_year > period								//firms birth year > period, it does not make sense. 
			bys 	tax_payer_no period: egen firstyearpanel = min(period)		
			replace borth_year = firstyearpanel 			if error == 1		//for when the previous error happens, lets consider the birth year the first year of the firm in the panel. 
			gen 	firms_age = period - borth_year
			drop	firstyearpanel error
			}

			
			**
			*Serbian maiority
			*---------------------------------------------------------------------------------------------------------------------------------->>
			{
			gen 		 ethnicity = 0 
			foreach 	 munid in 12 14 23 28 29 34 35 36 37 3 {
				replace  ethnicity = 1 if municipalityid == `munid'
			}
			label define ethnicity 0 "Non-Serbian majority" 1 "Serbian majority"
			label values ethnicity ethnicity		
			}

						
			*Outliers
			*---------------------------------------------------------------------------------------------------------------------------------->>
			{
			sort 	 tax_payer_no period
				
				forvalues period 	  = 2011(1)2021 {
					foreach size in 1 2 3 4 5  	    {
						di as red "period " `period' " and " " `size'" 
						 su     turnover				if size == `size' & period == `period', detail
						 replace turnover	 = . 		if size == `size' & period == `period' & (turnover 		 <  r(p5) |  turnover 	 > r(p95))
						*replace turnover	 = . 		if size == `size' & period == `period' & (turnover 		 <= r(p1) |  turnover 	 >= r(p99))
					}
				}
				gen   productivity     = turnover/employees	//sales divided by number of employees
				forvalues period 	  = 2011(1)2021 {
					foreach size in 1 2 3 4 5  	    {
					 su 	  productivity				if size == `size' & period == `period', detail
					  replace productivity   = . 		if size == `size' & period == `period' & (productivity   <  r(p5) | productivity  > r(p95))
					 *replace productivity   = . 		if size == `size' & period == `period' & (productivity   <= r(p1) | productivity  >= r(p99))
					}
				}
			}		
					
			
			*Real values
			*--------------------------------------------------------------------------------------------------------------------------------->>
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
				forvalues 	period  = 2011(1)2021   {
					foreach var of varlist turnover salaries exports_amount imports_amount operational_profit productivity {
						if `period' == 2011 gen 	`var'_r = `var'/(`ppi`period''/100) if period == `period'
						if `period' != 2011 replace `var'_r = `var'/(`ppi`period''/100) if period == `period'
					}
				}
			}
			
			
			*Other
			*--------------------------------------------------------------------------------------------------------------------------------->>
			{
			gen 	ln_turnover 		= ln(turnover)
			gen 	ln_productivity		= ln(productivity)
			gen 	ln_employees		= ln(employees)
			
			format *amount*  salaries* turnover* ln* *_r productivity* *profit* %15.2fc
			order 		tax_payer_no period municipalityid nr y ent_activity_no ent_activity_code ent_activity_desc description_sectory sectorid ethnicity size
			duplicates  report tax_payer_no period
			drop ///
			 vat_* cd_* pd_* qs_* is_*
			}
			compress
			save 	"$data\inter\Updated Tax Registry.dta", replace			//this dataset only has tax payer id. 
		}
		
		
		*Recovering business id
		*------------------------------------------------------------------------------------------------------------------------------------->>
		{
			**
			/*
			
			To merge Tax Registry with KCGF data, we need to recover the business registration numbers. 
			KCGF data only has business registration and the tax registry we just treated above only has tax payer number. 
			The tax authority shared with me the correspondency between tax payer and business registration numbers. It is important to point out that:
				- The same tax payer can have several business registrations numbers (the same tax payer can have more than one business)
				- when applying for loans, as far as we understood, firms share their business registration number.
			
			*/

			*---------------------------------------------------------------------------------------------------------------------------------->>
			import 		excel using "$data\raw\Tax-payer & Business Numbers.xlsx", sheet("TaxPayer x BR") clear allstring firstrow			//correspondency between tax payer number and business registration number.
				replace  	businessid = trim(businessid)
				keep 		if	tax_payer_no != ""
				duplicates 	report
				duplicates 	drop
				duplicates  tag businessid, generate(newvar)		//businessid associated with distinct tax payer id. 
				sort 		businessid 
				br   		tax_payer_no businessid newvar
				drop 		if newvar != 0							//lets not keep any case in which one business registration is linked to more than one tax payer number
				bys			tax_payer_no: gen n_businessid= _N		//for each taxpayer number, how many business id are associated with it. 
				keep 		if n_businessid == 1					//lets keep the tax numbers that only have one business id associated with it. 
				tempfile	businessid
				save 	   `businessid'
				save 		"$data\inter\Tax Payer and Businessid.dta", replace
					
		}
				
				
				
				
				
				
				
				
				
				
				
				
				
				
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
				
				
				

			/*	
			use 	"$data\inter\Updated Tax Registry.dta" if period >= 2016, clear
				merge 	m:1 tax_payer_no using `businessid', keep(3) nogen
				
				order 	tax_payer_no businessid period
				
				keep 	tax_payer_no businessid period y ln_turnover ln_employees ln_productivity  declared0turnover
				
				rename (ln_turnover ln_employees ln_productivity) (a b c)
				
				tostring a b c, force replace
				
				gen  ln_turnover 		= substr(a, 1,3)
				gen  ln_employees 		= substr(b, 1,3)
				gen  ln_productivity 	= substr(c, 1,3)
				
				drop a b c 
				
				duplicates report  				period y ln_turnover ln_employees ln_productivity  declared0turnover
				
				duplicates tag  				period y ln_turnover ln_employees ln_productivity  declared0turnover, gen(tag)
			
				drop if tag == 0
				
				drop tax_payer_no tag
												
				compress
				save 	"$data\inter\Tax Registry & Business Registration.dta", replace
		}
	
		
					
			import excel "C:\Users\vivia\OneDrive\DataWork\data\raw\Tax-payer & Business Numbers.xlsx", sheet("Select tax_bb") firstrow clear 

				tostring*, force replace
				foreach var of varlist FISCAL_NO NR_ID-NRB10 { //
					preserve
					keep 	TAX_PAYER `var' 
					keep 	if  `var' != "" & TAX_PAYER != "" & TAX_PAYER != "." & `var' !=  "." 
					rename 		`var' businessid
					tempfile    A`var'
					save       `A`var''
					restore
				}
			
				clear
				foreach data in FISCAL_NO NR_ID NRB1 NRB2 NRB3 NRB5 NRB6 NRB7 NRB8 NRB9 NRB10 {
					append using `A`data''
				}			
				rename TAX_PAYER tax_payer_no
				duplicates 	report
				duplicates 	drop
				duplicates  tag businessid, generate(newvar)		//businessid associated with distinct tax payer id. 
				sort 		businessid 
				br   		tax_payer_no businessid newvar
				drop 		if newvar != 0							//lets not keep any case in which one business registration is linked to more than one tax payer number
				bys			tax_payer_no: gen n_businessid= _N		//for each taxpayer number, how many business id are associated with it. 
				*keep 		if n_businessid == 1					//lets keep the tax numbers that only have one business id associated with it. 

				save 		"$data\inter\Tax Payer and Businessid.dta", replace	
		
		
		
		
		