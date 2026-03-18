# This script uses libsemanage directly to access the users list
# This is *much* faster than semanage user -l

# will work with python 2.6+
from __future__ import print_function
from sys import exit
try:
  import semanage
except ImportError:
  # The semanage python library does not exist, so let's assume SELinux is
  # disabled. In this case, the correct response is to return no logins when
  # puppet does a prefetch, to avoid an error. We depend on the semanage binary
  # anyway, which uses the library
  exit(0)


handle = semanage.semanage_handle_create()

if semanage.semanage_is_managed(handle) < 0:
    exit(1)
if semanage.semanage_connect(handle) < 0:
    exit(1)

def print_user(user):
    user_name = semanage.semanage_user_get_name(user)
    user_mlsrange = semanage.semanage_user_get_mlsrange(user)
    print("{} {}".format(user_name, user_mlsrange))


# Get a mapping of users to MLS ranges
(status, users) = semanage.semanage_user_list(handle)
if status < 0:
    raise ValueError("Could not list user config")

for user in users:
    print_user(user)

semanage.semanage_disconnect(handle)
semanage.semanage_handle_destroy(handle)
