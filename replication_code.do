
* -------
* Replication Code
* -------
 

* TABLE 1
* -------
clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year<=2016

set matsize 11000 
bys block0246: outreg2 using table1_nahy_ret1day.xls, sum(detail) keep(ret1day) eqkeep(mean sd min max N) excel replace


clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year<=2016

set matsize 11000 
bys block0246: outreg2 using table1_nahy_ret1day.xls, sum(detail) keep(ret1day) eqkeep(mean sd min max N) excel replace


* TABLE 2
* -------

clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year<=2016

tsset date

eststo clear
eststo: qui reg ret1day block0246, robust
eststo: qui reg ret1day block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace 


clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year<=2016

tsset date

eststo clear
eststo: qui reg ret1day block0246, robust
eststo: qui reg ret1day block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace 

 
* TABLE 3
* -------

* (1) HY

clear
use fomc_cdxhy1

tsset date

eststo clear
eststo: qui reg ex1 block0246, robust
eststo: qui reg ex1 block0 block246, robust
esttab, stats(r2 N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace


rolling _b _se, window(60) saving(betas, replace) keep(date2): reg ret1day ex1, r

use betas, clear
twoway (line _b_ex1 end), title("Empirical Hedge Ratio on CDX NA HY") ytitle("") xtitle("Date") tlabel(, format(%dm-CY)) 
graph export fig_hedge_hy.png, replace

drop start date _se_ex1 _se_cons
rename end date2

merge 1:1 date2 using fomc_cdxhy1

drop if _merge !=3
gen pred_ret = ex1*_b_ex1
gen resi_ret = ret1day - pred_ret

save temp_hy, replace

use temp_hy, clear
eststo clear
eststo: qui reg pred_ret block0246, robust
eststo: qui reg pred_ret block0 block246, robust
eststo: qui reg resi_ret block0246, robust
eststo: qui reg resi_ret block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace


* (2) IG

clear
use fomc_cdxig2

tsset date

eststo clear
eststo: qui reg ex1 block0246, robust
eststo: qui reg ex1 block0 block246, robust
esttab, stats(r2 N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace


rolling _b _se, window(60) saving(betas, replace) keep(date2): reg ret1day ex1, r

use betas, clear
twoway (line _b_ex1 end), title("Empirical Hedge Ratio on CDX NA IG") ytitle("") xtitle("Date") tlabel(, format(%dm-CY)) 
graph export fig_hedge_ig.png, replace

drop start date _se_ex1 _se_cons
rename end date2

merge 1:1 date2 using fomc_cdxig2

drop if _merge !=3
gen pred_ret = ex1*_b_ex1
gen resi_ret = ret1day - pred_ret

save temp_ig, replace

use temp_ig, clear
eststo clear
eststo: qui reg pred_ret block0246, robust
eststo: qui reg pred_ret block0 block246, robust
eststo: qui reg resi_ret block0246, robust
eststo: qui reg resi_ret block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace
 

 

* TABLE 4
* -------

* (1) HY

use temp_hy, clear
drop _merge
rename date2 date
merge 1:1 date using sp500_otm_volatility

keep if _merge == 3
drop _merge

tset date

gen ivol = impl_volatility*100

eststo clear
eststo: qui reg resi_ret D.vixclose, beta
eststo: qui reg resi_ret D.ivol, beta
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace

* (2) IG

use temp_ig, clear
drop _merge
rename date2 date
merge 1:1 date using  sp500_otm_volatility

keep if _merge == 3
drop _merge

tset date

gen ivol = impl_volatility*100

eststo clear
eststo: qui reg resi_ret D.vixclose, beta
eststo: qui reg resi_ret D.ivol, beta
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace



* TABLE 5
* -------

clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994

g ret1day2 = .
replace ret1day2 = ret1day if block0246==1
replace ret1day2 = -1*ret1day if block0246~=1

g m1 = 1 + ret1day/100
g m2 = 1 + ret1day2/100

for any m1 m2 r: egen sX=sum(ln(X)), by(year)
for any m1 m2 r: egen sXeven=sum(ln(X)) if block0246==1, by(year)
for any m1 m2 r: egen sXodd=sum(ln(X)) if block0246~=1, by(year)
for any m1 m2 r: egen msXeven=max(sXeven), by(year)
for any m1 m2 r: egen msXodd=max(sXodd), by(year)

for any m1 m2: egen ssX=sum(ln(X))
for any m1 m2: egen ssXeven=sum(ln(X)) if block0246==1
for any m1 m2: egen ssXodd=sum(ln(X)) if block0246~=1
for any m1 m2: egen mssXeven=max(ssXeven)
for any m1 m2: egen mssXodd=max(ssXodd)

so year month day
ge A=exp(sm1)-exp(sr)
ge B=exp(msm1even)-exp(msreven)
ge C=exp(msm1odd)-exp(msrodd)
ge D=exp(sm2)-exp(sr)

ge AA=exp(ssm1)
ge BB=exp(mssm1even)
ge CC=exp(mssm1odd)
ge DD=exp(ssm2)

su A-D if year~=year[_n-1]
su AA-DD 


clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994

g ret1day2 = .
replace ret1day2 = ret1day if block0246==1
replace ret1day2 = -1*ret1day if block0246~=1

g m1 = 1 + ret1day/100
g m2 = 1 + ret1day2/100

for any m1 m2 r: egen sX=sum(ln(X)), by(year)
for any m1 m2 r: egen sXeven=sum(ln(X)) if block0246==1, by(year)
for any m1 m2 r: egen sXodd=sum(ln(X)) if block0246~=1, by(year)
for any m1 m2 r: egen msXeven=max(sXeven), by(year)
for any m1 m2 r: egen msXodd=max(sXodd), by(year)

for any m1 m2: egen ssX=sum(ln(X))
for any m1 m2: egen ssXeven=sum(ln(X)) if block0246==1
for any m1 m2: egen ssXodd=sum(ln(X)) if block0246~=1
for any m1 m2: egen mssXeven=max(ssXeven)
for any m1 m2: egen mssXodd=max(ssXodd)

so year month day
ge A=exp(sm1)-exp(sr)
ge B=exp(msm1even)-exp(msreven)
ge C=exp(msm1odd)-exp(msrodd)
ge D=exp(sm2)-exp(sr)
ge E = exp(sr)

ge AA=exp(ssm1)
ge BB=exp(mssm1even)
ge CC=exp(mssm1odd)
ge DD=exp(ssm2)

su A-E if year~=year[_n-1]
su AA-DD 




* TABLE 6
* -------

clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year <=2016

replace dr=0 if dr==.
ge dr5=max(dr[_n-1],dr[_n-2],dr[_n-3],dr[_n-4],dr[_n-5])
replace dr5=0 if dr5~=1

for num 0 2 4 6: ge blockXpost=blockX*dr5
ge block0246post=block0246*dr5
ge block0246nonpost=block0246*(dr5==0)
ge blockm1135post=(block0246==0)*dr5

eststo clear 
reg ret1day block0post block2post block4post block6post block0246nonpost blockm1135post if cycle<=33, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace
 



clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year <=2016

replace dr=0 if dr==.
ge dr5=max(dr[_n-1],dr[_n-2],dr[_n-3],dr[_n-4],dr[_n-5])
replace dr5=0 if dr5~=1

for num 0 2 4 6: ge blockXpost=blockX*dr5
ge block0246post=block0246*dr5
ge block0246nonpost=block0246*(dr5==0)
ge blockm1135post=(block0246==0)*dr5

eststo clear 
reg ret1day block0post block2post block4post block6post block0246nonpost blockm1135post if cycle<=33, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace
 


* TABLE 7
* -------


clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year <=2016
 
eststo clear
eststo: qui reg ret1day block0 block246 if panic1==1, r
eststo: qui reg ret1day block0 block246 if panic1~=1, r
eststo: qui reg ret1day block0 block246 if panic2==1, r
eststo: qui reg ret1day block0 block246 if panic3==1, r
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace


clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year <=2016
 
eststo clear
eststo: qui reg ret1day block0 block246 if panic1==1, r
eststo: qui reg ret1day block0 block246 if panic1~=1, r
eststo: qui reg ret1day block0 block246 if panic2==1, r
eststo: qui reg ret1day block0 block246 if panic3==1, r
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace




* TABLE 9
* -------
clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year<=2016

sort t

eststo clear
eststo: qui reg ret1day block0246 vixclose, robust
eststo: qui reg ret1day block0 block246 vixclose, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace


clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year<=2016

sort t

eststo clear
eststo: qui reg ret1day block0246 vixclose, robust
eststo: qui reg ret1day block0 block246 vixclose, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace




* TABLE 10
* -------
clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year<=2016

tsset t
drop s* x* panic1 panic2 panic3 
for num 5 22 65: tssmooth ma smX=X*diff1, w(X)
for num 5 22 65: ge sX=smX
for num 5 22 65: xtile xX=sX if cycle<=33 & year>=1994, nq(5)

ge panic1=x5==1
ge panic2=x5==1 & x22==1
ge panic3=x5==1 & x22==1 & x65==1

label variable s5 "5-day excess return, day t-5 to t-1"
label variable x5 "Quintiles of days based on last week's excess return"
label variable panic1 "Quintile 1 day, based on last week"
label variable panic2 "Quintile 1 day, based on last week and last month"
label variable panic3 "Quintile 1 day, based on last week, last month, and last 3 months"
 
eststo clear
eststo: qui reg ret1day block0 block246, r
eststo: qui reg ret1day block0 block246 if panic1==1, r
eststo: qui reg ret1day block0 block246 if panic1~=1, r
eststo: qui reg ret1day block0 block246 if panic2==1, r
eststo: qui reg ret1day block0 block246 if panic3==1, r
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace
 

clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year<=2016

tsset t
drop s* x* panic1 panic2 panic3 
for num 5 22 65: tssmooth ma smX=X*diff1, w(X)
for num 5 22 65: ge sX=smX
for num 5 22 65: xtile xX=sX if cycle<=33 & year>=1994, nq(5)

ge panic1=x5==1
ge panic2=x5==1 & x22==1
ge panic3=x5==1 & x22==1 & x65==1

label variable s5 "5-day excess return, day t-5 to t-1"
label variable x5 "Quintiles of days based on last week's excess return"
label variable panic1 "Quintile 1 day, based on last week"
label variable panic2 "Quintile 1 day, based on last week and last month"
label variable panic3 "Quintile 1 day, based on last week, last month, and last 3 months"
 
eststo clear
eststo: qui reg ret1day block0 block246, r
eststo: qui reg ret1day block0 block246 if panic1==1, r
eststo: qui reg ret1day block0 block246 if panic1~=1, r
eststo: qui reg ret1day block0 block246 if panic2==1, r
eststo: qui reg ret1day block0 block246 if panic3==1, r
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace
 





* TABLE 11
* -------
clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year <=2016

eststo clear
eststo: qui reg ret1day block0 block246, r
eststo: qui reg ret1day block0 block246 ep1, r
eststo: qui reg ret1day block0 block246 ep2, r
eststo: qui reg ret1day block0 block246 ep3, r
eststo: qui reg ret1day block0 block246 ep6, r
eststo: qui reg ret1day block0 block246 ep12, r
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace


clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year <=2016

eststo clear
eststo: qui reg ret1day block0 block246, r
eststo: qui reg ret1day block0 block246 ep1, r
eststo: qui reg ret1day block0 block246 ep2, r
eststo: qui reg ret1day block0 block246 ep3, r
eststo: qui reg ret1day block0 block246 ep6, r
eststo: qui reg ret1day block0 block246 ep12, r
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace
 

 
 

* TABLE 12
* -------
clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year<=2016


tsset t
g diff_ep1 = D.ep1
g diff_ep2 = D.ep2
g diff_ep3 = D.ep3
g diff_ep6 = D.ep6
g diff_ep12 = D.ep12

eststo clear
eststo: qui reg ret1day block0 block246, r
eststo: qui reg ret1day block0 block246 D.ep12, r
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace

clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year<=2016


tsset t
g diff_ep1 = D.ep1
g diff_ep2 = D.ep2
g diff_ep3 = D.ep3
g diff_ep6 = D.ep6
g diff_ep12 = D.ep12

eststo clear
eststo: qui reg ret1day block0 block246, r
eststo: qui reg ret1day block0 block246 D.ep12, r
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace




* TABLE 13
* -------

* Part 1
clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year<=2016

tsset date

keep if date2 <= td(31mar2011)

eststo clear
eststo: qui reg ret1day block0246, robust
eststo: qui reg ret1day block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace
 

* Part 2
clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year<=2016

tsset date

keep if date2 >= td(31mar2011)

eststo clear
eststo: qui reg ret1day block0246, robust
eststo: qui reg ret1day block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace
 

 

* Part 1
clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year<=2016

tsset date

keep if date2 <= td(31mar2011)

eststo clear
eststo: qui reg ret1day block0246, robust
eststo: qui reg ret1day block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace
 

* Part 2
clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year<=2016

tsset date

keep if date2 >= td(31mar2011)

eststo clear
eststo: qui reg ret1day block0246, robust
eststo: qui reg ret1day block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace
 



* TABLE 14
* -----------------

clear
use fomc_cdxhy1
keep if cycle<=33 & year>=1994 & year<=2016


ge datadrop=year==2007&month>=9
drop if datadrop==1

tsset date

eststo clear
eststo: qui reg ret1day block0246, robust
eststo: qui reg ret1day block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace



clear
use fomc_cdxig2
keep if cycle<=33 & year>=1994 & year<=2016


ge datadrop=year==2007&month>=9
drop if datadrop==1

tsset date

eststo clear
eststo: qui reg ret1day block0246, robust
eststo: qui reg ret1day block0 block246, robust
esttab, stats(r2 N) b(3) t(3) starlevels(*  0.10 ** 0.05 *** 0.010) nogaps nonote replace




* TABLE 15
* -------



clear
use fomc_cdxhy1

* reserve maintenance period dummies
for num 1/10: ge drmpX=rmp==X
for num 1/10: label var drmpX "Dummy=1 for day X of bank's reserve maintenance period"

* calendar dummies
gen dow=dow(date)
tabulate day, gen(dmd) 
for num 1/5: gen dwdX =(dow==X)
gen deoy = 0
replace deoy = 1 if year~=year[_n+1] & _n>1
gen deom = 0
replace deom = 1 if month~= month[_n+1] & _n>1
gen deoq = 0
gen yq = qofd(date)
bys yq :  replace deoq = 1 if _n==_N
drop yq 

for num 1/31: label var dmdX "Dummy=1 for day X of a month"
for num 1/5:  label var dwdX "Dummy=1 for day X of a week (1=Monday, 5=Friday)"
label var deoy "Dummy=1 on last day of a year" 
label var deoq "Dummy=1 on last day of a quarter"
label var deom "Dummy=1 on last day of a month"

replace cnt_eps = cnt_eps/10000

keep if cycle<=33 & year>=1994 & year<=2016

eststo clear
eststo: qui: reg ret1day block0 block246 if cycle<=33 , robust
eststo: qui: reg ret1day block0 block246 bbg_cnt_relw if cycle<=33 , robust
eststo: qui: reg ret1day block0 block246 cnt_eps frac_eps_pos if cycle<=33 , robust
eststo: qui: reg ret1day block0 block246 drmp* if cycle<=33 , robust
eststo: qui: reg ret1day block0 block246 dwd* dmd* deoy deom deoq if cycle<=33 , robust
esttab, stats(r2 N) b(3) t(3) indicate(drmp*  dwd* dmd* deoy* deom* deoq* )  starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace varwidth(30) 
 



clear
use fomc_cdxig2

* reserve maintenance period dummies
for num 1/10: ge drmpX=rmp==X
for num 1/10: label var drmpX "Dummy=1 for day X of bank's reserve maintenance period"

* calendar dummies
gen dow=dow(date)
tabulate day, gen(dmd) 
for num 1/5: gen dwdX =(dow==X)
gen deoy = 0
replace deoy = 1 if year~=year[_n+1] & _n>1
gen deom = 0
replace deom = 1 if month~= month[_n+1] & _n>1
gen deoq = 0
gen yq = qofd(date)
bys yq :  replace deoq = 1 if _n==_N
drop yq 

for num 1/31: label var dmdX "Dummy=1 for day X of a month"
for num 1/5:  label var dwdX "Dummy=1 for day X of a week (1=Monday, 5=Friday)"
label var deoy "Dummy=1 on last day of a year" 
label var deoq "Dummy=1 on last day of a quarter"
label var deom "Dummy=1 on last day of a month"

replace cnt_eps = cnt_eps/10000

keep if cycle<=33 & year>=1994 & year<=2016

eststo clear
eststo: qui: reg ret1day block0 block246 if cycle<=33 , robust
eststo: qui: reg ret1day block0 block246 bbg_cnt_relw if cycle<=33 , robust
eststo: qui: reg ret1day block0 block246 cnt_eps frac_eps_pos if cycle<=33 , robust
eststo: qui: reg ret1day block0 block246 drmp* if cycle<=33 , robust
eststo: qui: reg ret1day block0 block246 dwd* dmd* deoy deom deoq if cycle<=33 , robust
esttab, stats(r2 N) b(3) t(3) indicate(drmp*  dwd* dmd* deoy* deom* deoq* )  starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote replace varwidth(30) 
 









