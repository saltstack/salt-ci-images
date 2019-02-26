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
