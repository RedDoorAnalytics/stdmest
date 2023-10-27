Things to implement/add:

* Consider doing some calculations on the cloglog scale.

* Documenting code:
  - `help smcl`
  - `help help`

* Discuss defaults – must be sensible, and I don't think percentile method + 100 reps is, at the moment

* Started setting up the _partially marginal_ version of regression standardisation for 2 levels, in `stdmestm.ado`.
  See R implementation for details...

Notes:
* I _think_ I have implemented using distinct values of _t only. Tested it a little and seemed okay!
* Forcing rows with `_st == 0` to not be used in the standardisation process. Okay? Not okay?
