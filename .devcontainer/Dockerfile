# Based on the official Anthropic reference at
# https://github.com/anthropics/claude-code/tree/main/.devcontainer
# Deviations for this project:
#  - install pyenv + the Python version pinned in .python-version (so the host
#    workflow — `pyenv` + `scripts/bootstrap/setup-venv.sh` — works identically
#    inside the container)
#  - install a mysql client so `scripts/db-query.sh` can talk to the `mysql`
#    compose service directly over the docker network, without mounting the
#    docker socket

FROM node:20

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  nano \
  vim \
  default-mysql-client \
  build-essential \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libncurses-dev \
  libffi-dev \
  liblzma-dev \
  tk-dev \
  curl \
  ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=nano
ENV VISUAL=nano

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Claude
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Install pyenv + the project's pinned Python version (so the bootstrap script
# works inside the container with the same `pyenv exec python` invocation it
# uses on the host).
ARG PYTHON_VERSION=3.13.3
ENV PYENV_ROOT=/home/node/.pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN curl -fsSL https://pyenv.run | bash
RUN pyenv install "$PYTHON_VERSION" && pyenv global "$PYTHON_VERSION"
RUN echo 'export PYENV_ROOT="/home/node/.pyenv"' >> /home/node/.zshrc \
  && echo 'export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"' >> /home/node/.zshrc \
  && echo 'eval "$(pyenv init -)"' >> /home/node/.zshrc

# Copy and set up the root-privileged init scripts that run at container start.
# Both are invoked via NOPASSWD sudo from `postStartCommand` so the unprivileged
# `node` user can rely on a writeable workspace and a sandboxed network without
# ever holding root itself.
COPY init-firewall.sh init-volumes.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/init-volumes.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh, /usr/local/bin/init-volumes.sh" > /etc/sudoers.d/node-init && \
  chmod 0440 /etc/sudoers.d/node-init

# On Windows hosts the bind-mounted workspace shows up with a UID that
# doesn't match `node` inside the container, which trips Git's
# "dubious ownership" check. Whitelist the workspace at system level so
# every shell inside the container can run git against /workspace.
RUN git config --system --add safe.directory /workspace

USER node
