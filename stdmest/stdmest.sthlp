{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "mestreg" "help mestreg"}{...}
{viewerjumpto "Syntax" "stdmest##syntax"}{...}
{viewerjumpto "Description" "stdmest##description"}{...}
{viewerjumpto "Options" "stdmest##options"}{...}
{viewerjumpto "Remarks" "stdmest##remarks"}{...}
{viewerjumpto "Examples" "stdmest##examples"}{...}

{synopt :{cmd: stdmest} {hline 2} Regression standardisation for standardised survival probabilities and contrasts between hierarchical units after fitting {cmd: mestreg} models}

{marker syntax}{...}
{title: Syntax}

{phang2}
{cmd: stdmest} {newvar} {ifin} [, {it:{help stdmest##options_table:options}}]
{p_end}

{synoptset}{...}
{marker options_table}{...}
{synopthdr: Option}
{synoptline}
{synopt: {cmdab: reat(#)}}Random intercept value to fix. Defaults to the value of 0.0 if not specified by the user{p_end}
{synopt: {cmdab: reatr:ef(#)}}Random intercept value to fix as the reference. This is useful when calculating contrasts, and defaults to the value of 0.0{p_end}
{synopt: {cmdab: reatse(#)}}Standard error of the random intercept value {opt reat}. This is used in the confidence intervals algorithm, and defaults to the value of 0.0{p_end}
{synopt: {cmdab: reatser:ef(#)}}Standard error of the reference random intercept value {opt reatref}. This is used in the confidence intervals algorithm, and defaults to the value of 0.0{p_end}
{synopt: {cmdab: time:var(varname)}}Time variable to obtain predictions at. Defaults to all values in {it: _t} if not specified by the user{p_end}
{synopt: {cmdab: contr:ast}}If defined, return contrasts of {opt reat} vs {opt reatref} for every value of {opt timevar}{p_end}
{synopt: {cmdab: ci}}If defined, confidence intervals for each quantity are calculated{p_end}
{synopt: {cmdab: cinorm:al}}If defined, use the normal approximation method for the confidence intervals. The default is to use the percentile method{p_end}
{synopt: {cmdab: cilev:el(#)}}Required confidence level for the confidence intervals. Defaults to 0.95 for 95% confidence intervals{p_end}
{synopt: {cmdab: rep:s(#)}}Number of repetitions used by the algorithm used to calculate the confidence intervals. Defaults to 100{p_end}
{synopt: {cmdab: dots}}If defined, display dots while iterating across repetitions when calculating confidence intervals. This can be useful to display progress of the algorithm{p_end}
{synoptline}

{marker description}{...}
{title: Description}

{phang}
{cmd: stdmest} is a post-estimation command that can be used to estimate standardised survival probabilities (and contrasts thereof) after fitting {helpb mestreg} models, using regression standardisation.
The goal is to obtain standardised survival probabilities, standardising over the observed covariates distributions (i.e., the fixed effects that were included in your {helpb mestreg} model) while fixing a certain value of the random intercept.
{p_end}

{phang}
Note that only {helpb mestreg} models with a single random intercept are supported at the moment.
Moreover, only models using the proportional hazards metric and an exponential or Weibull baseline hazard distribution are supported.
{p_end}

{marker options}{...}
{title: Options}

{phang}
{opt reat(#)} is the value of the random effect (intercept) to be fixed and to calculate standardised survival probabilities for.
This is usually the predicted BLUP for a certain hierarchical unit, obtained using the {helpb mestreg postestimation##predict:predict, reffects} post-estimation command of {helpb mestreg}.
Defaults to the value of 0.0, which denotes a theoretical average unit (given that the distribution of the random effects is normal and centered on 0.0).
{p_end}

{phang}
{opt reatref(#)} is the value of the random effect to be taken as the reference value.
This is useful when calculating contrasts (e.g., {opt reat} vs the theoretical average), and it defaults to the value of 0.0.
{p_end}

{phang}
{opt reatse(#)} is the standard error of {opt reat}, the BLUP for a certain hierarchical unit.
This is usually obtained with the {helpb mestreg postestimation##predict:reses} option of {helpb mestreg postestimation##predict:predict, reffects}, a post-estimation command of {helpb mestreg}.
It is used by the algorithm computing the confidence intervals, and defaults to the value of 0.0.
{p_end}

{phang}
{opt reatseref(#)} is the standard error of {opt reatref}, the reference BLUP.
Defaults to the value of 0.0.
{p_end}

{phang}
{opt timevar(varname)} denotes a variable containing the time points to predict at, either for standardised survival probabilities or constrasts thereof.
If not supplied by the user, all values in {it: _t} are used by default.
{p_end}

{phang}
{opt contrast} denotes whether to produce contrasts of survival probabilities between {opt reat} and {opt reatref} across time points.
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
Note that the normal approximation method might yield confidence intervals that are beyond the boundaries of a survival function (e.g., above 1 or below 0): {cmd: stdmest} does not fix this issues and only displays a warning when this happens.
This is never the case with the percentile method, but this may require more iterations (e.g., a higher number of {cmd: reps}) to converge.
{p_end}

{phang}
{opt cilevel(#)} denotes the confidence level for the confidence intervals.
Defaults to 0.95, for 95% confidence intervals.
{p_end}

{phang}
{opt reps(#)} denotes the number of repetitions to use for the confidence intervals algorithm.
Defaults to 100.
Note that a larger number of repetitions yields more accurate confidence intervals, at the cost of an increased computational costs.
{p_end}

{phang}
{opt dots} if provided, progress of the algorithm for the confidence intervals is displayed visually.
{p_end}

{marker examples}{...}
{title: Examples}

{pstd}
We start by replicating one of the examples from the {helpb mestreg} help file:

{phang}{stata webuse catheter: . webuse catheter}{p_end}
{phang}{stata "mestreg age female || patient:, distribution(weibull)": . mestreg age female || patient:, distribution(weibull)}{p_end}

{pstd}
Then, we obtain the BLUPs for the random effects:

{phang}{stata predict b, reffects reses(bse): . predict b, reffects reses(bse)}{p_end}

{pstd}
For the first example, we calculate standardised survival probabilities using the default options:

{phang}{stata stdmest S1: . stdmest S1}{p_end}

{pstd}
This calculates standardised survival probabilities, using all values of {cmd: _t}, and fixing the random intercept to the value of zero.
This can be interpeted as the standardised survival probability for a theoretical average patient, standardising over the entire study population.
We can plot this with the following code:

{phang}{stata twoway line S1 _t, sort: . twoway line S1 _t, sort}{p_end}

{pstd}
Next, if we pass the {opt ci} option to {cmd: stdmest} we obtain confidence intervals too:

{phang}{stata stdmest S2, ci: . stdmest S2, ci}{p_end}
{phang}{stata twoway (rarea S2_lower S2_upper _t, sort color(stblue%10)) (line S2 _t, sort lcolor(stblue)): . twoway (rarea S2_lower S2_upper _t, sort color(stblue%10)) (line S2 _t, sort lcolor(stblue))}

{pstd}
This uses the percentile method, and 100 repetitions for the confidence intervals algorithm.
If we wanted to use the normal approximation method, we could use the {opt cinormal} option:

{phang}{stata stdmest S3, ci cinormal: . stdmest S3, ci cinormal}{p_end}
{phang}{stata twoway (rarea S3_lower S3_upper _t, sort color(stgreen%10)) (line S3 _t, sort lcolor(stgreen)): . twoway (rarea S3_lower S3_upper _t, sort color(stgreen%10)) (line S3 _t, sort lcolor(stgreen))}{p_end}

{pstd}
We can also define custom time points to obtain predictions at:

{phang}{stata range tt 0 100 5: . range tt 0 100 5}{p_end}

{pstd}
Then, we can pass this to {cmd: stdmest} via the {opt timevar} option:

{phang}{stata stdmest S4, ci timevar(tt) reps(1000) dots: . stdmest S4, ci timevar(tt) reps(1000) dots}{p_end}
{phang}{stata list tt S4* if tt != .: . list tt S4* if tt != .}{p_end}

{pstd}
We also pass the {opt reps(1000)} options to run 1,000 repetitions of the algorithm for the confidence intervals and the {opt dots} option to display progress in the Stata console.

{pstd}
Finally, we illustrate how to obtain contrasts of standardised survival probabilities.
First, we identify the smallest predicted BLUP:

{phang}{stata sort b: . sort b}{p_end}
{phang}{stata list b bse if _n == 1: . list b bse if _n == 1}{p_end}

{pstd}
The smallest BLUP was predicted to be -2.098768, with a standard error of 0.4285454; note that the smallest BLUP corresponds to the patient with the lowest risk (i.e., the lowest hazard).
Then, we pass this to {cmd: stdmest} via the {opt reat} and {opt reatse} options:

{phang}{stata stdmest S5, ci timevar(tt) reps(1000) dots contrast reat(-2.098768) reatse(.4285454): . stdmest S5, ci timevar(tt) reps(1000) dots contrast reat(-2.098768) reatse(.4285454)}{p_end}

{pstd}
Estimated contrasts values (and confidence intervals) can be displayed (and plotted) with the following Stata code:

{phang}{stata sort tt: . sort tt}{p_end}
{phang}{stata list tt S5* if tt != .: . list tt S5* if tt != .}{p_end}

{pstd}
These could also be plotted using {helpb twoway} graphs, as before.

{marker author}{...}
{title: Author}

{pstd}Alessandro Gasparini{p_end}
{pstd}Red Door Analytics AB{p_end}
{pstd}Stockholm, Sweden{p_end}
{pstd}E-mail: {browse "mailto:alessandro.gasparini@reddooranalytics.se":alessandro.gasparini@reddooranalytics.se}.{p_end}

{phang}
Please report any errors you may find, e.g., on {browse "https://github.com/RedDoorAnalytics/stdmest":GitHub} or by e-mail.
{p_end}
