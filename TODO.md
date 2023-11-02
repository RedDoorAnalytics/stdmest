Things to implement/add:

* Consider doing some calculations on the cloglog scale.

* Documenting code:
  - `help smcl`
  - `help help`

* Discuss defaults – must be sensible, and I don't think percentile method + 100 reps is, at the moment

* Point estimates for partially marginal predictions done – need to do a bit more testing though.

* Need to implement the contrasts logic.

* Need to implement the CIs logic.

Notes:
* I _think_ I have implemented using distinct values of _t only. Tested it a little and seemed okay!
* Forcing rows with `_st == 0` to not be used in the standardisation process. Okay? Not okay?

* Compare -if- with margin's if

* Error checks could be standardised between `stdmest` and `stdmestm`, e.g., with a call to a certain ad-hoc function.
  This needs a separate .ado file.

