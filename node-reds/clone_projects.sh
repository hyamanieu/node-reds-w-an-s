#!/bin/bash
# cd into this sh file directory
cd "$(dirname "$0")"

# Verifies that the project is correctly cloned. If not, clone it
for CONTAINERID in $(docker ps -q -f "label=com.docker.compose.project=node-reds")
do
    #IMPORTANT: a container name must be exactly the same as a project name
    CONTAINERNAME=$(docker ps --filter Id=$CONTAINERID --format "{{.Names}}")
    PROJECTNAME=$CONTAINERNAME
    echo "# Starting project $PROJECTNAME..."
    if docker exec -it $CONTAINERID git -C /data/projects/$PROJECTNAME status >> /dev/null
    then
        echo "  $PROJECTNAME already cloned"
    else
        echo "  cloning $PROJECTNAME..."
        PROJECTURL=$(docker ps --filter Id=$CONTAINERID --format '{{.Label "node-red.project.url"}}')
        if [ "$GH_TOKEN" ]
        then
            echo "  Connecting to github..."
            gh auth login -p ssh > /dev/null
            echo "  Creating repository if it does not exist..."
            if gh repo create ${GIT_ORGANIZATION:?require organization}/$PROJECTNAME --private
            then
                echo "  New repository created for $PROJECTNAME"
            fi
        fi
        #Clone repo
        docker exec -it $CONTAINERID git clone $PROJECTURL /data/projects/$PROJECTNAME
    fi
done
