FROM ruby:2.7-slim-buster

# Install dependencies
RUN apt-get update \
 && apt-get -y install \
        fish \
        curl \
        unzip \
        zip \
        ruby-dev \
        build-essential \
 && apt-get clean

WORKDIR app
COPY test/Gemfile ./
RUN bundle install \
 && rm Gemfile

# Switch to non-root user for test context
ARG TEST_HOME="/home/test"
RUN groupadd -r test \
 && useradd --no-log-init -r -g test -m -d $TEST_HOME test
USER test
RUN curl -s "https://get.sdkman.io" | bash

# To speed up tests, uncomment this shared setup:
SHELL ["/bin/bash", "-c"]
RUN source "$TEST_HOME/.sdkman/bin/sdkman-init.sh" \
 && sdk install ant 1.9.7 \
 && sdk install ant 1.9.9 \
 && sdk install ant 1.10.1 \
 && sdk install crash 1.2.11 \
 && sdk install crash 1.3.0

#      And   candidate ant is installed at version 1.9.7
#      And   candidate ant is installed at version 1.9.9
#      And   candidate ant is installed at version 1.10.1
#      And   candidate crash is installed at version 1.2.11
#      And   candidate crash is installed at version 1.3.0

# "Install" sdkman-for-fish
RUN mkdir -p $TEST_HOME/.config/fish/
COPY --chown=test:test completions $TEST_HOME/.config/fish/completions/
COPY --chown=test:test conf.d      $TEST_HOME/.config/fish/conf.d/
COPY --chown=test:test functions   $TEST_HOME/.config/fish/functions/
RUN ls -R $TEST_HOME/.config/fish/

# Run tests
COPY test ./
ENTRYPOINT ["cucumber"]
CMD ["--publish-quiet", "--tags", "not @pending"]
