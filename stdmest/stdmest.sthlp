{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "mestreg" "help mestreg"}{...}
{vieweralsosee "uhtred" "help uhtred"}{...}
{viewerjumpto "Syntax" "stdmest##syntax"}{...}
{viewerjumpto "Description" "stdmest##description"}{...}
{viewerjumpto "Options" "stdmest##options"}{...}
{viewerjumpto "Remarks" "stdmest##remarks"}{...}
{viewerjumpto "Examples" "stdmest##examples"}{...}

{synopt :{cmd: stdmest} {hline 2} Regression standardisation for standardised survival probabilities and contrasts between hierarchical units after fitting {cmd: mestreg} and {cmd: uhtred} models}

{marker syntax}{...}
{title: Syntax}

{phang2}
{cmd: stdmest} {newvar} {ifin} [, {it:{help stdmest##options_table:options}}]
{p_end}

{synoptset}{...}
{marker options_table}{...}
{synopthdr: Option}
{synoptline}
{synopt: {cmdab: reat(#)}}Random intercept value(s) to fix{p_end}
{synopt: {cmdab: reatref(#)}}Random intercept(s) value to fix as the reference. This is useful when calculating contrasts{p_end}
{synopt: {cmdab: reatse(#)}}Standard error(s) of the random intercept value(s) {opt reat}. This is used in the confidence intervals algorithm{p_end}
{synopt: {cmdab: reatrefse(#)}}Standard error(s) of the reference random intercept value(s) {opt reatref}. This is used in the confidence intervals algorithm{p_end}
{synopt: {cmdab: time:var(varname)}}Time variable to obtain predictions at. Defaults to all values in {it: _t} if not specified by the user{p_end}
{synopt: {cmdab: contr:ast}}If defined, return contrasts of {opt reat} vs {opt reatref} for every value of {opt timevar}{p_end}
{synopt: {cmdab: ci}}If defined, confidence intervals for each quantity are calculated{p_end}
{synopt: {cmdab: cinorm:al}}If defined, use the normal approximation method for the confidence intervals. The default is to use the percentile method{p_end}
{synopt: {cmdab: l:evel(#)}}Required confidence level for the confidence intervals. If not set, the default system-wide setting is used{p_end}
{synopt: {cmdab: rep:s(#)}}Number of repetitions used by the algorithm used to calculate the confidence intervals. Defaults to 1000{p_end}
{synopt: {cmdab: verb:ose}}If defined, display progress of the algorithm{p_end}
{synopt: {cmdab: dots}}If defined, display additional details on progress of the algorithm{p_end}
{synoptline}

{marker description}{...}
{title: Description}

{phang}
{cmd: stdmest} is a post-estimation command that can be used to estimate standardised survival probabilities (and contrasts thereof) after fitting {helpb mestreg} and {helpb uhtred} models, using regression standardisation.
The goal is to obtain standardised survival probabilities, standardising over the observed covariates distributions (i.e., the fixed effects that were included in your multilevel survival model) while fixing certain random effect values.
{p_end}

{phang}
{helpb mestreg} and {helpb uhtred} models with random intercepts at any possible hierarchical level are supported, as long as they are all fixed for prediction purposes.
Examples with two- and three-level models are included below.
Note however that, for {cmd: mestreg}, only models using the proportional hazards metric and assuming an exponential or Weibull baseline hazard distribution are supported, at the moment.
{p_end}

{marker options}{...}
{title: Options}

{phang}
{opt reat(#)} is a vector of values for the random effect (intercept) to be fixed at each level of the hierarchy for calculating standardised survival probabilities.
These are usually the predicted BLUPs, obtained using the {cmd: predict} post-estimation command of {helpb mestreg} and {helpb uhtred}.
{p_end}

{phang}
{opt reatref(#)} is a vector of values of the random effect to be taken as the reference.
{p_end}

{phang}
{opt reatse(#)} is a vector of standard errors of {opt reat}, which are used by the algorithm computing the confidence intervals.
Note that values in {opt reat} and {opt reatse} must be in the same order, as they are picked according to their position: the first value in {opt reat} has a standard error given by the first element in {opt reatse}, and so on.
These are also usually obtained with the {cmd: predict} post-estimation command of {helpb mestreg} and {helpb uhtred}.
{p_end}

{phang}
{opt reatrefse(#)} is a vector of standard errors of {opt reatref}.
Note that the same considerations outlined above for {opt reatse} apply here as well.
{p_end}

{phang}
{opt timevar(varname)} denotes a variable containing the time points to predict at, either for standardised survival probabilities or contrasts thereof.
If not supplied by the user, all values in {it: _t} are used by default – which might be much more computationally intensive with large datasets.
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
The normal approximation method often converges faster (i.e., with a smaller number of {cmd: reps}) than the percentile method, so it may be useful when data size is large and computations are time-consuming.
Note that when using normal approximation method confidence intervals are computed on the complementary log-log ({help mf_logit:cloglog}) scale to ensure that no values are outside the boundaries of a survival function (e.g., above 1 or below 0).
Therefore, confidence intervals computed using the {opt cinormal} option are only symmetric on the transformed scale.
This only applies to confidence intervals of standardised survival probabilities, not contrasts thereof (whose confidence intervals are calculated on the original scale).
{p_end}

{phang}
{opt level(#)} denotes the confidence level for the confidence intervals.
If not set, the default system-wide setting is used: see {helpb set level} for more details.
{p_end}

{phang}
{opt reps(#)} denotes the number of repetitions to use for the confidence intervals algorithm.
Defaults to 1000.
Note that a larger number of repetitions yields more accurate confidence intervals, at the cost of increased computational costs.
{p_end}

{phang}
{opt verbose} if provided, the progress of the underlying algorithm implementing the predictions is displayed visually.
{p_end}

{phang}
{opt dots} if provided alongside the {opt verbose} option, additional details on progress of the prediction algorithm are displayed.
Note that this has no effect is the {opt verbose} and {opt ci} options are not used.
{p_end}

{marker examples}{...}
{title: Examples}

{pstd}
We start by replicating one of the examples from the {helpb mestreg} help file:

{phang}{stata . webuse catheter}{p_end}
{phang}{stata ". mestreg age female || patient:, distribution(weibull)"}{p_end}

{pstd}
This example covers the setting of two-level hierarchical models.

{pstd}
Then, we obtain the BLUPs for the random effects:

{phang}{stata . predict b, reffects reses(bse)}{p_end}

{pstd}
For the first example, we calculate standardised survival probabilities using the default options:

{phang}{stata . stdmest s1}{p_end}

{pstd}
This calculates standardised survival probabilities, using all values of {cmd: _t}, and fixing the random intercept to the value of zero.
This can be interpreted as the standardised survival probability for a theoretical average patient, standardising over the entire study population.
We can plot this with the following code:

{phang}{stata . twoway line s1 _t, sort}{p_end}

{pstd}
Next, if we pass the {opt ci} option to {cmd: stdmest} we obtain confidence intervals too:

{phang}{stata . stdmest s2, ci}{p_end}
{phang}{stata . twoway (rarea s2_lci s2_uci _t, sort color(stblue%10)) (line s2 _t, sort lcolor(stblue))}{p_end}

{pstd}
This uses the percentile method and 100 repetitions for the confidence intervals algorithm.
If we wanted to use the normal approximation method, we could use the {opt cinormal} option:

{phang}{stata . stdmest s3, ci cinormal}{p_end}
{phang}{stata . twoway (rarea s3_lci s3_uci _t, sort color(stgreen%10)) (line s3 _t, sort lcolor(stgreen))}{p_end}

{pstd}
We can also define custom time points to obtain predictions at:

{phang}{stata . range tt 0 100 5}{p_end}

{pstd}
Then, we can pass this to {cmd: stdmest} via the {opt timevar} option:

{phang}{stata . stdmest s4, ci timevar(tt) reps(1000) verbose}{p_end}
{phang}{stata . list tt s4* if tt != .}{p_end}

{pstd}
We also pass the {opt reps(1000)} options to run 1,000 repetitions of the algorithm for the confidence intervals and the {opt verbose} option to display progress in the Stata console.

{pstd}
If we add the {opt dots} options, more details on progress are provided:

{phang}{stata . stdmest s4b, ci timevar(tt) reps(1000) verbose dots}{p_end}

{pstd}
Finally, we illustrate how to obtain contrasts of standardised survival probabilities.
First, we identify the smallest predicted BLUP:

{phang}{stata . sort b}{p_end}
{phang}{stata . list b bse if _n == 1}{p_end}

{pstd}
The smallest BLUP was predicted to be -2.098768, with a standard error of 0.4285454; note that the smallest BLUP corresponds to the patient with the lowest risk (i.e., the lowest hazard).
Then, we pass this to {cmd: stdmest} via the {opt reat} and {opt reatse} options:

{phang}{stata . stdmest s5, ci timevar(tt) reps(1000) verbose contrast reat(-2.098768) reatse(.4285454) reatref(0.0) reatrefse(0.0)}{p_end}

{pstd}
Note that we needed to set reference values to contrast against, defined by the {opt reatref} and {opt reatrefse} options; values of 0.0 denote the theoretical average patient, with a fixed random intercept value of 0.0.
Estimated contrast values (and confidence intervals) can be displayed (and plotted) with the following Stata code:

{phang}{stata . sort tt}{p_end}
{phang}{stata . list tt s5* if tt != .}{p_end}

{pstd}
These could also be plotted using {helpb twoway} graphs, as before.

{pstd}
Now, we see an example using a three-level hierarchical model.
Specifically, we adapt the {cmd: jobhistory} example from the {helpb mestreg} help file:

{phang}{stata . webuse jobhistory}{p_end}
{phang}{stata . generate tt = tend - tstart}{p_end}
{phang}{stata . stset tt, fail(failure)}{p_end}
{phang}{stata ". mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)"}{p_end}

{pstd}
Note that we calculate and use {cmd: tt} as the time variable to not have to deal with delayed entry, which is beyond the scope of this package and not currently considered.

{pstd}
Then, we predict the random effects for both {cmd: birthyear} and {cmd: id} levels, and pick two sets of values to obtain predictions for:

{phang}{stata . predict b*, reffects reses(bse*)}{p_end}
{phang}{stata . list b1 bse1 b2 bse2 if _n <= 2}{p_end}

{pstd}
These values are for two distinct subjects (identified by {cmd: b2}) within a single birth year (identified by {cmd: b1}).
We can pass more than one value to the {opt reat}, {opt reatse}, {opt reatref}, {opt reatrefse} options:

{phang}{stata . stdmest s1, reat(-.0795512 -1.39209) reatse(.1930458 .4813395) ci}{p_end}
{phang}{stata . stdmest s2, reat(-.0795512 -.1309338) reatse(.1930458 .4605677) ci}{p_end}

{pstd}
These predictions can be plotted, once again, using {helpb twoway}.

{pstd}
If we wanted to calculate the standardised survival difference between the two subjects above, we can use {cmd: stdmest} as follows:

{phang}{stata . stdmest s3, reat(-.0795512 -1.39209) reatse(.1930458 .4813395) reatref(-.0795512 -.1309338) reatrefse(.1930458 .4605677) ci contrast}{p_end}

{marker author}{...}
{title: Author}

{pstd}Alessandro Gasparini{p_end}
{pstd}Red Door Analytics AB{p_end}
{pstd}Stockholm, Sweden{p_end}
{pstd}E-mail: {browse "mailto:alessandro.gasparini@reddooranalytics.se":alessandro.gasparini@reddooranalytics.se}.{p_end}

{phang}
Please report any errors you may find, e.g., on {browse "https://github.com/RedDoorAnalytics/stdmest":GitHub} or by e-mail.
{p_end}
