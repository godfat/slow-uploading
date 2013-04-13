#!/bin/sh

if test not $*; then
  echo "Usage: $0 URL"
  echo "  e.g. $0 http://example.com/"
  exit 1
fi

printf -- "--b\r\n"\
'Content-Disposition: form-data; name="f"; filename="payload"'\
"\r\n\r\n"                                                    > payload

dd if=/dev/zero bs=5M count=1                                >> payload

printf -- "\r\n--b--\r\n\r\n"                                >> payload

ab -n 10 -c 5 -p payload -T "multipart/form-data; boundary=b" $*
