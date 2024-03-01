This directory contains the workload data for the circuit-cutting example workload on Perlmutter.

PennyLane-Lightning was built using the v0.35.0 pre-release hash `102d848cc4232afb181eed33c753efd4093467fb` for both Lightning-Qubit and Lightning-GPU against CUDA 12.2 on Perlmutter.

To build a comparable environment, use the follow steps:

```bash
module load python cudatoolkit gcc/11.2.0
python -m venv venv
source ./venv/bin/activate
git clone https://github.com/PennyLaneAI/pennylane-lightning 
cd pennylane-lightning && git checkout 102d848cc4232afb181eed33c753efd4093467fb
python -m pip install -r requirements-dev.txt
python -m pip install git+https://github.com/PennyLaneAI/pennylane.git@f7bba2b8a21319309b21250073492573f5ee967a#egg=PennyLane
python -m pip install . # Lightning-Qubit and core functionality
CXX=g++ PL_BACKEND="lightning_gpu" python -m pip install -e . # Lightning-GPU
python -m pip install ray
```

For reference, the `pip freeze` output used for the workload is contained in `requirements.txt`.

To build a working environment against the latest-released version of PennyLane, use the following:

```bash
module load python cudatoolkit gcc/11.2.0
python -m venv venv
source ./venv/bin/activate
python -m pip install pennylane pennylane-lightning-gpu custatevec_cu12 ray
```
