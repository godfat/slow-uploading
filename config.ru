
run lambda{ |env|
  now  = Time.now
  Rack::Request.new(env).POST
  diff = (Time.now - now).to_f.to_s
  [200, {'Content-Length' => (diff.size + 1).to_s}, ["#{diff}\n"]]
}
