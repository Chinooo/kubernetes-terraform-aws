import cachetclient.cachet as cachet
import subprocess
import json
import re


ENDPOINT = 'http://test.com/api/v1'
API_TOKEN = 'token_api'
steps = []
string = ""
tasks = {}


def myrun(cmd, bol, tasks):
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout = []
    while True:
        line = p.stdout.readline()
        stdout.append(line)
        if bol:
            getSteps(line)
        else:
            getStatus(line, tasks)
        if line == '' and p.poll() != None:
            break
    return ''.join(stdout)


def getSteps(line):
    tmp = match("\[label = \"(?!provider).+\",", line)
    if tmp:
        tmp = match("\".+\"", tmp[0])
        if tmp:
            tmp = tmp[0][1:-1]
            steps.append(tmp)
            print tmp


def match(regex, line):
    result = re.findall(regex, line)
    if result:
        return result


def toString(string, steps):
    for step in steps:
        string += "(" + step + ":)|"
    string = string[:-1]
    string = string.replace(".", "\.")
    return string


def getStatus(line, tasks):
    tmp = match(string, line)
    if tmp:
        if 'Creating' in line:
            tmp = line.split(':')[0].strip()
            updateComponent(tmp, True, tasks) # yellow
        if 'complete' in line:
            #Destroy has 'complete' too
            tmp = line.split(':')[0].strip()
            updateComponent(tmp, False, tasks) # green
        print line,


def createGroup():
    groups = cachet.Groups(endpoint=ENDPOINT, api_token=API_TOKEN)
    group = json.loads(groups.post(name='Terraform'))
    return group['data']['id']


def createComponents(steps, _id, tasks):
    for step in steps:
        components = cachet.Components(endpoint=ENDPOINT, api_token=API_TOKEN)
        component = json.loads(components.post(name=step, status=4, group_id=_id))
        tasks[step] = component['data']['id']
    return tasks


def updateComponent(key, bol, tasks):
    components = cachet.Components(endpoint=ENDPOINT, api_token=API_TOKEN)
    tmp = 3 if bol else 1
    try:
        #deleting colors from terminal output
        color = re.compile(r'\x1b[^m]*m')
        components.put(id=tasks[color.sub('', key)], status=tmp) 
    except KeyError as ke:
        print ke
        pass


_id = createGroup()
print " ... Listing tasks ... "
myrun("terraform graph", True, tasks) #getSteps
string = toString(string, steps)
print " ... Adding tasks to dashboard ... "
tasks = createComponents(steps, _id, tasks)
print " ... Listing status ... "
myrun("terraform apply", False, tasks) #getStatus
#print " ... Destroying ... "
#myrun("terraform destroy -force", False, tasks)
