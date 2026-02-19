# -stdmest-: Post-Estimation Predictions for Standardised Hierarchical Contrasts after -mestreg- and -uhtred- Models

-stdmest- is a Stata post-estimation command for hierarchical survival models fitted using -[mestreg](https://www.stata.com/manuals/memestreg.pdf)- or -[uhtred](https://github.com/RedDoorAnalytics/uhtred)-.

This command can be used to obtain predictions of, e.g., standardised survival probabilities while fixing posterior predictions of the random effects at any level of the hierarchy.

In other words, -stdmest- can obtain marginal predictions standardising across observed covariates (i.e., the fixed effects) while fixing predicted values of the random effects.
Built-in post-estimation commands for -mestreg- and -uhtred- can do the opposite, i.e., marginalising over the random effects.

Three commands are provided by this package:

* `modexpt`, to export results (`e(b)`, `e(V)`) for fitted -mestreg- and -stmixed- models.
  This is useful to, e.g., use the R version of `stdmest`, which is available [here](https://github.com/RedDoorAnalytics/stdmest-r);

* `stdmest`, to perform regression standardisation while fixing random intercept values.
  Any number of random intercepts can be fixed using this command;

* `stdmestm`, to perform regression standardisation fixing one random intercept value while integrating over a second random intercept.
  For this, only three-level models (e.g., patients nested within surgeons, surgeons nested within hospitals) are supported.

## Installation

The development version of -stdmest- can be installed from this GitHub repository by typing the following in your Stata console:

```{stata}
net install stdmest, from("https://raw.githubusercontent.com/RedDoorAnalytics/stdmest/main/")
```

## References

* Gasparini, A., Crowther, M.J. & Schaffer, J.M. Standardized survival probabilities and contrasts between hierarchical units in multilevel survival models. BMC Med Res Methodol (2026). https://doi.org/10.1186/s12874-026-02782-8
