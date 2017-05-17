#!/usr/bin/python
"""
Backs up and restores a settings file to Dropbox.
This is an example app for API v2.
"""

import os
import sys
import dropbox
import argparse
from dropbox.files import WriteMode
from dropbox.exceptions import ApiError, AuthError

# Add OAuth2 access token here.
# You can generate one for yourself in the App Console.
# See <https://blogs.dropbox.com/developers/2014/05/generate-an-access-token-for-your-own-account/>
TOKEN = ''

# Uploads contents of LOCALFILE to Dropbox
def backup(file):
    with open(file, 'rb') as f:
        # We use WriteMode=overwrite to make sure that the settings in the file
        # are changed on upload
        if not os.path.isfile(file):
            print file + " is not a file"
            return
 
        remote_name = "/" +os.path.basename(file)
        print("Uploading " + file + " to Dropbox as " + remote_name + "...")
        try:
            dbx.files_upload(f.read(), remote_name, mode=WriteMode('overwrite'))
        except ApiError as err:
            # This checks for the specific error where a user doesn't have
            # enough Dropbox space quota to upload this file
            if (err.error.is_path() and
                    err.error.get_path().error.is_insufficient_space()):
                sys.exit("ERROR: Cannot back up; insufficient space.")
            elif err.user_message_text:
                print(err.user_message_text)
                sys.exit()
            else:
                print(err)
                sys.exit()

if __name__ == '__main__':
    # Check for an access token
    if (len(TOKEN) == 0):
        sys.exit("ERROR: Looks like you didn't add your access token. "
            "Open up backup-and-restore-example.py in a text editor and "
            "paste in your token in line 14.")

    parser = argparse.ArgumentParser(description='Upload file to Dropbox')
    parser.add_argument('file', help='Image file to be uploaded')

    args = parser.parse_args()

    # Create an instance of a Dropbox class, which can make requests to the API.
    print("Creating a Dropbox object...")
    dbx = dropbox.Dropbox(TOKEN)

    # Check that the access token is valid
    try:
        dbx.users_get_current_account()
    except AuthError as err:
        sys.exit("ERROR: Invalid access token; try re-generating an "
            "access token from the app console on the web.")


    # Create a backup of the current settings file
    backup(args.file)

    # print("Done!")
