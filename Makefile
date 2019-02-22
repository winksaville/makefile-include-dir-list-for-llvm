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
#result := $(shell ary=($(llvm.include_file_names)) ; for i in $${ary[@]}; do echo item: $$i; done)
#result := $(shell for i in $(llvm.include_file_names); do echo item: $$i; done) # Simplest

#Note: This does work, maybe becuase the "for" is a single statement?
#result := $(shell echo | for i in $(llvm.include_file_names); do echo item: $$i; done) # Simplest
#Note: This doesn't work result is empty, maybe because there are mutliple statements "ary=.." and "for i in ..."
#result := $(shell echo | ary=($(llvm.include_file_names)) ; for i in $${ary[@]}; do echo item: $$i; done)

# Using loopit variable for code
#loopit := for i in $(llvm.include_file_names); do echo item: $$i; done
loopit :=					\
	for i in $(llvm.include_file_names);	\
	do					\
		echo item: $$i;			\
	done
result := $(shell $(loopit))


#Testing

raw_search_paths= $(shell echo | $(CC) -v -E - 2>&1)
quoteDblQuote= $(subst ",\",${raw_search_paths})
quoted= $(subst \#,\\\#,${quoteDblQuote})
get_search_paths= sed 's/\(.*\)search starts here:\(.*\)End of search list.\(.*\)/\2/'
search_paths= $(shell echo "${quoted}" | $(get_search_paths))
$(warning search_paths=$(search_paths))

$(warning result=$(result))

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
