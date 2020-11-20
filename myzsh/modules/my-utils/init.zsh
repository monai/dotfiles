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

clear-prezto-cache() {
  rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/prezto"
}

hex() {
  od -A n -t x1 | tr -d ' ' | tr -d '\n'
}

scrape() {
  local args="$@"

  wget \
    --recursive \
    --page-requisites \
    --user-agent=Mozilla \
    --no-parent \
    --convert-links \
    --adjust-extension \
    --execute robots=off \
    --level inf \
    ${=args}
}
