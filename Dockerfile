ARG TAG=dind
FROM docker:${TAG}

# Replace dynamically-linked busybox with statically-linked one.
RUN apk add --no-cache bash python3 libcap-utils busybox-static && \
        mv /bin/busybox.static /bin/busybox

# Create unprivileged user with ability to run containers with runc.
RUN adduser -S -D -h /home/unprivileged -s /bin/bash unprivileged && \
        chmod 4755 $(which runc)

ARG SCRIPT
ADD --chmod=766 $SCRIPT /
