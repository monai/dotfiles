is-empty() {
  local var="$1"
  [ -z "$var" ]
}

freespace() {
  sudo rm -rf /.DocumentRevisions-V100
  rm -rf "$HOME/Library/Developer/Xcode/Archives"
  rm -rf "$HOME/Library/Developer/Xcode/DerivedData"
  rm -rf "$HOME/Library/Developer/Xcode/iOS\ DeviceSupport"
  rm -rf "$HOME/Library/Caches/com.apple.dt.Xcode"
  xcrun simctl delete unavailable
}

route-vpn() {
  sudo route add -net 10.0.0.0/8 -interface ppp0
  sudo route add -net 172.16.0.0/12 -interface ppp0
  sudo route add -net 192.168.0.0/16 -interface ppp0
}

clear-completion-cache() {
  local cache_path
  zstyle -s ':completion::complete:*' cache-path cache_path || cache_path = "${ZDOTDIR:-$HOME}/.zcompcache"

  rm -rf "$cache_path"
  rm -rf "${ZDOTDIR:-$HOME}/.zcompdump"
  rm -rf "${ZDOTDIR:-$HOME}/.zcompdump.zwc"
}
