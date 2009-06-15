#!/bin/bash
# $Id: camlp5_comm.sh,v 1.7 2007/09/07 04:31:52 deraugla Exp $

MODE="-mode T"
ARGS1="$MODE"
FILE=
QUIET=no
while test "" != "$1"; do
	case $1 in
	-q) QUIET=yes;;
	*.ml*) FILE=$1;;
	*) ARGS1="$ARGS1 $1";;
	esac
	shift
done

head -1 $FILE >/dev/null || exit 1

set - $(head -1 $FILE)
if test "$2" = "camlp5r" -o "$2" = "camlp5"; then
	WHAT="$(echo $2 | sed -e "s/camlp5/$NAME/")"
	COMM="ocamlrun$EXE ../boot/$WHAT$EXE -nolib -I ../boot"
        if test "$(basename "$(dirname $OTOP)")" != "ocaml_stuff"; then
            COMM="$OTOP/boot/$COMM"
        fi
	shift; shift
	ARGS2=$(echo $* | sed -e "s/[()*]//g")
#	ARGS1="$ARGS1 -verbose"
	if test "$QUIET" = "no"; then echo $COMM $ARGS2 $ARGS1 $FILE; fi
	$COMM $ARGS2 $ARGS1 $FILE
else
	if test "$(basename $FILE .mli).mli" = "$FILE"; then
		OFILE=$(basename $FILE .mli).ppi
	else
		OFILE=$(basename $FILE .ml).ppo
	fi
	if test "$QUIET" = "no"; then echo cp $FILE $OFILE; fi
	cp $FILE $OFILE
fi
