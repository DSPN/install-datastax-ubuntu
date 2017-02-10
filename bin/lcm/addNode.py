#!/usr/bin/python
import requests
import json
import time
import argparse
import utilLCM as lcm

# TODO!
# - addThing methods should return id value, or None with failure


def setupArgs():
    parser = argparse.ArgumentParser(description='Add calling instance to an LCM managed DSE cluster.')
    required = parser.add_argument_group('Required named arguments')
    required.add_argument('--opsc-ip', required=True, type=str,
                          help='Public ip of OpsCenter instance.')
    required.add_argument('--clustername', required=True, type=str,
                          help='Name of cluster.')
    required.add_argument('--dcname', required=True, type=str, help='Name of datacenter.')
    required.add_argument('--nodeid', required=True, type=str, help='Unique node id.')
    required.add_argument('--privip', required=True, type=str, help='Private ip of node.')
    required.add_argument('--pubip', required=True, type=str, help='Public ip of node.')
    required.add_argument('--dcsize', required=True, type=int, help='Number of nodes in datacenter, triggers DC level install job.')
    parser.add_argument('--clustersize', type=int, default=0, help='Number of nodes in cluster, non-zero OVERRIDES --dcsize, triggers cluster level install job')
    parser.add_argument('--dbpasswd', type=str, default='cassandra', help='DB password.')
    parser.add_argument('--pause',type=int, default=6, help="pause time (sec) between attempts to contact OpsCenter, default 6")
    parser.add_argument('--trys',type=int, default=100, help="number of times to attempt to contact OpsCenter, default 100")
    parser.add_argument('--verbose',
                        action='store_true',
                        help='Verbose flag, right now a NO-OP.' )
    return parser

def main():
    parser = setupArgs()
    args = parser.parse_args()
    pause = args.pause
    trys = args.trys
    clustername = args.clustername
    lcm.opsc_url = args.opsc_ip+':8888'
    dcname = args.dcname
    password = args.dbpasswd
    dcsize = args.dcsize
    clustersize = args.clustersize
    nodeid = args.nodeid
    privateip = args.privip
    publicip = args.pubip

    lcm.waitForOpsC(pause=pause,trys=trys)  # Block waiting for OpsC to spin up
    lcm.waitForCluster(clustername, pause, trys) # Block until cluster created

    clusters = requests.get("http://{url}/api/v1/lcm/clusters/".format(url=lcm.opsc_url)).json()
    cid = clusters['results'][0]['id']

    # Check if the DC --this-- node should belong to exists, if not add DC
    c = lcm.checkForDC(dcname)
    if (c == False):
        print("Datacenter {n} doesn't exist, creating...".format(n=dcname))
        lcm.addDC(dcname,cid)
    else:
        print("Datacenter {d} exists".format(d=dcname))

    # kludge, assuming ony one cluster
    dcid = ""
    datacenters = requests.get("http://{url}/api/v1/lcm/datacenters/".format(url=lcm.opsc_url)).json()
    for d in datacenters['results']:
        if (d['name'] == dcname):
            dcid = d['id']

    # always add self to DC
    nodes = requests.get("http://{url}/api/v1/lcm/datacenters/{dcid}/nodes/".format(url=lcm.opsc_url,dcid=dcid)).json()
    nodecount = nodes['count']
    # simple counting for node number hits a race condition... work around
    #nodename = 'node'+str(nodecount)
    # aws metadata service instance-id
    #inst = requests.get("http://169.254.169.254/latest/meta-data/instance-id").content
    nodename = 'node-'+nodeid
    nodeconf = json.dumps({
            'name': nodename,
            "datacenter-id": dcid,
            "ssh-management-address": publicip,
            "listen-address": privateip,
            "rpc-address": privateip,
            "broadcast-address": publicip,
            "broadcast-rpc-address": publicip})
    node = requests.post("http://{url}/api/v1/lcm/nodes/".format(url=lcm.opsc_url),data=nodeconf).json()
    print("Added node '{n}', json:".format(n=nodename))
    lcm.pretty(node)

    nodes = requests.get("http://{url}/api/v1/lcm/datacenters/{dcid}/nodes/".format(url=lcm.opsc_url,dcid=dcid)).json()
    nodecount = nodes['count']

    # vvv could get pulled out
    totalnodes = 0
    for d in datacenters['results']:
        nodes = requests.get("http://{url}/api/v1/lcm/datacenters/{dcid}/nodes/".format(url=lcm.opsc_url,dcid=d['id'])).json()
        totalnodes += nodes['count']

    if(clustersize != 0 and totalnodes == clustersize):
        print("Last node added, triggering cluster install job...")
        lcm.triggerInstall(cid, None, password)
        return
    elif (clustersize == 0 and nodecount == dcsize):
        print("Last node added, triggering install job...")
        lcm.triggerInstall(None, dcid, password)

# ----------------------------
if __name__ == "__main__":
    main()
