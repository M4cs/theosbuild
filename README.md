## Theos Build - A docker container that makes it easy to compile tweaks on any system.

### Features:

- #### iOS 9.3 - iOS 13.0 SDKs
- #### arm64e toolchain and compatibility
- #### Updated llvm binaries from apt.llvm.org

## Usage

To open a bash shell and start a Theos project:

```
docker run -it mabridgland/theosbuild:latest /bin/bash

# Once inside shell
$THEOS/bin/nic.pl # Opens New Instance Creator
```

To use as a base image in another script:

```dockerfile
# In your Dockerfile
FROM mabridgland/theosbuild:latest

ENV TWEAK_NAME {YOUR TWEAK NAME}

RUN mkdir -p /root/.ssh
RUN mkdir -p /root/$TWEAK_NAME

COPY Resources/* /root/$TWEAK_NAME/Resources-bak/
COPY control /root/$TWEAK_NAME/control-bak
COPY *.mm /root/$TWEAK_NAME/ # Change to *.xm or add a line with *.xm if using logos
COPY *.h /root/$TWEAK_NAME/
COPY Makefile /root/$TWEAK_NAME/

# Place an id_rsa, id_rsa.pub, and known_hosts into your
# tweak directory that is pre-authed with your device.
COPY id_rsa /root/.ssh/id_rsa
COPY id_rsa.pub /root/.ssh/id_rsa.pub
COPY known_hosts /root/.ssh/known_hosts

# Make sure perms are correct on ssh files
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/id_rsa /root/.ssh/id_rsa.pub /root/.ssh/known_hosts

WORKDIR /root/$TWEAK_NAME/

# Permissions get messed up with Windows, you may need this
RUN cat ./control-bak > ./control
RUN mkdir ./Resources
RUN cd ./Resources-bak/; for i in *; do cat $i > ../Resources/$i; done

# Own that directory
RUN chmod -R +x *

RUN make clean do
```

Place that as a Dockerfile in your Tweak's root directory.

Now make a `docker-compose.yml` file inside of your Tweak's directory with the following content:

```yaml
version: '2'
services:
  tweak_builder:
    build:
      context: ./
      dockerfile: Dockerfile
    volumes:
      - "./:/usr/src/tweak"
    environment:
      - THEOS=/usr/src/theos
      - THEOS_DEVICE_IP=YOUR DEVICE IP HERE # REPLACE THIS
      - THEOS_DEVICE_PORT=22 # Shouldn't have to replace this unless you set it to something else
```

To compile your tweak, run `docker-compose up --build`.

## Credit

[DavidSkrundz's SDKs](https://github.com/DavidSkrundz/sdks)

[Sam Binger's Toolchain](https://github.com/sbingner/llvm-project)