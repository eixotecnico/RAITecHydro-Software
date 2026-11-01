FROM mcr.microsoft.com/devcontainers/base:ubuntu

# *** instala dependências básicas ***
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    nodejs \
    npm \
    mosquitto-clients \
    && rm -rf /var/lib/apt/lists/*

# *** instalar Flutter ***
RUN git clone https://github.com/flutter/flutter.git /opt/flutter

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# *** pre-cache flutter ***
RUN flutter doctor

# *** instalar firebase tools ***
RUN npm install -g firebase-tools

# *** instalar ferramentas node ***
RUN npm install -g nodemon
