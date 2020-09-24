FROM ubuntu:18.04

RUN mkdir -p /usr/src/theos

RUN apt-get update && apt-get install -y \
    curl \
    fakeroot \
    git \
    perl \
    clang-6.0 \
    build-essential \
    unzip \
    rsync \
    subversion \
    lsb-release \
    wget \
    software-properties-common \
 && rm -rf /var/lib/apt/lists/*

ENV THEOS /usr/src/theos
RUN git clone --recursive https://github.com/theos/theos.git $THEOS

RUN curl https://kabiroberai.com/toolchain/download.php?toolchain=ios-linux -Lo toolchain.tar.gz
RUN tar xzf toolchain.tar.gz -C $THEOS/toolchain
RUN rm toolchain.tar.gz

RUN curl -LO https://github.com/DavidSkrundz/sdks/archive/master.zip
RUN mkdir -p /tmp/theos
RUN unzip master.zip -d /tmp/theos
RUN ls /tmp/theos
RUN cp -r /tmp/theos/sdks-master/*.sdk $THEOS/sdks
RUN rm -r master.zip /tmp/theos

RUN mkdir /tmp/arm64e
RUN curl https://github.com/sbingner/llvm-project/releases/download/v10.0.0-1/linux-ios-arm64e-clang-toolchain.tar.lzma -Lo /tmp/arm64e/linux-ios-arm64e-clang-toolchain.tar.lzma
RUN cd /tmp/arm64e && tar --lzma -xvf linux-ios-arm64e-clang-toolchain.tar.lzma
RUN cd /tmp/arm64e/ios-arm64e-clang-toolchain/bin && find * ! -name clang-10 -and ! -name ldid -and ! -name ld64 -exec cp {} arm64-apple-darwin14-{} \;
RUN cd /tmp/arm64e/ios-arm64e-clang-toolchain/bin && find * -xtype l -exec sh -c "readlink {} | xargs -I{LINK} ln -f -s arm64-apple-darwin14-{LINK} {}" \;

RUN mkdir -p $THEOS/toolchain/linux/iphone
RUN cp -r /tmp/arm64e/ios-arm64e-clang-toolchain/* $THEOS/toolchain/linux/iphone/
RUN rm -rf /tmp/arm64e

RUN mkdir /tmp/sdks
RUN svn checkout https://github.com/xybp888/iOS-SDKs/trunk/iPhoneOS13.0.sdk /tmp/sdks/iPhoneOS13.0.sdk
RUN cp -r /tmp/sdks/*.sdk $THEOS/sdks
RUN rm -rf /tmp/sdks

RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"