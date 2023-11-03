ARG VERSION=1.20
ARG ALPINE_VERSION=3.17

FROM golang:$VERSION-alpine${ALPINE_VERSION}
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
ARG GOPLS_VERSION=latest

RUN adduser $USERNAME -s /bin/sh -D -u $USER_UID $USER_GID && \
    mkdir -p /etc/sudoers.d && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

RUN apk add -q --update --progress --no-cache \
    git sudo openssh-client zsh curl zsh-vcs make gpg graphviz \
    python3 yamllint jq curl unzip git

RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

RUN go install golang.org/x/tools/gopls@${GOPLS_VERSION}
RUN for tool in tools/cmd/goimports lint/golint; \
    do go install golang.org/x/${tool}@latest; \
    done

# Detect shadowing bugs
RUN go install golang.org/x/tools/go/analysis/passes/shadow/cmd/shadow@latest

# Visual Studio Code tools
RUN go install github.com/cweill/gotests/gotests@latest
RUN go install github.com/fatih/gomodifytags@latest
RUN go install github.com/josharian/impl@latest
RUN go install github.com/haya14busa/goplay/cmd/goplay@latest
RUN go install github.com/go-delve/delve/cmd/dlv@latest
RUN go install honnef.co/go/tools/cmd/staticcheck@latest
RUN go install github.com/ramya-rao-a/go-outline@latest

# Setup shell
USER $USERNAME
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended &> /dev/null
ENV ENV="/home/$USERNAME/.ashrc" \
    ZSH=/home/$USERNAME/.oh-my-zsh \
    EDITOR=vi \
    LANG=en_US.UTF-8 \
    PATH=/home/vscode/.local/bin:$PATH \
    GOPATH=/home/$USERNAME/go
RUN printf 'ZSH_THEME="agnoster"\nENABLE_CORRECTION="false"\nplugins=(git copyfile extract colorize dotenv encode64 golang)\nsource $ZSH/oh-my-zsh.sh' > "/home/$USERNAME/.zshrc"
RUN echo "exec `which zsh`" > "/home/$USERNAME/.ashrc"

# To run mkdocs server as per Eitri standards
COPY config/* .
RUN python3 -m pip install -r requirements.txt

USER root
