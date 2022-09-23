#!/usr/bin/env python3

import argparse
import subprocess
import os

# parser = argparse.ArgumentParser()
# parser.add_argument('-b', '--wiki_backup_limit', action='store')
# parser.add_argument('-g', '--disable_pingback', action='store')
# parser.add_argument('-u', '--bs_url', action='store')
# parser.add_argument('-l', '--bs_lang', action='store')
# parser.add_argument('-s', '--bs_user', action='store')
# parser.add_argument('-p', '--bs_password', action='store')
# args = parser.parse_args()

INIT_WITH_ARGS_SCRIPT = "/opt/docker/install-scripts/init_with_args.sh"

# subprocess.call([
#     INIT_WITH_ARGS_SCRIPT,
#     args.wiki_backup_limit,
#     args.disable_pingback,
#     args.bs_url,
#     args.bs_lang,
#     args.bs_user,
#     args.bs_password
#     ])
print('running with env variables:', os.environ)

# subprocess.call(
#     [
#         INIT_WITH_ARGS_SCRIPT,
#         os.environ['WIKI_BACKUP_LIMIT'],
#         os.environ['DISABLE_PINGBACK'],
#         os.environ['BS_URL'],
#         os.environ['BS_LANG'],
#         os.environ['BS_USER'],
#         os.environ['BS_PASSWORD'],
#     ]
# )
