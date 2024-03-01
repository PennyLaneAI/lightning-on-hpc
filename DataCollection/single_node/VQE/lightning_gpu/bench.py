import pennylane as qml
from pennylane import numpy as np
from timeit import default_timer as timer

mols = [
    "H2", # 4 / 15
    "HeH+", # 4 / 27
    "H3+", # 6 / 66
    "He2", # 8 / 181
    "H2", # 8 / 185
    # "H4", # 8 / 185
    "LiH", # 12 / 631
    # "OH-", # 12 / 631
    "H3+", # 12 / 1403
    "BeH2", # 14 / 666
    "H2O", # 14 / 1086
    "H2", # 20 / 2951
    "C2H2", # 24 / 6500
]
basis_sets = [
    "STO-3G", # "H2",
    "STO-3G", # "HeH+",
    "STO-3G", # "H3+",
    "6-31G", # "He2",
    "6-31G", # "H2",
    # "STO-3G", # "H4",
    "STO-3G", # "LiH",
    # "STO-3G", # "OH-",
    "6-31G", # "H3+",
    "STO-3G", # "BeH2",
    "STO-3G", # "H2O",
    "CC-PVDZ", # "H2",
    "STO-3G", # "C2H2",
]
devicename = "lightning.qubit"
devicename = "lightning.gpu"
batch_obs=False
for mol, basis_set in zip(mols, basis_sets):
    dataset = qml.data.load("qchem", molname=mol, basis=basis_set)[0]
    ham, num_qubits = dataset.hamiltonian, len(dataset.hamiltonian.wires)
    hf_state = dataset.hf_state
    ham = dataset.hamiltonian
    wires = ham.wires
    dev = qml.device(devicename, wires=wires, batch_obs=batch_obs)

    n_electrons = dataset.molecule.n_electrons

    singles, doubles = qml.qchem.excitations(n_electrons, len(wires))

    @qml.qnode(dev, diff_method="adjoint")
    def cost(weights):
        qml.templates.AllSinglesDoubles(weights, wires, hf_state, singles, doubles)
        return qml.expval(ham)

    np.random.seed(42)
    params = np.random.normal(0, np.pi, len(singles) + len(doubles))

    opt = qml.GradientDescentOptimizer(stepsize=0.2)

    energy = [1000]

    # store the values of the circuit parameter
    angle = [params]

    #warmup
    opt.step_and_cost(cost, params)

    max_iterations = 10
    conv_tol = 1e-16
    timetot = 0
    for n in range(max_iterations):
        start = timer()
        params, prev_energy = opt.step_and_cost(cost, params)
        end = timer()
        timetot += end-start
        energy.append(cost(params))
        angle.append(params)
        conv = np.abs(energy[-1] - prev_energy)
        if conv <= conv_tol:
            break

    message = f"{mol}, {basis_set}, {len(wires)}, {len(ham.coeffs)}, {timetot}"
    print(message)
    with open(f"{devicename}-data.txt", "a") as f:
        f.write(message+"\n")
