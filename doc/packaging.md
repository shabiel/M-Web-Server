## Packaging
This section is to help the maintainer remember how to package this when it
gets updated. We rely on the github tag for automated installation. The OSEHRA
VistA repo contains the PackRO script which is used here.

 * After editing and committing the routines, update webinit (2 places) with the new version number to be.
 * `python3 ../VistA/Scripts/PackRO.py src/webinit.m > webinit.rsa`
 * `python3 ../VistA/Scripts/PackRO.py $(find src -name '*.m' -not -name 'webinit.m' -not -name '_weburl.m') > mws.rsa`
 * Update the Install Documentation with the new version number.
 * Commit and push
 * git tag the new version number; and git push --tags
 * Attach code to the new version in releases.
 * Test on YottaDB and Cache

