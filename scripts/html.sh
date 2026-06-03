#!/bin/bash

set -euo pipefail

this_dir=$(readlink -qe "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )")
wd=$(readlink -qe "${this_dir}"/../)
parent=$(readlink -qe "${wd}"/../)

cd "${wd}"

echo "Rendering HTML..."

while read f ; do
    d=$(dirname "${f}")
    b="${d}"/index.html
    a="${d}"/$(basename "${f}")
	echo "    ${a}" | sed -re 's,'"${parent}"'/,,g'
    # minify --type html --html-keep-document-tags --html-keep-end-tags "${a}" > "${b}"
	export TITLE="New Model Works"
	if [[ -r body.md ]]; then
		export BODY=$(
			pandoc --strip-comments \
				   --wrap none \
				   --filter pandoc-crossref \
				   --citeproc \
				   --bibliography "${wd}/literature.bibtex" \
				   body.md
		)
	else
		export BODY=""
	fi
	envsubst < "${a}" | minify --type html --html-keep-document-tags --html-keep-end-tags > "${b}"
done < <(find "${wd}" -name index.raw.html)

echo "Done."
