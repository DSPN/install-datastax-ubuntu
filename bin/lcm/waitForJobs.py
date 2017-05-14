#!/usr/bin/python
import requests
import json
import time
import os
import utilLCM as lcm
import argparse

def setupArgs():
    parser = argparse.ArgumentParser(description='Block template shell until LCM jobs are not in RUNNING/PENDING state.')
    parser.add_argument('--num', type=int, default=1, help='Expected number of jobs')
    parser.add_argument('--opsc-ip', type=str, default='localhost',
                          help='IP/hostname of OpsCenter instance, default localhost. REST calls made to this host:8888')
    return parser

def runningJob(jobs):
    running = False
    for r in jobs['results']:
      if r['status'] == 'RUNNING' or r['status'] == 'PENDING':
          running = True
    return running

def main():
    parser = setupArgs()
    args = parser.parse_args()
    lcm.opsc_url = args.opsc_ip + ':8888'
    lcm.waitForOpsC(pause=6, trys=200)  # Block waiting for OpsC to spin up
    pause = 60
    trys = 100
    count = 0

    while (True):
        count += 1
        if(count>trys):
            print "Maximum attempts, exiting"
            exit(1)
        try:
            jobs = requests.get("http://{url}/api/v1/lcm/jobs/".format(url=lcm.opsc_url)).json()
        except requests.exceptions.Timeout as e:
            print("Request {c} to OpsC timeout after initial connection, exiting.".format(c=count))
            exit(1)
        except requests.exceptions.ConnectionError as e:
            print("Request {c} to OpsC refused after initial connection, exiting.".format(c=count))
            exit(1)
        lcm.pretty(jobs)
        if(jobs['count']==0):
            print "No jobs found on try {c}, sleeping {p} sec...".format(c=count,p=pause)
            time.sleep(pause)
            continue
        if(runningJob(jobs)):
            print "Jobs running/pending on try {c}, sleeping {p} sec...".format(c=count,p=pause)
            time.sleep(pause)
            continue
        if((not runningJob(jobs)) and (jobs['count'] < args.num)):
            print "Jobs found on try {c} but num {j} < {n}, sleeping {p} sec...".format(c=count,j=jobs['count'],n=args.num,p=pause)
            time.sleep(pause)
            continue
        if((not runningJob(jobs)) and (jobs['count'] >= args.num)):
            print "No jobs running/pending and num >= {n} on try {c}, exiting".format(n=args.num,c=count)
            break



# ----------------------------
if __name__ == "__main__":
    main()
