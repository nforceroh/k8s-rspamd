hashfile = "${DBDIR}/fuzzy.db";
backend = redis;
sync = 60s;
expire = 90d;
allow_update = ["127.0.0.1", "10.0.0.0/8", "172.16.0.0/12"];
bind_socket = "127.0.0.1:11335";