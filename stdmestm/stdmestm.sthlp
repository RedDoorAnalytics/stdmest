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
We denote these predictions as {it: partially marginal} because we marginalise over {it: only} one of the two hierarchical levels of a three-levels survival model.
{p_end}

{phang}
Note that only three-level {helpb mestreg} models using the proportional hazards metric and assuming an exponential or Weibull baseline hazard distribution are supported, at the moment.
{p_end}

{phang}
The difference between {cmd: stdmestm} and {helpb stdmest} is that the latter fixes random intercept values at all levels, while the former fixes one and marginales over the other.
{p_end}

{marker options}{...}
{title: Options}

{phang}
{opt reat(#)} is a values for the random (intercept) to be fixed for a certain level, and to calculate standardised survival probabilities for.
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

{marker author}{...}
{title: Author}

{pstd}Alessandro Gasparini{p_end}
{pstd}Red Door Analytics AB{p_end}
{pstd}Stockholm, Sweden{p_end}
{pstd}E-mail: {browse "mailto:alessandro.gasparini@reddooranalytics.se":alessandro.gasparini@reddooranalytics.se}.{p_end}

{phang}
Please report any errors you may find, e.g., on {browse "https://github.com/RedDoorAnalytics/stdmest":GitHub} or by e-mail.
{p_end}
