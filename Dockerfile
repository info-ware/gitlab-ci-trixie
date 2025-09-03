FROM debian:bookworm-slim

RUN apt update && apt install -y build-essential
RUN apt install -y devscripts cmake gcc g++ debhelper 
RUN apt install -y dh-exec pkg-config libboost-dev libboost-filesystem-dev 
RUN apt install -y libasound2-dev libgles2-mesa-dev
RUN apt install -y gcc-multilib g++-multilib
RUN apt install -y libtool autoconf
RUN apt install -y git joe ccache rsync
RUN apt install -y libcurl4-gnutls-dev
RUN apt install -y uuid-dev
RUN apt install -y qt6-base-dev
RUN apt install -y zlib1g-dev zip unzip
RUN apt install -y libxext-dev libz3-dev

# Tools
RUN apt install -y doxygen doxygen-latex graphviz wget ccache rsync joe 

# Java
RUN apt install -y maven default-jdk binutils-i686-linux-gnu 

# Additional tools
RUN apt install -y libboost-all-dev bzip2 curl git-core html2text libc6-i386 libc6-dev-i386
RUN apt install -y lib32stdc++6 lib32gcc-s1 lib32z1 unzip openssh-client sshpass lftp 
RUN apt install -y libgnutls28-dev adb 
RUN apt install -y python3-pip
RUN apt install -y pkg-config

# Install wget, sudo, and .NET SDK 8.0
RUN apt install -y wget  && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0

# ------------------------------------------------------
# --- Android SDK
# ------------------------------------------------------
# must be updated in case of new versions set 
#ENV VERSION_SDK_TOOLS="4333796"
#ENV VERSION_SDK_TOOLS=6858069
ENV VERSION_SDK_TOOLS=13114758

ENV ANDROID_HOME="/sdk"
ENV ANDROID_SDK_ROOT="/sdk"

RUN rm -rf /sdk
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_SDK_TOOLS}_latest.zip -O sdk.zip
RUN unzip sdk.zip -d /sdk 
RUN rm -v sdk.zip

RUN mkdir -p ${ANDROID_HOME}/licenses/ && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license

ADD packages.txt /sdk

RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg && ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --update --sdk_root=/sdk 

# accept all licences
RUN yes | ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --licenses --sdk_root=/sdk

RUN ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --package_file=/sdk/packages.txt --sdk_root=/sdk

# ------------------------------------------------------
# --- Android NDK
# ------------------------------------------------------
ENV ANDROID_NDK_VERSION="r28"
ENV ANDROID_NDK_HOME=/sdk/ndk/28.0.13004108

# download
RUN mkdir -p /opt/android-ndk-tmp
WORKDIR /opt/android-ndk-tmp
RUN wget  https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip

