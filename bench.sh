#!/bin/sh

rm payload
echo -n --b\r\n'Content-Disposition: form-data; name="f"; filename="payload"'\r\n\r\n > payload
dd if=/dev/zero bs=5M count=1 >> payload
echo -n \r\n--b--\r\n\r\n >> payload
time ab -n 10 -c 5 -p payload -T "multipart/form-data; boundary=b" $*
