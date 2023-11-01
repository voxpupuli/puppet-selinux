#!/bin/sh
module_name="$1"
module_dir="$2"

set -e

cd "$module_dir"
mkdir -p tmp

checkmodule -M -m -o "tmp/${module_name}.mod" "${module_name}.te"

if [ -s "${module_name}.fc" ]; then
    semodule_package -o "${module_name}.pp" -m "tmp/${module_name}.mod" --fc "${module_name}.fc"
else
    semodule_package -o "${module_name}.pp" -m "tmp/${module_name}.mod"
fi
