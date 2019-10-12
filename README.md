# M Web Server
This source tree represents a web (HTTP) server implemented in the M language.
It is maintained by OSEHRA, the Open Source Electronic Health Record Alliance.

## Purpose
The MUMPS Advanced Shell MUMPS Web Server (MWS) provides for a way to serve web
services from the MUMPS Database. It does that by mapping URLs to MUMPS
procedures that retrieve or save the data depending on the request. The mapping
is dynamic and depends on a Fileman-compatible file which allows you to
configure security on each web service. The MUMPS Web Server is independent of
VISTA and does not need any part of VISTA in order to run--not even Fileman.

MWS provides the following features:

 - It is completely stateless.
 - It runs plain RESTful web services rather than implementing a custom protocol.
 - It does not introduce any new data structures. Fileman data structures are used as the source of truth.
 - It fully supports JSON out of the box; XML is also supported.
 - It provides Meaningful URLs to VISTA data to make it easy to program against VISTA.
 - It is integrated with VISTA's security primitives.
 - It is simple to deploy.

This project aims to provide standardized and easy to deploy RESTful web 
services from M and from VISTA. The software can also serve file-system based
resources that can take advantage of the web services.

See [M-Restful-Services-White-Paper.md](M-Restful-Services-White-Paper.md) for
more information.

## Install & Dependencies
See [INSTALL.md](doc/INSTALL.md).

## Developer Documentation
See the [doc](doc) folder.

To make a new version, see [doc/packaging.md](doc/packaging.md).

To set-up TLS, see [doc/tls-setup.md](doc/tls-setup.md).

## Testing Documentation
There are extensive [unit tests](doc/testing.md) covering 80% of
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
