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

clear-icon-cache() {
  sudo rm -rfv /Library/Caches/com.apple.iconservices.store
  sudo find /private/var/folders/ \
    \( \
      -name com.apple.dock.iconcache -or \
      -name com.apple.iconservices \
    \) -exec rm -rfv {} \;
  sleep 3
  sudo touch /Applications/*
  killall Dock
  killall Finder
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

scrape-wm() {
  local url=$1; shift
  local domain=$1; shift

  httrack \
    "${url}" \
    "-*" \
    "+*/${domain}/*" \
    -N1005 \
    --advanced-progressinfo \
    --can-go-up-and-down \
    --display \
    --keep-alive \
    --mirror \
    --robots=0 \
    --user-agent=Mozilla \
    --verbose
}
