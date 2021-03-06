FROM ubuntu:bionic

RUN apt update
RUN apt install -y software-properties-common sudo

RUN sudo apt install -y openssh-client openssh-server
RUN sudo apt install -y patch
RUN sudo apt install -y git
RUN sudo apt install -y curl
RUN sudo apt install -y libfontconfig
RUN sudo apt install -y libcurl4-openssl-dev
RUN sudo apt install -y imagemagick
RUN sudo apt install -y ffmpeg

# 8.1
RUN sudo apt install -y nodejs

# Install java
COPY ./jdk1.8.0_144 /opt/jdk1.8.0_144
ENV PATH="/opt/jdk1.8.0_144/bin:${PATH}"
RUN chmod +x /opt/jdk1.8.0_144/bin/*

# mecab 0.996-5; ipadic 2.7.0-20070801+main-1
RUN sudo apt install -y mecab mecab-ipadic-utf8 libmecab-dev

# Install elasticsearch 1.7.1
COPY ./circleci /var/tmp/circleci
RUN chmod +x /var/tmp/circleci/*.sh
RUN sudo /var/tmp/circleci/install_elasticsearch.sh
RUN /var/tmp/elasticsearch-1.7.1/bin/plugin --install elasticsearch/elasticsearch-analysis-kuromoji/2.6.0
RUN /var/tmp/elasticsearch-1.7.1/bin/plugin --install elasticsearch/elasticsearch-analysis-smartcn/2.7.0

# 2.1.1
RUN sudo /var/tmp/circleci/install_phantomjs.sh

RUN echo "mysql-server-5.7 mysql-server/root_password password password" | sudo debconf-set-selections
RUN echo "mysql-server-5.7 mysql-server/root_password_again password password" | sudo debconf-set-selections
RUN sudo apt install -y mysql-server libmysqlclient-dev
RUN sudo /bin/bash -l -c "cd /etc/mysql/mysql.conf.d && patch -p0 < /var/tmp/circleci/mysqld.cnf.diff"

RUN sudo apt-add-repository -y ppa:rael-gc/rvm
RUN sudo apt update
RUN sudo apt install -y rvm
RUN /bin/bash -l -c "rvm install 2.4.4"
RUN /bin/bash -l -c "gem install bundler"
RUN echo "source /etc/profile.d/rvm.sh" >> /root/.bashrc

# Needed for cld gem
ENV CFLAGS="-Wno-narrowing"
ENV CXXFLAGS="-Wno-narrowing"

RUN chmod +x /usr/local/bin/phantomjs

CMD /bin/bash
