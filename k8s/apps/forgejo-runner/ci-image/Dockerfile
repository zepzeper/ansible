# CI job image for Forgejo Actions PHP phases.
#
# setup-php re-downloads and reconfigures PHP in every phase of every run
# (~1-2 min x 5). Baking PHP into the job image makes the phases start in
# seconds; the cost is rebuilding this image when PHP or an extension bumps.
#
# Build it into the runner's dind (the image lives in the dind storage, which
# persists in /var/lib/forgejo-runner-docker):
#
#   cat k8s/apps/forgejo-runner/ci-image/Dockerfile | \
#     ssh zepzeper@100.117.255.24 \
#     "sudo k3s kubectl exec -i -n forgejo deploy/forgejo-runner -c dind -- \
#        env DOCKER_HOST=tcp://localhost:2375 docker build -t kodai-ci:php8.5 -"
#
# Base matches the ubuntu-latest label (catthehacker act image): it ships the
# node runtime that `uses:` steps need, plus the act tooling the runner
# expects. Floating tag, like the ubuntu-latest label - pin if that bothers
# you, but the label and this image should move together.
FROM ghcr.io/catthehacker/ubuntu:act-24.04

# From the sury PPA rather than setup-php's channel: same prebuilt packages,
# but apt-native so the image build is reproducible from this file alone.
# Extensions mirror the Dockerfile's runtime set: pdo_mysql, intl, pcntl
# (compiled into the cli package), zip, redis, gd - plus the mbstring/xml/
# curl that composer and a Laravel-style app need to boot.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg software-properties-common unzip \
  && add-apt-repository -y ppa:ondrej/php \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
      php8.5-cli php8.5-mysql php8.5-intl php8.5-zip php8.5-gd \
      php8.5-redis php8.5-mbstring php8.5-xml php8.5-curl \
      php8.5-mailparse \
  && ln -sf /usr/bin/php8.5 /usr/bin/php \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Composer installer piped to the PHP we just installed - keeps the build
# free of COPY (a stdin build has no context).
RUN curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/local/bin --filename=composer --version=2.8.10
