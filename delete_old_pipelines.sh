#!/bin/bash
set -e

TOKEN="__SET_YOUR_ACCESS_TOKEN__"
# Visible under name of project page.
PROJECT_ID="__SET_PROJECT_ID__"
# Set your gitlab instance url.
GITLAB_INSTANCE="https://gitlab.com/api/v4/projects"
# How many to delete from the oldest, 100 is the maximum, above will just remove 100.
PER_PAGE=100

# jq need to be installed
for PIPELINE in $(curl --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_INSTANCE/$PROJECT_ID/pipelines?per_page=$PER_PAGE&sort=asc" | jq '.[].id') ; do
    echo "Deleting pipeline $PIPELINE"
    curl --header "PRIVATE-TOKEN: $TOKEN" --request "DELETE" "$GITLAB_INSTANCE/$PROJECT_ID/pipelines/$PIPELINE"
done

# Another useful script below for several projects
'''
#!/bin/bash
set -e

TOKEN=""
# How many to delete from the oldest.
PER_PAGE=100
UPDATED_BEFORE=2021-02-01T00:00:00Z
GITLAB_URL=


while : ; do
  COUNTER=0

  for PROJECT in $(curl -s --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/projects?per_page=$PER_PAGE" | jq '.[].id') ; do
    echo "Deleting in project $PROJECT"
    for PIPELINE in $(curl -s --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT/pipelines?per_page=$PER_PAGE&sort=asc&updated_before=$UPDATED_BEFORE" | jq '.[].id') ; do
        echo "Deleting pipeline $PIPELINE"
        curl --header "PRIVATE-TOKEN: $TOKEN" --request "DELETE" "$GITLAB_URL/api/v4/projects/$PROJECT/pipelines/$PIPELINE"
        (( COUNTER++ )) || true
    done
  done

  echo $COUNTER

  if [[ "$COUNTER" -le 0 ]]; then
    break;
  fi
done
'''
