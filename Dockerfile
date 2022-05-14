FROM alpine:3.15 as builder

RUN apk add alpine-sdk libtool sudo
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/abuild
RUN adduser -s /bin/sh -D -G abuild abuild
RUN addgroup abuild abuild
RUN addgroup abuild wheel
RUN mkdir -p /var/cache/distfiles
RUN chgrp abuild /var/cache/distfiles
RUN chmod g+w /var/cache/distfiles

USER abuild
WORKDIR /home/abuild
RUN wget https://github.com/ralph-irving/squeezelite/archive/master.zip
RUN unzip master.zip

WORKDIR /home/abuild/squeezelite-master/alpine
RUN ls -lAR
RUN abuild-keygen -a -n -i

WORKDIR /home/abuild/squeezelite-master/alpine/libalac
RUN abuild checksum
RUN abuild -r

WORKDIR /home/abuild/squeezelite-master/alpine/libtremor
RUN abuild checksum
RUN abuild -r

RUN sudo apk add \
	/home/abuild/packages/alpine/*/libalac-1.0.0-r1.apk \
	/home/abuild/packages/alpine/*/libalac-dev-1.0.0-r1.apk \
	/home/abuild/packages/alpine/*/libtremor-0.19681-r0.apk \
	/home/abuild/packages/alpine/*/libtremor-dev-0.19681-r0.apk

WORKDIR /home/abuild/squeezelite-master/alpine
RUN abuild checksum
RUN abuild -r

RUN mv /home/abuild/packages/alpine/*/*.apk /home/abuild/packages/alpine/ && \
	mv /home/abuild/packages/squeezelite-master/*/*.apk /home/abuild/packages/squeezelite-master/


FROM alpine:3.15

COPY --from=builder /home/abuild/packages/alpine/libalac-1.0.0-r1.apk /home/abuild/packages/alpine/libtremor-0.19681-r0.apk /home/abuild/packages/squeezelite-master/squeezelite-1.9.9.1401-r0.apk /root/
RUN apk add --allow-untrusted /root/libalac-1.0.0-r1.apk /root/libtremor-0.19681-r0.apk /root/squeezelite-1.9.9.1401-r0.apk
