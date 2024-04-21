#!/usr/bin/env bash


loadkey () 
{
    pidof ssh-agent
    pkill ssh-agent
    eval "$(ssh-agent)" && ssh-add
}


sky ()
{
    command ssh-add -l | command grep id_rsa &&  { echo "A key is already loaded."; return 1; }
    command pkill ssh-agent
    eval "$(ssh-agent)" && command ssh-add
}

upzen ()
{

    echo -- "The zen scripts are now symlnk in ~/somewhere"
#     if [[ -d ~/.bashrc_zen.d ]] && [[ -d ~/gitdir/configs/.bashrc_zen.d ]]
#     then
#        command cp -ruv ~/gitdir/configs/.bashrc_zen.d/* ~/.bashrc_zen.d
#     fi
}


mkzen ()
{
    if [[ ! -d ~/.bashrc_zen.d ]] && [[ -d ~/gitdir/configs/.bashrc_zen.d ]]
    then
        command mkdir -v -p ~/.bashrc_zen.d
        upzen
    else
        return 1
    fi
}

rmzen ()
{
    if [[ -d ~/.bashrc_zen.d ]]
    then
        command rm --preserve-root=all --one-file-system -v -r -- ~/.bashrc_zen.d
    fi
}
