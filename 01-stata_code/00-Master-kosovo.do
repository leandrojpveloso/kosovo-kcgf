* Made by Vivian Amorim and Leandro Veloso
* vivianamorim5@gmail.com/leandrojpveloso@gmail.com
* Last Update: 2024-03
*-------------------------------------------------------------------------------

* 1: Stata Setting
{
	* 1: Stata set definitions settings
	{
		set more off, permanently 
		graph set window fontface "Times"
		set scheme s1mono
		
		**Others
		set matsize 11000
		set level   95
		set seed    740592
		clear all
		mata: mata clear 
	}
	.

	* 2: Set this value to the user currently using this file
	{
		if "`c(username)'" == "vivia" { // Vivian
			 global projectfolder 		"C:\Users\vivia\OneDrive\DataWork"
			 global data		    	"$projectfolder\data"
			 global output        		"$projectfolder\output"
		}
		.

		if "`c(username)'" == "wb495845" { // Vivian
			global projectfolder 		"C:\Users\wb495845\OneDrive - WBG\IV. Firms\Kosovo\DataWork" 
			global data		    		"$projectfolder\data"
			global output        		"$projectfolder\output"
		}
		.
		
		if "`c(username)'" == "leand" 	{ // Leandro
			 global path_project 		"C:\Users\leand\Dropbox\3-Profissional\07-World BANK\05-CAIO\10-kosovo"
			 global path_overleaf       "C:\Users\leand\Dropbox\5-Aplicativos\01-Overleaf\02-kosovo-kcgf-2024"
			 
			 * Temp global
			 global data				"${path_project}/data"
		}
		.
	}
	.
 
	* 3: Packages requirements
	{
	   *ieboilstart, version(15)   
	   local user_commands   ///
		ietoolkit 	///
		rdrobust 	///
		ftools 		///
		jwdid 		///
		frause 		///
		hdfe 		///
		psmatch2 	///
		parmest		///
		gtools	
		
		* Install package if it does not exits
	   foreach command of local user_commands   {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command'
		   }
	   }		
	
	}
	.
	
	* 4: Folder structure
	{
		cap mkdir "${path_project}/output/01-tempfiles"
		cap mkdir "${path_project}/output/02-tables"
		cap mkdir "${path_project}/output/03-figures"
	}
	.	
}
.

* 2:     


* Notes --------------------------

* os logs não são deflacionados
* Turnover e produtividade são trimm por 5% upper and lower*.

* Operacoes de data perigosos na base do banco central. 
* Tax Payer and Businessid parece que nao leva em consideração o tamanho
* das strings
 