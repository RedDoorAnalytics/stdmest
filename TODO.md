Things to implement/add/consider:

* Consider doing some calculations on the cloglog scale.

* Discuss defaults – must be sensible, and I don't think percentile method + 100 reps is, at the moment

Notes:
* I _think_ I have implemented using distinct values of _t only. Tested it a little and seemed okay!
* Forcing rows with `_st == 0` to not be used in the standardisation process. Okay? Not okay?

* Error checks could be standardised between `stdmest` and `stdmestm`, e.g., with a call to a certain ad-hoc function.
  This needs a separate .ado file.
