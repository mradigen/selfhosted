## User:
shopt -s expand_aliases

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export DOCKER_REGISTRY="reg.phy0.in/"
export PATH=$PATH:/usr/local/go/bin:/home/adigen/.local/bin

alias headscale="docker exec headscale headscale"
alias kubectl="sudo k3s kubectl"
alias d="docker"
alias dc="docker compose"

# Additional features
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

eval "$(zoxide init bash)"
alias cd="z"
