ARG USERNAME
ARG TAG

FROM $USERNAME/hadoop-base:$TAG

# Allow buildtime config of HIVE_VERSION
ARG HIVE_VERSION
# Set HIVE_VERSION from arg if provided at build, env if provided at run, or default
# https://docs.docker.com/engine/reference/builder/#using-arg-variables
# https://docs.docker.com/engine/reference/builder/#environment-replacement
ENV HIVE_VERSION=${HIVE_VERSION:-3.1.2}

ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH

WORKDIR /opt

# Install Hive and PostgreSQL JDBC
RUN apt-get update && apt-get install -y wget procps vim file tcpdump telnet

RUN	apt-get --purge remove -y wget && \
	apt-get clean
	#rm -rf /var/lib/apt/lists/*

#RUN wget -c https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/a;spache-hive-$HIVE_VERSION-bin.tar.gz
COPY apache-hive-$HIVE_VERSION-bin.tar.gz .
#ADD https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz .

RUN	tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
	mv apache-hive-$HIVE_VERSION-bin hive && \
	rm -rf apache-hive-$HIVE_VERSION-bin && \
	rm apache-hive-$HIVE_VERSION-bin.tar.gz

# FIX https://issues.apache.org/jira/browse/HIVE-22915
# See https://github.com/IBM/docker-hive/blob/hadoop3.1.3-hive3.1.2/Dockerfile
RUN rm $HIVE_HOME/lib/guava-19.0.jar
RUN cp /opt/hadoop-3.2.2/share/hadoop/hdfs/lib/guava-27.0-jre.jar $HIVE_HOME/lib/

#RUN	wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar -O $HIVE_HOME/lib/postgresql-jdbc.jar
COPY postgresql-9.4.1212.jar $HIVE_HOME/lib/postgresql-jdbc.jar

#Spark should be compiled with Hive to be able to use it
#hive-site.xml should be copied to $SPARK_HOME/conf folder

RUN mkdir -p $HIVE_HOME/tmp/java

#Custom configuration goes here
RUN mkdir -p $HIVE_HOME/conf
RUN rm $HIVE_HOME/conf/*.template

ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

#EXPOSE 10000
#EXPOSE 10002

ENTRYPOINT ["entrypoint.sh"]
CMD startup.sh
