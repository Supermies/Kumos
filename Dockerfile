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
RUN sed -i '3s/.*/nosql_db_provider_name=cassandra/' /etc/kaa-node/conf/nosql-dao.properties
# Set mariadb host
RUN sed -i "s/\(jdbc_url *= *\).*/\1jdbc\:mysql\:failover\:\/\/mariadb\:3306\/kaa/" /usr/lib/kaa-node/conf/admin-dao.properties
RUN sed -i "s/\(jdbc_password *= *\).*/\1adminkadmin/" /usr/lib/kaa-node/conf/admin-dao.properties
RUN sed -i "s/\(jdbc_host_port *= *\).*/\1mariadb\:3306/" /usr/lib/kaa-node/conf/sql-dao.properties
RUN sed -i "s/\(jdbc_password *= *\).*/\1adminkadmin/" /usr/lib/kaa-node/conf/sql-dao.properties
# Set zookeeper host
RUN sed -i "s/\(zk_host_port_list *= *\).*/\1zookeeper\:2181/" /usr/lib/kaa-node/conf/kaa-node.properties
RUN sed -i "s/\(transport_public_interface *= *\).*/\1localhost=kaa/" /usr/lib/kaa-node/conf/kaa-node.properties

EXPOSE 8080 25 20 9888 9889 9997 9999
RUN service kaa-node start
RUN /bin/bash
