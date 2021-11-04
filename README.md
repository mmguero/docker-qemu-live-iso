# docker-qemu-live-iso

This docker image serves two purposes:

1. Boots a live ISO image in QEMU (based on [`tianon/qemu:native`](https://github.com/tianon/docker-qemu))
2. Provides an HTTP server from which the ISO itself can be downloaded

## Customizing the Docker image

By default this image is built with [Tiny Core Linux](http://www.tinycorelinux.net/) ISO as an example. Modify the `ISO_URL` argument when building the image to provide your own ISO URL. Or, create a child Dockerfile based on this image to add a local ISO:

```
FROM ghcr.io/mmguero/qemu-live-iso:latest

ARG QEMU_CPU=4
ARG QEMU_RAM=4096
ENV QEMU_CPU $QEMU_CPU
ENV QEMU_RAM $QEMU_RAM

ADD --chown=${DEFAULT_UID}:${DEFAULT_GID} foobar.iso /image/live.iso
```

## Customizing runtime

Set the following environment variables to control runtime parameters. See the [`Dockerfile`](Dockerfile) for the complete list.

* `QEMU_CPU` - the number of CPU cores for QEMU (default `2`)
* `QEMU_RAM` - the megabytes of RAM for QEMU (default `1024`)
* `QEMU_START` - whether to start QEMU when the container is run (default `true`)
* `QEMU_RESTART` - whether to retart QEMU if it stops (default `true`)
