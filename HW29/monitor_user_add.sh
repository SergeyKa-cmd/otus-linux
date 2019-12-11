#!/bin/bash

mysql -h 127.0.0.1 -uroot -p'1MySQL(Password)' << EOF
CREATE USER 'monitor'@'%' IDENTIFIED BY 'monitor';
GRANT SELECT on sys.* to 'monitor'@'%';
GRANT USAGE ON *.* TO 'monitor'@'%';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then echo "User monitor added!"; else echo "Error occured"; fi