
# Demonstration for Slow Uploading Issue on Heroku Cedar Stack with Unicorn

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
(Make sure you have `celluloid-io` installed before running this script:
`gem install celluloid-io`)

    ./dos-attack.rb your-app.herokuapp.com

It would make 50 concurrent requests with 1M payload to the host. Running
this command and launch your browser and hit `http://your-app.herokuapp.com/`.
With Unicorn running, you can see the application is blocked by the script,
making it unavailable to your browser.

Switching to Rainbows! with EventMachine would solve this issue. However,
this could only solve slow clients issue, but not head-of-queue blocking
issue. If your application is running slowly, you would need threads to
address it. If you don't want to use threads, Nginx would be your best
friend.

Here's a simple [Rainbows! config with EventMachine and a thread pool](https://github.com/godfat/ruby-server-exp/blob/master/config/rainbows-em-thread-pool.rb).
I'm working on merging this back to the official repository. However, I
cannot make all tests passed. The failing test is against pipelined large
chunked requests. The current work is located at [my branch](https://github.com/godfat/rainbows/pull/2). Nevertheless, this is a very rare case, there
might be no one using that. So I guess it is ok.

## Trivial Benchmark

This benchmark would run `ab -n 10 -c 5` with 5M payload.

    ./bench.sh http://your-app.herokuapp.com/

## How to Switch to Rainbows!?

Edit `Procfile` with `sed s/unicorn/rainbows/g` and you're done. See
`rainbows` branch if you don't get it.
