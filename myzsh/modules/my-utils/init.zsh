freespace() {
  sudo rm -rf /.DocumentRevisions-V100
  rm -rf "$HOME/Library/Developer/Xcode/DerivedData"
  rm -rf "$HOME/Library/Developer/Xcode/Archives"
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
  rm -rf "$HOME/.zcompcache"
  rm -rf "$HOME/.zcompdump"
  rm -rf "$HOME/.zcompdump.zwc"
}
