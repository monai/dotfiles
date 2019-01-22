work-vpn() {
  sudo route add -net 10.0.0.0/8 -interface ppp0
  sudo route add -net 172.16.0.0/12 -interface ppp0
  sudo route add -net 192.168.0.0/16 -interface ppp0
}
