#!/bin/sh
set -eu

cd "$(dirname "$0")"

upstream=https://github.com/sublimehq/Packages.git
ref=$(git ls-remote --exit-code "$upstream" refs/heads/master)
commit=$(printf '%s\n' "$ref" | cut -f1)
base_url="https://raw.githubusercontent.com/sublimehq/Packages/$commit/ShellScript"

staging=$(mktemp -d ./.update.XXXXXX)
trap 'rm -rf "$staging"' EXIT
trap 'exit 1' HUP INT TERM

for syntax in Bash Zsh; do
    curl -fsSL "$base_url/$syntax.sublime-syntax" -o "$staging/$syntax.sublime-syntax"
done

for syntax in Bash Zsh; do
    mv "$staging/$syntax.sublime-syntax" .
done

printf 'Updated Bash and Zsh syntax references to %s\n' "$commit"
