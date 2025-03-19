pip install -U setuptools wheel auditwheel-symbols ninja cmake "numpy<2.0.0"
# We want to figure out the CUDA version to download pytorch
# e.g. we can have system CUDA version being 11.7 but if torch==1.12 then we need to download the wheel from cu116
# see https://github.com/pytorch/pytorch/blob/main/RELEASE.md#release-compatibility-matrix
# This code is ugly, maybe there's a better way to do this.
export TORCH_CUDA_VERSION=$(python -c "from os import environ as env; \
    minv = {'1.12': 113, '1.13': 116, '2.0': 117, '2.1': 118, '2.2': 118, '2.3': 118, '2.4': 118, '2.5': 118, '2.6': 118}[env['MATRIX_TORCH_VERSION']]; \
    maxv = {'1.12': 116, '1.13': 117, '2.0': 118, '2.1': 121, '2.2': 121, '2.3': 121, '2.4': 124, '2.5': 124, '2.6': 126}[env['MATRIX_TORCH_VERSION']]; \
    print(max(min(int(env['MATRIX_CUDA_VERSION']), maxv), minv))" \
)

python --version
gcc --version
pip --version
which python
which pip

echo "install torch==${CI_TORCH_VERSION}+cu${TORCH_CUDA_VERSION}"
pip install --no-cache-dir torch==${CI_TORCH_VERSION} --index-url https://download.pytorch.org/whl/cu${TORCH_CUDA_VERSION}

echo "$(cat build_tools/VERSION.txt)+cu${TORCH_CUDA_VERSION}torch${CI_TORCH_VERSION}cxxabi${CXX11_ABI}" > build_tools/VERSION.txt
echo "VERSION=$(cat build_tools/VERSION.txt)"
