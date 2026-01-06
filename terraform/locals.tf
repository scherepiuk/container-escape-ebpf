locals {
  runc_version = "1.1.11"
  files = {
    "${path.module}/../files/pocs/cve-2024-21626.py" = "/tmp/pocs/cve-2024-21626.py"
    "${path.module}/../files/pocs/cve-2025-31133.py" = "/tmp/pocs/cve-2025-31133.py"
    "${path.module}/../files/rules/example.yaml"     = "/tmp/rules/example.yaml"
  }
}
