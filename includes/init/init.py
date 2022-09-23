#!/usr/bin/env python3

import argparse
import subprocess
import os
# from dotenv import load_dotenv
# load_dotenv()

INIT_WITH_ARGS_SCRIPT = "/opt/docker/install-scripts/init_with_args.sh"
print('running with env variables:', os.environ)

subprocess.call(
    [
        INIT_WITH_ARGS_SCRIPT,
        os.environ['WIKI_INSTALL_DIR'],
        os.environ['WIKI_BACKUP_LIMIT'],
        os.environ['DISABLE_PINGBACK'],
        os.environ['BS_URL'],
        os.environ['BS_LANG'],
        os.environ['BS_USER'],
        os.environ['BS_PASSWORD'],
    ]
)
