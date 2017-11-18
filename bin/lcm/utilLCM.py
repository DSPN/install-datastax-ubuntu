import json
import time
import requests

# Yay globals!
opsc_url = "127.0.0.1:8888"

def pretty(data):
    print '\n', json.dumps(data, sort_keys=True, indent=4), '\n'

def addCluster(cname, credid, repoid, configid):
    try:
        conf = json.dumps({
            'name': cname,
            'machine-credential-id': credid,
            'repository-id': repoid,
            'config-profile-id': configid})
        clusterconf = requests.post("http://{url}/api/v1/lcm/clusters/".format(url=opsc_url), data=conf).json()
        print "Added cluster, json:"
        pretty(clusterconf)
        return clusterconf['id']
    except requests.exceptions.Timeout as e:
        print "Request for cluster config timed out."
        return None
    except requests.exceptions.ConnectionError as e:
        print "Request for cluster config refused."
        return None
    except Exception as e:
        # Do something?
        raise
    return clusterconf

def addCred(cred):
    try:
        creds = requests.get("http://{url}/api/v1/lcm/machine_credentials/".format(url=opsc_url)).json()
        if creds['count'] == 0:
            creds = requests.post("http://{url}/api/v1/lcm/machine_credentials/".format(url=opsc_url), data=cred).json()
            print "Added default dse creds, json:"
            pretty(creds)
            return creds
    except requests.exceptions.Timeout as e:
        print "Request to add ssh creds timed out."
        return None
    except requests.exceptions.ConnectionError as e:
        print "Request to add ssh creds refused."
        return None
    except Exception as e:
        # Do something?
        raise

def addConfig(conf):
    try:
        configs = requests.get("http://{url}/api/v1/lcm/config_profiles/".format(url=opsc_url)).json()
        if configs['count'] == 0:
            config = requests.post("http://{url}/api/v1/lcm/config_profiles/".format(url=opsc_url), data=conf).json()
            print "Added default condig profile, json:"
            pretty(config)
            return config
    except requests.exceptions.Timeout as e:
        print "Request to add config profile timed out."
        return None
    except requests.exceptions.ConnectionError as e:
        print "Request to add config profile refused."
        return None
    except Exception as e:
        # Do something?
        raise

def addRepo(repo):
    try:
        repos = requests.get("http://{url}/api/v1/lcm/repositories/".format(url=opsc_url)).json()
        if repos['count'] == 0:
            repconf = requests.post("http://{url}/api/v1/lcm/repositories/".format(url=opsc_url), data=repo).json()
            print "Added default repo, json:"
            pretty(repconf)
            return repconf
    except requests.exceptions.Timeout as e:
        print "Request to add repo timed out."
        return None
    except requests.exceptions.ConnectionError as e:
        print "Request to add repo refused."
        return None
    except Exception as e:
        # Do something?
        raise

def waitForOpsC(pause, trys):
    # Constants that should go elsewhere?
    timeout = 1 # connection timeout in sec
    # maxtrys * pause = 600 sec or 10 min, should be enough time for
    # OpsC instance to come up.
    count = 0
    while True:
        count += 1
        if count > trys:
            print "Error: OpsC connection failed after {n} trys".format(n=trys)
            print "Exiting..."
            exit(1)
        try:
            print "Trying:  http://{url}/meta".format(url=opsc_url)
            meta = requests.get("http://{url}/meta".format(url=opsc_url), timeout=timeout)
        except requests.exceptions.Timeout as e:
            print "Request {c} to OpsC timeout, wait {p} sec...".format(c=count, p=pause)
            time.sleep(pause)
            continue
        except requests.exceptions.ConnectionError as e:
            print "Request {c} to OpsC refused, wait {p} sec...".format(c=count, p=pause)
            time.sleep(pause)
            continue
        except Exception as e:
            # Do something?
            raise
        if meta.status_code == 200:
            data = meta.json()
            print "Found OpsCenter version: {version}".format(version=data['version'])
            return

