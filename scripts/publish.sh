#!/bin/bash

set -euo pipefail

this_dir=$(readlink -qe "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )")
wd=$(readlink -qe "${this_dir}"/../)

cd "${wd}"

[[ $(git status --porcelain) = "" ]] || {
	echo "Uncommitted changes! Quitting." >&2
	exit 1
}

old_branch=$(git branch --show-current)

git checkout main # >/dev/null 2>/dev/null

while read f ; do
    git restore --source dev "${f}"
done < <(git ls-tree --full-tree -r --name-only dev | ag '(\.(css|html|ico|js|png)|CNAME)$' | ag -v '\.raw.html$')

find -type f -name "*.raw.html" -exec rm {} \;
git add .

if [[ $(git status --porcelain) = "" ]]; then
	echo
	echo "+----------------------------------------------------------------------+"
    echo "|                           Nothing to do!                             |"
	echo "+----------------------------------------------------------------------+"
	echo
    git checkout "${old_branch}"
    exit 0
else
	git commit -m "Latest site $(date)"
	git push
fi

git checkout "${old_branch}"
