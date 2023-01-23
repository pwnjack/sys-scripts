#!/bin/bash

usage() { echo "Usage: $0 [-c <certificate.csr>]" 1>&2; exit 1; }

while getopts ":c:" o; do
    case "${o}" in
        c)
            c=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${c}" ]; then
    usage
fi

altNames=($(openssl req -noout -text -in ${c} | grep -oP '(?<=DNS:|IP Address:)[^,]+'|sort -uV))

IFS=$'\n'

count=0
getSan () {
        for i in ${altNames[@]}; do
                let "count++"
                echo "DNS.$count = $i"
        done
}

sanNames=$(getSan)

sed -i '/\[alt_names\]/q' server_cert.cnf
printf "%s\n" ${sanNames[@]} >> server_cert.cnf

cat server_cert.cnf | grep "DNS"

fileName=$(echo ${c} | sed 's/\.[^.]*$//')

openssl x509 -req -in ${c} -CA rootCA/rootCA.crt -CAkey rootCA/rootCA.key -CAserial rootCA/rootCA.srl -days 730 -sha256 -out $fileName.crt -extensions req_ext -extfile server_cert.cnf

#openssl x509 -text -noout -in $fileName.crt | grep "DNS"

read -p "Want to see the signed certificate (.crt) content? (y/n)" choicesee
case "$choicesee" in
  y|Y ) echo "yes" && openssl x509 -text -noout -in $fileName.crt;;
  n|N ) echo "no";;
  * ) echo "invalid";;
esac

read -p "Looking good? Want to copy the signed certificate in /tmp folder? (y/n)?" choicecopy
case "$choicecopy" in
  y|Y ) echo "yes" && cp $fileName.crt /tmp/;;
  n|N ) echo "no";;
  * ) echo "invalid";;
esac

echo "DONE"