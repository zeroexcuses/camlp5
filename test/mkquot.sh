#!/bin/sh
# mkquot.sh,v

echo '(* file generated by mkquot.sh: do not edit! *)'
echo
../meta/camlp5r -nolib -I ../meta ../etc/pa_mktest.cmo ../etc/pr_r.cmo -flag D -impl ../main/mLast.mli |
sed -e '1,/begin_stuff/d; /end_stuff/,$d'
