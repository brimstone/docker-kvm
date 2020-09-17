FROM ubuntu:20.04 as builder
RUN apt update \
 && mkdir /etc/initramfs-tools \
 && echo "9p" > /etc/initramfs-tools/modules \
 && echo "9pnet_virtio" >> /etc/initramfs-tools/modules \
 && yes | apt --no-install-recommends -y install \
    linux-headers-generic linux-image-generic curl pciutils initramfs-tools \
    systemd systemd-sysv linux-base procps iproute2 isc-dhcp-client netbase ifupdown \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists \
 && echo 'root:toor' | chpasswd

# Undo container specific environment changes
RUN echo 'auto eth0' > /etc/network/interfaces.d/eth0 \
 && echo 'iface eth0 inet dhcp' >> /etc/network/interfaces.d/eth0

###############################################################################

RUN export DEBIAN_FRONTEND=noninteractive \
 && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime \
 && echo virtualbox-ext-pack virtualbox-ext-pack/license select true | debconf-set-selections \
 && apt update \
 && apt --no-install-recommends -y install \
    virtualbox virtualbox-ext-pack vagrant packer git \
    xauth virtualbox-qt \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists

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
