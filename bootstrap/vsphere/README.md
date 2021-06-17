# Summary

This directory contains a Docker container which is configured to run Ansible
for the purpose of configuring a freshly installed set of ESXi servers. The
container includes all the required dependencies and the only external
requirement is a mounted copy of the vCenter ISO image and the required
environment variables for connecting to and configuring ESXi/vCenter. 

# Process

The series of Ansible playbooks performs the following process:

1. Configures ESXi hosts by changing the root password, configuring services,
and getting the deployment host ready for recieving the vCenter deployment.
2. Deploys the VCSA VM to the deployment host
3. Creates the DC/cluster and adds ESXi hosts accordingly
4. Configures iSCSI and migrates the VCSA VM to the iSCSI datastore
5. Migrate the VCSA VM (and it's host) to the cluster
6. Configures vDS and it's associated port groups and migrate host networking
over to it
7. Enables HA/DRS on the cluster
8. Configures misc settings like adding tags and silencing warnings

# Usage

Since the configuration/secret infrastructure has not been configured in a
scenario where the virtualization infrastructure is being bootstrapped, the 
required secrets are obtained via LastPass using the CLI tool. The below script
will automatically login to LastPass and configure the required environment
variables:

```bash
$> source env.sh
```

The vCenter ISO image will need to be mounted on the local system before running
the Docker container. The image is mounted as a volume to the container and is
used for deploying vCenter. Once the image is mounted, execute the run script
and pass the path to the mounted image as such:

```bash
$> ./run.sh /Volumes/VMware\ VCSA/
```

The script will proceed with all the required installation steps and this
process can take anywhere between 30-45 minutes. Once completed, the appropriate
cluster will be configured and ready for recieving VM deployments. 