#!/bin/bash

# Get the name of the first pod. Adjust as necessary to target a specific pod.
POD_NAME=$(kubectl get pods -o=jsonpath='{.items[0].metadata.name}')

# Check if /tmp/hacked exists in the pod. If it does, remove it and then touch it. If it doesn't exist, just touch it.
kubectl exec $POD_NAME -- /bin/sh -c '[ -f /tmp/hacked ] && rm /tmp/hacked; touch /tmp/hacked'