def waitForCluster(cname, pause, trys):
    count = 0
    while True:
        count += 1
        if count > trys:
            return False
        found = checkForCluster(cname)
        if found:
            print "Cluster found."
            return True
        print "Cluster not found on try {c}, wait {p} sec...".format(c=count, p=pause)
        time.sleep(pause)

def waitForNodes(numnodes, pause, trys):
    count = 0
    while True:
        count += 1
        if count > trys:
            return False
        nodes = requests.get("http://{url}/api/v1/lcm/nodes/".format(url=opsc_url)).json()
        ncount = nodes["count"]
        if ncount >= numnodes:
            print "{n} nodes found.".format(n=numnodes)
            return True
        print "Only found {f} < {n} on try {c}, wait {p} sec...".format(f=ncount, n=numnodes, c=count, p=pause)
        time.sleep(pause)

def checkForCluster(cname):
    try:
        clusters = requests.get("http://{url}/api/v1/lcm/clusters/".format(url=opsc_url)).json()
        for r in clusters['results']:
            if r['name'] == cname:
                return True
        return False
    except requests.exceptions.Timeout as e:
        print "Request for cluster config timed out."
        return False
    except requests.exceptions.ConnectionError as e:
        print "Request for cluster config refused."
        return False
    except Exception as e:
        # Do something?
        raise

def checkForDC(dcname):
    try:
        dcs = requests.get("http://{url}/api/v1/lcm/datacenters/".format(url=opsc_url)).json()
        exists = False
        for dc in dcs['results']:
            if dc['name'] == dcname:
                exists = True
        return exists
    except requests.exceptions.Timeout as e:
        print "Request to add repo timed out."
        return None
    except requests.exceptions.ConnectionError as e:
        print "Request to add repo refused."
        return None
    except Exception as e:
        # Do something?
        raise

def addDC(dcname, cid):
    try:
        dc = json.dumps({
            'name': dcname,
            'cluster-id': cid,
            "graph-enabled": True,
            "solr-enabled": True,
            "spark-enabled": True})
        dcconf = requests.post("http://{url}/api/v1/lcm/datacenters/".format(url=opsc_url), data=dc).json()
        # edge case where api returns "server error" string not json
        if isinstance(dcconf, (str, unicode)):
            print "Unexpected return value: ", dcconf
            print "Retry after 5s sleep..."
            time.sleep(5)
            dcconf = requests.post("http://{url}/api/v1/lcm/datacenters/".format(url=opsc_url), data=dc).json()
        if 'code' in dcconf and (dcconf['code'] == 409):
            print "Error {c} - {t} : {m}".format(c=dcconf['code'], m=dcconf['msg'], t=dcconf['type'])
            print "Finding id for dcname='{n}'".format(n=dcname)
            alldcs = requests.get("http://{url}/api/v1/lcm/datacenters/".format(url=opsc_url)).json()
            for r in alldcs['results']:
                if r['name'] == dcname:
                    print "Found id='{n}'".format(n=r['id'])
                    return r['id']
        print "Added datacenter {n}, json:".format(n=dcname)
        pretty(dcconf)
        return dcconf['id']
    except requests.exceptions.Timeout as e:
        print "Request to add repo timed out."
        return None
    except requests.exceptions.ConnectionError as e:
        print "Request to add repo refused."
        return None
    except Exception as e:
        # Do something?
        raise

# Install will use larger scope, if both passed.
def triggerInstall(cid, dcid, pw):
    scope = "datacenter"
    r_id = dcid
    if cid != None:
        scope = "cluster"
        r_id = cid
    job = {"job-type":"install",
           "job-scope":scope,
           "resource-id":r_id,
           "auto-bootstrap":False,
           "continue-on-error":True}
    if pw != "cassandra":
        job["change-default-cassandra-password"] = pw
    data = json.dumps(job)
    response = requests.post("http://{url}/api/v1/lcm/actions/install".format(url=opsc_url), data=data).json()
    pretty(response)
