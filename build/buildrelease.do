// Package files for new release
local newversion 0_1_0
capture mkdir ../release/version_`newversion'
local fdir ../release/version_`newversion'/

// -modexpt-
copy ../modexpt/modexpt.ado `fdir', replace
copy ../modexpt/modexpt.sthlp `fdir', replace

// -stdmest-
copy ../stdmest/stdmest.ado `fdir', replace
copy ../stdmest/stdmest.sthlp `fdir', replace

// -stdmestm-
copy ../stdmestm/stdmestm.ado `fdir', replace
copy ../stdmestm/stdmestm.sthlp `fdir', replace

// Mata library
capture erase `fdir'lstdmest.mlib
copy ../lstdmest.mlib `fdir', replace

// README
copy ../README.md `fdir', replace
