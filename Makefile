LLVM_CONFIG := llvm-config
LLVM_LINK_STATIC :=
CROSS_SYSROOT :=

llvm.get_cflags := $(LLVM_CONFIG) --cflags $(LLVM_LINK_STATIC)
##$(warning "llvm.get_cflags=$(llvm.get_cflags)")
llvm.cflags := $(shell sh -c "$(llvm.get_cflags)")
#$(warning llvm.cflags="$(llvm.cflags)")

# test_string has two -I
test_string := -I/usr/include -march=x86-64  -I  /sec/time   -I   /3/4 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt -fPIC -Werror=date-time -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wno-missing-field-initializers -pedantic -Wno-long-long -Wno-comment -fdiagnostics-color -ffunction-sections -fdata-sections -O3 -DNDEBUG -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -I/xyz/abc  
#test_string := $(llvm.cflags)
llvm.get_include_file_names := "echo '$(test_string)' | grep -oE -- '(^| )-I\s*\S+' | sed 's/^\s*-I\s*//'"
#$(warning llvm.get_include_file_names=$(llvm.get_include_file_names))
llvm.include_file_names := $(shell sh -c $(llvm.get_include_file_names))
$(warning llvm.include_file_names="$(llvm.include_file_names)")

## iterate the include_file_names individually
#n="a,b,c"
##iterate := IFS=',' ; for i in `echo $n`; do echo $f; done
#iterate := IFS=',' ;for i in `echo "Hello,World,Questions,Answers,bash shell,script"`; do echo $i; done
#iterate := declare -a ary=($$(llvm.include_file_names)) ; for i in $${ary[@]}; do echo $$i; done
#iterate := 'declare -a ary=("a b c") ; for i in ${ary[@]}; do echo $i; done'
#$(warning iterate=$(iterate))
#result := $(shell sh -c $(iterate))
#result := $(shell echo | $(iterate))

#These work
#result := $(shell echo | echo "hi" ; echo "bye")
#result := $(shell echo | for i in `seq 1 4`; do echo item: $$i; done)
#result := $(shell for i in `seq 1 4`; do echo item: $$i; done)
#result := $(shell declare -a ary=(a b c) ; echo $${ary[0]}; echo $${ary[1]})
#result := $(shell declare -a ary=("a b c") ; for i in $${ary[@]}; do echo "item: $$i"; done)
#result := $(shell declare -a ary=($(llvm.include_file_names)) ; for i in $${ary[@]}; do echo item: $$i; done)
#result := $(shell declare -a ary=($(llvm.include_file_names)) ; for i in $${ary[@]}; do echo "item: $$i"; done)

#loopit := declare -a ary=($(llvm.include_file_names)) ; for i in $${ary[@]}; do echo "item: $$i"; done
#result := $(shell $(loopit))

#loopit :=						\
#	declare -a ary=($(llvm.include_file_names));	\
#       	for i in $${ary[@]};				\
#	do						\
#		echo "item: $$i";			\
#	done
#result := $(shell $(loopit))


#Testing

raw= $(shell echo | $(CC) -v -E - 2>&1)
#$(warning raw=${raw})
quoteDblQuote= $(subst ",\",${raw})
quoted= $(subst \#,\\\#,${quoteDblQuote})
$(warning quoted=${quoted})
sxx= sed 's/\(.*\)search starts here:\(.*\)End of search list.\(.*\)/\2/'
$(warning sxx=$(sxx))
###search_paths= $(shell echo "Using built-in specs. COLLECT_GCC=cc Target: x86_64-pc-linux-gnu Configured with: /build/gcc/src/gcc/configure  search starts here: /abc/a /usr/include /usr/local/include End of search list. other" | $(sxx))
###search_paths= $(shell echo "search starts here:  /usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/include  /usr/local/include  /usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/include-fixed  /usr/include End of search list. \# 1 \"<stdin>\" ") # 1 \"<built-in>\" # 1 \"<command-line>\" # 31 \"<command-line>\" # 1 \"/usr/include/stdc-predef.h\" 1 3 4 # 32 \"<command-line>\" 2 # 1 \"<stdin>\" COMPILER_PATH=/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/:/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/:/usr/lib/gcc/x86_64-pc-linux-gnu/:/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/:/usr/lib/gcc/x86_64-pc-linux-gnu/ LIBRARY_PATH=/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/:/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/../../../../lib/:/lib/../lib/:/usr/lib/../lib/:/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/../../../:/lib/:/usr/lib/ COLLECT_GCC_OPTIONS='-v' '-E' '-mtune=generic' '-march=x86-64'")
###search_paths= $(shell echo "search starts here:  /usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/include  /usr/local/include  /usr/lib/gcc/x86_64-pc-linux-gnu/8.2.1/include-fixed  /usr/include End of search list.")
search_paths= $(shell echo "${quoted}" | $(sxx))
$(warning search_paths=$(search_paths))

#These don't work
#result := $(shell echo | declare -a ary=($(llvm.include_file_names)) ; for i in $${ary[@]}; do echo item: $$i; done)
#result := $(shell echo | declare -a ary=(a b c) ; echo "$${ary[0]}"; echo "$${ary[1]}")
#result := $(shell echo | declare -a ary=(a b c) ; for i in $${ary[@]}; do echo $$i; done)
#result := $(shell echo | ary=(a b c) ; for i in "$${ary[@]}"; do echo $$i ; done)

#$(warning result=$(result))

#llvm.include.dir := $(CROSS_SYSROOT)$(shell $(LLVM_CONFIG) --includedir $(LLVM_LINK_STATIC))
#include.paths := $(shell echo | $(CC) -v -E - 2>&1)
#ifeq (,$(findstring $(llvm.include.dir),$(include.paths)))
## LLVM include directory is not in the existing paths;
## put it at the top of the system list
#llvm.include := -isystem $(llvm.include.dir)
#else
## LLVM include directory is already on the existing paths;
## do nothing
#llvm.include :=
#endif
#
