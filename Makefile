LDFLAGS := -ldflags '-s'

.PHONY: all
all: test lint build

.PHONY: test
test:
	go test -v ./...

.PHONY: fix
fix:
	golangci-lint run --fix

.PHONY: lint
lint:
	golangci-lint run

.PHONY: wait
wait:
	dist/dbmate-linux-amd64 -e MYSQL_URL wait
	dist/dbmate-linux-amd64 -e POSTGRESQL_URL wait
	dist/dbmate-linux-amd64 -e ORACLE_URL wait

.PHONY: clean
clean:
	rm -rf dist/*

.PHONY: build
build: clean build-linux build-macos build-windows
	ls -lh dist

.PHONY: build-linux
build-linux:
	PKG_CONFIG_PATH=/src/config/linux GOOS=linux GOARCH=amd64 CGO_ENABLED=1 \
	LD_LIBRARY_PATH=/opt/linux/lib C_INCLUDE_PATH=/opt/linux/include \
	     go build $(LDFLAGS) -o dist/dbmate-linux-amd64 .

.PHONY: build-macos
build-macos:
	PKG_CONFIG_PATH=/src/config/darwin C_INCLUDE_PATH=/opt/darwin/include \
	LD_LIBRARY_PATH=/opt/darwin/lib:/osxcross/target/lib \
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 CC=o64-clang CXX=o64-clang++ \
	     go build $(LDFLAGS) -o dist/dbmate-macos-amd64 .

.PHONY: build-windows
build-windows:
	PKG_CONFIG_PATH=/src/config/win LD_LIBRARY_PATH=/opt/win/lib C_INCLUDE_PATH=/opt/win/include \
	GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc-posix CXX=x86_64-w64-mingw32-g++-posix \
	     go build $(LDFLAGS) -o dist/dbmate-windows-amd64.exe .

.PHONY: docker-all
docker-all:
	docker-compose build
	docker-compose run --rm dbmate make

.PHONY: docker-bash
docker-bash:
	docker-compose build
	docker-compose run --rm dbmate
