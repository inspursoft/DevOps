#!/bin/sh
#
# how to use is: vi /etc/hosts , the content as below
# 10.110.25.226 test1
# 10.110.25.227 test2
# call the command line as below
# ./ssh.sh test1 test2
#
#
#. /etc/init.d/functions
[[ -f /usr/bin/expect ]] || { echo "install expect";yum install expect -y; } #if have not expect will install it 
[ $? = 0 ] || { echo "failed for install expect package!!";exit; } #failed install
PUB=/root/.ssh/id_dsa.pub 
[[ -f $PUB ]] || { ssh-keygen -t dsa -P "" -f /root/.ssh/id_dsa>/dev/null 2>&1; } 

USER=root   #username
PASS=BOARD123456a? #password
PASS=$1

#expect

function EXP() {
/usr/bin/expect << EOF
set timeout 5
spawn /usr/bin/ssh-copy-id -i $PUB  $USER@$SIP$n
expect {
        "*yes/no*" { send "yes\r";exp_continue }
        "password:" { send "$PASS\n";exp_continue } 
        eof { exit }
        }
EOF
}
#
#for n in $*
for n in ${@:2}
do
  EXP >/dev/null 2>&1
  echo $n hostname >/dev/null 2>&1
  echo $n
#  [[ $? == 0 ]] && action "========$n" /bin/true || action "========$n" /bin/false
done
