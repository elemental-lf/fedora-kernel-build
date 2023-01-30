KERNEL_VERSION=5.10.164
export DOCKER_BUILDKIT = 1

all:
	docker build \
	  --rm \
	  --force-rm \
	  --build-arg=KERNEL_VERSION=$(KERNEL_VERSION) \
	  -t fedora-kernel-build .
	-docker rm --force fedora-kernel-build
	docker run --name=fedora-kernel-build fedora-kernel-build
	docker cp fedora-kernel-build:/root/rpmbuild/RPMS/ .
	docker rm --force fedora-kernel-build
	docker rmi --force fedora-kernel-build
