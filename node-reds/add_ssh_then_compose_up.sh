#!/bin/bash
# cd into this sh file directory
cd "$(dirname "$0")"

MODE_ARG=$@

# Make sure the SSH Agent is running
echo ""
echo "### SSH AGENT STEP ###"
if [ -v $SSH_AGENT_PID ]
then
    echo "Looking if SSH agent already started"
    export SSH_AGENT_PID=$(pgrep -u $USER -n ssh-agent)
fi

if [ -v $SSH_AUTH_SOCK -a -v $SSH_AGENT_PID ]
then
    echo "Starting SSH agent"
    eval $(ssh-agent) 
elif [ -v $SSH_AUTH_SOCK ]
then
    echo "SSH agent started in different shell. Adding socket..."
    export SSH_AUTH_SOCK=$(ls /tmp/ssh-*/agent.$(($SSH_AGENT_PID-1)))
fi

# Make sure the key to access the various node red projects is added on the host
echo ""
echo "### SSH KEY STEP ###"
ssh -T ${GIT_SSH_LINK:?Please export env vars} >> /dev/null 2>&1 #no prompt
COULD_CONNECT=$? # 255 if cannot connect
if [ "$COULD_CONNECT" -eq 255 ]
then
    echo "Please run 'ssh-add <yoursshkey>' using a key recognized by your remote host"
    echo "or add it in your '.ssh/config' file."
    echo "will now exit with error"
    exit 1
fi

echo ""
echo "### BUILD NODE-RED CONTAINERS ###"
echo "Build and starting container. Passed arguments are all passed to docker compose up"
docker compose up $MODE_ARG -d