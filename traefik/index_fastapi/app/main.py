from typing import Union
import re

from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from urllib.request import urlopen
import json
import docker

app = FastAPI()
app.mount("/static", StaticFiles(directory="app/static"), name="static")

TEMPLATES = Jinja2Templates(directory="app/templates")


def get_nodered_containers():
    client = docker.APIClient(base_url='unix://var/run/docker.sock')
    nodered_containers = client.containers(
        all=True,
        filters={"label":["com.docker.compose.project=node-reds"]}
    )
    return nodered_containers

def return_url_to_metadata(container_info):
    client = docker.APIClient(base_url='unix://var/run/docker.sock')
    try:
        config = client.inspect_container(container_info['Id'])
        env_vars = config['Config']['Env']
    except KeyError:
        return None
    try:
        giturl = container_info['Labels']['node-red.project.url']
        name = container_info['Labels']['com.docker.compose.service']
    except KeyError:
        return None
    env_vars = {var.split('=')[0]:var.split('=')[1] for var in env_vars}
    if 'ACCESSURL' not in env_vars:
        return None
    return (env_vars['ACCESSURL'], {
        'keycloak_role': env_vars.get('KEYCLOAK_WRITER_ROLE',''),
        'status': container_info.get("Status",""),
        'repository': giturl,
        'name': name
    })    

def assign_nodered_app_url_to_metadata():
    containers = get_nodered_containers()
    urls = []
    for container in containers:
        url_to_metadata = return_url_to_metadata(container)
        if url_to_metadata is None:
            continue
        urls.append(url_to_metadata)
    return dict(urls)


def decipher_rules_to_matching_url(rule):

    regexp = r"Host\(\`(?P<domain>[\w\.]*)\`\)(\s?&&\s?Path\w*\(\`(?P<path>/[\w]*))?"
    g = re.search(regexp, rule)
    groups = g.groupdict()

    matching_url = groups['domain'] + groups['path'] if groups['path'] else groups['domain']
    return matching_url



@app.get("/", 
 response_class = HTMLResponse
)
async def read_root(request : Request):
    global TEMPLATES
    nodered_urls = assign_nodered_app_url_to_metadata()
    return TEMPLATES.TemplateResponse("index.html", {'request': request, 'urls': nodered_urls})

