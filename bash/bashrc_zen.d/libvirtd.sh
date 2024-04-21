startvirt ()
{
    sudo systemctl start libvirtd && sudo virsh start cp ; sudo virsh start wrk1 ; sudo virsh start wrk2 ; echo hello
}
