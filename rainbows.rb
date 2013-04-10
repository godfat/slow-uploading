
eval File.read('unicorn.rb')

Rainbows! do
  use :EventMachine
  client_max_body_size      10*1024*1024 # 10 megabytes
  client_header_buffer_size  8*1024      #  8 kilobytes
end
