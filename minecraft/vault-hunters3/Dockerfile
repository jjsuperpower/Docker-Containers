FROM openjdk:17-ea-slim-buster

ENV MC_INST_DIR /minecraft
ENV MEM_SIZE=4G
ENV RESTART_TIME=10:00
ENV REPLACE_CONFIG=true

WORKDIR /
COPY root /

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y wget zip unzip

RUN chmod +x /mc_init.sh
RUN chmod +x /mc_init.d/auto_restart.sh
RUN chmod +x /mc_init.d/auto_chmod.sh

EXPOSE 25565/tcp

CMD ["/bin/bash", "/mc_init.sh"]
