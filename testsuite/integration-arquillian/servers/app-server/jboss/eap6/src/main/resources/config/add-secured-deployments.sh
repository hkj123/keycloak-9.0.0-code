#!/bin/bash
echo "JBOSS_HOME=$JBOSS_HOME"

if [ ! -d "$JBOSS_HOME/bin" ] ; then
    >&2 echo "JBOSS_HOME/bin doesn't exist"
    exit 1
fi

cd $JBOSS_HOME/bin

./standalone.sh -Djboss.server.config.dir=$JBOSS_HOME/standalone-secured-deployments/configuration &
sleep 3

TIMEOUT=10
DELAY=1
T=0

RESULT=0

until [ $T -gt $TIMEOUT ]
do
    if ./jboss-cli.sh -c --command=":read-attribute(name=server-state)" | grep -q "running" ; then
        echo "Server is running. Adding secured deployments"

        ./jboss-cli.sh -c --file="$CLI_PATH/add-secured-deployments.cli"
        RESULT=$?
        echo "Return code:"${RESULT}

        ./jboss-cli.sh -c --command=":shutdown"
        rm -rf $JBOSS_HOME/standalone/data
        rm -rf $JBOSS_HOME/standalone/log

        echo "Exiting with return code: "$RESULT
        exit $RESULT
    fi
    echo "Server is not running."
    sleep $DELAY
    let T=$T+$DELAY
done

exit 1
