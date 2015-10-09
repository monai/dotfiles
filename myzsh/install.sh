#!/bin/bash

readonly PROGDIR=$(dirname $0)
readonly TARGETDIR=${ZDOTDIR:-$HOME}

function main {
    local file
    local dir
    local base

    ln -s $PWD/$PROGDIR $TARGETDIR/.myzsh

    for file in $PROGDIR/runcoms/*; do
        dir=$(dirname $file)
        base=$(basename $file)
        ln -s "$PWD/$dir/$base" "$TARGETDIR/.$base"
    done
}
