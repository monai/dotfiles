module_aliases_init() {
  alias gs='git status'
  alias ls="${aliases[ls]:-ls} -F"
  alias https='http --default-scheme=https'
}
