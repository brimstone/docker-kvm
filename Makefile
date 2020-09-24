.PHONY: build
build:
	docker build -t brimstone/kvm:ubuntu-20.04 .
	-docker rm -vf kvm

.PHONY: test
test:
	docker run -v /sys:/sys --rm -it --privileged --name kvm --device /dev/kvm -v /lib/modules:/lib/modules:ro brimstone/kvm:ubuntu-20.04
.PHONY: test-loop
test-loop:
	while true; do make test; sleep 2; done

.PHONY: watch
watch:
	find . -type f | entr make

.PHONY: push
push: build
	docker push brimstone/kvm:ubuntu-20.04
