# This template is used by the Hathora Plugin to generate a Dockerfile when making a server build

FROM centos:centos8

RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y wget unzip libXcursor openssl openssl-libs libXinerama libXrandr-devel libXi alsa-lib pulseaudio-libs mesa-libGL

ENV GODOT_RELEASE_URL "https://github.com/godotengine/godot-builds/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip"
ENV GODOT_RELEASE_FILENAME "Godot_v4.4.1-stable_linux.x86_64"

# Install Godot Server
RUN wget -q ${GODOT_RELEASE_URL} \
	&& unzip ${GODOT_RELEASE_FILENAME}.zip \
	&& mv ${GODOT_RELEASE_FILENAME} /usr/local/bin/godot \
	&& chmod +x /usr/local/bin/godot

# Create Runtime User
# RUN useradd -d . ruser

COPY game_server.pck .
# Copy hathora_config only if it exists
COPY hathora_config* /usr/local/bin/
CMD /usr/local/bin/godot --headless --main-pack ./game_server.pck
