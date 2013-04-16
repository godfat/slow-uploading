
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
