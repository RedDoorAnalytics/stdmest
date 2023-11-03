clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmestm"
clear all
// set trace on

// helpfile
// help stdmestm

webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
range tv 0 365 200
stdmestm Smin, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) contrast ci
stdmestm Smax, reat(.2269995) reatse(.1666193) varmargname(birthyear>id) timevar(tv) contrast ci

twoway /// 
	(rarea Smin_ref_lower Smin_ref_upper tv, sort color(stblue%10)) ///
	(rarea Smin_lower Smin_upper tv, sort color(stgreen%10)) ///
	(rarea Smax_lower Smax_upper tv, sort color(stred%10)) ///
	(line Smin_ref tv, sort lcolor(stblue)) ///
	(line Smin tv, sort lcolor(stgreen)) ///
	(line Smax tv, sort lcolor(stred))
	
	