#!/bin/sh
module_name="$1"
set -e
checkmodule -M -m -o ${module_name}.mod ${module_name}.te
package_args="-o ${module_name}.pp -m ${module_name}.mod"
if [ -f "${module_name}.fc" ]; then
    package_args="${package_args} --fc ${module_name}.fc"
fi

semodule_package ${package_args}
