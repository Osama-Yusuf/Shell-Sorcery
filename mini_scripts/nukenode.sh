#!/usr/bin/env python3

import os
import shutil
import stat

print("Starting to clean node_modules directories...")

def on_error(func, path, exc_info):
    """
    Error handler for shutil.rmtree.
    If the error is due to an access error (read only file)
    it attempts to add write permission and then retries.
    If the error is due to the directory not being empty, it logs the error and passes.
    """
    if not os.access(path, os.W_OK):
        # Is the error an access error?
        os.chmod(path, stat.S_IWUSR)
        func(path)
    else:
        print(f"Error removing {path}: {exc_info[1]}")

# Directory to start searching from
search_dir = os.path.expanduser('~/OneDrive')

# Walk through the directory
for root, dirs, files in os.walk(search_dir, topdown=True):
    if 'node_modules' in dirs:
        full_path = os.path.join(root, 'node_modules')
        print(f"node_modules found: {full_path}, Deleting...")
        try:
            shutil.rmtree(full_path, onerror=on_error)
        except Exception as e:
            print(f"Failed to remove {full_path} due to: {e}")
        # Skip descending into the node_modules directory
        dirs[:] = [d for d in dirs if d != 'node_modules']

print("Finished cleaning node_modules directories.")