# MUMPS Based RESTful Services Using the MUMPS Web Server
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

## Statelessness
Each request is independent of other requests and does not depend on previous
requests for state. MWS does not use cookies. Authentication is handled by
authenticating for every request. RPC security (not currently implemented) will
be implemented using custom HTTP headers.

## RESTful Web Services
Datapoints (or resources in RESTful parlance) in VISTA are each represented
using a unique URL. Manipulation of resources can be done using POST, PUT, and
GET HTTP verbs. GET and PUT HTTP requests are idempotent (i.e. doing multiple
requests does not result in a change of the result). Bodies of responses can be
used to guide the client on next actions. All of these properties enable easy
development of consuming client code.

## Data Structures
MWS does not re-invent VISTA data structures. Fileman remains the source of
truth for VISTA data structures.

## JSON and XML Support
MWS natively supports JSON conversion from and to MUMPS sparse arrays, allowing
the representation of most MUMPS globals as JSON. XML can be supported through the
VISTA MXML package.

## Meaningful URLs
MWS exposes VISTA data in meaningful URLs: fileman data is exposed as
/fileman/file/iens/field; search for data is exposed as
/fileman/file/index/search-string. Remote procedures are exposed as /rpc/\[url
encoded rpc-name\].

## Integration with VISTA Security Primitives
The web services configuration file supports securing each individual web
service differently. A web service can be secured by requiring authentication,
and requiring access to a combination of the following: a security key, no
access to a security key (i.e. a reverse key), and access to a menu option in
the VISTA menu system.

## Simplicity of Deployment
MWS serves web services directly from MUMPS. Native support for TLS is
available. As such, it's very easy to install and deploy.  Future development
can allow integration with non-blocking servers such as node.js.

Source code repository: <https://github.com/shabiel/M-Web-Server>

It is hoped that MWS will provide an easy way to develop for VISTA.

# Credits:
The M web server was written by Kevin Meldrum as part of the Virtual Patient
Record/Health Management Platform project.  Security, Remote Procedure support,
parameterized request handling was written by Sam Habiel.

This project started with code contained in the [Health Management Platform (HMP)
JSON store](https://github.com/OSEHRA-Sandbox/Health-Management-Platform/tree/master/hmp/hmp-main/src/main/mumps/dbj).
