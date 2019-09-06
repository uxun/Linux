# Openresty Dockerfile Centos

# Image
ARG RESTY_IMAGE_BASE="centos"
ARG RESTY_IMAGE_TAG="7"

FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

# Openresty Build
ARG RESTY_VERSION="1.11.2.1"
ARG RESTY_CONFIG_OPTIONS="\
    --prefix=/usr/local/openresty \
    --with-luajit \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_drizzle_module \
    --with-http_iconv_module \
    --http-client-body-temp-path=/usr/local/openresty/nginx/cache/client \
    --http-proxy-temp-path=/usr/local/openresty/nginx/cache/proxy \
    --http-fastcgi-temp-path=/usr/local/openresty/nginx/cache/fcgi \
    --http-uwsgi-temp-path=/usr/local/openresty/nginx/cache/uwsgi \
    --http-scgi-temp-path=/usr/local/openresty/nginx/cache/scgi \
    --with-http_realip_module \
    --with-http_image_filter_module \
    " 

# MODS
# nginx-module-vts-0.1.18
ARG RESTY_VTS_OPTIONS="--add-module=/usr/local/src/nginx-module-vts-0.1.18"

# nginx_upload_module-2.2.0 [Optional]
ARG RESTY_UPLOAD_OPTIONS="--add-module=/usr/local/src/nginx_upload_module-2.2.0"

# nginx_ModSecurity-nginx [Optional]
ARG RESTY_MODSECURITY_OPTIONS="--add-module=/usr/local/src/ModSecurity-nginx"

# nginx_upstream_check_module [Optional]
ARG RESTY_UPCHECK_OPTIONS="--add-module=/usr/local/src/nginx_upstream_check_module" 

# module
ARG RESTY_DRIZZLE_VERSION="2011.07.21"
ARG RESTY_VTS_VERSION="v0.1.18"


# prepare
RUN yum update -y \
    && yum install -y epel-release \
    http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
    yum-utils \
    pcre-devel \
    libtool \
    openssl-devel \
    gcc \
    gcc-c++ \
    make \
    perl \
    curl \
    gd \
    gd-devel \
    postgresql-devel \
    wget \
    && cd /tmp \
    && wget https://openresty.org/download/drizzle7-${RESTY_DRIZZLE_VERSION}.tar.gz \
    && tar xzvf drizzle7-${RESTY_DRIZZLE_VERSION}.tar.gz \
    && cd drizzle7-${RESTY_DRIZZLE_VERSION} \
    && ./configure --without-server \
    && make libdrizzle-1.0 \
    && make install-libdrizzle-1.0 \
    && cd /tmp \
    && cd /tmp \
    && wget https://github.com/vozlt/nginx-module-vts/archive/${RESTY_VTS_VERSION}.tar.gz \
    && tar xzf ${RESTY_VTS_VERSION}.tar.gz -C /usr/local/src \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \ 
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && ./configure ${RESTY_CONFIG_OPTIONS} ${RESTY_VTS_OPTIONS} \
    && make \
    && make install \
    && ln -s /usr/local/lib/libdrizzle.so.1 /lib64/libdrizzle.so.1 \
    && mkdir -pv /usr/local/openresty/nginx/cache/client \
    && yum clean all \
    && yum remove \
    gcc \
    gcc-c++ \
    make \
    && rm -rf /tmp/* \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log 

# add PATH    
ENV PATH=$PATH:/usr/local/openresty/nginx/sbin

# Copy nginx.conf
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY openresty /etc/init.d/openresty

#EXPOSE 80/tcp

# CMD
CMD ["/usr/local/openresty/nginx/sbin/nginx","-g","daemon off;"]
#CMD ["/etc/init.d/openresty","start"]
STOPSIGNAL SIGQUIT


