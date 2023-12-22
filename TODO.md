Things to implement/add/consider:

* Consider doing some calculations on the cloglog scale.

Notes:

* I _think_ I have implemented using distinct values of _t only. Tested it a little and seemed okay!
* Forcing rows with `_st == 0` to not be used in the standardisation process. Okay? Not okay?
* Error checks could be standardised between `stdmest` and `stdmestm`, e.g., with a call to a certain ad-hoc function.
  This needs a separate .ado file.
* Modifying the view on `xbb` is risky (e.g., in 	`xbb = xbb :+ reat`).
* Many functions can be shared between `stdmest` and `stdmestm` via a Mata library.
* The main loop can be done in Stata, for (1) efficiency and (2) to avoid incurring in issues due to the large number of columns to be added to the dataset.
