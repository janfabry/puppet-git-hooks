#!/bin/sh

git_root=`git rev-parse --show-toplevel`
syntax_errors=0
error_msg=$(mktemp /tmp/error_msg_rspec-puppet.XXXXX)

# Run rspec-puppet tests
if [ `which rspec` ]; then
    for puppetmodule in `git diff --cached --name-only --diff-filter=ACM | grep '\.*.pp$\|\.*.rb$'`; do
        module_dir=$(dirname $puppetmodule | cut -d"/" -f1,2)
        cd $module_dir
        rspec > $error_msg
        RC=$?
        cd - > /dev/null
        if [ $RC -ne 0 ]; then
            cat $error_msg
            echo "rspec-puppet test failed for $module_dir (see above)"
            syntax_errors=`expr $syntax_errors + 1`
        fi
    done
fi

rm $error_msg

if [ "$syntax_errors" -ne 0 ]; then
    echo "Error: $syntax_errors rspec-puppet tests failed. Commit will be aborted."
    exit 1
fi

exit 0