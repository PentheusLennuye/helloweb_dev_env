ARG VERSION=1.20
ARG ALPINE_VERSION=3.17

FROM golang:$VERSION-alpine${ALPINE_VERSION}
ARG USERNAME=vscode
ARG HOMEDIR=/home/vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN adduser $USERNAME -s /bin/sh -D -h $HOMEDIR -u $USER_UID $USER_GID && \
    mkdir -p /etc/sudoers.d && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

RUN apk add -q --update --progress --no-cache \
    git sudo openssh-client zsh curl zsh-vcs make gpg graphviz \
    python3 yamllint jq curl unzip git

RUN python3 -m ensurepip && pip3 install --no-cache --upgrade pip setuptools

# Go linting
RUN for tool in tools/cmd/goimports \
                lint/golint \
                tools/go/analysis/passes/shadow/cmd/shadow; \
    do go install golang.org/x/${tool}@latest; \
    done

# Testing third party tools
RUN for tool in github.com/cweill/gotests/gotests \
                honnef.co/go/tools/cmd/staticcheck; \
    do go install ${tool}@latest; \
    done

# Visual Studio Code and development tools
RUN for tool in fatih/gomodifytags \
                josharian/impl \
                haya14busa/goplay/cmd/goplay \
                go-delve/delve/cmd/dlv \
                ramya-rao-a/go-outline; \
    do go install github.com/${tool}@latest; \
    done
RUN go install golang.org/x/tools/gopls@latest

# Setup shell
USER $USERNAME
WORKDIR $HOMEDIR
COPY config/* .
ENV ENV=/$HOMEDIR/.ashrc \
    ZSH=/$HOMEDIR/.oh-my-zsh \
    EDITOR=vi \
    LANG=en_US.UTF-8 \
    PATH=/$HOMEDIR/.local/bin:$PATH \
    GOPATH=/$HOMEDIR/go
RUN sh user_shell.sh 

# To run mkdocs server as per company standards
RUN python3 -m pip install -r requirements.txt

USER root
