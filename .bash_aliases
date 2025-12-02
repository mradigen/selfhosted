## User:
shopt -s expand_aliases

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export DOCKER_REGISTRY="reg.phy0.in/"
export PATH=$PATH:/usr/local/go/bin:/home/adigen/.local/bin

alias headscale="docker exec headscale headscale"
alias kubectl="sudo k3s kubectl"
alias r="ranger"
alias d="docker"
alias dc="docker compose"
alias artillery="docker run --rm -it -v ${PWD}:/scripts artilleryio/artillery:latest"
alias cd="z"
alias zj="zellij"

# Additional features
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

eval "$(zoxide init bash)"

# Start Zellij
if [[ -z "$ZELLIJ" ]]; then
    if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
        zellij attach -c
    else
        zellij
    fi

    if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
        exit
    fi
fi

