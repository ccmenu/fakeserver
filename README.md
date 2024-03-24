# fakeserver

A fake CI server for testing CCMenu.

The server is written in Ruby and uses the Sinatra web framework. You can start it with this command

`./fakeserver.sh`

If you want to test https then you can start the server as follows. A self-signed certificate is checked into this repository.

 `./fakeserver.sh -- --ssl`

The server provides a CCTray feed at `/cctray.xml` where CCMenu should disover it when you only enter the hostname without a path. The server provides feeds at various other paths to allow manual testing of some special cases. Credentials for HTTP Basic Auth are hard-coded in the `authorized?` method.

The server offers a web-based interface to start and stop builds for the connectfour test project. This interface is served on `/control` but there's a redirect from `/`, too.

By default the feed and the web interface are served at `http://localhost:4567`.
