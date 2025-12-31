.PHONY: build run stop exec

CVE_2025_31133_PATH=scripts/cve-2025-31133-poc.py

build:
	docker build \
		--build-arg TAG=28.4-dind \
		--build-arg SCRIPT="$(CVE_2025_31133_PATH)" \
		-t cee:cve-2025-31133 .

run:
	docker run -d --rm --name cee-cve-2025-31133 --privileged cee:cve-2025-31133

stop:
	docker stop cee-cve-2025-31133

exec:
	docker exec -it cee-cve-2025-31133 /bin/bash
