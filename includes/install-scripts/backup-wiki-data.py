import sys
import os
import subprocess

WIKI_BACKUP_LIMIT=5
if len(sys.argv)>1:
    WIKI_BACKUP_LIMIT=int(sys.argv[1])

WIKI_BACKUP_DIR = "/data/www/backups"

all_backups = next(os.walk(WIKI_BACKUP_DIR))[1]

if len(all_backups) > WIKI_BACKUP_LIMIT:
    all_backups = sorted(all_backups)
    subprocess.call(['rm', '-rf', f'{WIKI_BACKUP_DIR}/{all_backups[0]}'])


