module ovs-plugin

go 1.21

require (
    github.com/docker/go-plugins-helpers v0.2.1
    github.com/Microsoft/go-winio v0.0.0
    github.com/coreos/go-systemd/activation v0.0.0
    github.com/docker/go-connections/sockets v0.0.0
    github.com/stretchr/testify v0.0.0
)

replace github.com/docker/go-plugins-helpers => ./vendor/github.com/docker/go-plugins-helpers
replace github.com/Microsoft/go-winio => ./vendor/github.com/Microsoft/go-winio
replace github.com/coreos/go-systemd/activation => ./vendor/github.com/coreos/go-systemd/activation
replace github.com/docker/go-connections/sockets => ./vendor/github.com/docker/go-connections/sockets
replace github.com/stretchr/testify => ./vendor/github.com/stretchr/testify

