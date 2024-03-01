export OMP_PLACES=sockets
export OMP_PROC_BIND=close
for TT in 32 16 8 4 2; do
# for TT in 32 16 8 4 2 1; do
    OMP_NUM_THREADS=$TT python bench.py
done