#!/usr/bin/python
import requests
import json
import time
import argparse
import os
import utilLCM as lcm

def setupArgs():
    parser = argparse.ArgumentParser(description='Alter all system keyspaces to use NetworkTopologyStrategy and RF 3.')
    parser.add_argument('--opsc-ip', type=str, default='127.0.0.1', help='Opscenter IP (or FQDN).')
    return parser

def main():
    parser = setupArgs()
    args = parser.parse_args()
    lcm.opsc_url = args.opsc_ip+':8888'
    # check for OpsC, fewer tries since it should be up
    lcm.waitForOpsC(pause=6, trys=10)

    # get cluster id, assume 1 cluster
    opsc_url=lcm.opsc_url
    clusterconf = requests.get("http://{url}/cluster-configs".format(url=opsc_url)).json()
    cid = clusterconf.keys()[0]
    # get all node configs
    nodes = requests.get("http://{url}/{id}/nodes".format(url=opsc_url,id=cid)).json()
    # loop of configs, counting nodes in each dc
    datacenters = {}
    for n in nodes:
        if n['dc'] in datacenters:
            datacenters[n['dc']] += 1
        else:
            datacenters[n['dc']] = 1
    # reuse dict for post data in REST call
    # min(3,#) handles edge case where # of nodes < 3
    for d in datacenters:
        datacenters[d] = min(3, datacenters[d])
    # keyspaces to alter
    # leaving out LocalStrategy (system & system_schema) and EverywhereStrategy (dse_system & solr_admin)
    keyspaces = ["system_auth","system_distributed","system_traces","dse_security","dse_perf","dse_leases","cfs_archive","spark_system","cfs","dsefs","OpsCenter","HiveMetaStore"]
    postdata = {"strategy_class": "NetworkTopologyStrategy", "strategy_options": datacenters, "durable_writes": True}
    rawjson = json.dumps(postdata)
    # loop over keyspaces
    print "Looping over keyspaces: {k}".format(k=keyspaces)
    print "NOTE: No response indicates sucess"
    for ks in keyspaces:
        print "Calling: PUT http://{url}/{id}/keyspaces/{ks} with {d}".format(url=opsc_url,id=cid,ks=ks,d=rawjson)
        response = requests.put("http://{url}/{id}/keyspaces/{ks}".format(url=opsc_url,id=cid,ks=ks),data=rawjson).json()
        print "Response: "
        lcm.pretty(response)

# ----------------------------
if __name__ == "__main__":
    main()
