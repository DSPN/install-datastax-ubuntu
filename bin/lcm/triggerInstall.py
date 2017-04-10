#!/usr/bin/python
import requests
import json
import time
import argparse
import os
import utilLCM as lcm

def setupArgs():
    parser = argparse.ArgumentParser(description='Setup LCM managed DSE cluster, repo, config, and ssh creds')
    required = parser.add_argument_group('Required named arguments')
    required.add_argument('--opsc-ip', required=True, type=str, help='public ip of OpsCenter instance')
    required.add_argument('--clustername', required=True, type=str, help='Name of cluster.')
    required.add_argument('--clustersize', type=int, default=0, help='Trigger install job when clustersize nodes have posted')
    parser.add_argument('--dbpasswd', type=str, default='cassandra', help='DB password.')
    return parser

def main():
    parser = setupArgs()
    args = parser.parse_args()
    lcm.opsc_url = args.opsc_ip+':8888'

    lcm.waitForOpsC(pause=6, trys=200)  # Block waiting for OpsC to spin up
    lcm.waitForCluster(cname=args.clustername, pause=6, trys=200) # Block until cluster created
    clusters = requests.get("http://{url}/api/v1/lcm/clusters/".format(url=lcm.opsc_url)).json()
    for r in clusters['results']:
        if r['name'] == args.clustername:
            cid = r['id']
    lcm.waitForNodes(numnodes=args.clustersize, pause=6, trys=400)
    lcm.triggerInstall(cid, None, args.dbpasswd)

# ----------------------------
if __name__ == "__main__":
    main()
