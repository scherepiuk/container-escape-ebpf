locals {
  runc_version = "1.1.11"
  files = {
    "${path.module}/../files/pocs/cve-2024-21626.py"    = "/tmp/pocs/cve-2024-21626.py"
    "${path.module}/../files/pocs/cve-2025-31133.py"    = "/tmp/pocs/cve-2025-31133.py"
    "${path.module}/../files/rules/cve-2024-21626.yaml" = "/tmp/rules/cve-2024-21626.yaml"
    "${path.module}/../files/rules/cve-2025-31133.yaml" = "/tmp/rules/cve-2025-31133.yaml"
    "${path.module}/../files/utils/reset.sh"            = "/tmp/utils/reset.sh"
    "${path.module}/../files/utils/performance.py"      = "/tmp/utils/performance.py"
  }
}
