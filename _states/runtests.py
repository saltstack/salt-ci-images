# -*- coding: utf-8 -*-
'''
    :codeauthor: :email:`Pedro Algarvio (pedro@algarvio.me)`
    :copyright: © 2013 by the UfSoft.org Team, see AUTHORS for more details.
    :license: BSD, see LICENSE for more details.


    runtests.py
    ~~~~~~~~~~~


'''

import yaml

def run(name, env=None):
    ret = {
        'name': name,
        'result': False,
        'changes': {},
        'comment': ''
    }

    if env:
        if isinstance(env, basestring):
            try:
                env = yaml.safe_load(env)
            except Exception:
                _env = {}
                for var in env.split():
                    try:
                        key, val = var.split('=')
                        _env[key] = val
                    except ValueError:
                        ret['comment'] = \
                            'Invalid environmental var: "{0}"'.format(var)
                        return ret
                env = _env
        elif isinstance(env, dict):
            pass

        elif isinstance(env, list):
            _env = {}
            for comp in env:
                try:
                    if isinstance(comp, basestring):
                        _env.update(yaml.safe_load(comp))
                    if isinstance(comp, dict):
                        _env.update(comp)
                    else:
                        ret['comment'] = \
                            'Invalid environmental var: "{0}"'.format(env)
                        return ret
                except Exception:
                    _env = {}
                    for var in comp.split():
                        try:
                            key, val = var.split('=')
                            _env[key] = val
                        except ValueError:
                            ret['comment'] = \
                                'Invalid environmental var: "{0}"'.format(var)
                            return ret
            env = _env

    result = __salt__['runtests.run'](name, env=env)
    ret.update({
        'result': result > 0,
        'comment': 'Test Suite Exit Code: {0}'.format(result)
    })
    return ret
