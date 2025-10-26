FROM ruby:3.1.3-slim

# Instalar dependencias del sistema
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de la aplicación
WORKDIR /app

# Copiar archivos de dependencias
COPY Gemfile Gemfile.lock ./

# Instalar dependencias
RUN bundle install

# Copiar código de la aplicación
COPY . .

# Crear directorio para logs
RUN mkdir -p log

# Exponer puerto
EXPOSE 3000

# Comando por defecto
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]