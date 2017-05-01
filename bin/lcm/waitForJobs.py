#!/usr/bin/python
import requests
import json
import time
import os
import utilLCM as lcm

def runningJob(jobs):
    running = False
    for r in jobs['results']:
      if r['status'] == 'RUNNING' or r['status'] == 'PENDING':
          running = True
    return running

def main():
    lcm.opsc_url = 'localhost:8888'
    lcm.waitForOpsC(pause=6, trys=200)  # Block waiting for OpsC to spin up
    pause = 60
    trys = 100
    count = 0

    while (True):
        count += 1
        if(count>trys):
            print "Timeout, exiting"
            exit()
        jobs = requests.get("http://{url}/api/v1/lcm/jobs/".format(url=lcm.opsc_url)).json()
        if(jobs['count']==0):
            print "No jobs found on try {c}, sleeping {p} sec...".format(c=count,p=pause)
            time.sleep(pause)
            continue
        if(runningJob(jobs)):
            print "Job running/pending on try {c}, sleeping {p} sec...".format(c=count,p=pause)
            time.sleep(pause)
        else:
            print "No jobs running/pending on try {c}, exiting".format(c=count)
            break



# ----------------------------
if __name__ == "__main__":
    main()
