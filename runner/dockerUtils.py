#!/usr/bin/env python3

import subprocess
import shutil


def docker_clean(vol_dir):
    try:
        shutil.rmtree(vol_dir)
        return True
    except FileNotFoundError:
        return False
    finally:
        subprocess.call('docker rm -vf $(docker ps -aq)', shell=True)
        return False


def docker_clean_wikis(vol_dir):
    try:
        shutil.rmtree(vol_dir)
        return True
    except FileNotFoundError:
        return False
    finally:
        subprocess.call(
            'docker rmi $(docker images --format "{{.Repository}}:{{.Tag}}" | grep "wiki_")',
            shell=True)
        subprocess.call('docker system prune -f', shell=True)
        return False


def docker_clean_dangling():
    subprocess.call('docker image prune -f', shell=True)


def docker_up_build(emulate_as_amd64=False):
    subprocess.call('./prepare.sh', shell=True)
    if emulate_as_amd64:
        subprocess.call(
            'DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose up --build -d',
            shell=True)
    else:
        subprocess.call('docker-compose up --build -d', shell=True)


def docker_down(remove_orphans=False):
    if remove_orphans:
        subprocess.call('docker-compose down --remove-orphans', shell=True)
    else:
        subprocess.call('docker-compose down', shell=True)


def build_docker(blubber_file, variant, docker_img_tag):
    # subprocess.call(
    #     f'./blubber.sh {blubber_file} {variant} -p ./blubber.policy.yaml | docker build --tag {docker_img_tag} --file - .',
    #     shell=True)
    policy_file_uri='/home/jonty/go/src/gerrit.wikimedia.org/r/blubber/policy.example.yaml'
    subprocess.call(
        f'./blubber.sh {blubber_file} --policy={policy_file_uri} {variant}',
        shell=True)

