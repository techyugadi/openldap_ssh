#!/bin/bash
LDAPROOTPSWD=secret
USERPSWD=bobsecret

/sbin/slapd -h 'ldap:///  ldapi:///' -g ldap -u ldap -d 0 & sleep 6
/bin/ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
/bin/ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
/bin/ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sed -i "s|LDAPROOTPSWD|$( slappasswd -h {SSHA} -s $LDAPROOTPSWD )|g" /ldapconfig/root.ldif
/bin/ldapmodify -Y EXTERNAL -H ldapi:/// -f /ldapconfig/root.ldif
sed -i "s|cn=Manager,dc=my-company,dc=com|cn=Manager,dc=mycompany,dc=com|g" /etc/openldap/slapd.d/cn=config/olcDatabase={1}monitor.ldif

echo "olcAccess: {0}to attrs=userPassword by self write by dn.base=\"cn=Manager,dc=mycompany,dc=com\" write by anonymous auth by * none" >> /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif
echo "olcAccess: {1}to * by dn.base=\"cn=Manager,dc=mycompany,dc=com\" write by self write by * read" >> /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif

kill -INT `cat /var/run/openldap/slapd.pid`
sleep 6
/sbin/slapd -h 'ldap:///  ldapi:///' -g ldap -u ldap -d 0 & sleep 6

/bin/ldapadd -x -w $LDAPROOTPSWD -D cn=Manager,dc=mycompany,dc=com -H ldapi:/// -f /ldapconfig/org.ldif
sed -i "s|USERPSWD|$(slappasswd -h {SSHA} -s $USERPSWD)|g" /ldapconfig/users.ldif

/sbin/slapd -h 'ldap:///  ldapi:///' -g ldap -u ldap -d 0 & sleep 6 &&\
/bin/ldapadd -v -x -w secret -D cn=Manager,dc=mycompany,dc=com -H ldapi:/// -f /ldapconfig/users.ldif

kill -INT `cat /var/run/openldap/slapd.pid`
sleep 6
