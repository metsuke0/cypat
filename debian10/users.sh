#!/bin/bash
FILE=$1

AUTH_USERS=$(sed -n '/Authorized Users:/,$p' ${FILE} | sed '/Competition Guidelines/q' | tail +2 | head -n -1)
AUTH_ADMINS=$(sed -n '/Authorized Administrators:/,$p' ${FILE} | sed '/Authorized Users:/q' | tail +2 | head -n -1 | grep -E "^[a-z]")
ALL_USERS=(${AUTH_USERS[@]} ${AUTH_ADMINS[@]})
CURRENT_USERS=$(grep -E "[0-9]{4,5}:[0-9]{4,5}" /etc/passwd | grep -v nobody)

# Delete unauthorized users

for LINE in ${CURRENT_USERS}; do
  USER=$(echo ${LINE} | sed 's/:.*//' | sed 's/ (you)//')
  if [[ ${ALL_USERS[@]} =~ ${USER} ]]; then
    echo "${USER} authorized"
    for i in "${!ALL_USERS[@]}"; do
      if [[ ${ALL_USERS[i]} == ${USER} ]]; then
        unset ALL_USERS[i]
      fi
    done
  else
    echo "${USER} UNAUTHORIZED"
    /usr/sbin/deluser --remove-home ${USER}
  fi
done

# Set passwords on admins

