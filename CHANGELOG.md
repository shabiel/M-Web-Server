# 0.1.1
Initial Version

# 0.1.2
Version of GTM Multithreaded Listener

# 0.1.3
 - Gzip compression for GTM
 - TLS Support for Cache/GTM
 - Fix installer for Cache
 - Fixes of upsteam JSON parser included (David from Fourth Watch)

# 0.1.4
 - Gzip will use /dev/shm or /tmp depending on OS (current code failed on Darwin)
 - Cache-Control header support (Ken from VEN)
 - Default 7 day cache for web pages (Ken from VEN)
 - Much bigger list of MIME support (Ken from VEN)
 - Installer bug fixes; code for downloading and installing routines from the internet optimized for copying and pasting into other programs.
 - Databaseless mode support for GTM/YDB (Chris from YottaDB LLC)
 - Home page can be replaced with index.html if it is present. However, /filesystem/ needs to be removed so that links from the index page would work - they currently don't. (Chris from YottaDB LLC)
