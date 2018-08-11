# Release Report / Dashboard

A collection scripts to read mutiple log files (from different environments), and extract the release version of software installed on a server, and display as a single table.

## ReleaseDasboard.ps1

* Will read all LOG files in a directory, and search for a release/reference line and extract the details such as version, and executed date
* The information is then stored in an array, and finally sorted according to the release version
* The result is outputed to the console in a CSV format, which can be piped to a file

## CSVtoHMTL.ps1

* Will read the contents of a CSV, and convert it to a formatted HTML table, with headings supplied as a parameter
* The table cells are formatted to be mint green in colour if they contain data, using Google API javascript 