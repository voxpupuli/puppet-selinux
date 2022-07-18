# This script uses libsemanage directly to access the ports list
# it is *much* faster than semanage port -l

# will work with python 2.6+
from __future__ import print_function
from sys import exit
try:
  import semanage
except ImportError:
  # The semanage python library does not exist, so let's assume SELinux is disabled...
  # In this case, the correct response is to return no ports when puppet does a
  # prefetch, to avoid an error. We depend on the semanage binary anyway, which
  # is uses the library
  exit(0)


handle = semanage.semanage_handle_create()

if semanage.semanage_is_managed(handle) < 0:
    exit(1)
if semanage.semanage_connect(handle) < 0:
    exit(1)

def print_seuser(seuser):
    seuser_login = semanage.semanage_seuser_get_name(seuser)
    selinux_user = semanage.semanage_seuser_get_sename(seuser)
    print("{} {}".format(seuser_login, selinux_user))


(status, seusers) = semanage.semanage_seuser_list(handle)

for seuser in seusers:
    print_seuser(seuser)


semanage.semanage_disconnect(handle)
semanage.semanage_handle_destroy(handle)
