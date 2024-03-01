
#!/bin/bash

idx=0

for entry in $(ls $PWD/ | grep out); do 
    exec_method=$(echo $entry | awk '{split($0,a,"_"); print a[2]}')
    if [ $idx -eq 0 ]; then
        cat data_header.csv > ${exec_method}.csv
        idx=$(($idx+1))
    fi
    slurm_id=$(echo $entry | awk '{split($0,a,"."); print a[2]}')
    frag_exec_t=$(cat $entry | grep "fragment execution" | awk '{split($0,a,":="); print a[2]}' )
    max_wires=$(cat $entry | grep "Max_wires" | awk '{split($0,a,":="); split(a[3],b,","); print b[1]}' )
    cut_ccts=$(cat $entry | grep "cut circuits" | awk '{split($0,a,":="); split(a[4],b,","); print b[1]}' )
    num_params=$(cat $entry | grep "params=" | awk '{split($0,a,"params="); split(a[2],b,">"); print b[1]}' )
    cut_time=$(cat $entry | grep "cut time:=" | awk '{split($0,a,"cut time:="); split(a[2],b,"\n"); print b[1]}' )
    num_nodes=$(echo $entry | awk '{split($0,a,"_"); split(a[3],b,"N"); print b[1]}')
    num_gpus_dict=$(cat $entry | grep "cluster resources" | awk '{split($0,a,":="); print a[2]}' )
    num_gpus=$(python3 -c "print(int(${num_gpus_dict}['GPU']))")
    post_proc_t=$(cat $entry | grep postproc | awk '{split($0,a,"="); print a[2]}' )
    output_val=$(cat $entry | grep "QAOA expval" | awk '{split($0,a,":="); split(a[2],b," "); print b[1]}' )
    csv_line=$(echo $exec_method,$slurm_id,$max_wires,$cut_ccts,$num_params,$cut_time,$num_nodes,$num_gpus,$frag_exec_t,$post_proc_t,$output_val)
    echo $csv_line >> ${exec_method}.csv
done