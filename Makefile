# "external definitions
LLVM_CONFIG := llvm-config
LLVM_LINK_STATIC :=
CROSS_SYSROOT := /cross

# Get cflags using llvm-config
llvm.get_cflags := $(LLVM_CONFIG) --cflags $(LLVM_LINK_STATIC)
##$(warning "llvm.get_cflags=$(llvm.get_cflags)")
llvm.cflags := $(shell sh -c "$(llvm.get_cflags)")

# For testing have more than one -I
llvm.cflags := -I/usr/include -march=x86-64  -I  /sec/time -I /usr/local/include -I   /3/4 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt -fPIC -Werror=date-time -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wno-missing-field-initializers -pedantic -Wno-long-long -Wno-comment -fdiagnostics-color -ffunction-sections -fdata-sections -O3 -DNDEBUG -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -I/xyz/abc
$(warning llvm.cflags="$(llvm.cflags)")

# Get include dirs using grep & sed to extract "-I x/xx" entries
llvm.get_include_dirs := "echo '$(llvm.cflags)' | grep -oE -- '(^| )-I\s*\S+' | sed 's/^\s*-I\s*//'"
#$(warning llvm.get_include_dirs=$(llvm.get_include_dirs))
llvm.include_dirs := $(shell sh -c $(llvm.get_include_dirs))
$(warning llvm.include_dirs="$(llvm.include_dirs)")

# Get verbose from preprocessing code to which has the search paths
# by using verbose "-v" and preprocess, "-E" parameters to compiler
verbose_preprocess_string= $(shell echo | $(CC) -v -E - 2>&1)

# We must escape any double quotes, ", and any hash, #, characters.
quoteDblQuote := $(subst ",\",$(verbose_preprocess_string))
quoted_verbose_preprocess_string := $(subst \#,\\\#,$(quoteDblQuote))

# Create a send command line to extract the search paths from the
# quoted verbose preprocess string
get_search_paths := sed 's/\(.*\)search starts here:\(.*\)End of search list.\(.*\)/\2/'
search_paths := $(shell echo "$(quoted_verbose_preprocess_string)" | $(get_search_paths))
$(warning search_paths=$(search_paths))

# Note: $(search_paths) is padded with a space on front and back so
# that when we search for the ${inc_dir} we are guaranteed that each
# item in $(search_paths) has a space at beginning and end.
loopit :=								\
	for inc_dir in $(llvm.include_dirs); do				\
		if [[ " $(search_paths) " != *" $${inc_dir} "* ]]; then	\
			echo "-isystem $(CROSS_SYSROOT)$${inc_dir}";	\
		fi							\
	done

$(warning loopit=$(loopit))
llvm.include = $(shell $(loopit))
$(warning llvm.include=$(llvm.include))
