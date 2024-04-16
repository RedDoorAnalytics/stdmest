Things to implement/add/consider:

* Consider doing some calculations on the cloglog scale.

Notes:

* I _think_ I have implemented using distinct values of _t only. Tested it a little and seemed okay!
* Forcing rows with `_st == 0` to not be used in the standardisation process. Okay? Not okay?
* Error checks could be standardised between `stdmest` and `stdmestm`, e.g., with a call to a certain ad-hoc function.
  This needs a separate .ado file.
* Modifying the view on `xbb` is risky (e.g., in 	`xbb = xbb :+ reat`).
* The main loop can be done in Mata, for (1) efficiency and (2) to avoid incurring in issues due to the large number of columns to be added to the dataset.

* Call Stata from Mata:
  - `_stata("predict, xb")`, `help mata stata`

* merlin-ish loop:
  ```
  for (i in 1:B) {
    merlin_parse(GML)
    merlin_util_xzb(GML, new_parameters)
    merlin_predict(GML)
  }
  ```
