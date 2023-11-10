{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "mestreg" "help mestreg"}{...}
{viewerjumpto "Syntax" "stdmestm##syntax"}{...}
{viewerjumpto "Description" "stdmestm##description"}{...}
{viewerjumpto "Options" "stdmestm##options"}{...}
{viewerjumpto "Remarks" "stdmestm##remarks"}{...}
{viewerjumpto "Examples" "stdmestm##examples"}{...}

{synopt :{cmd: stdmestm} {hline 2} Partially marginal regression standardisation for standardised survival probabilities and contrasts between hierarchical units after fitting {cmd: mestreg} models}

{marker syntax}{...}
{title: Syntax}

{phang2}
{cmd: stdmestm} {newvar} {ifin} [, {it:{help stdmestm##options_table:options}}]
{p_end}

{synoptset}{...}
{marker options_table}{...}
{synopthdr: Option}
{synoptline}
{synopt: {cmdab: reat(#)}}Random intercept value to fix{p_end}
{synopt: {cmdab: reatr:ef(#)}}Random intercept value to fix as the reference. This is useful when calculating contrasts{p_end}
{synopt: {cmdab: reatse(#)}}Standard error of the random intercept value {opt reat}. This is used in the confidence intervals algorithm{p_end}
{synopt: {cmdab: reatser:ef(#)}}Standard error of the reference random intercept value {opt reatref}. This is used in the confidence intervals algorithm{p_end}
{synopt: {cmdab: time:var(varname)}}Time variable to obtain predictions at. Defaults to all values in {it: _t} if not specified by the user{p_end}
{synopt: {cmdab: contr:ast}}If defined, return contrasts of {opt reat} vs {opt reatref} for every value of {opt timevar}{p_end}
{synopt: {cmdab: ci}}If defined, confidence intervals for each quantity are calculated{p_end}
{synopt: {cmdab: cinorm:al}}If defined, use the normal approximation method for the confidence intervals. The default is to use the percentile method{p_end}
{synopt: {cmdab: cilev:el(#)}}Required confidence level for the confidence intervals. Defaults to 0.95 for 95% confidence intervals{p_end}
{synopt: {cmdab: rep:s(#)}}Number of repetitions used by the algorithm used to calculate the confidence intervals. Defaults to 100{p_end}
{synopt: {cmdab: dots}}If defined, display dots while iterating across repetitions when calculating confidence intervals. This can be useful to display the progress of the algorithm{p_end}
{synopt: {cmdab: varmarg:name}}Name of the random intercept to integrate (i.e., marginalise) over{p_end}
{synopt: {cmdab: nk}}Number of Gauss-Hermite quadrature nodes used by the algorithm to numerically integrate out the random intercept denoted by {opt varmargname}{p_end}
{synoptline}

{marker description}{...}
{title: Description}

{phang}
{cmd: stdmestm} is a post-estimation command that can be used to estimate standardised survival probabilities (and contrasts thereof) after fitting three-level {helpb mestreg} models, using regression standardisation.
The goal is to obtain standardised survival probabilities, standardising over the observed covariates distributions (i.e., the fixed effects that were included in your {helpb mestreg} model) while 1. fixing the random intercept for a certain level and 2. marginalise over the random intercept for the other level.
We denote these predictions as {it: partially marginal} because we marginalise over {it: only} one of the two hierarchical levels of a three-level survival model.
{p_end}

{phang}
Note that only three-level {helpb mestreg} models using the proportional hazards metric and assuming an exponential or Weibull baseline hazard distribution are supported, at the moment.
{p_end}

{phang}
The difference between {cmd: stdmestm} and {helpb stdmest} is that the latter fixes random intercept values at all levels, while the former fixes one and marginalises over the other.
{p_end}

{marker options}{...}
{title: Options}

{phang}
{opt reat(#)} is a value for the random (intercept) to be fixed for a certain level, and to calculate standardised survival probabilities for.
This is usually the predicted BLUP, obtained using the {helpb mestreg postestimation##predict:predict, reffects} post-estimation command of {helpb mestreg}.
{p_end}

{phang}
{opt reatref(#)} is a value for the random intercept to be taken as the reference in the comparison with {opt reat}.
Thus, this must be a value referring to the same hierarchical level fixed by {opt reat}.
{p_end}

{phang}
{opt reatse(#)} is the standard error of {opt reat}, which is used by the algorithm computing the confidence intervals.
This is usually obtained with the {helpb mestreg postestimation##predict:reses} option of {helpb mestreg postestimation##predict:predict, reffects}, a post-estimation command of {helpb mestreg}.
{p_end}

{phang}
{opt reatseref(#)} is the standard error of {opt reatref}.
{p_end}

{phang}
{opt timevar(varname)} denotes a variable containing the time points to predict at, either for standardised survival probabilities or contrasts thereof.
If not supplied by the user, all values in {it: _t} are used by default – which might be much more computationally intensive with large datasets.
{p_end}

{phang}
{opt contrast} denotes whether to produce contrasts of survival probabilities between {opt reat} and {opt reatref}, across time points.
Specifically, survival differences S({it:t} | {opt reat}) - S({it:t} | {opt reatref}) are calculated, for every value of {it: t}.
Note that standardised survival probabilities for both {opt reat} and {opt reatref} and their contrasts are returned if {opt contrast} is specified.
{p_end}

{phang}
{opt ci} denotes whether confidence intervals for standardised survival probabilities (or contrasts thereof) are to be computed and returned.
The underlying algorithm is a stochastic algorithm based on resampling the fitted model parameters (assuming a multivariate normal distribution with mean {cmd: e(b)} and variance-covariance matrix {cmd: e(V)}), the BLUP value fixed by the user (assuming a normal distribution centered on {opt reat} and with standard deviation {opt reatse}), and any possible reference BLUP (if needed, assuming a normal distribution centered on {opt reatref} and {opt reatrefse}).
The algorithm runs for {opt reps} iterations, which can be controlled by the user.
{p_end}

{phang}
{opt cinormal} denotes to use the normal approximation method within the algorithm used to obtain confidence intervals; this method calculates the standard deviation of the predictions, across repetitions, and uses it to produce confidence intervals that are symmetric and centered around the point estimates.
If not specified, the algorithm will use the percentile method, which will take percentiles of the distribution of the predictions as the confidence intervals.
Note that the normal approximation method might yield confidence intervals that are beyond the boundaries of a survival function (e.g., above 1 or below 0): {cmd: stdmest} does not fix this issue and only displays a warning when this happens.
This is never the case with the percentile method, but this may require more iterations (e.g., a higher number of {cmd: reps}) to converge.
{p_end}

{phang}
{opt cilevel(#)} denotes the confidence level for the confidence intervals.
Defaults to 0.95, for 95% confidence intervals.
{p_end}

{phang}
{opt reps(#)} denotes the number of repetitions to use for the confidence intervals algorithm.
Defaults to 100.
Note that a larger number of repetitions yields more accurate confidence intervals, at the cost of increased computational costs.
{p_end}

{phang}
{opt dots} if provided, the progress of the algorithm for the confidence intervals is displayed visually.
{p_end}

{phang}
{opt varmargname} denotes the name of the random intercept to be marginalised over.
This can be picked from the output table of {helpb mestreg}, from the variance components section – see the examples below for more details.
{p_end}

{phang}
{opt nk} Number of Gauss-Hermite quadrature nodes used by the numerical integration algorithm to marginalise over the random intercept defined by {opt varmargname}.
Defaults to 7, which provided good results in our experience, but a higher number can be used to ensure a more precise approximation.
{p_end}

{marker examples}{...}
{title: Examples}

{pstd}
To illustrate the functionality of {cmd: stdmestm} we adapt the {cmd: jobhistory} example from the {helpb mestreg} help file:

{phang}{stata . webuse jobhistory}{p_end}
{phang}{stata . generate tt = tend - tstart}{p_end}
{phang}{stata . stset tt, fail(failure)}{p_end}
{phang}{stata ". mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)"}{p_end}

{pstd}
Note that, as in the examples for {helpb stdmest}, we calculate and use {cmd: tt} as the time variable to not have to deal with delayed entry, which is beyond the scope of this package and not currently considered.

{pstd}
Then, we predict the random effects and list BLUPs for a certain {cmd: birthyear}, say, 1930:

{phang}{stata . predict b_by b_by_id, reffects reses(b_by_se b_by_id_se)}{p_end}
{phang}{stata . list birthyear id b_by b_by_se b_by_id b_by_id_se if birthyear == 1930 & jobno == 1}{p_end}

{pstd}
Note that in the {helpb list} command above we filter on {cmd: jobno == 1} to ensure we get a single line per subject.

{pstd}
Then, we define a new {cmd: timevar} variable {cmd: tv} that we will predict for and we run {cmd: stdmestm} while fixing the BLUP for {cmd: birthyear == 1930}:

{phang}{stata . range tv 0 365 100}{p_end}
{phang}{stata . stdmestm S1930, reat(-.0795512) reatse(.1930458) varmargname(birthyear>id) timevar(tv) ci}{p_end}

{pstd}
We pick the values of {opt reat} and {opt reatse} from the output of {helpb list}, above, and we integrate over the random intercept at the subject level (denoted with {cmd: birthyear>id} in the output table of {helpb mestreg}).
We also request confidence intervals, which are calculated using the default settings.

{pstd}
We can plot the resulting predictions with the following code:

{phang}{stata . twoway (rarea S1930_lower S1930_upper tv, sort color(stblue%10)) (line S1930 tv, sort lcolor(stblue))}{p_end}

{pstd}
These predictions are interpreted as standardised survival probabilities for study subjects born in 1930, over time, standardising over the observed covariates distribution and marginalising over the subject-level random intercept.

{pstd}
For reference, we want to compare these predictions with {it: fully conditional} predictions from {helpb stdmest}.
For this, we predict standardised survival probabilities for every subject born in 1930, fixing the random intercept values listed above (one at a time):

{phang}{stata . stdmest S1930_1, reat(-.0795512 -1.39209) reatse(.1930458 .4813395) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_2, reat(-.0795512 -.1309338) reatse(.1930458 .4605677) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_47, reat(-.0795512 .0648713) reatse(.1930458 .4757858) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_52, reat(-.0795512 .0921726) reatse(.1930458 .6059889) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_53, reat(-.0795512 .2572126) reatse(.1930458 .5502837) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_73, reat(-.0795512 -.3866474) reatse(.1930458 .4431536) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_84, reat(-.0795512 .1991294) reatse(.1930458 .487356) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_100, reat(-.0795512 .9406086) reatse(.1930458 .4313854) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_109, reat(-.0795512 -.0400392) reatse(.1930458 .4674065) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_119, reat(-.0795512 -.4323267) reatse(.1930458 .4766487) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_125, reat(-.0795512 -.1077823) reatse(.1930458 .4622744) timevar(tv) ci}{p_end}
{phang}{stata . stdmest S1930_161, reat(-.0795512 .3662371) reatse(.1930458 .5660748) timevar(tv) ci}{p_end}

{pstd}
All these predictions can then be plotted using the following code:

{pstd}
{bf}
. levelsof id if birthyear == 1930, local(ids_1930)
{break}
. foreach i of local ids_1930 {
{break}
. {space 4} local addplot `addplot' ///
{break}
. {space 8} (rarea S1930_`i'_lower S1930_`i'_upper tv, sort color(black%05)) ///
{break}
. {space 8} (line S1930_`i' tv, sort lcolor(black) lpattern(dash))
{break}
. }
{break}
. local margplot (rarea S1930_lower S1930_upper tv, sort color(stblue%20)) (line S1930 tv, sort lcolor(stblue) lwidth(thick))
{break}
. twoway `addplot' `margplot', legend(order(25 "95% C.I." 26 "birthyear = 1930"))

{pstd}
{it}
Note that the {ul:entire} code chunk above needs to be run together, in a single go, given the use of {help local} macro variables.
{reset}

{pstd}
The blue line denotes standardised survival probabilities for study subjects born in 1930.
Each black, dashed line denotes standardised survival probabilities for a specific study subject born in 1930.
Note that, as expected, the blue line is approximately the average of the black lines.

{marker author}{...}
{title: Author}

{pstd}Alessandro Gasparini{p_end}
{pstd}Red Door Analytics AB{p_end}
{pstd}Stockholm, Sweden{p_end}
{pstd}E-mail: {browse "mailto:alessandro.gasparini@reddooranalytics.se":alessandro.gasparini@reddooranalytics.se}.{p_end}

{phang}
Please report any errors you may find, e.g., on {browse "https://github.com/RedDoorAnalytics/stdmest":GitHub} or by e-mail.
{p_end}
