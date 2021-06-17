This repository contains the files necessary to bring up a development version
of the Gilman Lab core infrastructure.

# Usage

1. Run `./up.sh` to bring up the development stack
2. Run `source scripts/login.sh` to login to Vault
3. Run `source env.sh` to finish setting up the local environment
4. Run `./dev.sh` to enter into a development container

Note that the CA certificate is mounted into the development container but
not yet loaded. To load the certificate run `update-ca-certificates` in the
container.