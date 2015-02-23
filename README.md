# openldap-ssh-docker
Dockerfile and other required files to build and run a CentOS 7 docker with OpenLDAP and sshd installed. Suitable for dev and test purposes that need an LDAP.
The purpose of having sshd installed is to enable accessing the docker using ssh from the host machine and adding / modifying user records in LDAP.
Besides, it also illustrates technique of running more than one service in a docker (if you have to) using supervisor.

#Dockerhub

A docker using this Dockerfile has already been published to dockerhub at :

https://registry.hub.docker.com/u/techyugadi/openldap_ssh/

# Build

To build your docker using the Dockerfile in this repository :

i. Copy these files to your local machine : Dockerfile , initldap.sh, root.ldif, org.ldif, users.ldif and supervisord.conf. 

ii.Ensure that the file initldap.sh has execute permissions after copying. MODIFY the ldif files, to reflect your domain name and organizational hieararchy. 

iii. MOST IMPORTANT : create your own ssh key pair and copy the id_rsa.pub file to the same directory

(The docker image techyugadi/openldap_ssh in docker hub has a public key already embedded in it. This public key and the corresponding private key are added to this git repo, in the keys directory, just in case you want to get started quickly.)

iv. Then from the directory where you copied the files, run :

sudo docker build -t="your_user/openldap_ssh" . 

(Replace your_user by your user name)

# Run

To run the docker, issue the following command :

sudo docker run -d your_user/openldap_ssh

(Replace your_user by your user name)

This will start the docker, and expose ports 22 (for SSH daemon) and 389 (for OpenLDAP) in the docker container.

# Trouble-shooting

If you come across an error like : 'ch_calloc: Assertion failed', please set ulimit to a high value (in your Dockerfile) as per the discussion here :

http://github.com/docker/docker/issues/8231
