FROM yottadb/yottadb-base:latest-master

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libcurl4-openssl-dev git make gcc

# Install cURL plugin
RUN git clone https://github.com/shabiel/fis-gtm-plugins.git
ENV LD_LIBRARY_PATH /opt/yottadb/current
RUN cd fis-gtm-plugins/libcurl && \
    . /opt/yottadb/current/ydb_env_set && \
    export gtm_dist=$ydb_dist && \
    make install

# Install M-Unit
RUN git clone https://github.com/ChristopherEdwards/M-Unit.git munit

RUN cd munit && \
    mkdir r && \
    cd Routines && \
    for file in _*.m; do mv $file /data/munit/r/; done

# Install M-Web-Server
COPY ./src /mwebserver/r
ENV GTMXC_libcurl "/opt/yottadb/current/plugin/libcurl_ydb_wrapper.xc"
ENV ydb_routines "/mwebserver/r /data/munit/r"
RUN . /opt/yottadb/current/ydb_env_set && \
    mumps -r ^%webtest
