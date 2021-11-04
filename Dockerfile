FROM tianon/qemu:native

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker-qemu-live-iso'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker-qemu-live-iso'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/docker-qemu-live-iso'
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
ENV QEMU_CPU $QEMU_CPU
ENV QEMU_RAM $QEMU_RAM
ENV QEMU_CDROM $QEMU_CDROM
ENV QEMU_NO_SSH $QEMU_NO_SSH
ENV QEMU_BOOT $QEMU_BOOT
ENV QEMU_START $QEMU_START
ENV QEMU_RESTART $QEMU_RESTART

ARG ISO_URL="http://www.tinycorelinux.net/12.x/x86/release/TinyCore-current.iso"

ARG HTTP_SERVER_PORT=8000
ENV HTTP_SERVER_PORT $HTTP_SERVER_PORT

RUN apt-get -q update && \
    apt-get install --no-install-recommends -y -q \
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

ADD supervisord.conf /etc/supervisord.conf
ADD $ISO_URL $QEMU_CDROM

EXPOSE $HTTP_SERVER_PORT

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-u", "root", "-n"]

