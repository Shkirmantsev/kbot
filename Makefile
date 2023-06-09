GIT_URL=$(shell git remote get-url origin)
APP ?= $(shell basename $(GIT_URL) | sed 's/\.git$$//')
REGISTRY ?= gcr.io/shkirmantsev
VERSION ?= $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

TARGETOS ?= linux# darwin, linux, windows
TARGETARCH ?= not_set# arm, arm64, amd64, 386

ifeq ($(TARGETARCH),not_set)
	ifeq ($(TARGETOS),darwin)
		MACOS_TARGET_ARCHITECTURE := $(shell uname -m)
	endif
	ifeq ($(TARGETOS),macos)
		MACOS_TARGET_ARCHITECTURE := $(shell uname -m)
	endif
else
	MACOS_TARGET_ARCHITECTURE := $(TARGETARCH)
endif

ifeq ($(TARGETARCH),not_set)
	ifeq ($(TARGETOS),linux)
		LINUX_TARGET_ARCHITECTURE := $(shell dpkg --print-architecture)
	endif
else
	LINUX_TARGET_ARCHITECTURE := $(TARGETARCH)
endif

ifeq ($(TARGETARCH),not_set)
	ifeq ($(TARGETOS),windows)
		WINDOWS_TARGET_ARCHITECTURE := $(shell powershell -command "if ([System.IntPtr]::Size -eq 8) { 'amd64' } else { '386' }")
	endif
else
	WINDOWS_TARGET_ARCHITECTURE := $(TARGETARCH)
endif

# Set ARCH based on TARGETOS
ifeq ($(TARGETOS),linux)
	ARCH := $(LINUX_TARGET_ARCHITECTURE)
else ifeq ($(TARGETOS),windows)
	ARCH := $(WINDOWS_TARGET_ARCHITECTURE)
else ifeq ($(TARGETOS),darwin)
	ARCH := $(MACOS_TARGET_ARCHITECTURE)
else ifeq ($(TARGETOS),macos)
	ARCH := $(MACOS_TARGET_ARCHITECTURE)
endif

ifeq ($(TARGETARCH),not_set)
	TARGETARCH := ${ARCH}
endif

IMAGE_TAG := ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

linux: format get
	CGO_ENABLED=0 GOOS=linux GOARCH=${LINUX_TARGET_ARCHITECTURE} go build -v -o kbot --ldflags "-X="github.com/shkirmantsev/kbot/cmd.appVersion=${VERSION}

darwin: format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=${MACOS_TARGET_ARCHITECTURE} go build -v -o kbot --ldflags "-X="github.com/shkirmantsev/kbot/cmd.appVersion=${VERSION}

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=${WINDOWS_TARGET_ARCHITECTURE} go build -v -o kbot --ldflags "-X="github.com/shkirmantsev/kbot/cmd.appVersion=${VERSION}

build: format get
ifeq ($(TARGETOS),linux)
	$(MAKE) linux
else ifeq ($(TARGETOS),windows)
	$(MAKE) windows
else ifeq ($(TARGETOS),darwin)
	$(MAKE) darwin
else ifeq ($(TARGETOS),macos)
	$(MAKE) darwin
endif

image:
	docker build --build-arg TARGETARCH=${TARGETARCH} --build-arg TARGETOS=${TARGETOS} -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} .

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	rm -rf kbot
	rm -rf LICENSE
	docker rmi ${IMAGE_TAG}
