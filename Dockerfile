FROM debian:stretch-slim
LABEL maintainer="vvakame@gmail.com"

ENV REVIEW_VERSION=3.0.0 \
    REVIEW_PEG_VERSION=0.2.2 \
    NODEJS_VERSION=10 \
    LANG=en_US.UTF-8

# setup
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git-core \
    locales \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen en_US.UTF-8 && update-locale en_US.UTF-8

# install Re:VIEW environment
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    cm-super \
    fonts-lmodern \
    fonts-texgyre \
    ghostscript \
    gnuplot \
    graphviz \
    gsfonts \
    lmodern \
    mecab \
    mecab-ipadic-utf8 \
    poppler-data \
    python-aafigure \
    python-blockdiag \
    ruby-mecab \
    ruby-nokogiri \
    ruby-zip \
    tex-gyre \
    texlive-fonts-recommended \
    texlive-lang-japanese \
    texlive-latex-extra \
    texlive-pictures \
    zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
## if you want to use ipa font instead of noto font, use this settings
# RUN kanji-config-updmap ipaex

# setup Re:VIEW
RUN gem install bundler rake --no-rdoc --no-ri && \
    gem install review -v "$REVIEW_VERSION" --no-rdoc --no-ri && \
    gem install review-peg -v "$REVIEW_PEG_VERSION" --no-rdoc --no-ri

# install node.js environment
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    gnupg \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash -
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g yarn

# install noto font from backports
RUN echo "deb http://ftp.jp.debian.org/debian/ stretch-backports main" >> /etc/apt/sources.list
RUN apt-get update \
 && apt-get -y install \
    fonts-noto-cjk-extra/stretch-backports \
    fonts-noto-cjk/stretch-backports

## install font map of noto for dvipdfmx
COPY noto/ /usr/share/texlive/texmf-dist/fonts/map/dvipdfmx/ptex-fontmaps/noto/

## use noto for uplatex
RUN texhash && kanji-config-updmap-sys noto

## set cache folder to work folder (disabled by default)
# RUN mkdir -p /etc/texmf/texmf.d && echo "TEXMFVAR=/work/.texmf-var" > /etc/texmf/texmf.d/99local.cnf
