{smcl}
{* *! version 1.0.0}{...}
{viewerjumpto "Syntax" "mestreg_export##syntax"}{...}
{viewerjumpto "Description" "mestreg_export##description"}{...}
{viewerjumpto "Options" "mestreg_export##options"}{...}
{viewerjumpto "Remarks" "mestreg_export##remarks"}{...}
{viewerjumpto "Examples" "mestreg_export##examples"}{...}

{synopt :{cmd: mestreg_export} {hline 2} Export estimation results of {cmd: mestreg} models to an Excel file}

{marker syntax}{...}
{title: Syntax}

{phang}
Export results of {cmd: mestreg} models to an Excel file:
{p_end}

{phang2}
{cmd: mestreg_export}, {opt filename(string)} [{opt replace}]
{p_end}

{synoptset}{...}
{marker options_table}{...}
{synopthdr: Option}
{synoptline}
{synopt: {cmdab: filen:ame(}{it: string})}Name of the file to export results to{p_end}
{synopt: {cmdab: replace}}Overwrite Excel file{p_end}
{synoptline}

{pstd}See {helpb putexcel}, which is used under-the-hood, for more details.

{title: Description}

{pstd}
{cmd: mestreg_export} can be used to export an Excel file with estimated coefficients and their variance-covariance matrix of {cmd: mestreg} models.
Specifically, {cmd: e(b)} and {cmd: e(V)} that are stored in {cmd: ereturn} by {cmd: mestreg} are exported in separate tabs of the Excel file specified with {opt filename(string)}.

{title: Options}

{phang}
{opt filename(string)} specifies the name of the Excel file to be used to export the estimation results after {cmd: mestreg}.
The name must be a string, potentially including the path to a location other than the working directory.
{p_end}

{phang}
{opt replace} overwrites the specified Excel file, if needed.

{title: Examples}

{pstd}
We start by replicating one of the examples from the {helpb mestreg} help file:

{phang}{stata webuse catheter: . webuse catheter}{p_end}
{phang}{stata "mestreg age female || patient:, distribution(weibull)": . mestreg age female || patient:, distribution(weibull)}{p_end}

{pstd}
Then, we export the estimation results in a file named {cmd: test.xlsx}:

{phang}{stata mestreg_export, filename("test.xlsx"): . mestreg_export, filename("test.xlsx")}{p_end}

{pstd}
If we were to run the above command again we would get an error, as the file already exists.
We can overcome this by using the {opt replace} option:

{phang}{stata mestreg_export, filename("test.xlsx") replace: . mestreg_export, filename("test.xlsx") replace}{p_end}

{title: Author}

{pstd}Alessandro Gasparini{p_end}
{pstd}Red Door Analytics AB{p_end}
{pstd}Stockholm, Sweden{p_end}
{pstd}E-mail: {browse "mailto:alessandro.gasparini@reddooranalytics.se":alessandro.gasparini@reddooranalytics.se}.{p_end}

{phang}
Please report any errors you may find, e.g., on {browse "https://github.com/RedDoorAnalytics/stdmest":GitHub} or by e-mail.
{p_end}
