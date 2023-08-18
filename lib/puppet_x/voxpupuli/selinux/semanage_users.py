# This script uses libsemanage directly to access the logins list
# This is *much* faster than semanage login -l

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

def print_seuser(kind, seuser):
    seuser_login = semanage.semanage_seuser_get_name(seuser)
    selinux_user = semanage.semanage_seuser_get_sename(seuser)
    print("{} {} {}".format(kind, seuser_login, selinux_user))


# Always list local config afterwards so that the provider works correctly
(status, seusers) = semanage.semanage_seuser_list(handle)
if status < 0:
    raise ValueError("Could not list user config")

for seuser in seusers:
    print_seuser('policy', seuser)

(status, seusers) = semanage.semanage_seuser_list_local(handle)
if status < 0:
    raise ValueError("Could not list local user config")

for seuser in seusers:
    print_seuser('local', seuser)


semanage.semanage_disconnect(handle)
semanage.semanage_handle_destroy(handle)
