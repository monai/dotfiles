fpath=("${0:h}/completions" $fpath)

load_zsh_completion() {
  local comp_path="/usr/local/share/zsh/site-functions"
  local filename="${1}"
  load_completion "${comp_path}/${filename}"
}

load_bash_completion() {
  local comp_path="/usr/local/etc/bash_completion.d"
  local filename="${1}"
  load_completion "${comp_path}/${filename}"
}

load_completion() {
  local filename=$1
  if [[ -f "${filename}" ]]; then
    source "${filename}"
  fi
}
