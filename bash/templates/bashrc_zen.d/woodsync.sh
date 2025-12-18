# slash after will dump the contents of the directory in the destination
# sync youtube-down

function wood-sync() {

	rsync -rvptgle ssh /home/una/y/youtube-down star.example.net:/sync/$HOSTNAME
	rsync --del -rvptgle ssh /home/una/gitdir star.example.net:/sync/$HOSTNAME

}
