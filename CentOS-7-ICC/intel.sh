if [ -z "$INTEL_SH_GUARD" ]; then
    source /opt/intel/parallel_studio_xe*/compilers_and_libraries*/linux/pkg_bin/compilervars.sh intel64
fi
export INTEL_SH_GUARD=1
