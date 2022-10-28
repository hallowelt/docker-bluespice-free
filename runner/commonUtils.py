#!/usr/bin/env python3

from functools import wraps
import time
import os


def get_env(path: str) -> dict:
    with open(path, "r") as f:
        return dict(
            tuple(line.replace("\n", "").split("="))
            for line in f.readlines()
            if not line.startswith("#")
        )


def timeit(func):
    @wraps(func)
    def timeit_wrapper(*args, **kwargs):
        start_time = time.perf_counter()
        print(f"Started executing command...")
        result = func(*args, **kwargs)
        end_time = time.perf_counter()
        total_time = end_time - start_time
        print(
            f"Finished executing command, took {total_time:.4f} seconds")
        return result

    return timeit_wrapper


def check_install():
    virtual_env = os.environ.get('VIRTUAL_ENV')
    if virtual_env is not None and virtual_env.endswith('bs_venv'):
        return True
    return False
