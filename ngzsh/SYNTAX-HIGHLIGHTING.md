# ngzsh Syntax Highlighting

ngzsh uses a small native zsh lexer for interactive command-line highlighting.
The Sublime Text zsh syntax is the coverage checklist, not a runtime grammar
or an implementation shape.

The implementation intentionally stops short of a full Sublime/TextMate parser:
it scans the current ZLE buffer, emits half-open character ranges with compact
ngzsh categories, and lets `ng-syntax-highlight` translate those categories into
`region_highlight` entries. This keeps redraw work predictable while preserving
a narrow test seam for behavior.

`ng-syntax-highlight-spans` is the classifier seam. Given a buffer, it prints
`start end category` records. Tests should assert those externally visible
categories instead of private parser state.

`ng-syntax-highlight` is the ZLE paint seam. It preserves non-ngzsh
`region_highlight` entries and replaces only entries marked with the
`memo=ngzsh-syntax-highlighting` marker.

Styles are configured through the ordinary associative array
`NG_SYNTAX_HIGHLIGHT_STYLES`. Large buffers are skipped according to
`NG_SYNTAX_HIGHLIGHT_MAX_BUFFER_LENGTH` so pasted or generated commands do not
make editing sluggish.
