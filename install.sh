#!/bin/bash

function register () {

cp /etc/issue /etc/issue-standard

cat << EOF > /usr/local/bin/get-ip-address
#!/bin/bash
ip=\$(type -p ip)
\$ip a | grep "inet " | grep -v  "127.0.0.1" | awk '{print "IP/Subnet is [ "\$2" ]  NIC is [ " \$NF" ]"}'
EOF
chmod +x /usr/local/bin/get-ip-address
# Debian/ubuntu
if [ $(grep -i ubuntu /proc/version | wc -l) -eq "1" ]
then
cat << EOF > /etc/network/if-up.d/show-ip-address
#!/bin/sh
if [ "\$METHOD" = loopback ]; then
    exit 0
fi

# Only run from ifup.
if [ "\$MODE" != start ]; then
    exit 0
fi

cp /etc/issue-standard /etc/issue
/usr/local/bin/get-ip-address >> /etc/issue
echo "" >> /etc/issue
EOF
chmod +x /etc/network/if-up.d/show-ip-address
fi

#redhat/centos
if [ $(grep -i "red hat" /proc/version | wc -l) -eq "1" ]
then
cat << EOF > /sbin/ifup-local
#!/bin/sh

if [ "\$1" = lo ]; then
    exit 0
fi

cp /etc/issue-standard /etc/issue
/usr/local/bin/get-ip-address >> /etc/issue
echo "" >> /etc/issue
EOF
chmod +x /sbin/ifup-local
fi
}


function delete () {

rm -rf /etc/issue-standard
rm -rf /usr/local/bin/get-ip-address
# Debian/ubuntu
if [ $(grep -i ubuntu /proc/version | wc -l) -eq "1" ]
then 
	rm -rf /etc/network/if-up.d/show-ip-address
fi
#redhat/centos
if [ $(grep -i "red hat" /proc/version | wc -l) -eq "1" ]
then
	rm -rf /sbin/ifup-local
fi
}

function usage () {
    echo "Usage: $(basename $0) [-d|-i]"
    echo "	-i : install ShowIP_PreLogin"
    echo " 	-d : delete ShowIP_PreLogin"
    echo ""
    echo ""
    exit $E_BADARGS
}

E_BADARGS=65
index=1

if [ ! -n "$1" ]
then
    usage
fi

for arg in "$@"
do
    let "index+=1"
done

if [ $index != 2 ]
then
    echo "using only one options [-d|-i]"
    usage
fi


case $1 in

-i)
    register
;;

-d)
    delete
;;

*)
    usage

;;

esac
