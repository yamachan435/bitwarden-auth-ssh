#!/bin/bash

if [ -z ${BW_SESSION} ]; then
  SESS_ARG="--session $(bw unlock --raw)"
fi

bash -c "\
  eval \$( \
    bw list items --search bookers ${SESS_ARG} |\
    jq -r .[0].attachments[0].fileName,.[0].id,.[0].login.username,.[0].login.uris[0].uri |\
    paste -s |\
    awk '{print \"\
      eval \$(ssh-agent) &&\
      bw get attachment --raw ${SESS_ARG} \" \$1 \" --itemid \" \$2 \" |\
      ssh-add -q -t 1 - &&\
      ssh -l \" \$3 \" \" \$4 \
    }' \
  ); \
  eval \$(ssh-agent -k) \
"
