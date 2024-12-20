pip install -U setuptools wheel auditwheel-symbols ninja cmake "numpy<2.0.0"
# We want to figure out the CUDA version to download pytorch
# e.g. we can have system CUDA version being 11.7 but if torch==1.12 then we need to download the wheel from cu116
# see https://github.com/pytorch/pytorch/blob/main/RELEASE.md#release-compatibility-matrix
# This code is ugly, maybe there's a better way to do this.
export TORCH_CUDA_VERSION=$(python -c "from os import environ as env; \
    minv = {'1.12': 113, '1.13': 116, '2.0': 117, '2.1': 118, '2.2': 118, '2.3': 118, '2.4': 118, '2.5': 118}[env['MATRIX_TORCH_VERSION']]; \
    maxv = {'1.12': 116, '1.13': 117, '2.0': 118, '2.1': 121, '2.2': 121, '2.3': 121, '2.4': 124, '2.5': 124}[env['MATRIX_TORCH_VERSION']]; \
    print(max(min(int(env['MATRIX_CUDA_VERSION']), maxv), minv))" \
)

export WHEEL_PYTHON_VERSION=$(python -c "from os import environ as env; \
    version = {'37': 'cp37-cp37m', '38': 'cp38-cp38', '39': 'cp39-cp39', '310': 'cp310-cp310', '311': 'cp311-cp311', '312': 'cp312-cp312' }[env['MATRIX_PYTHON_VERSION']]; \
    print(version)" \
)

python --version
gcc --version
pip --version
which python
which pip

echo "install torch==${CI_TORCH_VERSION}+cu${TORCH_CUDA_VERSION}"
pip install --no-cache-dir torch==${CI_TORCH_VERSION} --index-url https://download.pytorch.org/whl/cu${TORCH_CUDA_VERSION}

echo "install flash_attn==2.6.3+${CI_TORCH_VERSION}+cu${TORCH_CUDA_VERSION}"
pip install --no-cache-dir https://github.com/Dao-AILab/flash-attention/releases/download/v2.6.3/flash_attn-2.6.3+cu${TORCH_CUDA_VERSION}torch${MATRIX_TORCH_VERSION}cxx11abiFALSE-${WHEEL_PYTHON_VERSION}-linux_x86_64.whl

echo "$(cat build_tools/VERSION.txt)+cu${TORCH_CUDA_VERSION}torch${CI_TORCH_VERSION}" > build_tools/VERSION.txt
echo "VERSION=$(cat build_tools/VERSION.txt)"
