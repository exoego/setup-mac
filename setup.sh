#!/bin/zsh
set --errexit --nounset --xtrace

brew update
arch -arm64 brew upgrade

declare -a packages=(
    "alacritty"

    "openssl@1.1"
    "postgresql"

    "docker" # CLI, not docker-desktop
    "docker-compose"
    "lima"

    "jetbrains-toolbox"
    "asdf"
    "git-lfs"
    "git-delta"
    "bat"
    "hyperfine"
    "broot"
    "tokei"
    "dust"
    "dua-cli"
    "zoxide"
    "sk"
    "xh"
    "procs"
    "bottom"
    "zellij"

    "tealdeer"
    "navi"

    "exa"
    "lsd"

    "pnpm"
)
arch -arm64 brew install $packages

declare -a cask_packages=(
    "karabiner-elements"
)
arch -arm64 brew install --cask $cask_packages

# Setup Java
asdf plugin-add java https://github.com/halcyon/asdf-java.git
sed -i '' '\/libexec\/asdf.sh/d' ~/.zshrc
echo ". $(brew --prefix asdf)/libexec/asdf.sh" >> ~/.zshrc

# Setupd Docker + Lima (Avoid Docker Desktop)
# https://docs.docker.com/engine/install/ubuntu/
limactl start
lima sudo apt-get update
lima sudo apt-get install -y ca-certificates curl gnupg lsb-release
lima sh -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg'
lima sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
lima sudo apt-get update
lima sudo apt-get install -y docker-ce docker-ce-cli containerd.io
lima sudo sh -c 'echo "{\"hosts\": [\"tcp://127.0.0.1:2375\", \"unix:///var/run/docker.sock\"]}" > /etc/docker/daemon.json'
lima sudo mkdir -p /etc/systemd/system/docker.service.d/
lima sudo sh -c 'echo "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd" > /etc/systemd/system/docker.service.d/override.conf'
lima sudo systemctl daemon-reload
lima sudo systemctl restart docker.service
# Interact with Lima from Mac
sed -i '' '/DOCKER_HOST="tcp:\/\/127.0.0.1:2375"/d' ~/.zshrc
echo 'export DOCKER_HOST="tcp://127.0.0.1:2375"' >> ~/.zshrc

# Setup Node.js
asdf plugin add nodejs
asdf install nodejs latest:16
asdf global nodejs latest:16

# Setup sbt for Scala
asdf plugin-add sbt
asdf install sbt latest:1
asdf global sbt latest:1

# Setup Ruby development
asdf plugin add ruby
RUBY_CFLAGS="-DUSE_FFI_CLOSURE_ALLOC" arch -arm64 asdf install ruby 2.7.1
asdf global ruby 2.7.1

# Setup Sheldon
arch -arm64 brew install sheldon
sed -i '' '/eval "$(sheldon source)"/d' ~/.zshrc
echo 'eval "$(sheldon source)"' >> ~/.zshrc
mkdir -p ~/.sheldon && touch ~/.sheldon/plugins.toml

# Setups starship
arch -arm64 brew install starship
mkdir -p ~/.config && touch ~/.config/starship.toml
sed -i '' '/eval "$(starship init zsh)"/d' ~/.zshrc
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
