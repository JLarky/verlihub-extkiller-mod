#!/bin/bash

wget http://spb.edu/campus/networks.txt -O /tmp/networks.txt

echo "DELETE from localnets where residence != 777" | mysql vtc
sed s/campus// /tmp/networks.txt | sed 's/\//\t/' | grep -v "#"| 
while read base mask desc
do
if [[ -z $base ]]; then continue; fi # пропускаем пустые строчки
i1=$(echo $base | cut -d "." -f 1)
i2=$(echo $base | cut -d "." -f 2)
i3=$(echo $base | cut -d "." -f 3)
i4=$(echo $base | cut -d "." -f 4)
let 'fip=i4+256*(i3+256*(i2+256*i1))'
let 'range=2<<(31-mask)'
let 'lip=fip+range'
echo $base/$mask $desc - $fip $lip $range

echo "INSERT INTO localnets (base, mask, start, end, residence) VALUES('$base', '$mask', '$fip', '$lip', '$desc')" | mysql vtc
done
