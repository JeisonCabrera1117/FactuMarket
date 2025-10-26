# Dockerfile simplificado usando una imagen base con Oracle
FROM ruby:3.1.3

# Instalamos dependencias del sistema
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    curl \
    libaio1 \
    && rm -rf /var/lib/apt/lists/*

# Instalamos Oracle Instant Client usando el método más simple y confiable
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && cd /tmp \
    && wget -q https://download.oracle.com/otn_software/linux/instantclient/2113000/instantclient-basic-linux.x64-21.13.0.0.0dbru.zip \
    && wget -q https://download.oracle.com/otn_software/linux/instantclient/2113000/instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip \
    && unzip instantclient-basic-linux.x64-21.13.0.0.0dbru.zip \
    && unzip instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip \
    && mv instantclient_21_13 /opt/ \
    && rm instantclient-basic-linux.x64-21.13.0.0.0dbru.zip instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip \
    && echo /opt/instantclient_21_13 > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig \
    && apt-get remove -y wget unzip \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno necesarias para Oracle
ENV LD_LIBRARY_PATH=/opt/instantclient_21_13
ENV PATH=/opt/instantclient_21_13:$PATH
ENV OCI_LIB_DIR=/opt/instantclient_21_13
ENV OCI_INC_DIR=/opt/instantclient_21_13/sdk/include

# Configura el directorio de la app
WORKDIR /app

# Copiamos dependencias Ruby
COPY Gemfile Gemfile.lock ./

# Instalamos bundler y gems
RUN gem install bundler -v 2.4.19
RUN bundle config set --local frozen false
RUN bundle install

# Copiamos el resto del código
COPY . .

# Crear directorio para logs
RUN mkdir -p log tmp/pids

# Exponer puerto
EXPOSE 3000

# Script de inicio
COPY bin/docker-entrypoint /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint

# Comando por defecto
ENTRYPOINT ["docker-entrypoint"]
CMD ["rails", "server", "-b", "0.0.0.0"]