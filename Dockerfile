# This Dockerfile is for creating a Centos 7 docker with openldap installed
# Customize the associated ldif files to create your own openldap docker
#
FROM centos:centos7
MAINTAINER TechYugadi <techyugadi@gmail.com>

#LDAP configuration

ENV OPENLDAP_PORT 389

#Install OpenLDAP server and client
RUN yum -y update; yum clean all
RUN yum -y install openldap-servers openldap-clients cyrus-sasl; yum clean all

#Copy LDAP Config
RUN \cp -f /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

RUN mkdir -p /ldapconfig
COPY root.ldif /ldapconfig/
COPY users.ldif /ldapconfig/
COPY org.ldif /ldapconfig/
COPY initldap.sh /ldapconfig/

RUN /ldapconfig/initldap.sh

#SSH Configuration

ENV OPENSSH_PORT 22

RUN yum -y update; yum clean all
RUN yum -y install openssh-server; yum clean all
RUN rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
    /bin/ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
    /bin/ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key

RUN /bin/mkdir -p /sshconfig
COPY id_rsa.pub /sshconfig/
RUN /bin/mkdir -p /root/.ssh && /bin/cat /sshconfig/id_rsa.pub >> /root/.ssh/authorized_keys

RUN /bin/chmod 400 /root/.ssh/authorized_keys
RUN /bin/chown root:root /root/.ssh/authorized_keys
# tell ssh to not use ugly PAM
#RUN /bin/sed -i 's/UsePAM\syes/UsePAM no/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN echo 'NETWORKING=yes' >> /etc/sysconfig/network

#Supervizor Configuration

RUN yum -y update; yum clean all
RUN yum -y install python-setuptools; yum clean all
RUN /bin/easy_install supervisor
COPY supervisord.conf /etc/supervisord.conf

#Run supervisor 
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

EXPOSE $OPENSSH_PORT $OPENLDAP_PORT
