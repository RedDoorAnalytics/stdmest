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
This is never the case with the percentile method, but this may require more iterations to converge.
{p_end}

{phang}
{opt cilevel(#)}
{p_end}

{phang}
{opt reps(#)}
{p_end}

{phang}
{opt dots}
{p_end}

{marker examples}{...}
{title: Examples}

{marker author}{...}
{title: Author}

{pstd}Alessandro Gasparini{p_end}
{pstd}Red Door Analytics AB{p_end}
{pstd}Stockholm, Sweden{p_end}
{pstd}E-mail: {browse "mailto:alessandro.gasparini@reddooranalytics.se":alessandro.gasparini@reddooranalytics.se}.{p_end}

{phang}
Please report any errors you may find, e.g., on {browse "https://github.com/RedDoorAnalytics/stdmest":GitHub} or by e-mail.
{p_end}
