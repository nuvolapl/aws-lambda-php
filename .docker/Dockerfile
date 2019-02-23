FROM amazonlinux:2017.03.1.20170812

RUN sed -i 's;^releasever.*;releasever=2017.03;;' /etc/yum.conf \
    && yum clean all \
    && yum install -y \
        autoconf \
        bison \
        gcc \
        gzip \
        gcc-c++ \
        libcurl-devel \
        libxml2-devel

WORKDIR /home/ec2-user

RUN curl -sL http://www.openssl.org/source/openssl-1.0.1k.tar.gz | tar -xz

WORKDIR /home/ec2-user/openssl-1.0.1k

RUN ./config \
    --prefix=/usr/local/ssl \
    --openssldir=/usr/local/ssl

RUN make
RUN make -j $(nproc) install

RUN curl -sL https://curl.haxx.se/ca/cacert.pem -o /usr/local/ssl/cert.pem

RUN /usr/local/ssl/bin/openssl version

WORKDIR /home/ec2-user

RUN curl -sL https://github.com/php/php-src/archive/php-7.3.2.tar.gz | tar -xz

WORKDIR /home/ec2-user/php-src-php-7.3.2

RUN ./buildconf --force

RUN mkdir php-7-bin

RUN ./configure \
    --prefix=/home/ec2-user/php-7-bin \
    --disable-all \
    --enable-cli \
    --enable-filter \
    --enable-hash \
    --enable-iconv \
    --enable-json \
    --enable-mbstring \
    --enable-opcache \
    --enable-opcache-file \
    --enable-phar \
    --enable-shared \
    --with-curl \
    --with-openssl=/usr/local/ssl \
    --with-zlib

RUN make -j $(nproc)
RUN make install

RUN /home/ec2-user/php-7-bin/bin/php -v
RUN /home/ec2-user/php-7-bin/bin/php -i

WORKDIR /home/ec2-user/php-7-bin

RUN yum install -y \
    git-core

ENV COMPOSER_ALLOW_SUPERUSER 1
RUN ./bin/php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
    && ./bin/php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm /tmp/composer-setup.php

RUN ./bin/php /usr/local/bin/composer global require \
    hirak/prestissimo \
    nuvolapl/aws-lambda-php-framework

WORKDIR /home/ec2-user