# uncompress
RUN unzip android-ndk-${ANDROID_NDK_VERSION}-linux.zip
# move to its final location
RUN mkdir -p ${ANDROID_NDK_HOME}
RUN mv ./android-ndk-${ANDROID_NDK_VERSION}/* ${ANDROID_NDK_HOME}
# remove temp dir
RUN rm -rf /opt/android-ndk-tmp

# TODO: Remove this when r18b is no longer needed
ENV ANDROID_NDK_VERSION="r18b"
ENV ANDROID_NDK_HOME=/sdk/ndk/18.1.5063045

# download
RUN mkdir -p /opt/android-ndk-tmp
WORKDIR /opt/android-ndk-tmp
RUN wget  https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip

# uncompress
RUN unzip android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
# move to its final location
RUN mkdir -p ${ANDROID_NDK_HOME}
RUN mv ./android-ndk-${ANDROID_NDK_VERSION}/* ${ANDROID_NDK_HOME}
# remove temp dir
RUN rm -rf /opt/android-ndk-tmp



# ------------------------------------------------------
# --- Finishing touch
# ------------------------------------------------------

RUN mkdir /scripts
ADD scripts/get-release-notes.sh /scripts
RUN chmod +x /scripts/get-release-notes.sh

ADD scripts/adb-all.sh /scripts
RUN chmod +x /scripts/adb-all.sh

ADD scripts/compare_files.sh /scripts
RUN chmod +x /scripts/compare_files.sh

ADD scripts/lint-up.rb /scripts
ADD scripts/send_ftp.sh /scripts


# add ANDROID_NDK_HOME to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}


# SETTINGS FOR GRADLE 7.6
ADD https://services.gradle.org/distributions/gradle-7.6-bin.zip /tmp
RUN mkdir -p /opt/gradle/wrapper/dists/gradle-7.6-bin/9l9tetv7ltxvx3i8an4pb86ye
RUN cp /tmp/gradle-7.6-bin.zip /opt/gradle/wrapper/dists/gradle-7.6-bin/9l9tetv7ltxvx3i8an4pb86ye
RUN unzip /tmp/gradle-7.6-bin.zip -d /opt/gradle/wrapper/dists/gradle-7.6-bin/9l9tetv7ltxvx3i8an4pb86ye
RUN touch /opt/gradle/wrapper/dists/gradle-7.6-bin/9l9tetv7ltxvx3i8an4pb86ye/gradle-7.6-bin.ok
RUN touch /opt/gradle/wrapper/dists/gradle-7.6-bin/9l9tetv7ltxvx3i8an4pb86ye/gradle-7.6-bin.lck

# SETTINGS FOR GRADLE 8.7
ADD https://services.gradle.org/distributions/gradle-8.7-bin.zip /tmp
RUN mkdir -p /opt/gradle/wrapper/dists/gradle-8.7-bin/bhs2wmbdwecv87pi65oeuq5iu
RUN cp /tmp/gradle-8.7-bin.zip /opt/gradle/wrapper/dists/gradle-8.7-bin/bhs2wmbdwecv87pi65oeuq5iu
RUN unzip /tmp/gradle-8.7-bin.zip -d /opt/gradle/wrapper/dists/gradle-8.7-bin/bhs2wmbdwecv87pi65oeuq5iu
RUN touch /opt/gradle/wrapper/dists/gradle-8.7-bin/bhs2wmbdwecv87pi65oeuq5iu/gradle-8.7-bin.ok
RUN touch /opt/gradle/wrapper/dists/gradle-8.7-bin/bhs2wmbdwecv87pi65oeuq5iu/gradle-8.7-bin.lck

# SETTINGS FOR GRADLE 8.12
ADD https://services.gradle.org/distributions/gradle-8.12-bin.zip /tmp
RUN mkdir -p /opt/gradle/wrapper/dists/gradle-8.12-bin/cetblhg4pflnnks72fxwobvgv
RUN cp /tmp/gradle-8.12-bin.zip /opt/gradle/wrapper/dists/gradle-8.12-bin/cetblhg4pflnnks72fxwobvgv
RUN unzip /tmp/gradle-8.12-bin.zip -d /opt/gradle/wrapper/dists/gradle-8.12-bin/cetblhg4pflnnks72fxwobvgv
RUN touch /opt/gradle/wrapper/dists/gradle-8.12-bin/cetblhg4pflnnks72fxwobvgv/gradle-8.12-bin.ok
RUN touch /opt/gradle/wrapper/dists/gradle-8.12-bin/cetblhg4pflnnks72fxwobvgv/gradle-8.12-bin.lck

# SETTINGS FOR GRADLE 8.14.3
ADD https://services.gradle.org/distributions/gradle-8.14.3-bin.zip /tmp
RUN mkdir -p /opt/gradle/wrapper/dists/gradle-8.14.3-bin/cv11ve7ro1n3o1j4so8xd9n66
RUN cp /tmp/gradle-8.12-bin.zip /opt/gradle/wrapper/dists/gradle-8.14.3-bin/cv11ve7ro1n3o1j4so8xd9n66
RUN unzip /tmp/gradle-8.12-bin.zip -d /opt/gradle/wrapper/dists/gradle-8.14.3-bin/cv11ve7ro1n3o1j4so8xd9n66
RUN touch /opt/gradle/wrapper/dists/gradle-8.14.3-bin/cv11ve7ro1n3o1j4so8xd9n66/gradle-8.14.3-bin.ok
RUN touch /opt/gradle/wrapper/dists/gradle-8.14.3-bin/cv11ve7ro1n3o1j4so8xd9n66/gradle-8.14.3-bin.lck

ENV GRADLE_HOME=/opt/gradle/gradle-8.14.3/bin

# Install vcpkg
WORKDIR /var/lib
RUN git clone https://github.com/microsoft/vcpkg.git
WORKDIR /var/lib/vcpkg
RUN ./bootstrap-vcpkg.sh
RUN ./vcpkg integrate install

# add ccache to PATH
ENV PATH=/usr/lib/ccache:${GRADLE_HOME}:${PATH}

ENV CCACHE_DIR /mnt/ccache
ENV NDK_CCACHE /usr/bin/ccache
ENV VCPKG_ROOT=/var/lib/vcpkg

# ------------------------------------------------------
# --- SENTRY CLI
# ------------------------------------------------------
RUN curl -sL https://sentry.io/get-cli/ | sh


