# Bundled live ISO for each platform. BuildKit only builds the stage selected
# for the target platform, so each image downloads just its own ISO.
# To update: change the URL, then set --checksum to the file's SHA-256.
ARG TARGETARCH

FROM scratch AS iso-amd64
# Alpine Linux "virt" (x86_64)
ADD --checksum=sha256:3ab424762af704b2c2a9e57df1dc37f982af260071504d977f2fb96822e7130b https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64/alpine-virt-3.24.2-x86_64.iso /live.iso

FROM scratch AS iso-arm64
# Alpine Linux "virt" (aarch64)
ADD --checksum=sha256:a57ba668b5f6b17a670fcf8e799d5d7fe43766ed086d6ce2927b0625bf43dbf6 https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/aarch64/alpine-virt-3.24.2-aarch64.iso /live.iso

FROM iso-${TARGETARCH} AS iso

FROM ghcr.io/mmguero/qemu@sha256:8f1ec584f3546b06b93cb3bcaa485544673fb29df6016c6f7202839341d46e88

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker-qemu-live-iso'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker-qemu-live-iso'
LABEL org.opencontainers.image.title='oci.guero.org/qemu-live-iso'
LABEL org.opencontainers.image.description='A docker image hosting a live ISO image in QEMU'

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# configure unprivileged user and runtime parameters
ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "user"
ENV PGROUP "user"

ARG QEMU_CPU=2
ARG QEMU_RAM=1024
ARG QEMU_CDROM="/image/live.iso"
ARG QEMU_NO_SSH=1
ARG QEMU_BOOT="order=d"
ARG QEMU_START="true"
ARG QEMU_RESTART="true"
ARG NOVNC_START="true"
ARG HTTP_SERVER_PORT=8000
ARG NOVNC_SERVER_PORT=8081

ENV QEMU_CPU $QEMU_CPU
ENV QEMU_RAM $QEMU_RAM
ENV QEMU_CDROM $QEMU_CDROM
ENV QEMU_NO_SSH $QEMU_NO_SSH
ENV QEMU_BOOT $QEMU_BOOT
ENV QEMU_START $QEMU_START
ENV NOVNC_START $NOVNC_START
ENV QEMU_RESTART $QEMU_RESTART
ENV HTTP_SERVER_PORT $HTTP_SERVER_PORT
ENV NOVNC_SERVER_PORT $NOVNC_SERVER_PORT

ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LC_ALL "C.UTF-8"

RUN apt-get -q update && \
    apt-get install --no-install-recommends -y -q \
      net-tools \
      novnc \
      procps \
      psmisc \
      python3-minimal \
      supervisor && \
    apt-get -y autoremove -qq && \
    apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
      useradd -M --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /nonexistant ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
    mkdir -p /deblive && \
      chown -R ${DEFAULT_UID}:${DEFAULT_GID} /deblive && \
      chmod 750 /deblive

ADD --chown=${DEFAULT_UID}:${DEFAULT_GID} supervisord.conf /etc/supervisord.conf
ADD --chmod=755 start-qemu-live /usr/local/bin/start-qemu-live
COPY --from=iso --chown=${DEFAULT_UID}:${DEFAULT_GID} /live.iso $QEMU_CDROM

EXPOSE $HTTP_SERVER_PORT
EXPOSE $NOVNC_SERVER_PORT

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-u", "root", "-n"]
