settings {
    logfile = "/var/log/lsyncd/lsyncd.log"
}

sync {
    default.rsyncssh,
    source = "/home/mukmo/data",
    host = "192.168.100.49",
    targetdir = "/tmp/backup",
    rsync = {
        rsh = "/usr/bin/ssh -l root -i /root/.ssh/id_rsa", 
        compress = true, 
        _extra = {"-auSs"}
    }
}