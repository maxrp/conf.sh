## ssh: ~/.ssh/config and id_*
conf ${HOME}/.ssh/config
for ktype in rsa dsa ed25519 ecdsa; do
    conf ${HOME}/.ssh/id_${ktype}
    conf ${HOME}/.ssh/id_${ktype}.pub
done
