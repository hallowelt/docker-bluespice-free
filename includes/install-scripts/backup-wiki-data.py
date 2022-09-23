import argparse
import os
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('-b', '--wiki_backup_limit', action='store')
args = parser.parse_args()

WIKI_BACKUP_LIMIT = int(args.wiki_backup_limit)
WIKI_BACKUP_DIR = "/data/www/backups"

all_backups = next(os.walk(WIKI_BACKUP_DIR))[1]

if len(all_backups) > WIKI_BACKUP_LIMIT:
    all_backups = sorted(all_backups)
    subprocess.call(['rm', '-rf', f'{WIKI_BACKUP_DIR}/{all_backups[0]}'])


