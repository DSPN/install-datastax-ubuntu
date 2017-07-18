#!/usr/bin/python
import requests
import json
import time
import argparse
import os
import utilLCM as lcm

def setupArgs():
    parser = argparse.ArgumentParser(description='Trigger LCM install job after last node posts.')
    required = parser.add_argument_group('Required named arguments')
    required.add_argument('--opsc-ip', required=True, type=str, help='public ip of OpsCenter instance')
    required.add_argument('--clustername', required=True, type=str, help='Name of cluster.')
    required.add_argument('--clustersize', type=int, default=0, help='Trigger install job when clustersize nodes have posted')
    parser.add_argument('--dbpasswd', type=str, default='cassandra', help='DB password.')
    parser.add_argument('--dclevel', action='store_true', help='Trigger DC level install job(s).' )
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
    if args.dclevel:
        datacenters = requests.get("http://{url}/api/v1/lcm/datacenters/".format(url=lcm.opsc_url)).json()
        pw = args.dbpasswd
        for r in datacenters['results']:
            dcid = r['id']
            print("Triggering install for DC, id = {i}".format(i=dcid))
            lcm.triggerInstall(None, dcid, pw)
            #set pw to default -> no-op when triggering the next install job
            pw = "cassandra"
    else:
        print("Triggering install for cluster, id = {i}".format(i=cid))
        lcm.triggerInstall(cid, None, args.dbpasswd)

# ----------------------------
if __name__ == "__main__":
    main()
