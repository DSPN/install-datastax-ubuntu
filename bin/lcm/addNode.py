#!/usr/bin/python
import json
import argparse
import requests
import utilLCM as lcm

# fixme
# - addThing methods should return id value, or None with failure


def setupArgs():
    parser = argparse.ArgumentParser(description='Add calling instance to an LCM managed DSE cluster.')
    required = parser.add_argument_group('Required named arguments')
    required.add_argument('--opsc-ip', required=True, type=str,
                          help='Public ip of OpsCenter instance.')
    required.add_argument('--clustername', required=True, type=str,
                          help='Name of cluster.')
    required.add_argument('--dcname', required=True, type=str, help='Datacenter node belongs to.')
    required.add_argument('--nodeid', required=True, type=str, help='Unique node id.')
    required.add_argument('--privip', required=True, type=str, help='Private ip of node.')
    required.add_argument('--pubip', required=True, type=str, help='Public ip of node.')
    parser.add_argument('--rack', type=str, default='rack0', help='Rack node belongs to.')
    parser.add_argument('--pause', type=int, default=6,
                        help="pause time (sec) between attempts to contact OpsCenter, default 6")
    parser.add_argument('--trys', type=int, default=100,
                        help="number of times to attempt to contact OpsCenter, default 100")
    parser.add_argument('--verbose', action='store_true', help='Verbose flag, right now a NO-OP.')
    return parser

def main():
    parser = setupArgs()
    args = parser.parse_args()
    pause = args.pause
    trys = args.trys
    clustername = args.clustername
    lcm.opsc_url = args.opsc_ip+':8888'
    dcname = args.dcname
    rack = args.rack
    nodeid = args.nodeid
    privateip = args.privip
    publicip = args.pubip

    lcm.waitForOpsC(pause=pause, trys=trys)  # Block waiting for OpsC to spin up
    lcm.waitForCluster(clustername, pause, trys) # Block until cluster created

    clusters = requests.get("http://{url}/api/v1/lcm/clusters/".format(url=lcm.opsc_url)).json()
    for r in clusters['results']:
        if r['name'] == clustername:
            cid = r['id']

    # Check if the DC --this-- node should belong to exists, if not add DC
    if lcm.checkForDC(dcname):
        print "Datacenter {d} exists".format(d=dcname)
    else:
        print "Datacenter {n} doesn't exist, creating...".format(n=dcname)
        lcm.addDC(dcname, cid)

    # kludge, assuming ony one cluster
    dcid = ""
    datacenters = requests.get("http://{url}/api/v1/lcm/datacenters/".format(url=lcm.opsc_url)).json()
    for d in datacenters['results']:
        if d['name'] == dcname:
            dcid = d['id']

    # always add self to DC
    nodes = requests.get("http://{url}/api/v1/lcm/datacenters/{dcid}/nodes/".format(url=lcm.opsc_url, dcid=dcid)).json()
    nodecount = nodes['count']
    # simple counting for node number hits a race condition... work around
    #nodename = 'node'+str(nodecount)
    # aws metadata service instance-id
    #inst = requests.get("http://169.254.169.254/latest/meta-data/instance-id").content
    nodename = 'node-'+nodeid
    nodeconf = json.dumps({
        'name': nodename,
        "datacenter-id": dcid,
        "rack": rack,
        "ssh-management-address": publicip,
        "listen-address": privateip,
        "rpc-address": "0.0.0.0",
        "broadcast-address": publicip,
        "broadcast-rpc-address": publicip})
    node = requests.post("http://{url}/api/v1/lcm/nodes/".format(url=lcm.opsc_url), data=nodeconf).json()
    print "Added node '{n}', json:".format(n=nodename)
    lcm.pretty(node)

    nodes = requests.get("http://{url}/api/v1/lcm/datacenters/{dcid}/nodes/".format(url=lcm.opsc_url, dcid=dcid)).json()
    nodecount = nodes['count']
    print "{n} nodes in datacenter {d}".format(n=nodecount, d=dcid)
    print "Exiting addNode..."

# ----------------------------
if __name__ == "__main__":
    main()
