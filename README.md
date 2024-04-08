# Avaliação dos Impactos do Kosovo Credit Guarantee Fund na Produtividade das Empresas

## Visão Geral do Projeto

### Kosovo Credit Guarantee Fund

The Kosovo Ministry of Trade and Industry, with the support of the US Agency for International Development, 
created the Kosovo Credit Guarantee Fund (KCGF). 

KCGF is a credit guarantee facility issuing portfolio loan guarantees to financial institutions to cover up to 50\% of the risk of loans to micro, small, and medium enterprises (MSMEs). 


KCGF aims to support the private sector by increasing access to finance by MSMEs, which might lead to job-creating, 
increase production, improve the trade balance, and enhance opportunities for under-served economic sectors.


  
The borrower benefits from potentially preferential interest rates, collateral reduction, and faster processing time 
for loan applications.  
The partner financial institutions have a reduction in credit risk, as well as capital relief and credit portfolio growth.  

KCGF eligibility
- Firms with less than 250 employees (MSMEs). 
- Private owned MSMEs. 
- At least 50\% owned by private citizens or permanent residents of Kosovo.
- Firms with business registration and fiscal numbers (formal firms).

- **Descrição**: Um fundo garantidor de crédito financiado pelo World Bank Group (WGB), destinado a proteger empresas e incentivar o crescimento econômico ao aumentar o acesso ao crédito.
- **Objetivo Principal**: Avaliar os impactos do fundo na produtividade das empresas, incluindo mudanças no turnover e na produtividade.
- **Perguntas de Pesquisa**:
  - O fundo está trazendo mais empresas para o mercado?
  - Quais características das empresas aumentam a probabilidade de serem incluídas no fundo?
  - Como o acesso ao crédito e a avaliação de crédito são afetados pelo fundo?

### Políticas Durante a COVID-19
- **Alterações no Fundo**: Implementação de políticas pré e durante a COVID-19, com cobertura de garantia aumentando de 50% para 80% entre 2020 e 2021.

## Desafios e Ferramentas

### Desorganização e Documentação
- **Desafios**: Desorganização no final do projeto, problemas com estimativas de programa.
- **Documentação**: Vários documentos armazenados no Overleaf, com uma nota sendo a mais organizada.

### Bases de Dados Principais
- **Banco Central**: Informações sobre empréstimos de empresas formais.
- **Tax Registration**: Dados financeiros, incluindo vendas e taxas.
- **Kosovo Credit Guarantee Fund**: Empresas beneficiadas com garantias, análise de produtividade.

### Problemas com as Bases de Dados
- **Inconsistências e Limitações**: Análise prejudicada pela falta de variáveis, dados e inconsistência nos Firm IDs devido a diferentes criptografias não unificadas. 
-  **Empréstimo baseado em trust:** Devido ao tamanho do país muito banco usa critério de confiança para empréstimo, o que difilculta a busca por características.

## Aprendizados e Desenvolvimentos

### Gestão de Dados
- **Recebimento de Dados**: Primeira base com Firm ID chegou no final do projeto. Esta foi uma**Contribuição de Lucio** que estava tentando estimar a TFP. Ele foi cuidadoso de pedir para instituições harmonizarem o processo de criptografia. 
- **Firm ID**: Composto por elementos da empresa e da pessoa. Diferenças nos registros de tax registration e no Banco Central.

### Contribuições Técnicas
- **Trabalho de Simon no GitHub**: Desenvolvimento de um modelo em Python para seleção de características de empréstimos, buscando variáveis relevantes.
- **Projeto da Vivi**: Duração de quase 2 anos, com foco em utilizar Machine Learning para a seleção de características.
- **Ideia para Blogpost**: Rascunho no Overleaf sobre o uso de Machine Learning na determinação de critérios para empréstimo.


# Tasks

E agora?

Estão tentando disseminar os resultados - High level.

Extrapolar o efeito out-of-sample.

Se expandirem esse programa, quantos empregos seriam criados. 

Tem uma análise que pode fazer - 

Se o banco quiser ser avesso a risco - Se eu continuar incluindo a taxa. 

Se tiver um propensity score - Quem ta fora do suporte comum.
- Sempre vai ter 

0.10 - 0.60
0.20 - 0.80

Vc tá sempre - para expandir!
 

Deadline - 8 de abril!
 
Tabela 1 - medida de vendas
N estranho

Recovery package - provavelmente

Inconsistencia

Rever machine learning

Estimar efeito


# Questions Leandro:

KCGF eligibility
- Firms with less than 250 employees (MSMEs). 
- Private owned MSMEs. 
- At least 50\% owned by private citizens or permanent residents of Kosovo.
- Firms with business registration and fiscal numbers (formal firms).


**Possiveis problemas**
> * os logs não são deflacionados
> * Turnover e produtividade são trimm por 5% upper and lower*.
> * Operacoes de data perigosos na base do banco central. 
> * Tax Payer and Businessid parece que nao leva em consideração o tamanho
> * das strings
 

# extra notes

