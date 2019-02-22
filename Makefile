LLVM_CONFIG := llvm-config
LLVM_LINK_STATIC :=
CROSS_SYSROOT := /cross

llvm.get_cflags := $(LLVM_CONFIG) --cflags $(LLVM_LINK_STATIC)
##$(warning "llvm.get_cflags=$(llvm.get_cflags)")
llvm.cflags := $(shell sh -c "${llvm.get_cflags}")

# For testing have more than one -I
llvm.cflags := -I/usr/include -march=x86-64  -I  /sec/time   -I   /3/4 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt -fPIC -Werror=date-time -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wno-missing-field-initializers -pedantic -Wno-long-long -Wno-comment -fdiagnostics-color -ffunction-sections -fdata-sections -O3 -DNDEBUG -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -I/xyz/abc  
$(warning llvm.cflags="$(llvm.cflags)")

# Get include dirs using grep & sed to extract "-I x/xx" entries
llvm.get_include_dirs := "echo '$(llvm.cflags)' | grep -oE -- '(^| )-I\s*\S+' | sed 's/^\s*-I\s*//'"
#$(warning llvm.get_include_dirs=$(llvm.get_include_dirs))
llvm.include_dirs := $(shell sh -c $(llvm.get_include_dirs))
$(warning llvm.include_dirs="$(llvm.include_dirs)")

## iterate over strings with spaces, see: https://stackoverflow.com/questions/9084257/bash-array-with-spaces-in-elements
n=Hello World Questions Answers "bash shell" script
#iterate := for i in d "e" "f h"; do echo item=$$i; done
iterate := for i in $n; do echo item=$$i; done # Simplest
#iterate := ary=($n); IFS=''; for i in $${ary[@]}; do echo item=$$i; done # IFS='' needed else "bash shell" is two items
$(warning iterate=$(iterate))
result_iterate := $(shell $(iterate))
$(warning result_iterate=$(result_iterate))

# These work: Examples of using shell and capturing output with "looping"
#result := $(shell echo | for i in `seq 1 4`; do echo item: $$i; done)
#result := $(shell echo "hi" ; echo "bye")
#result := $(shell for i in `seq 1 4`; do echo item: $$i; done)
#result := $(shell ary=(a b c) ; echo $${ary[0]}; echo $${ary[1]})
#result := $(shell ary=(a b c) ; for i in $${ary[@]}; do echo $$i; done)
#result := $(shell ary=(a b c) ; for i in "$${ary[@]}"; do echo $$i ; done)
#result := $(shell ary=("a b c") ; for i in "$${ary[@]}"; do echo $$i ; done)
#result := $(shell ary=("a b c") ; for i in $${ary[@]}; do echo "item: $$i"; done)
#result := $(shell ary=($(llvm.include_dirs)) ; for i in $${ary[@]}; do echo item: $$i; done)
#result := $(shell for i in $(llvm.include_dirs); do echo item: $$i; done) # Simplest

#Note: This does work, maybe becuase the "for" is a single statement?
#result := $(shell echo | for i in $(llvm.include_dirs); do echo item: $$i; done) # Simplest
#Note: This doesn't work result is empty, maybe because there are mutliple statements "ary=.." and "for i in ..."
#result := $(shell echo | ary=($(llvm.include_dirs)) ; for i in $${ary[@]}; do echo item: $$i; done)

$(warning result=$(result))

# Get the search paths using verbose "-v" and preprocess, "-E" parameters
verbose_preprocess_string= $(shell echo | $(CC) -v -E - 2>&1)

# We must escape any double quotes, ", and any hash, #, characters.
quoteDblQuote= $(subst ",\",${verbose_preprocess_string})
quoted_verbose_preprocess_string= $(subst \#,\\\#,${quoteDblQuote})

# Create a send command line to extract the search paths from the
# quoted verbose preprocess string
get_search_paths= sed 's/\(.*\)search starts here:\(.*\)End of search list.\(.*\)/\2/'
search_paths= $(shell echo "${quoted_verbose_preprocess_string}" | $(get_search_paths))
$(warning quoted_search_paths=$(quoted_search_paths))

# Note: ${search_paths} is padded with a space on front and back so
# that when we search for the ${inc_dir} we are guaranteed that each
# item in ${search_paths} has a space at beginning and end.
loopit :=								\
	for inc_dir in ${llvm.include_dirs}; do				\
		if [[ " ${search_paths} " != *" $${inc_dir} "* ]]; then	\
			echo "-isystem ${CROSS_SYSROOT}$${inc_dir}";	\
		fi							\
	done

$(warning loopit=$(loopit))
llvm.include = $(shell $(loopit))
$(warning llvm.include=$(llvm.include))

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
