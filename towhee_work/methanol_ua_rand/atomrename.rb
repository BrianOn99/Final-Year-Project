#!/usr/bin/ruby -n
if ARGF.lineno % 12 == 0
  $_.sub! "H ", "HO"
end
print $_
 
