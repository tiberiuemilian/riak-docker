#!/bin/bash

# Add standard config items
cat <<END >>$RIAK_CONF
nodename = riak@$HOST
distributed_cookie = $CLUSTER_NAME
listener.protobuf.internal = 0.0.0.0:$PB_PORT
listener.http.internal = 0.0.0.0:$HTTP_PORT
riak_control = on
END

# Maybe add user config items
if [ -s $USER_CONF ]; then
  cat $USER_CONF >>$RIAK_CONF
fi