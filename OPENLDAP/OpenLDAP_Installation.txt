OpenLDAP  Installation
- Purpose
 Centralized user authentication 
 Directory services for networks 
 Integration with applications (e.g., Samba, Dovecot, Postfix)
 Identity and access management
 Single Sign-On (SSO) support
- Key Compenents
 slapd          - LDAP server daemon
 ldapsearch     - Command-line tool to query LDAP
 ldapadd        - Adds entries to the directory
 ldapmodify     - Modifies existing entries

- Common use case:
 Authenticate users across multiple systems from a single LDAP server.
 Store user data (names, emails, passwords, groups) centrally.
