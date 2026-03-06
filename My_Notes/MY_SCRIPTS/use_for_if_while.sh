#!/bin/bash
# Aothor: Enver Önder USLU
# Date: 21.06.2025
# Description: This script demonstrates use of for loop in bash.
--------------------------------------
for i in {1..5}
do
  echo "Number: $i"
done
-----------------------------------------
echo "Enter a number greatef then 10:"
read number

if [ $number -gt 10 ]; then
    echo "The number is greater than 10. Aferin"
else
    echo "Beyinsiz. The number is not greater then 10."
fi
-----------------------------------------------
echo "Geben Sie eine Zahl ein"
read nummer

echo "hacked in $nummer seconds"

count=1

while [ $count -le $nummer ]
do
  echo " $count"
  sleep 1
  ((count++))
done

echo "Möchtest du fortfahren? (ja/nein)"
read antwort

case "$antwort" in
  ja | JA | Ja)
    echo "Fortfahren..."
    ;;
  nein | NEIN | Nein)
    echo "Abbruch."
    ;;
  *)
    echo "Ungültige Eingabe."
    ;;
esac
#reboot