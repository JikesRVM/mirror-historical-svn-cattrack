#!/bin/bash

export DAY=`date +%A'
cd /home/postgres && ( pg_dump cattrack | gzip cattrack.$DAY.gz