the business id in 
Kosovo VAT number format
Businesses in Kosovo that are required to collect tax will be issued an identification number. Tax identification numbers can be verified with the Tax Administration of Kosovo (TAK), and will follow a certain format. The VAT number format is 1234567890


https://www.vatify.eu/kosovo-vat-number.html

kosovo open data
https://www.atk-ks.org/en/open-data/

# Tax registry main variables
	tax_payer_no
	period
	municipalityid
	nr
	y
	ent_activity_no
	ent_activity_code
	ent_activity_desc
	description_sectory
	sectorid
	ethnicity
	size
	borth_year
	employees
	salaries
	turnover
	exports_amount
	operational_profit
	imports_amount
	declared0turnover
	export_tx
	import_tx
	firms_age
	productivity

# Tax registry main variables
	tax_payer_no
	period
	municipalityid
	nr
	y
	ent_activity_no
	ent_activity_code
	ent_activity_desc
	description_sectory
	sectorid
	ethnicity
	size
	borth_year
	employees
	salaries
	turnover
	exports_amount
	operational_profit
	imports_amount
	declared0turnover
	export_tx
	import_tx
	firms_age
	productivity






*--------------------------------------------------------------------------------------------------------------------------------*
**
Description of the data shared
**
*--------------------------------------------------------------------------------------------------------------------------------*

*A*
______________________________________________________________________________________________________________________________

*FIRST PRELIMINARY ANALYSIS

Our first and preliminary analysis was done based on the files shared by our World Bank colleague Lucio Castro


	*DATA
	**-------------------------------------------->>
	Kosovo-KCGF -> DataWork -> data -> raw

	-- Tax Registry-2010-2018.csv
			File shared by Lucio. It has fuid (masked firm identification number). 
			It has data on firms' sale, employment, and other. 

	-- LoanApplications-2010-2018.xlsx 
			File shared by Lucio. It has fuid (masked firm identification number). 
			Loans from 2010-2018
			It has data on all the loans. 
			
	-- KCGF.xls
			File shared by KCGF with Vivian. It does not have the masked firm id. 
			We use this file to get some descriptive statistics of loans covered by the fud. 

	*CODES
	**-------------------------------------------->>
	Kosovo-KCGF -> DataWork -> codes- > First premilinary analysis
	
	We use the above mentioned datasets to compare 1) KCGF firms, 2) firms with loans approved but not covered by the fund, and 3) firms with no loans approved. 

	We aim to :

		- identify what are the factors that play an important role in the decision of the bank to include the firm in the fund.
		- the main characteristics of credit-constrained firms. 
		- compare the loan amount, interest rates and duration of kcgf and non-kcgf loans. 

*B*
______________________________________________________________________________________________________________________________

*FINAL ANALYSIS

Our final analysis was done based on the updated files shared by the Tax Authority, Central Bank and KCGF. 





tax
credit
2010-2018 

Update KCGF
2011-2021

trimmed 5% 95%

produtividade

trimmed 5% 99%

* Base: municipio +  setor + ano + Continua (turnover).

70%

Histograma comparando numero de empregados do filtro.

Empregado
Turnover
salaries
Turnover / empregado

Corrigir o que da para corrigir.

N consistente.

Reestimar o modelo. Impact evaluation.

Fazer a previsao.

Usar esse grupo como contrafactural e reestimar o impacto.

The current minimum wage in Kosovo is €264.00 per month in 2022. It became valid on April 14, 2022.

# Lista de tarefas para encerrar o Projeto

Slides: ML
> * Colocar os 4 modelos
> * Checar as 96 variaveis usadas
> * Checar o N dos modelos de MLP
> * Verificar se já incluí os outcomes defasados
> * 
> * 

Avaliação: 
> * Para avaliação vamos usar as features dos 4 modelos usados + outcomes defasados
> * 
> * Extra: Fazer modelo de MLP usando o notebook do curso NG para as features já selecionadas

> tabela:
> Tirar última coluna.
> Colocar o effect em nível.
> Emprego nível
> log  Sales, Wage, Turnover,Produtividade em

Emprego 
Sales
Wage
Sales


Slides: Ajustes slides 
> * Tirar slide 6
> * Tirar slide 6


Sobre a avaliação

> * Did com pontos estimados



Você pode inserir uma tabela com os pontos estimados do DiD, por favor? 
Na tabela você pode colocar os outcomes nas colunas e nas linhas o ATT, o SE em parênteses, o N, a média do grupo de controle, e o número de vizinhos usados na estimação. Esta tabela viria antes dos testes de robustez. 

 
Também precisamos inserir na nota da tabela qual modelo (1-4) foi usado para selecionar as covariadas usadas na estimação do pscore.



Kosovo notes

* Tirar slide 6

* Checar as 96 variavia

Tirar


Referente aos modelos de selecao de empresa.

O argumento que as empresas com historico de credito.

* Compensa parte dos riscos dos bancos.

*-> Variaveis:
* Histórico de crédito!
* Histórico de crédito!

* Garantir de bias! 
Slide 33

Refazer analise para models.


Revisitar o modelo de machine learning

1 modelo: 

