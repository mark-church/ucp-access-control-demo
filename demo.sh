#!/bin/bash

set -e

UCP=52.25.60.65
USER=admin
PASS=docker123

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)



################################ demo ##############################
function basic-demo-setup () {
  #review https://gist.github.com/mbentley/f289435e065650253b608467251eef49

  echo -n "Creating Orgs and Teams"
  token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1

  curl -sk -X POST https://${UCP}/accounts/ -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"orcabank\",\"isOrg\":true}" > /dev/null 2>&1

  ops_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"ops\",\"description\":\"ops team of awesomeness\"}" | jq -r .id)

  mobile_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"mobile\",\"description\":\"dev team of awesomeness\"}" | jq -r .id)

  payments_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"payments\",\"description\":\"dev team of awesomeness\"}" | jq -r .id)

  security_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"security\",\"description\":\"security team of awesomeness\"}" | jq -r .id)

  echo "$GREEN" "[ok]" "$NORMAL"

  echo -n "Inputing Users"
  token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"bob\",\"password\":\"Pa22word\",\"first_name\":\"bob developer\"}"

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"tim\",\"password\":\"Pa22word\",\"first_name\":\"tim ops\"}"

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"jeff\",\"password\":\"Pa22word\",\"first_name\":\"jeff security\"}"

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"andy\",\"password\":\"Pa22word\",\"first_name\":\"andy $USER\"}"
  echo "$GREEN" "[ok]" "$NORMAL"

  echo -n "Adding Users to Teams"
  token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
  curl -skX PUT "https://${UCP}/accounts/orcabank/teams/ops/members/tim" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1

  curl -skX PUT "https://${UCP}/accounts/orcabank/teams/security/members/jeff" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1

  curl -skX PUT "https://${UCP}/accounts/orcabank/teams/mobile/members/bob" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1

  curl -skX PUT "https://${UCP}/accounts/orcabank/teams/payments/members/bob" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1
  echo "$GREEN" "[ok]" "$NORMAL"

  echo -n "Adding 'developer' role"
  token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
  dev_role_id=$(curl -skX POST "https://${UCP}/roles" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"developer\",\"system_role\": false,\"operations\": {\"Container\":{\"Container Attach\": [],\"Container Exec\": [],\"Container Logs\": [],\"Container View\": []},\"Service\": {\"Service Logs\": [],\"Service View\": [],\"Service View Tasks\":[]}}}" | jq -r .id)
  echo "$GREEN" "[ok]" "$NORMAL"

  echo -n "Creating collections"
  token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1

  prod_col_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"prod\",\"path\":\"/\",\"parent_id\": \"swarm\"}" | jq -r .id)

  mobile_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"mobile\",\"path\":\"/prod\",\"parent_id\": \"$prod_col_id\"}" | jq -r .id)

  payments_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"payments\",\"path\":\"/prod\",\"parent_id\": \"$prod_col_id\"}" | jq -r .id)

  shared_mobile_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"mobile\",\"path\":\"/\",\"parent_id\": \"shared\"}" | jq -r .id)

  shared_payments_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"payments\",\"path\":\"/\",\"parent_id\": \"shared\"}" | jq -r .id)

  #write id to a tmp file
  echo $shared_payments_id > col_tmp.txt
  echo $shared_mobile_id >> col_tmp.txt
  echo $payments_id >> col_tmp.txt
  echo $mobile_id >> col_tmp.txt
  echo $prod_col_id >> col_tmp.txt

  echo "$GREEN" "[ok]" "$NORMAL"
}



################################ demo wipe ##############################
function wipe () {
  #clean the demo stuff

  if [ -f col_tmp.txt ]; then

    token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1

    echo -n " removing secrets"
    for secret_id in $(curl -skX GET "https://${UCP}/secrets" -H  "accept: application/json" -H  "Authorization: Bearer $token"| jq -r .[].ID); do
       curl -skX DELETE "https://${UCP}/secrets/$secret_id" -H  "accept: application/json" -H  "Authorization: Bearer $token"
    done
    echo "$GREEN" "[ok]" "$NORMAL"

    echo -n " removing grants"
    echo "$GREEN" "[ok]" "$NORMAL"

    echo -n " removing users and organizations"
    for user in $(curl -skX GET "https://${UCP}/accounts/?filter=all&limit=100" -H  "accept: application/json" -H  "Authorization: Bearer $token"| jq -r .accounts[].name|grep -v $USER|grep -v docker-datacenter); do
      curl -skX DELETE "https://${UCP}/accounts/$user" -H  "accept: application/json" -H  "Authorization: Bearer $token"
    done
    echo "$GREEN" "[ok]" "$NORMAL"

    echo -n " removing collections"
    for cols in $(cat col_tmp.txt); do
       curl -skX DELETE "https://${UCP}/collections/$cols" -H  "accept: application/json" -H  "Authorization: Bearer $token"
    done
    rm -rf col_tmp.txt
    echo "$GREEN" "[ok]" "$NORMAL"

    echo -n " removing roles"
    for role in $(curl -skX GET "https://${UCP}/roles" -H  "accept: application/json" -H  "Authorization: Bearer $token"| jq -r .[].id | grep -v -E '(fullcontrol|scheduler|none|viewonly|restrictedcontrol)'); do
      curl -skX DELETE "https://${UCP}/roles/$role" -H  "accept: application/json" -H  "Authorization: Bearer $token"
    done
    echo "$GREEN" "[ok]" "$NORMAL"
  else
    echo -n " looks like nothing to remove"
    echo "$GREEN" "[ok]" "$NORMAL"
  fi
}

basic-demo-setup
wipe