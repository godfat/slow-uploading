
# Demonstration for Slow Uploading Issue on Heroku Cedar Stack with Unicorn

TL;DR: To address slow uploading issue for Unicorn, either use Nginx or
Rainbows! with EventMachine (until something could replace EventMachine).

## The Example Application

We take this very simple application which parses POST body as an example:

``` ruby
run lambda{ |env|
  now  = Time.now
  Rack::Request.new(env).POST
  diff = (Time.now - now).to_f.to_s
  [200, {'Content-Length' => (diff.size + 1).to_s}, ["#{diff}\n"]]
}
```

You can simply push this repository to Heroku to run it.

## Denial of Service Attack Against Unicorn on Heroku Cedar Stack

This script would do a very simple DoS attack against applications
running with Unicorn and parsing POST body on Heroku Cedar stack.
(Make sure you have `celluloid-io` installed and patched with this
[pull request](https://github.com/celluloid/celluloid-io/pull/52)
before running this script: `gem install celluloid-io`)

    ./dos-attack.rb your-app.herokuapp.com

It would make 50 concurrent requests with 1M payload to the host slowly,
and 50 concurrent fast requests which should be responded immediately.
With Unicorn running, you can see the application is blocked by the
slow uploading, making the server respond slowly to other fast clients.

Switching to Rainbows! with EventMachine would solve this issue. Any
fast clients could get the response fast, and let slow clients get
responses slowly as we would expect.

## How to Switch to Rainbows!?

Edit `Procfile` with `sed s/unicorn/rainbows/g` and you're done. See
[rainbows](https://github.com/godfat/slow-uploading/tree/rainbows) branch if you don't get it.

## A Simple Result

### With Unicorn

    Fast Request: Server:  0.006072  Client:  0.556211
    Fast Request: Server:  0.020797  Client:  0.549858
    Fast Request: Server:  0.000000  Client: 25.163803
     Slow Upload: Server: 24.598561  Client: 25.164132
    Fast Request: Server:  0.000017  Client: 27.133608
     Slow Upload: Server:  1.943602  Client: 27.129733
     Slow Upload: Server:  2.835424  Client: 29.965330
     Slow Upload: Server: 29.452087  Client: 29.992707
    Fast Request: Server:  0.000000  Client: 30.519966
    Fast Request: Server:  0.000000  Client: 30.522115
    Fast Request: Server:  0.000000  Client: 30.504414
    Fast Request: Server:  0.000000  Client: 30.500008
    Fast Request: Server:  0.000000  Client: 30.548768
    Fast Request: Server:  0.000000  Client: 30.544840
    Fast Request: Server:  0.000000  Client: 30.554672
    Fast Request: Server:  0.000000  Client: 30.549935
    Fast Request: Server:  0.000000  Client: 30.553387
    Fast Request: Server:  0.000000  Client: 30.537094
    Fast Request: Server:  0.000000  Client: 30.543002
    Fast Request: Server:  0.000000  Client: 30.536527
    Fast Request: Server:  0.000000  Client: 30.564070
    Fast Request: Server:  0.000000  Client: 30.549337
    Fast Request: Server:  0.000000  Client: 30.543024
    Fast Request: Server:  0.000000  Client: 30.570357
    Fast Request: Server:  0.000000  Client: 30.542086
    Fast Request: Server:  0.000000  Client: 30.547023
    Fast Request: Server:  0.000000  Client: 30.564763
    Fast Request: Server:  0.000000  Client: 30.569082
    Fast Request: Server:  0.000000  Client: 30.553861
    Fast Request: Server:  0.000000  Client: 30.573553
    Fast Request: Server:  0.000000  Client: 30.563701
    Fast Request: Server:  0.000000  Client: 30.593784
    Fast Request: Server:  0.000000  Client: 30.607062
    Fast Request: Server:  0.000000  Client: 30.601997
    Fast Request: Server:  0.000000  Client: 30.932576
    Fast Request: Server:  0.000000  Client: 30.977656
    Fast Request: Server:  0.000000  Client: 31.550038
    Fast Request: Server:  0.000000  Client: 31.550361
    Fast Request: Server:  0.000000  Client: 31.572741
    Fast Request: Server:  0.000000  Client: 31.554272
    Fast Request: Server:  0.000000  Client: 31.551809
    Fast Request: Server:  0.000000  Client: 31.565538
    Fast Request: Server:  0.000000  Client: 31.573551
    Fast Request: Server:  0.000000  Client: 31.568841
    Fast Request: Server:  0.000000  Client: 31.559254
    Fast Request: Server:  0.000000  Client: 31.581731
    Fast Request: Server:  0.000000  Client: 31.583682
    Fast Request: Server:  0.000000  Client: 31.679816
    Fast Request: Server:  0.000000  Client: 31.700620
    Fast Request: Server:  0.000000  Client: 33.447381
     Slow Upload: Server: 34.794628  Client: 35.309662
    Fast Request: Server:  0.000000  Client: 36.603441
    Fast Request: Server:  0.000000  Client: 36.600524
    Fast Request: Server:  0.000000  Client: 36.596304
    Fast Request: Server:  0.000000  Client: 36.587325
     Slow Upload: Server:  6.704092  Client: 36.667152
     Slow Upload: Server:  1.325843  Client: 37.970003
     Slow Upload: Server: 37.814853  Client: 38.369247
     Slow Upload: Server:  0.092056  Client: 38.462792
     Slow Upload: Server:  0.104226  Client: 38.560897
     Slow Upload: Server:  0.095220  Client: 38.646953
     Slow Upload: Server:  0.126940  Client: 38.790906
     Slow Upload: Server:  0.201364  Client: 38.990417
     Slow Upload: Server:  1.685444  Client: 39.712930
     Slow Upload: Server:  0.223756  Client: 39.914301
     Slow Upload: Server: 11.399644  Client: 41.397796
     Slow Upload: Server:  1.926276  Client: 41.838108
     Slow Upload: Server:  0.235048  Client: 42.069869
     Slow Upload: Server:  0.059699  Client: 42.120883
     Slow Upload: Server:  0.118339  Client: 42.234195
     Slow Upload: Server:  0.154221  Client: 42.386302
     Slow Upload: Server:  0.317082  Client: 42.706941
     Slow Upload: Server:  1.414012  Client: 42.792741
     Slow Upload: Server:  0.189865  Client: 42.886127
     Slow Upload: Server:  0.235988  Client: 43.044869
     Slow Upload: Server:  0.174253  Client: 43.073607
     Slow Upload: Server:  0.058848  Client: 43.152562
     Slow Upload: Server:  0.120868  Client: 43.143361
     Slow Upload: Server:  0.067199  Client: 43.189365
     Slow Upload: Server:  0.115995  Client: 43.253345
     Slow Upload: Server:  0.107812  Client: 43.358437
     Slow Upload: Server:  0.276069  Client: 43.478449
     Slow Upload: Server:  0.112423  Client: 43.503993
     Slow Upload: Server:  0.161059  Client: 43.651190
     Slow Upload: Server:  0.183011  Client: 43.666212
     Slow Upload: Server:  0.057671  Client: 43.713245
     Slow Upload: Server:  0.069114  Client: 43.716193
     Slow Upload: Server:  4.765837  Client: 43.760144
     Slow Upload: Server:  0.062533  Client: 43.758856
     Slow Upload: Server:  0.085408  Client: 43.813679
     Slow Upload: Server:  0.108062  Client: 43.844413
     Slow Upload: Server:  0.090623  Client: 43.857531
     Slow Upload: Server:  0.111162  Client: 43.932428
     Slow Upload: Server:  0.070169  Client: 43.936519
     Slow Upload: Server:  0.085543  Client: 43.925756
     Slow Upload: Server:  0.057380  Client: 44.002495
     Slow Upload: Server:  0.071675  Client: 44.009978
     Slow Upload: Server:  0.177558  Client: 44.167061
     Slow Upload: Server:  9.624512  Client: 44.993778
     Slow Upload: Server:  2.017310  Client: 45.960921

### With Rainbows! with EventMachine

    Fast Request: Server:  0.000021  Client:  0.480073
    Fast Request: Server:  0.000017  Client:  0.465383
    Fast Request: Server:  0.000008  Client:  0.477394
    Fast Request: Server:  0.000008  Client:  0.464261
    Fast Request: Server:  0.000009  Client:  0.482804
    Fast Request: Server:  0.000018  Client:  0.484193
    Fast Request: Server:  0.000009  Client:  0.462815
    Fast Request: Server:  0.000008  Client:  0.486749
    Fast Request: Server:  0.000008  Client:  0.478719
    Fast Request: Server:  0.000015  Client:  0.473328
    Fast Request: Server:  0.000008  Client:  0.472794
    Fast Request: Server:  0.000008  Client:  0.476616
    Fast Request: Server:  0.000010  Client:  0.488184
    Fast Request: Server:  0.000010  Client:  0.473193
    Fast Request: Server:  0.000036  Client:  0.474039
    Fast Request: Server:  0.000024  Client:  0.514449
    Fast Request: Server:  0.000024  Client:  0.484744
    Fast Request: Server:  0.000009  Client:  0.523951
    Fast Request: Server:  0.000009  Client:  0.490312
    Fast Request: Server:  0.000022  Client:  0.493404
    Fast Request: Server:  0.000018  Client:  0.527190
    Fast Request: Server:  0.000010  Client:  0.517327
    Fast Request: Server:  0.000011  Client:  0.525474
    Fast Request: Server:  0.000007  Client:  0.508925
    Fast Request: Server:  0.000012  Client:  0.501849
    Fast Request: Server:  0.000009  Client:  0.539673
    Fast Request: Server:  0.000008  Client:  0.540821
    Fast Request: Server:  0.000011  Client:  0.523010
    Fast Request: Server:  0.000015  Client:  0.543564
    Fast Request: Server:  0.000011  Client:  0.548428
    Fast Request: Server:  0.000011  Client:  0.515838
    Fast Request: Server:  0.000016  Client:  0.536290
    Fast Request: Server:  0.000018  Client:  0.557783
    Fast Request: Server:  0.000024  Client:  0.545607
    Fast Request: Server:  0.000017  Client:  0.555119
    Fast Request: Server:  0.000009  Client:  0.548268
    Fast Request: Server:  0.000020  Client:  0.573716
    Fast Request: Server:  0.000019  Client:  0.566002
    Fast Request: Server:  0.000014  Client:  0.550562
    Fast Request: Server:  0.000009  Client:  0.562170
    Fast Request: Server:  0.000009  Client:  0.559568
    Fast Request: Server:  0.000018  Client:  0.588529
    Fast Request: Server:  0.000022  Client:  0.814884
    Fast Request: Server:  0.000021  Client:  1.584281
    Fast Request: Server:  0.000022  Client:  1.594519
    Fast Request: Server:  0.000015  Client:  1.574818
    Fast Request: Server:  0.000021  Client:  1.595932
    Fast Request: Server:  0.000039  Client:  1.601574
    Fast Request: Server:  0.000010  Client:  1.600343
    Fast Request: Server:  0.000023  Client:  1.605428
     Slow Upload: Server:  0.008801  Client: 27.914253
     Slow Upload: Server:  0.014987  Client: 29.511524
     Slow Upload: Server:  0.006587  Client: 30.716685
     Slow Upload: Server:  0.006357  Client: 32.182543
     Slow Upload: Server:  0.012129  Client: 32.228273
     Slow Upload: Server:  0.005411  Client: 32.578170
     Slow Upload: Server:  0.012144  Client: 32.782130
     Slow Upload: Server:  0.011037  Client: 33.758409
     Slow Upload: Server:  0.042762  Client: 33.881185
     Slow Upload: Server:  0.013430  Client: 34.188827
     Slow Upload: Server:  0.101143  Client: 34.735648
     Slow Upload: Server:  0.005882  Client: 35.210380
     Slow Upload: Server:  0.007360  Client: 35.255416
     Slow Upload: Server:  0.007015  Client: 35.340739
     Slow Upload: Server:  0.014481  Client: 35.541253
     Slow Upload: Server:  0.017011  Client: 35.778469
     Slow Upload: Server:  0.011493  Client: 35.795213
     Slow Upload: Server:  0.012398  Client: 36.225711
     Slow Upload: Server:  0.015291  Client: 36.565516
     Slow Upload: Server:  0.011651  Client: 36.574548
     Slow Upload: Server:  0.006613  Client: 36.984746
     Slow Upload: Server:  0.014658  Client: 36.986202
     Slow Upload: Server:  0.013559  Client: 38.448018
     Slow Upload: Server:  0.013918  Client: 38.857900
     Slow Upload: Server:  0.014629  Client: 38.868641
     Slow Upload: Server:  0.004886  Client: 38.873898
     Slow Upload: Server:  0.015431  Client: 38.960264
     Slow Upload: Server:  0.007992  Client: 39.120231
     Slow Upload: Server:  0.013109  Client: 39.334079
     Slow Upload: Server:  0.005085  Client: 39.513112
     Slow Upload: Server:  0.013155  Client: 39.582475
     Slow Upload: Server:  0.017156  Client: 39.945550
     Slow Upload: Server:  0.015036  Client: 39.934605
     Slow Upload: Server:  0.014068  Client: 40.067253
     Slow Upload: Server:  0.004899  Client: 40.242732
     Slow Upload: Server:  0.005942  Client: 40.285879
     Slow Upload: Server:  0.006314  Client: 40.411893
     Slow Upload: Server:  0.014326  Client: 41.170308
     Slow Upload: Server:  0.012932  Client: 41.458996
     Slow Upload: Server:  0.012344  Client: 41.573364
     Slow Upload: Server:  0.005248  Client: 42.179275
     Slow Upload: Server:  0.005940  Client: 42.312414
     Slow Upload: Server:  0.005517  Client: 42.520032
     Slow Upload: Server:  0.013394  Client: 42.680050
     Slow Upload: Server:  0.012433  Client: 42.829225
     Slow Upload: Server:  0.015827  Client: 43.375164
     Slow Upload: Server:  0.012503  Client: 43.436595
     Slow Upload: Server:  0.005483  Client: 44.088135
     Slow Upload: Server:  0.012956  Client: 45.323259
     Slow Upload: Server:  0.013261  Client: 46.360929

You can see there's a huge difference between running Unicorn or
Rainbows! with EventMachine. With Unicorn, the `diff` time would be
quite long, because Unicorn doesn't read the body for you. The read
time would be spent in the application. That means, the Unicorn worker
is blocked until the uploading is done. There could be a sort of DoS
attack which sends a ton of requests with never ending body to
applications whichever try to parse the request body with Unicorn.

While running Rainbows! with EventMachine, the `diff` time would be
quite short, because Rainbows! would be buffering the body from the
request, and only pass it down to the application whenever it is fully
buffered. The read time would be spent in EventMachine, which won't
block the worker from processing the other fast clients.

## Why Is It Happening?

According to this document:
[HTTP Routing and the Routing Mesh: Request buffering](https://devcenter.heroku.com/articles/http-routing#request-buffering).
Cedar stack's routers (reverse proxies) won't be buffering the
request body, which would make Unicorn very inefficient for slow
clients, since it is assuming all clients are fast client. By fast
clients, it usually means clients from internal or local network.

That is, by using Unicorn, we would want something like Nginx which
would fully buffer all requests for all the clients around the world.
You can find this information from Unicorn's documents.

[PHILOSOPHY](http://unicorn.bogomips.org/PHILOSOPHY.html),
and [DESIGN](http://unicorn.bogomips.org/DESIGN.html).

Some quotes:

> Instead of attempting to be efficient at serving slow clients,
> unicorn relies on a buffering reverse proxy to efficiently deal
> with slow clients.
>
> unicorn uses an old-fashioned preforking worker model with
> blocking I/O. Our processing model is the antithesis of more
> modern (and theoretically more efficient) server processing
> models using threads or non-blocking I/O with events.
> \[...\]
> Like Mongrel, neither keepalive nor pipelining are supported.
> These aren’t needed since Unicorn is only designed to serve
> fast, low-latency clients directly. Do one thing, do it well;
> let nginx handle slow clients.

Recently there's a discussion on
[Unicorn's mailing list](http://rubyforge.org/mailman/listinfo/mongrel-unicorn)
regarding this issue. Here's the thread:
[Unicorn hangs on POST request](http://comments.gmane.org/gmane.comp.lang.ruby.unicorn.general/1724)

[According to Tom Pesman](http://permalink.gmane.org/gmane.comp.lang.ruby.unicorn.general/1734):

> I've some new information. Heroku buffers the headers of a HTTP
> request but it doesn't buffer the body of POST requests. Because of
> that I switched to Rainbows! and the responsiveness of the application
> increased dramatically.

They switched to Rainbows! with EventMachine, which would fully
buffer the request/response as in Nginx but with EventMachine,
the responsiveness of the application increased dramatically.

The current maintainer of Unicorn and Rainbows! responded with:
[Re: Unicorn hangs on POST request](http://permalink.gmane.org/gmane.comp.lang.ruby.unicorn.general/1735)

## Further Discussion

However, Rainbows! with EventMachine would still be suffering
from head-of-queue blocking issue. That is, suppose our app
would do some heavy computing, since EventMachine is single
threaded, at the time we're computing, the whole process is
still blocking there and therefore cannot keep working for
other clients at the same time.

This could be further solved by using threads together, like
using CoolioThreadPool or CoolioThreadSpawn. But cool.io is
not actively maintained at the moment, and the author Tony
Arcieri headed the development to celluloid (which is the
core of Sidekiq), celluloid-io, and nio4r.

Last time I tried cool.io (probably two years ago), it even
gave me some assertion failures. I don't know if anyone is
using cool.io on production, either. Even though
[Eric Wong is willing to patch cool.io](http://permalink.gmane.org/gmane.comp.lang.ruby.unicorn.general/1739)
if we can provide reproducible cases, I would rather try to
write a celluloid-io based model for Rainbows! since that's
the way the community is heading to at the moment.

All after all, we're using a combination of EventMachine
and thread pool strategy, which is something like this:
[Rainbows! config with EventMachine and a thread pool](https://github.com/godfat/ruby-server-exp/blob/master/config/rainbows-em-thread-pool.rb).
I was once working on making this merge back to Rainbows!.
The unfinished work is located at
[my branch](https://github.com/godfat/rainbows/pull/2).
It's almost done, but I failed to make one test case pass:

> "send big pipelined chunked requests"

I believe not many people are doing pipelined requests
combined with big chunked data, and probably this won't
even work with Heroku's Erlang routers, so I think it
might be fine to use it on Heroku. However, if I cannot
make it pass, I don't think it could be merged. The thing
which makes it quite hard is the EventMachine API. There's
no easy way to tell EventMachine to pause a connection,
leaving the data buffered at kernel level.
