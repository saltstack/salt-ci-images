import os
import logging
try:
    from salt.utils.platform import is_windows
except (ImportError, AttributeError):
    from salt.utils import is_windows
from salt.exceptions import CommandExecutionError
import salt.ext.six as six

log = logging.getLogger(__name__)
__all__ = [
    'download_git_repos',
]


def __virtual__():
    '''
    Set the winrepo module if the OS is Windows
    '''
    if is_windows():
        return True
    return (False, 'This module only works on Windows.')


def download_git_repos():
    '''
    Perform the inital checkout of the winrepo repositories.
    '''
    try:
        import dulwich.client
        import dulwich.repo
        import dulwich.index
    except ImportError:
        raise CommandExecutionError(
            'Command require dulwich python module'
        )
    winrepo_dir = __salt__['config.get']('winrepo_dir')
    winrepo_remotes = __salt__['config.get']('winrepo_remotes')
    winrepo_remotes_ng = __salt__['config.get']('winrepo_remotes_ng')
    winrepo_dir_ng = __salt__['config.get']('winrepo_dir_ng')

    winrepo_cfg = [(winrepo_remotes, winrepo_dir),
                   (winrepo_remotes_ng, winrepo_dir_ng)]
    ret = {}
    for remotes, base_dir in winrepo_cfg:
        for remote_info in remotes:
            try:
                if '/' in remote_info:
                    targetname = remote_info.split('/')[-1]
                else:
                    targetname = remote_info
                rev = 'HEAD'
                try:
                    rev, remote_url = remote_info.strip().split()
                except ValueError:
                    remote_url = remote_info
                gittarget = os.path.join(base_dir, targetname).replace('.', '_')
                client, path = dulwich.client.get_transport_and_path(remote_url)
                if os.path.exists(gittarget):
                    local_repo = dulwich.repo.Repo(gittarget)
                else:
                    os.makedirs(gittarget)
                    local_repo = dulwich.repo.Repo.init(gittarget)
                remote_refs = client.fetch(remote_url, local_repo)
                if six.b(rev) not in remote_refs.refs:
                    raise CommandExecutionError(
                        'Failed to find remote ref: {0}'.format(rev)
                    )
                local_repo[six.b(rev)] = remote_refs[six.b(rev)]
                dulwich.index.build_index_from_tree(
                    local_repo.path, local_repo.index_path(),
                    local_repo.object_store, local_repo[six.b('head')].tree
                )
                ret.update({remote_info: True})
            except Exception as exc:
                log.exception('Failed to process remote_info: %s', remote_info, exc_info=True)
                raise
    if __salt__['winrepo.genrepo']():
        return ret
    return False


#########################################################
# Everything below here is only needed in 2017.7 branch #
#########################################################
import salt.ext.win_inet_pton
import socket
import ctypes
import os
import ipaddress
import urllib3.util.ssl_


class sockaddr(ctypes.Structure):
    _fields_ = [("sa_family", ctypes.c_short),
                ("__pad1", ctypes.c_ushort),
                ("ipv4_addr", ctypes.c_byte * 4),
                ("ipv6_addr", ctypes.c_byte * 16),
                ("__pad2", ctypes.c_ulong)]

if hasattr(ctypes, 'windll'):
    WSAStringToAddressA = ctypes.windll.ws2_32.WSAStringToAddressA
    WSAAddressToStringA = ctypes.windll.ws2_32.WSAAddressToStringA
else:
    def not_windows():
        raise SystemError(
            "Invalid platform. ctypes.windll must be available."
        )
    WSAStringToAddressA = not_windows
    WSAAddressToStringA = not_windows

def inet_pton(address_family, ip_string):
    # Verify IP Address
    # This will catch IP Addresses such as 10.1.2
    if address_family == socket.AF_INET:
        try:
            if isinstance(ip_string, six.binary_type):
                ipaddress.ip_address(six.text_type(ip_string))
            else:
                ipaddress.ip_address(ip_string)
        except ValueError:
            raise socket.error('illegal IP address string passed to inet_pton')
        return socket.inet_aton(ip_string)

    # Verify IP Address
    # The `WSAStringToAddressA` function handles notations used by Berkeley
    # software which includes 3 part IP Addresses such as `10.1.2`. That's why
    # the above check is needed to enforce more strict IP Address validation as
    # used by the `inet_pton` function in Unix.
    # See the following:
    # https://stackoverflow.com/a/29286098
    # Docs for the `inet_addr` function on MSDN
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms738563.aspx
    addr = sockaddr()
    addr.sa_family = address_family
    addr_size = ctypes.c_int(ctypes.sizeof(addr))

    if WSAStringToAddressA(
            ip_string.encode('ascii'),
            address_family,
            None,
            ctypes.byref(addr),
            ctypes.byref(addr_size)
    ) != 0:
        raise socket.error(ctypes.FormatError())

    if address_family == socket.AF_INET:
        return ctypes.string_at(addr.ipv4_addr, 4)
    if address_family == socket.AF_INET6:
        return ctypes.string_at(addr.ipv6_addr, 16)

    raise socket.error('unknown address family')

# Adding our two functions to the socket library
if os.name == 'nt':
    socket.inet_pton = inet_pton
    salt.ext.win_inet_pton.inet_pton = inet_pton
    urllib3.util.ssl_.inet_pton = inet_pton
