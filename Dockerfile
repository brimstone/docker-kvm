FROM ubuntu:20.04 as builder
RUN apt update \
 && mkdir /etc/initramfs-tools \
 && echo "9p" > /etc/initramfs-tools/modules \
 && echo "9pnet_virtio" >> /etc/initramfs-tools/modules \
 && yes | apt --no-install-recommends -y install \
    linux-headers-generic linux-image-generic curl pciutils initramfs-tools \
    systemd systemd-sysv linux-base procps iproute2 isc-dhcp-client netbase ifupdown \
    ca-certificates \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists \
 && echo 'root:toor' | chpasswd

# Undo container specific environment changes
RUN echo 'auto eth0' > /etc/network/interfaces.d/eth0 \
 && echo 'iface eth0 inet dhcp' >> /etc/network/interfaces.d/eth0

# Fix rc-local
RUN echo '[Install]' >> /lib/systemd/system/rc-local.service \
 && echo 'WantedBy=multi-user.target' >> /lib/systemd/system/rc-local.service \
 && systemctl enable rc-local.service \
 && echo '#!/bin/bash' > /etc/rc.local \
 && chmod 755 /etc/rc.local

# Install docker
RUN curl -sSL https://get.docker.com | bash \
 && mkdir /etc/docker \
 && echo '{"storage-driver":"aufs"}' > /etc/docker/daemon.json

###############################################################################

FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt update \
 && apt --no-install-recommends -y install \
    qemu-kvm wget pciutils kmod vim cpio procps net-tools vim \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists

COPY --from=builder / /guest

COPY entrypoint /entrypoint

ENTRYPOINT ["/entrypoint"]
