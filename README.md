# Makefile include directory list fo LLVM

The following algorithm is used in ponyc [Makefile-ponyc](https://github.com/ponylang/ponyc/commit/9284debb574d15d9fd2d9f5bd1796d2a303fb61c).

In ponyc the Makefile uses `llvm-config --cflags` and then parses the output
to get a list of directories it wants to include. The are the `-I` and `-isystem`
parameters returned by `--cflags`. Another alternative, `llvm-config --includedir`,
is a subset of those returned by `--cflags`.
```
llvm.get_cflags := $(LLVM_CONFIG) --cflags $(LLVM_LINK_STATIC)
llvm.cflags := $(shell sh -c "$(llvm.get_cflags)")
llvm.get_include_dirs := echo '$(llvm.cflags)' | grep -oE -- '(^-I[[:space:]]*| -I[[:space:]]*|^-isystem[[:space:]]*| -isystem[[:space:]]*)[^[:space:]]+' | sed -E 's/^[[:space:]]*(-I[[:space:]]*|-isystem[[:space:]]*)//'
llvm.include_dirs := $(shell sh -c "$(llvm.get_include_dirs)")
```

The `llvm.include_dirs` can't just blindly be used because they could already
be present in the search path provided by the compiler (gcc/clang). The search
paths are embedded in the information returned by executing:
```
verbose_preprocess_string= $(shell echo | $(CC) -v -E - 2>&1)
```
Of course this has lots of information and prior to retriving the search paths we must
escape double quotes, ", and hash characters, #:
```
quoteDblQuote := $(subst ",\",$(verbose_preprocess_string))
quoted_verbose_preprocess_string := $(subst \#,\\\#,$(quoteDblQuote))
```

Then the search paths are extacted with:
```
get_search_paths := sed 's/\(.*\)search starts here:\(.*\)End of search list.\(.*\)/\2/'
search_paths := $(shell echo "$(quoted_verbose_preprocess_string)" | $(get_search_paths))
```
Then we loop through the include_dirs adding them the the final `llvm.includes`
only if they are not in the `search_paths`:
```
loopit :=								\
	for inc_dir in $(llvm.include_dirs); do				\
		if [[ " $(search_paths) " != *" $${inc_dir} "* ]]; then	\
			echo "-isystem $(CROSS_SYSROOT)$${inc_dir}";	\
		fi							\
	done

llvm.include = $(shell $(loopit))
```

Lastly, `llvm.include` is then passes as a parameter on the $(CC) $(CXX) command line.
