#! /bin/zsh
open -a "Safari" http://localhost:8080/
if ps -cax | grep -q calibre-server; then
  echo "calibre has been started."
  ps -ef | grep calibre-server
else
  echo "calibre not started. start it."
  calibre_home=/usr/bin
  ${calibre_home}/calibre-server
fi
