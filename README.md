# openldap-ssh-docker
Dockerfile and other required files to build and run a CentOS 7 docker with OpenLDAP and sshd installed. Suitable for dev and test purposes that need an LDAP.
The purpose of having sshd installed is to enable accessing the docker using ssh from the host machine and adding / modifying user records in LDAP.
Besides, it also illustrates best practices of running more than one service in a docker (if you have to) using supervisor.

#Dockerhub

A docker using this Dockerfile has already been published to dockerhub at :


# Build

To build your docker using the Dockerfile in this repository :

i. Copy these files to your local machine : Dockerfile , initldap.sh, root.ldif, org.ldif, users.ldif and supervisord.conf. 

ii.Ensure that the file initldap.sh has execute permissions after copying. MODIFY the ldif files, to reflect your domain name and organizational hieararchy. 

iii. Then from the directory where you copied the files, run :
sudo docker build -t="your_user/openldap_ssh" . 

(Replace your_user by your user name)

# Run

To run the docker, issue the follosing command :

sudo docker run -d your_user/openldap_ssh

(Replace your_user by your user name)

This will start the docker, and expose ports 22 (for SSH daemon) and 389 (for OpenLDAP) in the docker container.
