clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmestm"
clear all
// set trace on

// helpfile
help stdmestm

webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
range tv 0 365 200
stdmestm Smin_perc, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) contrast ci
stdmestm Smax_perc, reat(.2269995) reatse(.1666193) varmargname(birthyear>id) timevar(tv) contrast ci
stdmestm Smin_norm, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) contrast ci cinormal
stdmestm Smax_norm, reat(.2269995) reatse(.1666193) varmargname(birthyear>id) timevar(tv) contrast ci cinormal

twoway /// 
	(rarea Smin_perc_ref_lower Smin_perc_ref_upper tv, sort color(stblue%10)) ///
	(rarea Smin_perc_lower Smin_perc_upper tv, sort color(stgreen%10)) ///
	(rarea Smax_perc_lower Smax_perc_upper tv, sort color(stred%10)) ///
	(line Smin_perc_ref tv, sort lcolor(stblue)) ///
	(line Smin_perc tv, sort lcolor(stgreen)) ///
	(line Smax_perc tv, sort lcolor(stred))

twoway /// 
	(rarea Smin_norm_ref_lower Smin_norm_ref_upper tv, sort color(stblue%10)) ///
	(rarea Smin_norm_lower Smin_norm_upper tv, sort color(stgreen%10)) ///
	(rarea Smax_norm_lower Smax_norm_upper tv, sort color(stred%10)) ///
	(line Smin_norm_ref tv, sort lcolor(stblue)) ///
	(line Smin_norm tv, sort lcolor(stgreen)) ///
	(line Smax_norm tv, sort lcolor(stred))
