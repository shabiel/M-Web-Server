# M Web Server

This source tree represents a web (HTTP) server implemented in the M language.
It is maintained by OSEHRA, the Open Source Electronic Health Record Agent.

## Purpose

This project aims to provide standardized and easy to deploy RESTful web 
services from M and from VISTA. The software can also serve file-system based
resources that can take advantage of the web services.

This project is based off code contained in the [Health Management Platform (HMP)
JSON store](https://github.com/OSEHRA-Sandbox/Health-Management-Platform/tree/master/hmp/hmp-main/src/main/mumps/dbj).

## Install & Dependencies
See [INSTALL.md](INSTALL.md).

## Developer Documentation
See the [doc](doc) folder.

To make a new version, see [packaging.md](doc/packaging.md).

## Testing Documentation
There are extensive [unit tests](doc/documentation-testing.md) covering 80% of
the code.

## Future work
A lot of work needs to be put it to make this software more user friendly.

A list of issues can be [found
here](https://github.com/shabiel/M-Web-Server/issues).

## XINDEX Note
The code does not pass XINDEX checks due to its extensive use of OS specific
calls. It should be treated as a vendor utility for the purposes of SAC Compliance.

## Links
* OSEHRA Homepage: http://osehra.org
* OSEHRA Repositories: http://code.osehra.org
* OSEHRA Github: https://github.com/OSEHRA
* VA VistA Document Library: http://www.va.gov/vdl
