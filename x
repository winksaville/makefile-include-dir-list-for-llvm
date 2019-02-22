#!/bin/bash
#xyz=("a b c")
#for f in ${xyz[@]} ; do echo item: $f ; done
declare -a ary=(a b c) ; echo "${ary[0]}"; echo "${ary[1]}"
