

# source me
#
#

pacview ()
{
    command fzf &> /dev/null || { echo "Cannot find fzf"; return 1; }
    pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse
}

pacorphan ()
{
    command pacman &> /dev/null || { echo "Cannot find pacman"; return 1; }
    pacman -Qtdq
}

pacclean ()
{
    command pacman &> /dev/null || { echo "Cannot find pacman"; return 1; }
    pacman -Rns $(pacman -Qtdq)
}
