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
    required.add_argument('--opsc-ip', required=True, type=str,
                          help='IP of OpsCenter instance')
    required.add_argument('--clustername', required=True, type=str,
                          help='Name of cluster.')
    required.add_argument('--username', required=True, type=str,
                          help='username LCM uses when ssh-ing to nodes for install/config')
    required.add_argument('--repouser', required=True, type=str, help='username for DSE repo')
    required.add_argument('--repopw', required=True, type=str, help='pw for repouser')
    parser.add_argument('--privkey', type=str,
                          help='abs path to private key (public key on all nodes) to be used by OpsCenter')
    parser.add_argument('--password', type=str,
                          help='password for username LCM uses when ssh-ing to nodes for install/config. IGNORED if privkey non-null.')
    parser.add_argument('--becomepw', action='store_true',
                          help='use arg --password when sudo prompts for pw on nodes. IGNORED if privkey non-null.')
    parser.add_argument('--dsever', type=str, default = "5.1.5", help='DSE version for LCM config profile')
    parser.add_argument('--datapath', type=str, default = "",
                          help='path to root data directory containing data/commitlog/saved_caches (eg /data/cassandra)')
    parser.add_argument('--config', type=str, help='JSON for config profile. Will OVERRIDE all other config profile settings but not --dsever')
    parser.add_argument('--pause',type=int, default=6, help="pause time (sec) between attempts to contact OpsCenter, default 6")
    parser.add_argument('--trys',type=int, default=100, help="number of times to attempt to contact OpsCenter, default 100")
    parser.add_argument('--verbose',
                        action='store_true',
                        help='verbose flag, right now a NO-OP' )
    return parser

def main():
    parser = setupArgs()
    args = parser.parse_args()
    clustername = args.clustername
    lcm.opsc_url = args.opsc_ip+':8888'
    pause = args.pause
    trys = args.trys
    user = args.username
    password = args.password
    privkey = args.privkey
    datapath = args.datapath
    dsever = args.dsever
    repouser = args.repouser
    repopw = args.repopw

    if (password == None and privkey == None):
        parser.print_usage()
        print "setupCluster.py: error: argument --password OR --privkey is required"
        exit(1)
    if(args.config != None):
        try:
            json.loads(args.config)
        except ValueError:
            print("setupCluster.py: error: argument --config not valid json")
            exit(1)

# Yay globals!
# These should move to a config file, passed as arg maybe ?
    dserepo = json.dumps({
        "name":"DSE repo",
        "username":repouser,
        "password":repopw})

    if (privkey != None):
      keypath = os.path.abspath(args.privkey)
      with open(keypath, 'r') as keyfile:
          privkey=keyfile.read()
      print "Will create cluster {c} at {u} with keypath {k}".format(c=clustername, u=lcm.opsc_url, k=keypath)
      dsecred = {"become-mode":"sudo",
          "use-ssh-keys":True,
          "name":"DSE creds",
          "login-user":user,
          "ssh-private-key":privkey,
          "become-user":None}
    else:
        print "Will create cluster {c} at {u} with password".format(c=clustername, u=lcm.opsc_url)
        dsecred = {"become-mode":"sudo",
            "use-ssh-keys":False,
            "name":"DSE creds",
            "login-user":user,
            "login-password":password,
            "become-user":None}
    if (args.becomepw):
        dsecred['become-password'] = password
    dsecred = json.dumps(dsecred)

    defaultconfig = {
        "name":"Default config",
        "datastax-version": dsever,
        "json": {
           'cassandra-yaml': {
              "authenticator":"com.datastax.bdp.cassandra.auth.DseAuthenticator",
              "num_tokens":32,
              "endpoint_snitch":"GossipingPropertyFileSnitch"
           },
           "dse-yaml": {
              "authorization_options": { "enabled": True },
              "authentication_options": { "enabled": True }
           }
        }}
    # Since this isn't being called on the nodes where 'datapatah' exists
    # checking is pointless
    if (datapath != ""):
        defaultconfig["json"]["cassandra-yaml"]["data_file_directories"] = [os.path.join(datapath,"data")]
        defaultconfig["json"]["cassandra-yaml"]["saved_caches_directory"] = os.path.join(datapath,"saved_caches")
        defaultconfig["json"]["cassandra-yaml"]["commitlog_directory"] = os.path.join(datapath,"commitlog")

    if( args.config != None ):
        print "--config passed, overriding..."
        defaultconfig["json"] = json.loads(args.config)

    defaultconfig = json.dumps(defaultconfig)
    lcm.waitForOpsC(pause=pause,trys=trys)  # Block waiting for OpsC to spin up

    # return config instead of bool?
    c = lcm.checkForCluster(clustername)
    if (c == False): # cluster doesn't esist -> must be 1st node -> do setup
        print("Cluster {n} doesn't exist, creating...".format(n=clustername))
        cred = lcm.addCred(dsecred)
        repo = lcm.addRepo(dserepo)
        conf = lcm.addConfig(defaultconfig)
        cid = lcm.addCluster(clustername, cred['id'], repo['id'], conf['id'])
    else:
        print("Cluster {n} exists".format(n=clustername))



# ----------------------------
if __name__ == "__main__":
    main()
