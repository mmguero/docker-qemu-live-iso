FROM tianon/qemu:native

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

ARG ISO_URL="http://www.tinycorelinux.net/12.x/x86/release/TinyCore-current.iso"

ARG QEMU_CPU=2
ARG QEMU_RAM=1024
ARG QEMU_CDROM="/image/live.iso"
ARG QEMU_NO_SSH=1
ARG QEMU_BOOT="order=d"
ARG QEMU_START="true"
ARG QEMU_RESTART="true"
ARG NOVNC_START="true"
ARG DISPLAY_WIDTH=1920
ARG DISPLAY_HEIGHT=1080
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

ENV DISPLAY_WIDTH $DISPLAY_WIDTH
ENV DISPLAY_HEIGHT $DISPLAY_HEIGHT
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LC_ALL "C.UTF-8"
ENV DISPLAY ":0.0"

RUN apt-get -q update && \
    apt-get install --no-install-recommends -y -q \
      net-tools \
      novnc \
      procps \
      psmisc \
      python3-minimal \
      supervisor \
      x11vnc \
      xterm \
      xvfb && \
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
ADD --chown=${DEFAULT_UID}:${DEFAULT_GID} $ISO_URL $QEMU_CDROM

EXPOSE $HTTP_SERVER_PORT
EXPOSE $NOVNC_SERVER_PORT

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-u", "root", "-n"]

