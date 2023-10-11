Things to implement/add:

* Consider doing some calculations on the cloglog scale.
  But:
    1. Make sure the order of operations is correct (e.g., take the avg. on the natural vs transformed scale)
    2. Can also just return SEs
    3. Can also "clip" values to be in the [0,1] range

* Sketch functions signatures:
  - function 1:
    + does this: [...]
    + syntax: stdmest var, ci() cipercentile [...]
  - function 2:
    + [...]
    + [...]
  - [...]

* Start documenting code:
  - Start from existing help file
  - E.g., see `sthlp` files from other packages
  - `help smcl`
  - `help help`
