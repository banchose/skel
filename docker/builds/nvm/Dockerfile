FROM python:3.12.7-bookworm

RUN apt update && apt install -y \
  curl \
  bash \
  bash-completion \
  wget

  # Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN useradd -m -s /bin/bash dingo
# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /home/dingo/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install
CMD ["bash", "-l"]
