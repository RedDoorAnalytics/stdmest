# `stdmest`

`stdmest` is a Stata post-estimation command for hierarchical survival models fitted using [`mestreg`](https://www.stata.com/manuals/memestreg.pdf).

This command can be used to obtain predictions of, e.g., standardised survival probabilities while fixing predicted values of the random effects.

In other words, `stdmest` can obtain marginal predictions across observed covariates (i.e., the fixed effects) while fixing predicted values of the random effects.
Built-in post-estimation commands for `mestreg` can do the opposite, marginalising over the random effects.

Three commands are provided by this package:

* `mestreg_export`, to export results (`e(b)`, `e(V)`) for a fitted `mestreg` model;

* `stdmest`, to perform regression standardisation while fixing random intercept values.
  Any number of random intercepts can be fixed using `stdmest`;

* `stdmestm`, to perform regression standardisation fixing one random intercept value while integrating over a second random intercept.
  For this, only three-level models are supported.

## Installation

The dev version of `stdmest` cen be installed from this GitHub repository by typing the following in your Stata console:

```{stata}
net install stdmest, from("https://raw.githubusercontent.com/RedDoorAnalytics/stdmest/main/")
```
