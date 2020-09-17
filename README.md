docker-kvm
==========

This is just a wacky proof-of-concept that runs ubuntu inside kvm, inside a container, with the filesystem for the guest managed with Docker's multi-stage build pipeline.

Quickstart
----------
```
docker run -v /sys:/sys --rm -it --privileged --name kvm --device /dev/kvm -v /lib/modules:/lib/modules:ro brimstone/kvm:ubuntu-20.04
```

Build
-----
```
make build
```

Known bugs
----------

- Needs to detect the kvm_intel module as well
