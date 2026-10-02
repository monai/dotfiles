# Sublime shell syntax reference

These files are snapshots of [Sublime Text's ShellScript package](https://github.com/sublimehq/Packages/tree/master/ShellScript). `Zsh.sublime-syntax` extends `Bash.sublime-syntax`, so both are kept together for tracing inherited contexts such as `command-expansions`.

Source commit: [`b2bdd29577b4600ebc2c7fd0dd2511392b37926e`](https://github.com/sublimehq/Packages/commit/b2bdd29577b4600ebc2c7fd0dd2511392b37926e).

To check for updates, compare that commit with:

```sh
git ls-remote https://github.com/sublimehq/Packages.git refs/heads/master
```

To refresh the snapshots, replace the commit in the URLs below with the new commit ID:

```sh
curl -fsSL https://raw.githubusercontent.com/sublimehq/Packages/COMMIT/ShellScript/Zsh.sublime-syntax -o ngzsh/reference/sublime-shell-syntax/Zsh.sublime-syntax
curl -fsSL https://raw.githubusercontent.com/sublimehq/Packages/COMMIT/ShellScript/Bash.sublime-syntax -o ngzsh/reference/sublime-shell-syntax/Bash.sublime-syntax
```

Update the source commit above after refreshing. The files are reference material for ngzsh's small interactive lexer, not runtime inputs.
