# `stdmest`

`stdmest` is a Stata post-estimation command for hierarchical survival models fitted using [`mestreg`](https://www.stata.com/manuals/memestreg.pdf).

This command can be used to obtain predictions of, e.g., standardised survival probabilities while fixing predicted values of the random effects.

In other words, `stdmest` can obtain marginal predictions across observed covariates (i.e., the fixed effects) while fixing predicted values of the random effects.
Built-in post-estimation commands for `mestreg` can do the opposite, marginalising over the random effects.

## Installation

The dev version of `stdmest` cen be installed from this GitHub repository by typing the following in your Stata console:

```{stata}
net install stdmest, from("https://raw.githubusercontent.com/RedDoorAnalytics/stdmest/main/")
```
