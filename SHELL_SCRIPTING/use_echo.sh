#!/bin/bash
echo -e "birinci satir \nikinci satir \nson satir"
echo ====================================
echo -e "ikinci satir olmayacak \c"
echo -e "son satir"
# bu bir yorum satiridir ciktiya etkisi yok
: <<'COMMENT'
echo bu araa 
echo yazilanlari
echo okumaz
echo multiline comment
COMMENT
