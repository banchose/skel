vms=(
"192.168.122.120"
"192.168.122.121"
"192.168.122.122"
"192.168.122.123"
)

upavms ()
{
    if ssh-add -l | grep -q 'id_rsa'
    then
        echo "there is a key loaded"
        printf '%s\n' "${vms[@]}"
        for i in "${vms[@]}";
        do
            echo "root@$i"
            ssh "root@$i" "pacman -Suy --noconfirm" </dev/null
        done
    else
        echo "No root key which is una key"
    fi
}
startavms ()


{
  sudo virsh start cp
  sudo virsh start wrk1 
  sudo virsh start wrk2 
  sudo virsh start wrk3 
}


stopavms ()


{
  sudo virsh stop cp
  sudo virsh stop wrk1 
  sudo virsh stop wrk2 
  sudo virsh stop wrk3 
}

