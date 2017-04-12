import cachetclient.cachet as cachet
import jenkins
import json
import time
import re


j_server = "http://jenkins/"
j_user = "user"
j_pass = "pass"
ENDPOINT = 'http://test.com/api/v1'
API_TOKEN = 'token_api'
tasks = {}
steps = []


def createGroup():
    groups = cachet.Groups(endpoint=ENDPOINT, api_token=API_TOKEN)
    group = json.loads(groups.post(name='Jenkins'))
    return group['data']['id']


def createComponents(steps, _id, tasks):
    for step in steps:
        components = cachet.Components(endpoint=ENDPOINT, api_token=API_TOKEN)
        component = json.loads(components.post(name=step, status=4, group_id=_id))
        tasks[step] = component['data']['id']
    return tasks


def match(regex, line):
    result = re.findall(regex, line)
    if result:
        return result


def updateComponent(key, tmp, tasks):
    components = cachet.Components(endpoint=ENDPOINT, api_token=API_TOKEN)
    try:
        components.put(id=tasks[key], status=tmp)
    except KeyError as ke:
        print ke
        pass


def listJobs(steps):
    server = jenkins.Jenkins(j_server, username=j_user, password=j_pass)
    jobs = server.get_jobs(folder_depth=3)
    for job in jobs:
        tmp = match("Reference_Application_", job['name'])
        if tmp:
            steps.append(job['name'])
    return steps


def defineStatus(color):
    if color == 'blue':
        return 1
    elif color == 'yellow':
        return 3
    else:
        return 4


def loop(steps, tasks):
    server = jenkins.Jenkins(j_server, username=j_user, password=j_pass)                                                     
    jobs = server.get_jobs(folder_depth=3) 
    for job in jobs:
        if job['name'] in steps:
            tmp = defineStatus(job['color'])
            #we need to compare if the actual color is the same before
            #and if correspond to the las build
            updateComponent(job['name'], tmp, tasks)


_id = createGroup()
steps = listJobs(steps)
tasks = createComponents(steps, _id, tasks)
while True:
    print "--"
    loop(steps, tasks)
    time.sleep(10)
