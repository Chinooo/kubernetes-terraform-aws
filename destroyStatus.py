import cachetclient.cachet as cachet
import json


ENDPOINT = 'http://test.com/api/v1'
API_TOKEN = 'token_api'


## TODO ##
# eliminar solo los de Terradorm (el grupo y componentes)


# /components/groups
groups = cachet.Groups(endpoint=ENDPOINT, api_token=API_TOKEN)
grps = json.loads(groups.get())
for group in grps['data']:
    groups.delete(group['id'])

# /components
components = cachet.Components(endpoint=ENDPOINT, api_token=API_TOKEN)
comps = json.loads(components.get())
for component in comps['data']:
    components.delete(component['id'])
