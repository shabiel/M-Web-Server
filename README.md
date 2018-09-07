# M Web Server

This source tree represents a web (HTTP) server implemented in the M language.
It is maintained by OSEHRA, the Open Source Electronic Health Record Agent.

## Purpose

This project aims to provide standardized and easy to deploy RESTful web 
services from M and from VISTA. The software can also serve file-system based
resources that can take advantage of the web services.

This project is based off code contained in the [Health Management Platform (HMP)
JSON store](https://github.com/OSEHRA-Sandbox/Health-Management-Platform/tree/master/hmp/hmp-main/src/main/mumps/dbj).

## Install
See [INSTALL.md](INSTALL.md).

## Developer Documentation
See the [doc](doc) folder.

## Packaging
This section is to help the maintainer remember how to package this when it gets updated. We rely on the github tag for automated installation.

 * After editing and committing the routines, update WWWINIT with the new version number to be.
 * Pack WWWINIT into WWWINIT.RSA with PackRO.py from the OSEHRA/VistA repo.
 * Pack MWS.RSA like this: `../VistA/Scripts/PackRO.py $(find src -name '*.m' -not -name 'WWWINIT.m') > dist/MWS.RSA`
 * Update the Install Documentation with the new version number.
 * git tag the new version number; and git push --tags
 * Test on GT.M and Cache

## Links
* OSEHRA Homepage: http://osehra.org
* OSEHRA Repositories: http://code.osehra.org
* OSEHRA Github: https://github.com/OSEHRA
* VA VistA Document Library: http://www.va.gov/vdl
