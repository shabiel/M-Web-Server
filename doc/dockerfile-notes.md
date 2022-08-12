Dockerfile Notes
----------------
- To build docker image/run tests, do this:

```
docker build -t mws .
```

- To run server inside of image (at port 9080):

```
docker run -v $PWD/src:/mwebserver/r --rm -it -p 9080:9080 mws bash
$ . /opt/yottadb/current/ydb_env_set
$ mumps -r %webreq
```

At the same time, you can modify the source code in the `src` directory and see
the changes live.
