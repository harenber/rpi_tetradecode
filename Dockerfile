FROM debian:buster

MAINTAINER harenberg@gmail.com

ADD debconf /tmp
ADD passwd /root/.vnc/passwd
ADD start_services.sh /
ADD install_telive.sh /

RUN debconf-set-selections /tmp/debconf && chmod +x install_telive.sh && apt-get update && \
    apt-get install -y sudo wget && ./install_telive.sh && \
    apt-get install -y openbox lightdm tigervnc-scraping-server xvfb  xterm

ADD telive_1ch_simple_gr37_th.grc /root/tetra/telive/gnuradio-companion/receiver_pipe

CMD ["/bin/bash", "/start_services.sh"]
