FROM nimmis/java:oracle-8-jdk

#Install build dependencies
RUN apt-get update && apt-get install -y maven gcc cmake wget

#ADD https://github.com/kaaproject/kaa/releases/download/v0.9.0/kaa-#deb-0.9.0.tar.gz /deb
RUN mkdir -p /kaa \
    && wget --no-check-certificate https://github.com/kaaproject/kaa/releases/download/v0.9.0/kaa-deb-0.9.0.tar.gz -P /kaa 
RUN tar -xvzf /kaa/kaa-deb-0.9.0.tar.gz -C /kaa
RUN dpkg -i /kaa/deb/kaa-node.deb

RUN service kaa-node stop

#Don't prompt for password
RUN sudo echo 'kaa     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
ENV CONTROL_ENABLED=true
ENV BOOTSTRAP_ENABLED=true
ENV OPERATIONS_ENABLED=true
ENV DATABASE=cassandra
ENV ZK_HOSTS=zk:2181
ENV CASSANDRA_HOSTS=Cassandra:9042
ENV JDBC_HOST=mariadb
ENV JDBC_PORT=3306
#ADD ./config_listener.sh /
#RUN chmod 777 /config_listener.sh
EXPOSE 8080 25 20 9888 9889 9997 9999
RUN service kaa-node start
RUN /bin/bash
