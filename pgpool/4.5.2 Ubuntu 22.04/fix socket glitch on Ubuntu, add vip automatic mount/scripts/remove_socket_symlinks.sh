#!/bin/bash

/usr/bin/test -L /var/run/postgresql/.s.PGSQL.9999 && rm -f /var/run/postgresql/.s.PGSQL.9999 ; /usr/bin/test -L /tmp/.s.PGSQL.9999 && rm -f /tmp/.s.PGSQL.9999

/usr/bin/test -L /var/run/postgresql/.s.PGPOOLWD_CMD.9000 && rm -f /var/run/postgresql/.s.PGPOOLWD_CMD.9000 ; /usr/bin/test -L /tmp/.s.PGPOOLWD_CMD.9000 && rm -f /tmp/.s.PGPOOLWD_CMD.9000

/usr/bin/test -L /var/run/postgresql/.s.PGSQL.9898 && rm -f /var/run/postgresql/.s.PGSQL.9898 ; /usr/bin/test -L /tmp/.s.PGSQL.9898 && rm -f /tmp/.s.PGSQL.9898

true
