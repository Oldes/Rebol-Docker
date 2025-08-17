#!/usr/local/bin/rebol -cs
REBOL []

print "Content-type: text/html^/"
print "<html><body><h1>REBOL CGI Works!</h1><pre>"
print ["Current time:" now]
probe system/options
print "Environment variables:"
print list-env

foreach file read dir: %/usr/local/apache2/conf/ [
	print newline 
	print-horizontal-line
	probe file
	conf: read/string dir/:file
	replace/all conf "<" "&lt;"
	print conf
	print-horizontal-line
]

print "</pre></body></html>"