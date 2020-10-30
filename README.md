# rfilter

Usage :
```
cat log*.txt | rfilter 'pprint _1,_3,_.size," ==> ",_0'
#  extract first and third field, number of field,all line,  foreach line ( lines splitted with \s*),
#  _[0] == _1 ; _[1]==_2 . . .

rfilter 'expression' log*.txt 
# same

rfilter -F pattern -v a=b -v cc=dd 'expression' log*.txt
#       pattern is used for splitting lines
#       define $a with value 'b' and $cc='dd'

rfilter  # without args
  ....>> help
```  

Tested on linux and Windows.

Work (faster) with jruby.

For plotting, gem 'gruff' is used.

# mecanism for function with END action

Some function need that something be done at the end of stdin.

By exemple, ```sum(_1)``` will sum  contents of first collumn, and wanted to print the value at the end of scan.
+
They are 3 patterns for that :
* eend {} : declare the bloc of instruction to be execute at the end
* write some ruby data in $pending : at the end; $pending is pretty-printed
* write in $pending a Hash with template : {type: :yourendname ,data: [...]}.
  At the end, method 'eend_yourendname()' will be called. it can work with $pending[:data].

See statistics(i) function for simple usage of this pattern.

# List of special functions

```
show()                         : helper for debugging : show each field scanned by rfilter  on first line of stdin, and exit
eend(&b)                       : specify a bloc to evaluate after end of input scanning
timediff(delta_max,date=nil)   : extract date from current line and compare with last one, call bloc if delta is 
                                 greater than delta_max, in seconds
ifdiff(field)                  : yield bloc if parameter value is distinct of last call value
```

Extract some strings, and print
-------------------------------

```
clear()                        : clear screen
extr(word)                     : extract first match in current line
atoi(str=nil)                  : return first number in scaned in current line (or in str parameter)
after(str,x=1,n=1)             : extract next word after a word in current line
sum(i)                         : add all data in a column/data
mult(i)                        : mutliply all data in a column
statistics(i)                  : register value, at end calculus and print mean/median/stddev
```

Ploting
-------


plotting is global : one session generate one raster image, containing one zone plot with one or several curve/barrgraph.

Raster file name (in /tmp) is printed at the end.

```
plot(*v)                       : register some value in only-one curve, plot line at end
splot(name,value)              : append value to named curve, plot curves in one plot, at end
rplot(name,lvalue,h=nil)       : append values in curve name, plot graph at end (one call >> one curve)
bplot(label,*v)                : register x/y values (label and values) in curves, plot bargraphs at end (several call=>several barrs)
```



synthesis in Hashmap(s)
-----------------------

```
toh(a,b)                       : put in Hash h[a]=b ; print Hash at exit
tohcount(a,b="1")              : put in Hash h[a]+=b ; print Hash at exit
tohlist(a,b="?")               : push b in array in h[a] ; print Hash of Array at exit
tohh(a,b,c)                    : put in Hash h[a][b]= c ; print Hash of hash at exit
tohhcount(a,b,n=1)             : put in Hash h[a][b]+= n ; print Hash of hash at exit
``````


Selection and format
--------------------

```
pprint(*args)                  : print args in context : blank-separated, _1,_2... is understand, 
delta(value,no=0)              : compare value with old-one, varname 'no'. so several delta() can be used in one session
```

stop/skip packet on stdin lines
-------------------------------

```
skip_until(filter)             : do nothing until a line match ; eval bloc after this time 
stop_after(n)                  : stop n seconds after startup
stop_nol(n)                    : stop if noline exceed parameter (print beginning and stop)
stop_if(v)                     : stop if parameter is true
```




# simples Exemples

```
cat log*.txt | rfilter 'expression' 
```

or
```
rfilter 'expression' *.txt`
```

Count number of file which have size bigger than 1K:
```
ls -l | rfilter 'sell {_5.to_i>1024}' | rfilter 'sum 1'
```

Format lines

```
ls -l | rfilter "format('%-15s | %s',_9,_5)" 
```

extract data from json fragment, en sumerize at end
A directorie have file contening this kind of fragment :
```
{"Action":"/BootNotification", "chargeBoxIdentity":"FR*S33*E*2232*A-1", "chargePointModel":"eee", "chargePointSerialNumber":"89798 "chargeBoxSerialNumber":"87909", "firmwareVersion":"23.44", "iccid":"888888888888888", "imsi":"999999999999", "date":"2018-01-13 20:16:55"},
. . . .
```

This code create a CSV file contenning last value of iccid and imsi for each equipment Id (chargeboxId) :`
```
grep iccid * | rfilter 'cbi=extr(/"chargeBoxIdentity":"(.*?)"/);\
                        iccid=extr(/"iccid":"(.*?)"/);\
                        imsi=extr(/"imsi":"(.*?)"/); \
                        toh(cbi,"%s;%s" % [iccid,imsi]) if iccid; \
                        eend { $pending.each {|k,v| puts "#{k};#{v}" }}' > iccid_imsi.csv

```

Explanation:
* extr extract field frem regexp
* toh(k,v) memorise $pending[k]=v , so at the ending, $pending contain last value of each key 'k'
* eend declare code to be executed : it scan $pending and format 'chargeboxId;iccid;imsi' foreach equipment in log.
(the eend declaration is repeated for each line : stupid but efficace )


