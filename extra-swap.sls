{% set freebsd = True if grains['os'] == 'FreeBSD' else False %}

{% if not freebsd %}
{% set swapfile = '/.salt-runtests.swapfile' %}

create-swap-file:
  {# because everytime a new subprocess.Popen() is instantiated, a copy of the current python
     interpreter memory is cloned. Yes, it's copy-on-write, however, due to python's refcount
     for garbage collection, copy-on-write's happen to often and we endup with getting out of
     memory errors in the tests suite.
     Let's see if this solves that issue.
  #}
  cmd.run:
    - name: dd if=/dev/zero of={{ swapfile }} bs=1024 count=1M

make-swap:
  cmd.run:
    - name: mkswap {{ swapfile }}
    - require:
      - cmd: create-swap-file


add-extra-swap:
  mount.swap:
    - name: {{ swapfile }}
    - persist: False
    - require:
      - cmd: make-swap
{% endif %}
