FROM ubuntu:20.04

ARG RUNNER_VERSION="2.314.1"

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies including libicu for Dotnet Core
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    sudo \
    git \
    jq \
    tar \
    gzip \
    ca-certificates \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and switch to it
RUN useradd -m docker && \
    usermod -aG sudo docker && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /actions-runner

# Give ownership of the workdir to the 'docker' user
RUN chown -R docker:docker /actions-runner

# Switch to the non-root user
USER docker

# Download and install the GitHub Actions runner as the non-root user
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Run the installdependencies.sh script to resolve all Dotnet Core dependencies
RUN sudo ./bin/installdependencies.sh

# Copy the entry script and make sure it's executable
COPY --chown=docker:docker start.sh ./start.sh
RUN chmod +x ./start.sh

ENTRYPOINT ["./start.sh"]
