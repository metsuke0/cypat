#!/bin/bash
FILE=$1

AUTH_USERS=($(sed -n '/Authorized Users:/,$p' ${FILE} | sed '/Competition Guidelines/q' | tail +2 | head -n -1))
AUTH_ADMINS=($(sed -n '/Authorized Administrators:/,$p' ${FILE} | sed '/Authorized Users:/q' | tail +2 | head -n -1 | grep -E "^[a-z]"))
# Remove "(you)" from the array
unset AUTH_ADMINS[$(echo ${AUTH_ADMINS[@]/(you)//} | cut -d / -f1 | wc -w | tr -d ' ')]
# Reinitialize array due to empty 1 index
AUTH_ADMINS=(${AUTH_ADMINS[@]})
AUTH_ADMINS_PASSWORDS=($(sed -n '/Authorized Administrators:/,$p' ${FILE} | sed '/Authorized Users:/q' | tail +2 | head -n -1 | grep -v -E "^[a-z]" | sed 's/password: //'))
# Create a new array from two other arrays
ALL_USERS=(${AUTH_USERS[@]} ${AUTH_ADMINS[@]})
CURRENT_USERS=$(grep -E "[0-9]{4,5}:[0-9]{4,5}" /etc/passwd | grep -v nobody)

# Delete unauthorized users

for LINE in ${CURRENT_USERS}; do
  USER=$(echo ${LINE} | sed 's/:.*//')
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

for i in "${!AUTH_ADMINS[@]}"; do
  if echo ${AUTH_ADMINS[i]} | grep --quiet 'dartmonkey'; then
    continue
  fi
  echo -e "${AUTH_ADMINS_PASSWORDS[i]}\n${AUTH_ADMINS_PASSWORDS[i]}" | passwd "${AUTH_ADMINS[i]}"
done

# Set admin group

sudo:x:27:ninjamonkey,gluegunner,dartlinggunner,dartmonkey

