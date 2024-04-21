# source me

function agx() {

	local searchpat=${1:?Missing search parameter}
	ag --ignore gitdir --ignore '.git' --smart-case --hidden "$searchpat"
}
