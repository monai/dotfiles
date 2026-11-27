#!/usr/bin/env python3
import json
import pathlib
import sys

root = pathlib.Path(__file__).parent
assert sys.argv[1:-1] == json.loads((root / 'options').read_text())
mode = (root / 'mode').read_text().strip()
target = pathlib.Path(sys.argv[-1])
(root / 'editor-input').write_bytes(target.read_bytes())
if mode == 'interactive':
    (root / 'editor-ready').write_text('ready')
    assert input() == 'save example edit'
target.write_bytes((root / 'edited').read_bytes())
if mode == 'editor-failure':
    sys.exit(1)
if mode == 'concurrent':
    with (root / 'history').open('ab') as history:
        history.write(b': 1700000010:1;example concurrent\n')
