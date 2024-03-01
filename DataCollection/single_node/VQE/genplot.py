import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

filenames = ["lightning_qubit/lightning.qubit-32-data.txt", "lightning_gpu/lightning.gpu-data.txt", "lightning_kokkos/lightning.kokkos-data.txt"]
codenames = ["L-Qubit (32 threads)", "L-GPU (Batch=4)", "L-Kokkos (CUDA)"]


def parse_csv(filename):
    with open(filename, "r") as fid:
        lines = fid.readlines()
    # ncols = lines[0].count(",") + 1
    data = {
        "mols": [],
        "bases": [],
        "num_qubits": [],
        "num_ham": [],
        "times": [],
    }
    for line in lines:
        tmp = line.split(",")
        data["mols"].append(tmp[0])
        data["bases"].append(tmp[1])
        data["num_qubits"].append(int(tmp[2]))
        data["num_ham"].append(int(tmp[3]))
        data["times"].append(float(tmp[4]))

    data["num_qubits"] = np.array(data["num_qubits"])
    data["num_ham"] = np.array(data["num_ham"])
    data["times"] = np.array(data["times"])

    return data


datas = [parse_csv(f) for f in filenames]

palette = list(mcolors.TABLEAU_COLORS.keys())
palette = [p[4:] for p in palette]

fig = plt.figure(figsize=(6, 5), dpi=500)
left, bottom, width, height = 0.125, 0.3, 0.8, 0.6
width = (1-left*2)
ax = fig.add_axes([left, bottom, width, height])

nt = len(datas)
width = 0.30
count = 0
for i, item in enumerate(zip(datas, codenames)):
    data, code = item 
    labels = [l + f"({n}/{t})" for l, n,t in zip(data["mols"], data["num_qubits"], data["num_ham"])]
    y = data["times"]
    x = np.arange(len(y))
    label = f"{code}"
    ax.bar(
        x + width * (count - nt / 2 + 1 / 2),
        y,
        width,
        align="center",
        color=palette[i],
        edgecolor=palette[i],
        label=label,
        # fill=code=="LQ",
    )
    count += 1

ax.set_xlabel("Molecule (# qubits/# H terms)")
ax.set_xticks(x)
ax.set_xticklabels(labels, rotation=90)
ax.set_yscale("log")
ax.set_ylabel("Time [sec / 10 iterations]")
# ax.set_title("Time vs. molecule")
ax.legend(loc="best")
plt.savefig("time_vs_mol.png")
