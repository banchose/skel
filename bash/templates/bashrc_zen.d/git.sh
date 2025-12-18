# source me
#

alias gitb='git branch -vv' # show detailed branch info
alias gitr='git branch -r'  # show remote branches

gitclear() {
	# Clear
	git config --unset-all credential.helper
}

gitcredwin() {
	gitclear
	git config --global credential.helper /mnt/c/"Program Files"/Git/mingw64/bin/git-credential-manager.exe
	# /mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
}

gitwho() {

	git config --get user.name
	git config --get user.email
	git config --get credential.helper

}

# hri swich git
hrigit() {

	git config --unset credential.helper
	git config user.name "wjs04-hri"
	git config user.email "william.stewart"
	git config credential.helper "cache --timeout=7000"

}

gitp() (
	# look for gitdir cd in and git
	cd ~/gitdir/configs || {
		echo "Missing gitdir"
		return 1
	}
	command -v git &>/dev/null || {
		echo "Cannot find git"
		return 1
	}
	git fetch
	git s
	git add .
	git commit -m "generic zen script"
	git push
)
