work-vpn() {
  sudo route add -net 10.0.0.0/8 -interface ppp0
  sudo route add -net 172.16.0.0/12 -interface ppp0
  sudo route add -net 192.168.0.0/16 -interface ppp0
  # echo -e "nameserver 172.22.25.3\nnameserver 172.24.25.4" | sudo tee -a /etc/resolv.conf
}
