#!/bin/bash

# Script to re-load corosync configuration on a crowbar managed pacemaker
# cluster.
# This script can be used when you switch from single corosync ring to
# dual corosync ring.
# After you applied the modified proposal successfully, run this script on
# crowbar
# Please stop all chef-client runs while running this script.
set -eux

CLUSTER_PROPOSAL_NAME="$1"

# Make sure that the proposal exists by asking for it's details
# if this command fails, the script exits
crowbarctl proposal show pacemaker "$CLUSTER_PROPOSAL_NAME"

NODES=$(crowbarctl \
    proposal show pacemaker "$CLUSTER_PROPOSAL_NAME" \
    --format=plain \
    --filter "deployment.pacemaker.elements.pacemaker-cluster-member" |
     cut -d " " -f 2)

# Get the first node - it will be used to issue crm commands
for node in $NODES; do
    FIRST_NODE="$node"
    break
done

# Print out initial configuration
ssh "$FIRST_NODE" corosync-cfgtool -s

# Put the cluster in maintenance mode
ssh "$FIRST_NODE" crm --wait configure property maintenance-mode=true

# Restart corosync on all nodes
for node in $NODES; do
    ssh "$node" systemctl restart corosync
done

# Give some time for corosync to stand up
sleep 30

# Exit from maintenance mode
ssh "$FIRST_NODE" crm --wait configure property maintenance-mode=false

# Print out new configuration
ssh "$FIRST_NODE" corosync-cfgtool -s
