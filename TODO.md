Things to implement/add:

* Do all calculations for survival on the c-log-log scale to ensure predictions are bounded between 0-1
* Allow setting the confidence level (currently hard-coded at 5%)
* It is horribly slow... but it seems to work

Some points to optimise code:

* Can definitely write more sub-routines
* Can probably use matrices and not add to data, summarise, and then drop
* Use views instead of copying data from Stata to Mata
