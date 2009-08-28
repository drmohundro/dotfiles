# use vim to view git diffs (see http://technotales.wordpress.com/2009/05/17/git-diff-with-vimdiff/)
function git-diff() {
	git diff --no-ext-diff -w "$@" | vim -R -
}
