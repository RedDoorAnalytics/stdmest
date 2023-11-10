clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
adopath ++ "stdmestm"
clear all

// Three-levels example
clear
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
predict b_by b_by_id, reffects reses(b_by_se b_by_id_se)

list birthyear id b_by b_by_se b_by_id b_by_id_se if birthyear == 1930 & jobno == 1
//      +--------------------------------------------------------------+
//      | birthy~r    id        b_by    b_by_se     b_by_id   b_by_i~e |
//      |--------------------------------------------------------------|
//   1. |     1930     1   -.0795512   .1930458    -1.39209   .4813395 |
//   2. |     1930     2   -.0795512   .1930458   -.1309338   .4605677 |
// 147. |     1930    47   -.0795512   .1930458    .0648713   .4757858 |
// 154. |     1930    52   -.0795512   .1930458    .0921726   .6059889 |
// 155. |     1930    53   -.0795512   .1930458    .2572126   .5502837 |
//      |--------------------------------------------------------------|
// 198. |     1930    73   -.0795512   .1930458   -.3866474   .4431536 |
// 234. |     1930    84   -.0795512   .1930458    .1991294    .487356 |
// 273. |     1930   100   -.0795512   .1930458    .9406086   .4313854 |
// 310. |     1930   109   -.0795512   .1930458   -.0400392   .4674065 |
// 341. |     1930   119   -.0795512   .1930458   -.4323267   .4766487 |
//      |--------------------------------------------------------------|
// 359. |     1930   125   -.0795512   .1930458   -.1077823   .4622744 |
// 447. |     1930   161   -.0795512   .1930458    .3662371   .5660748 |
//      +--------------------------------------------------------------+


// stdmestm for birthyear == 1930
range tv 0 365 100
stdmestm S1930, reat(-.0795512) reatse(.1930458) varmargname(birthyear>id) timevar(tv) ci
twoway ///
	(rarea S1930_lower S1930_upper tv, sort color(stblue%10)) ///
	(line S1930 tv, sort lcolor(stblue))

// for reference, we want to predict fully conditional for all subjects born in 1930,
//    the above should be about in the middle!
stdmest S1930_1, reat(-.0795512 -1.39209) reatse(.1930458 .4813395) timevar(tv) ci
stdmest S1930_2, reat(-.0795512 -.1309338) reatse(.1930458 .4605677) timevar(tv) ci
stdmest S1930_47, reat(-.0795512 .0648713) reatse(.1930458 .4757858) timevar(tv) ci
stdmest S1930_52, reat(-.0795512 .0921726) reatse(.1930458 .6059889) timevar(tv) ci
stdmest S1930_53, reat(-.0795512 .2572126) reatse(.1930458 .5502837) timevar(tv) ci
stdmest S1930_73, reat(-.0795512 -.3866474) reatse(.1930458 .4431536) timevar(tv) ci
stdmest S1930_84, reat(-.0795512 .1991294) reatse(.1930458 .487356) timevar(tv) ci
stdmest S1930_100, reat(-.0795512 .9406086) reatse(.1930458 .4313854) timevar(tv) ci
stdmest S1930_109, reat(-.0795512 -.0400392) reatse(.1930458 .4674065) timevar(tv) ci
stdmest S1930_119, reat(-.0795512 -.4323267) reatse(.1930458 .4766487) timevar(tv) ci
stdmest S1930_125, reat(-.0795512 -.1077823) reatse(.1930458 .4622744) timevar(tv) ci
stdmest S1930_161, reat(-.0795512 .3662371) reatse(.1930458 .5660748) timevar(tv) ci
//
levelsof id if birthyear == 1930, local(ids_1930)
foreach i of local ids_1930 {
	local addplot `addplot' (rarea S1930_`i'_lower S1930_`i'_upper tv, sort color(black%05)) (line S1930_`i' tv, sort lcolor(black) lpattern(dash))
}
local margplot (rarea S1930_lower S1930_upper tv, sort color(stblue%20)) (line S1930 tv, sort lcolor(stblue) lwidth(thick))
twoway `addplot' `margplot', legend(order(25 "95% C.I." 26 "birthyear = 1930"))
