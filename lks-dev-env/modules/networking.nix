{ pkgs }: {
  # Scanning + discovery
  nmap    = pkgs.nmap;            # port scanning + host discovery
  masscan = pkgs.masscan;         # very fast port scanner

  # Packet capture / inspection
  wireshark    = pkgs.wireshark;      # GUI packet inspector (bundles tshark, pulls GTK)
  tshark       = pkgs.wireshark-cli;  # CLI-only build; no GTK deps
  tcpdump      = pkgs.tcpdump;

  # Path + bandwidth diagnostics
  mtr    = pkgs.mtr;              # traceroute + ping combined
  iperf3 = pkgs.iperf3;           # bandwidth testing
}
