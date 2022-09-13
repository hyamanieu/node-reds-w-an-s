#!/bin/bash
# cd into this sh file directory
cd "$(dirname "$0")"

CONTAINERID=$1
PROJECTNAME=$2


! test -z "$CONTAINERID"; TESTCONTAINERID=$?
! test -z "$PROJECTNAME"; TESTPROJECTNAME=$?

#if both are missing, then loop every node-red container
if (test -z "$CONTAINERID" ) && (test -z "$PROJECTNAME" )
then
    for CONTAINERID in $(docker ps -q -f "label=com.docker.compose.project=node-reds")
    do
        CONTAINERNAME=$(docker ps --filter Id=$CONTAINERID --format "{{.Names}}")
        PROJECTNAME=$CONTAINERNAME
        echo "Processing $PROJECTNAME secret..."
        ./add_secrets.sh $CONTAINERID $PROJECTNAME
    done
#if one of them are missing, then prompt help
elif [ $TESTCONTAINERID -ne $TESTPROJECTNAME ]
then
    echo "Usage: $0 [CONTAINERID PROJECTNAME]"
    echo "  CONTAINERID should be the ID of the docker container"
    echo "    running the nodered application"
    echo "  PROJECTNAME should be the exact name of the project"
    echo "If both parameters are missing, it will run it for"
    echo "each container within the docker compose 'node-reds' project."
#if both parameters are present, check the project secret is correctly copied.
else
    PROJECTSECRET=$(docker exec -it $CONTAINERID cat /data/.config.projects.json | jsonpointer /projects/$PROJECTNAME/credentialSecret /dev/stdin)
    echo ""
    if [ -z "$PROJECTSECRET" ]
    then
        echo "  Credential secret for project $PROJECTNAME is missing."
        echo "  Secret for project $PROJECTNAME (no prompt): "
        read -s PROJECTSECRET
        export PROJECTSECRET PROJECTNAME
        tmpfile=$(mktemp)
        cat ./.config.projects.template.json | envsubst > $tmpfile
        docker cp $tmpfile $CONTAINERID:/data/.config.projects.json
        docker restart $CONTAINERID
    else
        echo "  Secret already present"
    fi
fi
