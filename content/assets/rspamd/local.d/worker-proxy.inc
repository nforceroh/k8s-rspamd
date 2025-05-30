bind_socket = "*:11332";
milter = yes; # Enable milter mode
timeout = 120s; # Needed for Milter usually
upstream "local" {
  default = yes;
  self_scan = yes;
}
